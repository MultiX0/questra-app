// ignore_for_file: file_names

import 'package:questra_app/imports.dart';

final questFunctionsProvider = Provider<QuestFunctions>((ref) => QuestFunctions(ref: ref));

class QuestFunctions {
  final Ref _ref;
  QuestFunctions({required Ref ref}) : _ref = ref;

  void removeQuestFromCurrentQuests(String questId) {
    final currentQuests = _ref.read(currentOngointQuestsProvider) ?? [];
    List<QuestModel> quests = List.from(currentQuests);
    quests.removeWhere((quest) => quest.id == questId);
    _ref.read(currentOngointQuestsProvider.notifier).state = quests;
  }
}
