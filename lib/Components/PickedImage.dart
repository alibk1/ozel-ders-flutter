import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // kIsWeb için
import 'package:file_picker/file_picker.dart';

class PickedImage {
  final String? path;
  final Uint8List? bytes;

  PickedImage({this.path, this.bytes});
}

Future<PickedImage?> selectImage() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
  );
  if (result != null) {
    // Web platformunda bytes dolu olur, mobilde path dolu olur.
    return PickedImage(
      path: result.files.single.path,
      bytes: result.files.single.bytes,
    );
  }
  return null;
}
