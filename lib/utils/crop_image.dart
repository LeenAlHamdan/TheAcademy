import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:image_cropper/image_cropper.dart';

Future<File?> cropingImage(
  File storedImage, {
  required Color primaryColor,
  required Color backgroundColor,
}) async {
  var result = (await ImageCropper().cropImage(
    sourcePath: storedImage.path,
    aspectRatioPresets: Platform.isAndroid
        ? [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ]
        : [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio5x3,
            CropAspectRatioPreset.ratio5x4,
            CropAspectRatioPreset.ratio7x5,
            CropAspectRatioPreset.ratio16x9
          ],
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'crop_image'.tr,
          toolbarColor: primaryColor,
          toolbarWidgetColor: backgroundColor,
          activeControlsWidgetColor: primaryColor,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      IOSUiSettings(
        title: 'crop_image'.tr,
      )
    ],
  ));
  return File(result != null ? result.path : '');
}
