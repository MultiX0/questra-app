import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/imports.dart';

class Navs {
  final BuildContext context;
  final WidgetRef ref;
  Navs(this.context, this.ref);

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

  void goToEventPlayerQuestCompletionPage(String userId) {
    context.push('${Routes.playerCompletionPage}/$userId');
  }

  void goPlayerProfile(UserModel user) {
    ref.read(selectedFriendProvider.notifier).state = user;
    context.push("${Routes.player}/${user.id}");
  }
}
