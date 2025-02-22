import 'dart:developer';
import 'dart:io';

import 'package:image_cropper/image_cropper.dart' as c;
import 'package:image_picker/image_picker.dart';
import 'package:questra_app/imports.dart';

Future<List<File>> imagePicker(bool single) async {
  try {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      limit: 4,
      imageQuality: 70,
    );
    List<File> _selectedImages = [];

    for (final image in images) {
      _selectedImages = [..._selectedImages, File(image.path)];
    }

    return _selectedImages;
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

Future<File?> avatarPicker() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final croppedImage = await imageCropper(File(image.path));
      if (croppedImage != null) {
        return croppedImage;
      }
    }
    return null;
  } catch (e) {
    log(e.toString());
    rethrow;
  }
}

Future<File?> imageCropper(File imageFile) async {
  c.CroppedFile? croppedFile = await c.ImageCropper().cropImage(
    aspectRatio: c.CropAspectRatio(ratioX: 400, ratioY: 400),
    compressFormat: c.ImageCompressFormat.png,
    compressQuality: 70,
    sourcePath: imageFile.path,
    uiSettings: [
      c.AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: AppColors.primary,
        toolbarWidgetColor: AppColors.scaffoldBackground,
        aspectRatioPresets: [
          c.CropAspectRatioPreset.square,
        ],
      ),
    ],
  );
  if (croppedFile != null) {
    return File(croppedFile.path);
  }
  return null;
}
