import 'dart:developer';

import 'package:questra_app/core/shared/constants/function_names.dart';
import 'package:questra_app/features/shared_quests/models/request_model.dart';
import 'package:questra_app/imports.dart';

final sharedQuestsProvider = Provider<SharedQuestsRepository>(
  (ref) => SharedQuestsRepository(ref: ref),
);

class SharedQuestsRepository {
  final Ref _ref;
  SharedQuestsRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _sharedQuestRequestsTable => _client.from(TableNames.shared_quests);
  SupabaseQueryBuilder get _sharedQuestTable => _client.from(TableNames.shared_quests);

  Future<void> sendRequest(RequestModel request) async {
    try {
      await _sharedQuestRequestsTable.insert(request.toMap());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<RequestModel>> getAllQuestRequests(String userId) async {
    try {
      final now = DateTime.now().add(const Duration(hours: 3)).toIso8601String();
      final data = await _sharedQuestRequestsTable
          .select("*")
          .eq(KeyNames.receiver_id, userId)
          .eq(KeyNames.is_accepted, false)
          .gt(KeyNames.dead_line, now);
      return data.map((request) => RequestModel.fromMap(request)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<RequestModel>> getAllSharedRequests({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      final query = _sharedQuestTable.select("*");
      final condition1 = query
          .eq(KeyNames.sender_id, user1Id)
          .eq(KeyNames.receiver_id, user2Id)
          .order(KeyNames.created_at, ascending: false);
      final condition2 = query
          .eq(KeyNames.sender_id, user2Id)
          .eq(KeyNames.receiver_id, user1Id)
          .order(KeyNames.created_at, ascending: false);

      var data = await condition1;
      if (data.isEmpty) {
        data = await condition2;
      }

      return data.map((request) => RequestModel.fromMap(request)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> completeQuest({required String userId, required String questId}) async {
    try {
      await _client.rpc(
        FunctionNames.addCompletedPlayersToSharedQuest,
        params: {'user_id': questId, 'quest_id': userId},
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
