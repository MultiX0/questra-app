import 'dart:developer';

import 'package:questra_app/features/shared_quests/models/request_model.dart';
import 'package:questra_app/features/shared_quests/models/shared_quest_model.dart';
import 'package:questra_app/features/shared_quests/repository/shared_quests_repository.dart';
import 'package:questra_app/imports.dart';

final sharedQuestsControllerProvider = StateNotifierProvider<SharedQuestsController, bool>(
  (ref) => SharedQuestsController(ref: ref),
);

final getAllSharedQuestsProvider = FutureProvider.family<List<SharedQuestModel>, String>((
  ref,
  userId,
) async {
  final controller = ref.watch(sharedQuestsControllerProvider.notifier);
  return await controller.getAllSharedQuests(userId);
});

class SharedQuestsController extends StateNotifier<bool> {
  final Ref _ref;
  SharedQuestsController({required Ref ref}) : _ref = ref, super(false);

  SharedQuestsRepository get _repo => _ref.watch(sharedQuestsProvider);
  bool get _isArabic => _ref.watch(localeProvider).languageCode == 'ar';

  Future<void> sendRequest({
    required String questContent,
    required String receiverId,
    required DateTime deadLine,
    required bool isAiGenerated,
    required bool firstCompleteWin,
  }) async {
    state = true;
    final user = _ref.read(authStateProvider)!;
    try {
      final request = RequestModel(
        content: questContent,
        deadLine: deadLine,
        receiverId: receiverId,
        senderId: user.id,
        aiGenerated: isAiGenerated,
        requestId: -1,
        firstCompleteWin: firstCompleteWin,
        isAccepted: false,
      );
      await _repo.sendRequest(request);
      final toastMessage =
          _isArabic
              ? "تم ارسال طلب مهمة مشتركة بنجاح"
              : "shared quest request successfully created";
      CustomToast.systemToast(toastMessage, systemMessage: true);
    } catch (e) {
      log(e.toString());
      CustomToast.systemToast(appError);
      await ExceptionService.insertException(
        path: "/shared_quests_controller",
        error: e.toString(),
        userId: user.id,
      );
    }
    state = false;
  }

  Future<List<RequestModel>> getAllQuestRequests() async {
    final me = _ref.read(authStateProvider)!;

    try {
      return await _repo.getAllQuestRequests(me.id);
    } catch (e, trace) {
      log(e.toString());
      await ExceptionService.insertException(
        path: "/shared_quests_controller",
        error: "${e.toString()}\ntrace:$trace",
        userId: me.id,
      );
      rethrow;
    }
  }

  Future<List<SharedQuestModel>> getAllSharedQuests(String userId) async {
    try {
      final me = _ref.read(authStateProvider)!;
      return await _repo.getAllSharedRequests(user1Id: me.id, user2Id: userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
