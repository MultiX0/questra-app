import 'dart:developer';

import 'package:questra_app/features/shared_quests/models/request_model.dart';
import 'package:questra_app/imports.dart';

final sharedQuestsProvider = Provider<SharedQuestsRepository>(
  (ref) => SharedQuestsRepository(ref: ref),
);

class SharedQuestsRepository {
  final Ref _ref;
  SharedQuestsRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _sharedQuestsTable => _client.from(TableNames.shared_quests);

  Future<void> sendRequest(RequestModel request) async {
    try {
      await _sharedQuestsTable.insert(request.toMap());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<RequestModel>> getAllQuestRequests(String userId) async {
    try {
      final data = await _sharedQuestsTable.select("*").eq(KeyNames.receiver_id, userId);
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
      final data = await _sharedQuestsTable
          .select("*")
          .or('${KeyNames.sender_id}.eq.$user1Id,${KeyNames.receiver_id}.eq.$user1Id,')
          .or('${KeyNames.sender_id}.eq.$user2Id,${KeyNames.receiver_id}.eq.$user2Id,')
          .order(KeyNames.created_at, ascending: false);

      return data.map((request) => RequestModel.fromMap(request)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
