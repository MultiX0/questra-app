import 'dart:developer';

import 'package:questra_app/features/events/models/event_model.dart';
import 'package:questra_app/features/events/models/event_quest_model.dart';
import 'package:questra_app/imports.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) => EventsRepository(ref: ref));

class EventsRepository {
  final Ref _ref;
  EventsRepository({required Ref ref}) : _ref = ref;
  SupabaseClient get _client => _ref.read(supabaseProvider);
  SupabaseQueryBuilder get _eventsTable => _client.from(TableNames.events);
  SupabaseQueryBuilder get _eventPlayersTable => _client.from(TableNames.event_players);
  SupabaseQueryBuilder get _eventQuestsTable => _client.from(TableNames.event_quests);

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

  // Future<EventQuestModel> getEventQuests() async {}
}
