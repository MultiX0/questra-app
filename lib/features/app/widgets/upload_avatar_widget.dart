import 'dart:io';

import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/features/profiles/controller/profile_controller.dart';
import 'package:questra_app/imports.dart';

import '../../../core/shared/utils/image_picker.dart';

class UploadAvatarWidget extends ConsumerStatefulWidget {
  const UploadAvatarWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UploadAvatarWidgetState();
}

class _UploadAvatarWidgetState extends ConsumerState<UploadAvatarWidget> {
  List<File> _images = [];
  bool done = false;

  void selectImages() async {
    if (_images.isNotEmpty) {
      setState(() {
        _images.clear();
      });
    }

    final images = await imagePicker(true);
    setState(() {
      _images = List<File>.from(images);
    });
  }

  void finish() async {
    if (_images.isEmpty) return;
    final user = ref.read(authStateProvider);
    ref.read(profileControllerProvider.notifier).updateUserAvatar(_images[0], user!.id, context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.read(profileControllerProvider);
    return BackgroundWidget(
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SystemCard(
              color: Colors.transparent,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Update Your Avatar.",
                    style: TextStyle(
                      fontFamily: AppFonts.header,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: SystemCard(
                        padding: EdgeInsets.zero,
                        onTap: selectImages,
                        // padding: EdgeInsets.all(25),
                        child: _images.isEmpty
                            ? Icon(
                                LucideIcons.upload,
                                color: AppColors.primary,
                                size: 20,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image(
                                  image: FileImage(_images.first),
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (isLoading) ...[
                    const BeatLoader(),
                  ] else ...[
                    SystemCardButton(
                      onTap: finish,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
