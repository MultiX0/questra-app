import 'dart:developer';

import 'package:questra_app/core/providers/leveling_providers.dart';
import 'package:questra_app/core/shared/constants/function_names.dart';
import 'package:questra_app/features/events/models/event_model.dart';
import 'package:questra_app/features/events/models/event_quest_model.dart';
import 'package:questra_app/features/events/models/view_quest_model.dart';
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
  SupabaseQueryBuilder get _eventQuestReportsTable => _client.from(TableNames.event_player_reports);

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

      if (data != null && data[KeyNames.is_banned] as bool) {
        throw "You have been banned from participating in this event.";
      }

      return data != null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<int>> uploadEventPlayerQuestImages({
    required List<String> images,
    required String userId,
    required int eventId,
    required String questId,
  }) async {
    try {
      List<int> _ids = [];
      for (final image in images) {
        final data = await _eventQuestImagesTable
            .insert({
              KeyNames.quest_id: questId,
              KeyNames.user_id: userId,
              KeyNames.event_id: eventId,
              KeyNames.image_url: image,
            })
            .select("*");

        if (data.isNotEmpty) {
          _ids.add(data.first[KeyNames.id]);
        }
      }

      return _ids;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> finishQuest({
    required EventQuestModel quest,
    required UserModel user,
    required List<int> imageIds,
    required int minPicsNeeds,
    required BuildContext context,
  }) async {
    try {
      if (imageIds.isEmpty) {
        throw AppLocalizations.of(context).event_quest_finish_alert(minPicsNeeds);
      }
      await _eventFinishQuestsLogs.insert({
        KeyNames.user_id: user.id,
        KeyNames.quest_id: quest.id,
        KeyNames.images: imageIds,
      });
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

  Future<void> insertQuestReport({
    required String reporterId,
    required String userId,
    required String questId,
    required String reason,
    required int eventId,
    required int finishLogId,
  }) async {
    try {
      await _eventQuestReportsTable.insert({
        KeyNames.user_id: userId,
        KeyNames.reporter_id: reporterId,
        KeyNames.quest_id: questId,
        KeyNames.reason: reason,
        KeyNames.event_id: eventId,
        KeyNames.finish_log_id: finishLogId,
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<String>> getQuestCompletionImages({
    required String userId,
    required String questId,
  }) async {
    try {
      final data = await _eventQuestImagesTable
          .select("*")
          .eq(KeyNames.user_id, userId)
          .eq(KeyNames.quest_id, questId);

      final images = data.map((d) => d[KeyNames.image_url].toString()).toList();
      return images;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<String>> getImagesByIds(List ids) async {
    try {
      final data = await _eventQuestImagesTable.select("*").inFilter(KeyNames.id, ids);
      return data.map((image) => image[KeyNames.image_url].toString()).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<ViewEventQuestModel>> getPlayerSubmissions({
    required String userId,
    required String questId,
  }) async {
    final data = await _eventFinishQuestsLogs
        .select('*,${TableNames.event_quests}(*)')
        .eq(KeyNames.user_id, userId)
        .eq(KeyNames.quest_id, questId)
        // .neq('report_approved', true)
        .order(KeyNames.created_at, ascending: false);

    List<ViewEventQuestModel> viewList = [];
    for (final d in data) {
      if (d['report_approved'] == true) {
        continue;
      }
      final images = await getImagesByIds(d[KeyNames.images] ?? []);
      final view = ViewEventQuestModel(
        userId: userId,
        questId: questId,
        questDescription: d[TableNames.event_quests][KeyNames.description],
        questTitle: d[TableNames.event_quests][KeyNames.title],
        images: images,
        submittedAt: DateTime.parse(d[KeyNames.created_at]),
        finishLogId: d[KeyNames.id],
      );

      viewList.add(view);
    }

    return viewList;
  }

  Future<int> getEventPlayersCount(int eventId) async {
    try {
      final count = await _client.rpc(
        FunctionNames.count_event_players,
        params: {'event_id_param': eventId},
      );

      return count;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
