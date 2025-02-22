import 'package:questra_app/imports.dart';

class Navs {
  final BuildContext context;
  final WidgetRef ref;
  Navs(
    this.context,
    this.ref,
  );

  void viewQuest(QuestModel quest, bool special) {
    ref.read(viewQuestProvider.notifier).state = quest;
    context.pushNamed(Routes.viewQuest, extra: {KeyNames.is_custom: special});
  }

  void goToProfile(String userId) {
    context.push("${Routes.profile}/$userId");
  }

  void goToAboutUs() {
    context.push(Routes.aboutUsPage);
  }
}
