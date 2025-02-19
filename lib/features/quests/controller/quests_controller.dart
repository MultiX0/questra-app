// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:questra_app/core/shared/utils/upload_storage.dart';
import 'package:questra_app/features/ads/ads_service.dart';
import 'package:questra_app/features/quests/ai/ai_functions.dart';
import 'package:questra_app/features/quests/pages/quests_archive_provider.dart';
import 'package:questra_app/features/quests/providers/functions..dart';
import 'package:questra_app/features/quests/repository/quests_repository.dart';
import 'package:questra_app/imports.dart';

final questsControllerProvider = StateNotifierProvider<QuestsController, bool>((ref) {
  return QuestsController(ref: ref);
});

final getCustomQuestsProvider =
    FutureProvider.family<List<QuestModel>, String>((ref, userId) async {
  final _controller = ref.watch(questsControllerProvider.notifier);
  final quests = await _controller.getCustomQuests(userId);

  return quests;
});

final getActiveCustomQuestsProvider =
    FutureProvider.family<List<QuestModel>, String>((ref, userId) async {
  final _controller = ref.watch(questsControllerProvider.notifier);
  return await _controller.getActiveCustomQuests(userId);
});

final getAllQuestTypesProvider = FutureProvider<List<QuestTypeModel>>((ref) async {
  final _controller = ref.watch(questsControllerProvider.notifier);
  return await _controller.getAllQuestTypes();
});

class QuestsController extends StateNotifier<bool> {
  final Ref _ref;
  QuestsController({required Ref ref})
      : _ref = ref,
        super(false);

  QuestsRepository get _repository => _ref.watch(questsRepositoryProvider);

  Future<List<QuestTypeModel>> getAllQuestTypes() async {
    try {
      return await _repository.getAllQuestTypes();
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  Future<List<QuestModel>> getQuestsArchive(String user_id) async {
    try {
      return await _repository.getQuestsArchive(user_id);
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<bool> finishQuest({
    required BuildContext context,
    required QuestModel quest,
    FeedbackModel? feedback,
  }) async {
    try {
      state = true;

      QuestModel updatedQuest = await _repository.finishQuest(
        quest: quest,
        feedback: feedback,
      );

      final images = await _uploadImages(quest.id);
      updatedQuest = updatedQuest.copyWith(images: images);
      await _repository.updateQuest(updatedQuest);

      _ref.read(questFunctionsProvider).removeQuestFromCurrentQuests(quest.id);
      _ref.read(questImagesProvider.notifier).state = null;

      state = false;

      return true;
    } catch (e) {
      if (e.toString().contains('expired')) {
        _ref.read(questFunctionsProvider).removeQuestFromCurrentQuests(quest.id);
      }

      state = false;
      log(e.toString());
      CustomToast.systemToast(e.toString(), systemMessage: true);

      context.pop();
      return false;
    }
  }

  Future<List<String>> _uploadImages(String questId) async {
    try {
      final userId = _ref.read(authStateProvider)?.id;
      final _images = _ref.read(questImagesProvider) ?? [];
      List<String> links = [];

      for (final image in _images) {
        final link =
            await UploadStorage.uploadImages(image: image, path: "$userId/quests/$questId/");
        links.add(link);
      }

      return links;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> handleSkip({
    required QuestModel quest,
    required FeedbackModel feedback,
    required BuildContext context,
  }) async {
    try {
      state = true;
      final userId = _ref.read(authStateProvider)?.id ?? "";

      await _repository.handleSkip(
        quest: quest,
        userId: userId,
        feedback: feedback,
      );

      CustomToast.systemToast("quest skipped successfully");
      _ref.read(questFunctionsProvider).removeQuestFromCurrentQuests(quest.id);
      _ref.invalidate(questArchiveProvider);
      state = false;

      context.pop();
    } catch (e) {
      state = false;
      context.pop();
      log(e.toString());
      CustomToast.systemToast(e.toString(), systemMessage: true);
      rethrow;
    }
  }

  Future<void> failedPunishment({
    required QuestModel quest,
    required FeedbackModel feedback,
    required BuildContext context,
  }) async {
    try {
      state = true;
      await _repository.updateQuestStatus(StatusEnum.failed, quest.id);
      await _repository.failedPunishment(quest);
      CustomToast.systemToast("penalty is received", systemMessage: true);
      await _repository.insertFeedback(feedback);
      _ref.read(questFunctionsProvider).removeQuestFromCurrentQuests(quest.id);
      _ref.invalidate(questArchiveProvider);
      state = false;
      context.pop();
    } catch (e) {
      state = false;

      CustomToast.systemToast(appError);
      log(e.toString());
      rethrow;
    }
  }

  Future<List<QuestModel>> getCustomQuests(String userId) async {
    try {
      final data = await _repository.getCustomQuests(userId);
      _ref.read(customQuestsProvider.notifier).state =
          data.where((quest) => quest.isActive == true).toList();
      return data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<QuestModel>> getActiveCustomQuests(String userId) async {
    try {
      return await _repository.getActiveCustomQuests(userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> addCustomQuest({required String description, required BuildContext context}) async {
    try {
      state = true;
      await _ref.read(aiFunctionsProvider).customQuestAnalizer(description, 0);
      await _ref.read(adsServiceProvider.notifier).showAd();
      state = false;
      context.pop();
    } catch (e) {
      state = false;

      log(e.toString());
      CustomToast.systemToast(e.toString());
      throw Exception(e);
    }
  }

  Future<void> deActiveCustomQuest(
      {required String userId, required String questId, required BuildContext context}) async {
    try {
      state = true;
      await _repository.deActiveCustomQuest(userId, questId);
      final currentQuests = _ref.read(customQuestsProvider);
      final newQuests = List<QuestModel>.from(currentQuests);
      newQuests.removeWhere((quest) => quest.id == questId);
      _ref.read(customQuestsProvider.notifier).state = newQuests;
      state = false;
      CustomToast.systemToast("The quest has been successfully deleted.", systemMessage: true);
      context.pop();
    } catch (e) {
      state = false;

      log(e.toString());
      rethrow;
    }
  }
}
