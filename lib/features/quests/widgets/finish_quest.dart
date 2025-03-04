import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:questra_app/features/quests/widgets/feedback_widget.dart';
import 'package:questra_app/features/quests/widgets/quest_image_upload.dart';
import 'package:questra_app/imports.dart';

class FinishQuestWidget extends ConsumerStatefulWidget {
  const FinishQuestWidget({super.key, required this.cancel});

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
      final now = DateTime.now();
      final quest = ref.read(viewQuestProvider)!;
      log(now.toString());

      // log(quest.toMap().toString());
      final duration = Duration(seconds: quest.estimated_completion_time);
      // log(duration.inHours.toString());
      if (!kDebugMode) {
        if (quest.created_at.toUtc().add(duration).isAfter(now.toUtc())) {
          CustomToast.systemToast(
            "${AppLocalizations.of(context).wait_until} ${appDateFormat(quest.created_at.toLocal().add(duration))}",
            systemMessage: true,
          );
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

  bool get isArabic => ref.watch(localeProvider).languageCode == 'ar';

  Widget buildDefaultPage() {
    return SystemCard(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).quest_status_card_title,
            style: TextStyle(
              fontFamily: isArabic ? null : AppFonts.header,
              fontSize: 18,
              fontWeight: isArabic ? FontWeight.bold : null,
            ),
          ),
          const SizedBox(height: 15),
          SystemCardButton(
            onTap: () {
              setState(() {
                status = 'finish';
              });
            },
            text: AppLocalizations.of(context).quest_finished,
          ),
          const SizedBox(height: 20),
          SystemCardButton(
            onTap: () {
              setState(() {
                status = 'failed';
              });
            },
            text: AppLocalizations.of(context).quest_failed,
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
            AppLocalizations.of(context).quest_complete_confirmation,
            style: TextStyle(
              fontFamily: isArabic ? null : AppFonts.header,
              fontSize: 18,
              fontWeight: isArabic ? FontWeight.bold : null,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            AppLocalizations.of(context).quest_finish_alert1,
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context).quest_finish_alert2,

            style: TextStyle(fontSize: 12, color: AppColors.redColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context).quest_finish_alert3,
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          SystemCardButton(onTap: finish, text: AppLocalizations.of(context).quest_finish_btn1),
          const SizedBox(height: 20),
          SystemCardButton(
            onTap: () {
              widget.cancel();
            },
            text: AppLocalizations.of(context).quest_finish_btn2,
            doneButton: false,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
