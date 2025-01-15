import 'package:questra_app/features/quests/widgets/quest_image_upload.dart';
import 'package:questra_app/imports.dart';

class FinishQuestWidget extends ConsumerStatefulWidget {
  const FinishQuestWidget({
    super.key,
    required this.cancel,
  });

  final VoidCallback cancel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FinishQuestWidgetState();
}

class _FinishQuestWidgetState extends ConsumerState<FinishQuestWidget> {
  bool done = false;

  @override
  Widget build(BuildContext context) {
    void finish() {
      setState(() {
        done = true;
      });

      return;
      // // TODO design the ui of the  alert dialog of the system
      // // TODO design the upload pic of the quest that completed
      // // TODO make the quest feedback section

      // final quest = ref.watch(viewQuestProvider)!;
      // List<QuestModel> quests = List.from(ref.read(currentOngointQuestsProvider) ?? []);

      // quests.removeWhere((q) => q.id == quest.id);
      // ref.read(currentOngointQuestsProvider);
      // ref.invalidate(currentOngointQuestsProvider);

      // context.pop();
      // log("the quest is removing ...");
      // log(quests.toString());
      // ref.read(currentOngointQuestsProvider.notifier).state = quests;
    }

    if (done) {
      return QuestImageUpload();
    }

    return SystemCard(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Are You Sure You’ve Completed the Quest?",
            style: TextStyle(
              fontFamily: AppFonts.header,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            "Completing a quest is an honorable achievement! However, if you claim completion without truly finishing, you may face penalties",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "· Lose Your Current Streak.\n· Forfeit Earned XP.\n· Block your account!",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.redColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Be honest, adventurer—your reputation and progress depend on it. Are you ready to confirm quest completion?",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: GestureDetector(
              onTap: finish,
              child: Text(
                "[ Yes, I’ve Completed It ]",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: GestureDetector(
              onTap: widget.cancel,
              child: Text(
                "[ No, I’ll Keep Working ]",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.redColor,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
