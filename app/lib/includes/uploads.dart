

import 'dart:io';
import 'dart:ui';

import 'package:app/controllers/service_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:mime/mime.dart';

Future<File> resizeImage(File file, Size size) async {
  // File name
  final String name = file.path.split("/").last.toLowerCase();

  // Open the image
  Image? image = decodeImage(file.readAsBytesSync());

  // Resize the image
  if(image == null) return file;

  // Resize the image
  Image resized = copyResize(image, width: size.width.toInt());

  return File(file.path)..writeAsBytesSync(encodeJpg(resized));
}

Future<File?> filePicker({ type = FileType.image}) async {
  FilePickerResult? file = await FilePicker.platform.pickFiles(type: type, allowMultiple: false);
  if (file != null) {
    return File(file.files.single.path!);
  } else {
    return null;
  }
}

Future<String?> uploadFile(ServiceController services, File file, String path, String filename, String uid) async {

  // Creating reference
  Reference ref = services.storage.ref(path).child(filename);

  // Mime type
  final String? type = lookupMimeType(file.path.split("/").last.toLowerCase());

  // Metadata
  final metadata = SettableMetadata(
    contentType: type,
    customMetadata: {
      "uid": uid
    }
  );

  // Uploading file
  if (kIsWeb) {
    UploadTask task = ref.putData(await file.readAsBytes(), metadata);
    await Future.value(task);
  } else {
    UploadTask task = ref.putFile(File(file.path), metadata);
    await Future.value(task);
  }

  // Getting download url
  return ref.getDownloadURL();
}