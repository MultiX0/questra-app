// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

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
  }) async {
    try {
      state = true;
      await _repository.finishQuest(quest);
      _ref.read(questFunctionsProvider).removeQuestFromCurrentQuests(quest.id);
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
}
