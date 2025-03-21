import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:questra_app/features/notifications/controller/notifications_controller.dart';
import 'package:questra_app/features/shared_quests/providers/shared_quests_provider.dart';
import 'package:questra_app/imports.dart';

final sharedQuestsProvider = Provider<SharedQuestsRepository>(
  (ref) => SharedQuestsRepository(ref: ref),
);

class SharedQuestsRepository {
  final Ref _ref;
  SharedQuestsRepository({required Ref ref}) : _ref = ref;
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _sharedQuestRequestsTable =>
      _client.from(TableNames.shared_quest_requests);
  SupabaseQueryBuilder get _sharedQuestTable => _client.from(TableNames.shared_quests);
  bool get isArabic => _ref.watch(localeProvider).languageCode == 'ar';

  Future<void> _sendNotification({
    required String arTitle,
    required String enTitle,
    required String arContent,
    required String enContent,
    required String userId,
  }) async {
    try {
      if (isArabic) {
        await NotificationsController.sendNotificaction(
          userId: userId,
          content: arContent,
          title: arTitle,
        );
        return;
      }
      await NotificationsController.sendNotificaction(
        userId: userId,
        content: enContent,
        title: enTitle,
      );
    } catch (e, trace) {
      log(e.toString(), stackTrace: trace);
      return;
    }
  }

