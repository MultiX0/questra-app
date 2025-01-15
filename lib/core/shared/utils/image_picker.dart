import 'dart:developer';
import 'dart:io';

import 'package:hl_image_picker/hl_image_picker.dart';

Future<List<File>> imagePicker() async {
  try {
    final _picker = HLImagePicker();
    List<File> _selectedImages = [];

    final images = await _picker.openPicker(
      pickerOptions: HLPickerOptions(
        mediaType: MediaType.image,
        maxSelectedAssets: 3,
      ),
      cropping: true,
    );

    for (final image in images) {
      _selectedImages = [..._selectedImages, File(image.path)];
    }

    return _selectedImages;
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}
