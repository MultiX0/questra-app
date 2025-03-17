import 'dart:developer';

import 'package:questra_app/core/enums/shared_quest_status_enum.dart';
import 'package:questra_app/core/shared/utils/lang_detect.dart';
import 'package:questra_app/features/ads/ads_service.dart';
import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/features/quests/ai/ai_functions.dart';
import 'package:questra_app/features/shared_quests/models/request_model.dart';
import 'package:questra_app/features/shared_quests/models/shared_quest_model.dart';
import 'package:questra_app/features/shared_quests/providers/quest_requests_provider.dart';
import 'package:questra_app/features/shared_quests/providers/shared_quests_provider.dart';
import 'package:questra_app/features/shared_quests/providers/shared_quests_providers.dart';
import 'package:questra_app/features/shared_quests/repository/shared_quests_repository.dart';
import 'package:questra_app/features/translate/translate_service.dart';
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

final getAllSharedRequestsFromUserProvider = FutureProvider<List<RequestModel>>((ref) async {
  final controller = ref.watch(sharedQuestsControllerProvider.notifier);
  return await controller.getAllQuestRequestsFromUser();
});

class SharedQuestsController extends StateNotifier<bool> {
  final Ref _ref;
  SharedQuestsController({required Ref ref}) : _ref = ref, super(false);

  SharedQuestsRepository get _repo => _ref.watch(sharedQuestsProvider);
  bool get _isArabic => _ref.watch(localeProvider).languageCode == 'ar';

  Future<void> sendRequest({
    required String questContent,
    required DateTime deadLine,
    required bool isAiGenerated,
    required bool firstCompleteWin,
    required BuildContext context,
  }) async {
    state = true;
    final adResult = await _ref.read(adsServiceProvider.notifier).showAd();
    if (!adResult) return;
    final receiverId = _ref.read(selectedFriendProvider)!.id;
    final user = _ref.read(authStateProvider)!;
    try {
      var request = RequestModel(
        content: questContent,
        deadLine: deadLine,
        receiverId: receiverId,
        senderId: user.id,
        aiGenerated: isAiGenerated,
        requestId: -1,
        firstCompleteWin: firstCompleteWin,
        sentAt: DateTime.now(),
        status: SharedQuestStatusEnum.pending,
        arContent: '',
      );
      if (isArabic(questContent)) {
        final _enDescription = await TranslationService().translate("ar", "en", questContent);
        request = request.copyWith(content: _enDescription, arContent: questContent);
      } else {
        final _arDescription = await TranslationService().translate("ar", "en", questContent);
        request = request.copyWith(arContent: _arDescription);
      }
      final requestId = await _repo.sendRequest(request);
      log("request id is $requestId");
      _ref.read(insertedSharedQuestId.notifier).state = requestId;
      await _handleAiAnalyzer(request.content, requestId);

      // ignore: use_build_context_synchronously
      context.pop();
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

  Future<void> _handleAiAnalyzer(String questContent, int requestId) async {
    final user = _ref.read(authStateProvider)!;

    try {
      await _ref
          .read(aiFunctionsProvider)
          .customQuestAnalizer(
            questDescription: questContent,
            errors: 0,
            userId: user.id,
            isCustomQuest: false,
          );
    } catch (e) {
      await _repo.deleteSharedQuest(requestId);
      await _repo.deleteRequest(requestId);

      rethrow;
    }
  }

  Future<void> handleRequest({
    required int id,
    required bool isAccpeted,
    required String senderId,
    required BuildContext context,
  }) async {
    try {
      state = true;
      _ref.read(appLoading.notifier).state = true;
      final result = await _repo.handleRequest(id: id, isAccpeted: isAccpeted);
      if (result) {
        final quest = await _repo.getQuestByRequestId(id);
        _ref.read(sharedQuestsStateProvider.notifier).addQuest(quest);
      }
      _ref.read(appLoading.notifier).state = false;
      state = false;
      _removeRequestFromState(id);
      // ignore: use_build_context_synchronously
      context.pop();
    } catch (e) {
      _ref.read(appLoading.notifier).state = false;
      state = false;

      log(e.toString());
      rethrow;
    }
  }

  void _removeRequestFromState(int id) {
    _ref.read(questRequestsProvider.notifier).removeRequest(id);
  }

  Future<List<RequestModel>> getAllQuestRequestsFromUser() async {
    try {
      final sender = _ref.read(selectedFriendProvider);
      return await _repo.getAllQuestRequestsFromUser(sender!.id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
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
