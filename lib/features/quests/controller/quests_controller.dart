// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:questra_app/core/shared/utils/upload_storage.dart';
import 'package:questra_app/features/quests/models/feedback_model.dart';
import 'package:questra_app/features/quests/models/quest_model.dart';
import 'package:questra_app/features/quests/models/quest_type_model.dart';
import 'package:questra_app/features/quests/providers/functions..dart';
import 'package:questra_app/features/quests/repository/quests_repository.dart';
import 'package:questra_app/imports.dart';

final questsControllerProvider = StateNotifierProvider<QuestsController, bool>((ref) {
  return QuestsController(ref: ref);
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

  Future<bool> finishQuest({
    required BuildContext context,
    required QuestModel quest,
    FeedbackModel? feedback,
  }) async {
    try {
      state = true;

      final images = await _uploadImages(quest.id);
      final _quest = quest.copyWith(images: images);

      await _repository.finishQuest(
        quest: _quest,
        feedback: feedback,
      );
      _ref.read(questFunctionsProvider).removeQuestFromCurrentQuests(quest.id);
      _ref.read(questImagesProvider.notifier).state = null;

      state = false;

      return true;
    } catch (e) {
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
}
