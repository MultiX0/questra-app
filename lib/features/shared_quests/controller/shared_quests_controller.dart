import 'dart:developer';

import 'package:questra_app/features/shared_quests/models/request_model.dart';
import 'package:questra_app/features/shared_quests/repository/shared_quests_repository.dart';
import 'package:questra_app/imports.dart';

class SharedQuestsController extends StateNotifier<bool> {
  final Ref _ref;
  SharedQuestsController({required Ref ref}) : _ref = ref, super(false);

  SharedQuestsRepository get _repo => _ref.watch(sharedQuestsProvider);
  bool get _isArabic => _ref.watch(localeProvider).languageCode == 'ar';

  Future<void> sendRequest({
    required String questContent,
    required String receiverId,
    required DateTime deadLine,
  }) async {
    state = true;
    final user = _ref.read(authStateProvider)!;
    try {
      final request = RequestModel(
        content: questContent,
        deadLine: deadLine,
        receiverId: receiverId,
        senderId: user.id,
        requestId: -1,
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

  Future<List<RequestModel>> getAllSharedRequests({required String userId}) async {
    final me = _ref.read(authStateProvider)!;

    try {
      return await _repo.getAllSharedRequests(user1Id: userId, user2Id: me.id);
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
}
