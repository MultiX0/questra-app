import 'dart:io';

import 'package:hl_image_picker/hl_image_picker.dart';

imagePicker() async {
  final _picker = HLImagePicker();
  List<File> _selectedImages = [];

  final images = await _picker.openPicker(
    pickerOptions: HLPickerOptions(mediaType: MediaType.image),
    cropping: true,
  );

  for (final image in images) {
    _selectedImages = [..._selectedImages, File(image.path)];
  }

  return _selectedImages;
}
