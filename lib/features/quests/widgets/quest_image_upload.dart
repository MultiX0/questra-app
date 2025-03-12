// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:questra_app/core/shared/utils/image_picker.dart';
import 'package:questra_app/features/events/controller/events_controller.dart';
import 'package:questra_app/features/quests/widgets/feedback_widget.dart';
import 'package:questra_app/features/quests/widgets/quest_completion_widget.dart';
import 'package:questra_app/imports.dart';

class QuestImageUpload extends ConsumerStatefulWidget {
  const QuestImageUpload({super.key, this.minImagesCount, this.isEvent = false});

  final int? minImagesCount;
  final bool isEvent;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuestImageUploadState();
}

class _QuestImageUploadState extends ConsumerState<QuestImageUpload> {
  List<File> _images = [];
  bool done = false;

  void selectImages() async {
    if (_images.isNotEmpty) {
      setState(() {
        _images.clear();
      });
    }

    final images = await imagePicker(false);
    setState(() {
      _images = List<File>.from(images);
    });
    if (widget.minImagesCount != null) {
      if (_images.length < widget.minImagesCount!) {
        CustomToast.systemToast(
          AppLocalizations.of(context).image_upload_count_alert(widget.minImagesCount!),
        );
        return;
      }
    }
  }

  void finish() async {
    try {
      if (widget.minImagesCount != null) {
        if (_images.length < widget.minImagesCount!) {
          CustomToast.systemToast(
            AppLocalizations.of(context).image_upload_count_alert(widget.minImagesCount!),
          );
          return;
        }
      }
      ref.read(questImagesProvider.notifier).state = _images;
      if (widget.isEvent) {
        await ref.read(eventsControllerProvider.notifier).finishEventQuest(context);
      }

      setState(() {
        done = true;
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  bool get isArabic => ref.watch(localeProvider).languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    if (done) {
      if (widget.isEvent) {
        return QuestCompletionWidget(isEvent: widget.isEvent);
      }
      return QuestFeedbackWidget(skip: false);
    }

    final eventsLoading = ref.watch(eventsControllerProvider);
    final isEventAndLoading = widget.isEvent && eventsLoading;

    return SystemCard(
      color: Colors.transparent,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).image_submit_card_title,
            style: TextStyle(
              fontFamily: isArabic ? null : AppFonts.header,
              fontSize: 18,
              fontWeight: isArabic ? FontWeight.bold : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context).image_submit_card_note,
            style: TextStyle(
              // fontFamily: AppFonts.header,
              fontWeight: FontWeight.w200,
              color: AppColors.descriptionColor,
              fontSize: 12,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: kTextTabBarHeight),
            child: SystemCard(
              onTap: selectImages,
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Center(
                child: Icon(
                  _images.isEmpty ? LucideIcons.upload : LucideIcons.delete,
                  color: _images.isEmpty ? AppColors.primary : AppColors.redColor,
                  size: 20,
                ),
              ),
            ),
          ),
          if (isEventAndLoading) BeatLoader() else SystemCardButton(onTap: finish),
        ],
      ),
    );
  }
}
