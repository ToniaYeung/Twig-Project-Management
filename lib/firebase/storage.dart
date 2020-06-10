import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class Storage {
  final FirebaseStorage _storage;

  Storage(this._storage);

  Future<void> uploadTaskPhoto(String localFilePath, String taskId) async {
    File image = File(localFilePath);

    //A pointer to where it should be saved
    StorageReference reference = _storage.ref().child("$taskId/");

    StorageUploadTask uploadTask = reference.putFile(image);
    //Wait for the upload to finish
    await uploadTask.onComplete;
  }

  Future<String> getTaskPhoto(String taskId) async {
    // Create the local temporary file path
    Directory systemTempDirectory = Directory.systemTemp;
    String tempFilePath = "${systemTempDirectory.path}/$taskId.jpg";
    File tempFile = File(tempFilePath);

    if (tempFile.existsSync()) {
      //Deletes the current temp file, as it may be an old version.
      tempFile.deleteSync();
    }

    try {
      // Download the photo to that path
      await _downloadTaskPhoto(taskId, tempFile);
    } on PlatformException catch (_) {
      // Catch the exception from there not being a photo in storage to download
      // As there is no photo, just return an empty string instead of the temp file path
      return "";
    }

    // return the file path
    // with the image
    return tempFilePath;
  }

  Future<void> _downloadTaskPhoto(String taskId, File tempFile) async {
    StorageReference reference = _storage.ref().child("$taskId/");

    // The url will not be used, but we run this line so that it throws a
    // PlatformException if the task photo does not exist in the Firebase Storage
    await reference.getDownloadURL();

    await tempFile.create();

    // Creates the task to write the photograph into the file
    StorageFileDownloadTask downloadTask = reference.writeToFile(tempFile);
    // runs the task
    // Future here is specific to running StorageFileDownloadTask
    await downloadTask.future;
  }
}
