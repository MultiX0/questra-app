import 'package:questra_app/features/quests/models/quest_model.dart';
import 'package:questra_app/features/quests/providers/quests_providers.dart';
import 'package:questra_app/imports.dart';

class Navs {
  final BuildContext context;
  final WidgetRef ref;
  Navs(
    this.context,
    this.ref,
  );

  void viewQuest(QuestModel quest) {
    ref.read(viewQuestProvider.notifier).state = quest;
    context.push(Routes.viewQuest);
  }
}
