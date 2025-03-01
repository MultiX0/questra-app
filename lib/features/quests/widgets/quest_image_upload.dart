import 'dart:developer';
import 'dart:io';

import 'package:questra_app/core/shared/utils/image_picker.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
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
        CustomToast.systemToast("You need to add at least ${widget.minImagesCount} photos.");
        return;
      }
    }
  }

  void finish() async {
    try {
      if (widget.minImagesCount != null) {
        if (_images.length < widget.minImagesCount!) {
          CustomToast.systemToast("You need to add at least ${widget.minImagesCount} photos.");
          return;
        }
      }
      ref.read(questImagesProvider.notifier).state = _images;
      if (widget.isEvent) {
        await ref.read(eventsControllerProvider.notifier).finishEventQuest();
      }

      setState(() {
        done = true;
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

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
            "Provide some pictures from your results please.",
            style: TextStyle(fontFamily: AppFonts.header, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            "Note: for more safety for your account from false reports we suggest at least to select one image for the quest that you've done.",
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
