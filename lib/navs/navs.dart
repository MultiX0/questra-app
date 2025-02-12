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

  void goToProfile(String userId) {
    context.push("${Routes.profile}/$userId");
  }
}
