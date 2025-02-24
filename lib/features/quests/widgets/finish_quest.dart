import 'dart:developer';

import 'package:questra_app/features/quests/widgets/feedback_widget.dart';
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
  String status = '';

  @override
  Widget build(BuildContext context) {
    void finish() {
      final now = DateTime.now().toUtc();
      final quest = ref.read(viewQuestProvider)!;
      log(now.toString());

      // log(quest.toMap().toString());
      final duration = Duration(seconds: quest.estimated_completion_time);
      log("the quest end duration is ${quest.estimated_completion_time}");
      log("quest created at time is ${quest.created_at.toUtc()}");
      log("now time is: $now");
      log("quest created time and the duration is: ${quest.created_at.add(duration).toLocal()}");

      // log(duration.inHours.toString());
      if (quest.created_at.toUtc().add(duration).isAfter(now)) {
        CustomToast.systemToast(
            "you need to wait until ${appDateFormat(quest.created_at.add(duration).toLocal())}",
            systemMessage: true);
        return;
      }

      // if (now.isBefore(quest.expected_completion_time_date)) {
      //   CustomToast.systemToast(
      //       "you need to wait until ${appDateFormat(quest.expected_completion_time_date)}",
      //       systemMessage: true);
      //   widget.cancel;
      //   return;
      // }

      setState(() {
        done = true;
      });

      return;
    }

    if (done) {
      return QuestImageUpload();
    }

    return buildController(finish);
  }

  Widget buildController(void Function() finish) {
    switch (status) {
      case "finish":
        return buildCompleteWarning(finish);
      case "failed":
        return buildFailed();
      default:
        return buildDefaultPage();
    }
  }

  Widget buildFailed() {
    return QuestFeedbackWidget(failed: true);
  }

  Widget buildDefaultPage() {
    return SystemCard(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quest Status is ?",
            style: TextStyle(
              fontFamily: AppFonts.header,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SystemCardButton(
            onTap: () {
              setState(() {
                status = 'finish';
              });
            },
            text: "Finished",
          ),
          const SizedBox(
            height: 20,
          ),
          SystemCardButton(
            onTap: () {
              setState(() {
                status = 'failed';
              });
            },
            text: "Failed",
            doneButton: false,
          ),
        ],
      ),
    );
  }

  Widget buildCompleteWarning(void Function() finish) {
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
          SystemCardButton(
            onTap: finish,
            text: "Yes, I’ve Completed It",
          ),
          const SizedBox(
            height: 20,
          ),
          SystemCardButton(
            onTap: () {
              widget.cancel();
            },
            text: "No, I’ll Keep Working",
            doneButton: false,
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
