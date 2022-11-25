import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickFileFunction {
  static Text? _getRetrieveErrorWidget(_retrieveDataError) {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  static Widget previewImage(_retrieveDataError, _imageFile, _pickImageError) {
    final Text? retrieveError = _getRetrieveErrorWidget(_retrieveDataError);
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Semantics(
          label: 'image_picker_example_picked_images',
          child: Semantics(
            // Why network for web?
            // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
            label: 'image_picker_example_picked_image',
            child: kIsWeb
                ? Image.network(_imageFile.path)
                : Image.file(File(_imageFile.path)),
          ));
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  static Future onImageButtonPressed(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );
      return pickedFile;
    } catch (e) {
      return e.toString();
    }
  }
}
