import 'dart:developer';

import 'package:questra_app/core/providers/leveling_providers.dart';
import 'package:questra_app/features/events/models/event_model.dart';
import 'package:questra_app/features/events/models/event_quest_model.dart';
import 'package:questra_app/features/wallet/repository/wallet_repository.dart';
import 'package:questra_app/imports.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) => EventsRepository(ref: ref));

class EventsRepository {
  final Ref _ref;
  EventsRepository({required Ref ref}) : _ref = ref;
  SupabaseClient get _client => _ref.read(supabaseProvider);
  SupabaseQueryBuilder get _eventsTable => _client.from(TableNames.events);
  SupabaseQueryBuilder get _eventPlayersTable => _client.from(TableNames.event_players);
  SupabaseQueryBuilder get _eventQuestsTable => _client.from(TableNames.event_quests);
  SupabaseQueryBuilder get _eventQuestImagesTable => _client.from(TableNames.event_quest_images);

  SupabaseQueryBuilder get _eventFinishQuestsLogs =>
      _client.from(TableNames.event_quest_finish_logs);

  Future<List<EventModel>> getEvents(UserModel user) async {
    try {
      final now = DateTime.now().toUtc();
      final eventsData = await _eventsTable
          .select("*")
          .gt(KeyNames.end_at, now.toIso8601String())
          .lt(KeyNames.start_at, now.toIso8601String());
      final events = eventsData.map((e) => EventModel.fromMap(e)).toList();
      final religionEvents =
          events.where((e) => (e.religion_based == true) && (e.religion == user.religion)).toList();
      final normalEvents = events.where((e) => e.religion_based == false).toList();

      return [...religionEvents, ...normalEvents];
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> registerToEvent({required String userId, required int eventId}) async {
    try {
      await _eventPlayersTable.insert({KeyNames.event_id: eventId, KeyNames.user_id: userId});
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<EventQuestModel>> getEventQuests(int eventId) async {
    try {
      final questsData = await _eventQuestsTable.select("*").eq(KeyNames.event_id, eventId);
      return questsData.map((quest) => EventQuestModel.fromMap(quest)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> isRegisteredInEvent({required String userId, required int eventId}) async {
    try {
      final data =
          await _eventPlayersTable
              .select("*")
              .eq(KeyNames.user_id, userId)
              .eq(KeyNames.event_id, eventId)
              .maybeSingle();

      return data != null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> uploadEventPlayerQuestImages({
    required List<String> images,
    required String userId,
    required int eventId,
    required String questId,
  }) async {
    try {
      for (final image in images) {
        await _eventQuestImagesTable.insert({
          KeyNames.quest_id: questId,
          KeyNames.user_id: userId,
          KeyNames.event_id: eventId,
          KeyNames.image_url: image,
        });
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> finishQuest({required EventQuestModel quest, required UserModel user}) async {
    try {
      await _eventFinishQuestsLogs.insert({KeyNames.user_id: user.id, KeyNames.quest_id: quest.id});
      _ref.read(cachedUserLevelProvider.notifier).state = user.level;
      await _ref
          .read(walletRepositoryProvider)
          .addCoins(userId: user.id, amount: quest.coin_reward);

      final currentLevelData = {'level': user.level?.level ?? 1, 'xp': user.level?.xp ?? 0};
      final newLevel = addXp(quest.xp_reward, currentLevelData);
      LevelsModel levelModel = user.level!;
      levelModel = levelModel.copyWith(level: newLevel['level'], xp: newLevel['xp']);
      await _ref.read(levelingRepositoryProvider).updateUserLevelData(levelModel);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<DateTime?> getLastCompletetionDate({
    required String userId,
    required String questId,
  }) async {
    try {
      final data = await _eventFinishQuestsLogs
          .select("*")
          .eq(KeyNames.user_id, userId)
          .eq(KeyNames.quest_id, questId)
          .order(KeyNames.created_at, ascending: false)
          .limit(1);

      if (data.isEmpty) return null;

      return DateTime.parse(data.first[KeyNames.created_at]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<UserModel>> getAllRegisteredUser({
    required int eventId,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final data = await _eventPlayersTable
          .select("${KeyNames.user_id},${TableNames.players}(*)")
          .eq(KeyNames.event_id, eventId)
          .range(startIndex, startIndex + pageSize - 1)
          .order(KeyNames.id, ascending: true);

      return data.map((d) => UserModel.fromMap(d[TableNames.players])).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
