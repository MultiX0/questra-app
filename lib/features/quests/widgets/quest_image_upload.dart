import 'dart:io';

import 'package:questra_app/core/shared/utils/image_picker.dart';
import 'package:questra_app/features/quests/widgets/feedback_widget.dart';
import 'package:questra_app/imports.dart';

class QuestImageUpload extends ConsumerStatefulWidget {
  const QuestImageUpload({super.key});

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

    final images = await imagePicker();
    setState(() {
      _images = List<File>.from(images);
    });
  }

  void finish() {
    setState(() {
      done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (done) {
      return QuestFeedbackWidget();
    }

    return SystemCard(
      color: Colors.transparent,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Provide some pictures from your results please.",
            style: TextStyle(
              fontFamily: AppFonts.header,
              fontSize: 18,
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
          Center(
            child: GestureDetector(
              onTap: finish,
              child: Text(
                "[ done ]",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
