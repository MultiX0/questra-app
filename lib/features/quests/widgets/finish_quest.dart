import 'dart:developer';
import 'dart:ffi';

import 'package:questra_app/features/quests/models/quest_model.dart';
import 'package:questra_app/features/quests/providers/quests_providers.dart';
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
  bool durationDone = false;
  double width = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final size = MediaQuery.sizeOf(context);

      setState(() {
        width = size.width;
      });
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        durationDone = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    void finish() {
      // TODO design the ui of the  alert dialog of the system
      // TODO design the upload pic of the quest that completed
      // TODO make the quest feedback section

      final quest = ref.watch(viewQuestProvider)!;
      List<QuestModel> quests = List.from(ref.read(currentOngointQuestsProvider) ?? []);

      quests.removeWhere((q) => q.id == quest.id);
      ref.read(currentOngointQuestsProvider);
      ref.invalidate(currentOngointQuestsProvider);

      context.pop();
      log("the quest is removing ...");
      log(quests.toString());
      ref.read(currentOngointQuestsProvider.notifier).state = quests;
    }

    return SystemCard(
      isButton: !durationDone,
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
            child: Text(
              "[ Yes, I’ve Completed It ]",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primary,
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
