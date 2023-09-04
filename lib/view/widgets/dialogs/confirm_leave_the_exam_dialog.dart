import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:the_academy/model/themes.dart';

void confirmLeaveTheExamDialog(Function onConfirm) {
  Get.defaultDialog(
    title: 'confirm'.tr,
    titleStyle: TextStyle(
        color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
    content: Text(
      'do_you_want_to_submit_your_answers'.tr,
      style: TextStyle(
          color: Get.isDarkMode ? Themes.primaryColorLightDark : null),
      textAlign: TextAlign.center,
    ),
    textConfirm: 'exit'.tr,
    confirmTextColor: Themes.primaryColorLight,
    cancelTextColor: Get.isDarkMode ? Themes.textColorDark : null,
    textCancel: 'stay'.tr,
    onConfirm: () {
      Get.back();
      onConfirm();
    },
  );
}
