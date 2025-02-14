import 'dart:developer';

import 'package:questra_app/core/shared/utils/parse_duration.dart';
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
      ref.read(soundEffectsServiceProvider).playSystemButtonClick();

      final now = DateTime.timestamp();
      final quest = ref.read(viewQuestProvider)!;

      log(quest.toMap().toString());
      final duration = parseDuration(quest.estimated_completion_time);
      if (duration != null) {
        if (now.add(duration).isBefore(quest.created_at)) {
          CustomToast.systemToast("you need to wait until ${appDateFormat(now.add(duration))}",
              systemMessage: true);
          return;
        }
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

              ref.read(soundEffectsServiceProvider).playSystemButtonClick();
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
