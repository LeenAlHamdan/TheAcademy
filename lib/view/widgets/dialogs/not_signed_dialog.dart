import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/themes.dart';

void notSignedDialog({String? title, String? content}) {
  Get.defaultDialog(
      barrierDismissible: false,
      title: title ?? 'you_are_not_signed'.tr,
      middleText: content ?? 'sorry_you_are_not_signed'.tr,
      titleStyle: TextStyle(
          color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
      middleTextStyle: TextStyle(
          color: Get.isDarkMode ? Themes.primaryColorLightDark : null),
      textConfirm: 'sign_in'.tr,
      confirmTextColor: Themes.primaryColorLight,
      onConfirm: () {
        Get.offAllNamed('/welcome');
      });
}