  Future<int> sendRequest(RequestModel request) async {
    try {
      final data = await _sharedQuestRequestsTable.insert(request.toMap()).select();
      final senderUsername = await _ref
          .read(profileRepositoryProvider)
          .getUserNameById(request.senderId);
      await _sendNotification(
        arTitle: 'تحدٍ جديد في مهمة مشتركة 🚀',
        enTitle: 'New Shared Mission Challenge 🚀',
        arContent: '$senderUsername قام بتحديك في مهمة مشتركة جديدة! هل أنت مستعد لقبول التحدي؟',
        enContent:
            '$senderUsername has challenged you to a new shared mission! Are you ready to accept the challenge?',
        userId: request.receiverId,
      );

      return data[0][KeyNames.id];
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> handleRequest({
    required int id,
    required bool isAccpeted,
    required String senderId,
  }) async {
    try {
      final me = _ref.read(authStateProvider)!;
      if (isAccpeted) {
        await _sharedQuestRequestsTable
            .update({KeyNames.status: sharedQuestStatusToString(SharedQuestStatusEnum.accepted)})
            .eq(KeyNames.id, id);
        await _sharedQuestTable
            .update({KeyNames.is_accepted: true})
            .eq(KeyNames.request_id, id)
            .eq(KeyNames.request_id, id);
        await _sendNotification(
          arTitle: '🎯 تم قبول المهمة بنجاح!',
          enTitle: '🎯 Mission Accepted Successfully!',
          arContent: 'اللاعب ${me.username} قبل التحدي! استعد للمنافسة 💪🔥',
          enContent: '${me.username} has accepted your mission! Get ready for the challenge 💪🔥',
          userId: senderId,
        );

        return true;
      } else {
        await _sharedQuestRequestsTable
            .update({KeyNames.status: sharedQuestStatusToString(SharedQuestStatusEnum.rejected)})
            .eq(KeyNames.id, id);
        await _sendNotification(
          arTitle: '❌ تم رفض المهمة',
          enTitle: '❌ Mission Declined',
          arContent: 'اللاعب ${me.username} رفض المهمة هذه المرة. حاول مرة أخرى لاحقًا!',
          enContent: '${me.username} has declined the mission this time. Try again later!',
          userId: senderId,
        );

        return false;
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteSharedQuest(int requestId) async {
    try {
      await _sharedQuestTable.delete().eq(KeyNames.request_id, requestId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteRequest(int requestId) async {
    try {
      await _sharedQuestRequestsTable.delete().eq(KeyNames.id, requestId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<int> insertQuest(SharedQuestModel quest) async {
    try {
      final data = await _sharedQuestTable.insert(quest.toMap()).select();
      return data[0][KeyNames.id];
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<RequestModel>> getAllQuestRequests(String userId) async {
    try {
      // final now = DateTime.now().add(const Duration(hours: 5)).toIso8601String();
      final data = await _sharedQuestRequestsTable
          .select("*")
          .eq(KeyNames.receiver_id, userId)
          .eq(KeyNames.status, sharedQuestStatusToString(SharedQuestStatusEnum.pending))
          .order(KeyNames.created_at, ascending: false);
      log(data.toString());
      // .gt(KeyNames.dead_line, now);
      return data.map((request) => RequestModel.fromMap(request)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<RequestModel>> getAllQuestRequestsFromUser(String senderId) async {
    try {
      final me = _ref.read(authStateProvider)!;
      final data = await _sharedQuestRequestsTable
          .select("*")
          .eq(KeyNames.sender_id, senderId)
          .eq(KeyNames.receiver_id, me.id)
          .eq(KeyNames.status, 'pending')
          .order(KeyNames.created_at, ascending: false);

      // log(data.toString());

      return data.map((request) => RequestModel.fromMap(request)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<SharedQuestModel> getQuestByRequestId(int id) async {
    try {
      final data = await _sharedQuestTable.select("*").eq(KeyNames.request_id, id).maybeSingle();
      if (data == null) throw "no data found";
      return SharedQuestModel.fromMap(data);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<SharedQuestModel>> getAllSharedRequests({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      final response = await _client.rpc(
        FunctionNames.get_shared_quests_between_users,
        params: {'user1': user1Id, 'user2': user2Id},
      );

      log(response.toString());

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => SharedQuestModel.fromMap(item)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> completeQuest({required String userId, required SharedQuestModel quest}) async {
    try {
      await _client.rpc(
        FunctionNames.addCompletedPlayersToSharedQuest,
        params: {'user_id': userId, 'quest_id': quest.id},
      );
      final me = _ref.read(authStateProvider)!;
      if (quest.playersCompleted.isEmpty) {
        await _sendNotification(
          arTitle: '⚡ لقد تم إنهاء المهمة قبلك!',
          enTitle: '⚡ Someone Completed the Mission Before You!',
          arContent: 'للأسف، سبقك ${me.username} في إكمال المهمة. حاول مجددًا في التحديات القادمة!',
          enContent:
              'Unfortunately, ${me.username} has completed the mission before you. Try again in future challenges!',
          userId:
              quest.request!.receiverId == userId
                  ? quest.request!.receiverId
                  : quest.request!.senderId,
        );
      }
      await _ref.read(sharedQuestsStateProvider.notifier).getQuests();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

Future<SharedQuestModel> getQuestById(int id) async {
  final token = RootIsolateToken.instance;
  log(token.toString());
  BackgroundIsolateBinaryMessenger.ensureInitialized(token!);
  // Pass both the function and the id parameter
  SharedQuestModel quest = await computeIsolate(_fetchQuestById, {
    'id': id,
    'supabaseUrl': dotenv.env['SUPABASE_URL'] ?? "",
    'supabaseKey': dotenv.env['SUPABASE_KEY'] ?? "",
  });
  log(quest.arTitle);

  return quest;
}

// Standalone computation function
Future _fetchQuestById(dynamic args) async {
  try {
    final id = args['id'];
    final supabaseUrl = args['supabaseUrl'];
    final supabaseKey = args['supabaseKey'];
    final client = SupabaseClient(supabaseUrl, supabaseKey);

    final questData =
        await client
            .from(TableNames.shared_quests)
            .select('*,${TableNames.shared_quest_requests}(*)')
            .eq(KeyNames.id, id)
            .maybeSingle();

    if (questData == null) throw 'There is no quest with id $id';
    return SharedQuestModel.fromMap(questData);
  } catch (e) {
    log('Error in isolate: ${e.toString()}');
    rethrow;
  }
}
