import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:the_academy/model/themes.dart';

void confirmLeaveTheCourseDialog(
  Function onConfirm, {
  String? title,
  String? confirm,
  String? cancel,
}) {
  Get.defaultDialog(
    title: 'confirm'.tr,
    titleStyle: TextStyle(
        color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
    content: Text(
      title ?? 'you_really_want_leave'.tr,
      style: TextStyle(
          color: Get.isDarkMode ? Themes.primaryColorLightDark : null),
      textAlign: TextAlign.center,
    ),
    textConfirm: confirm ?? 'exit'.tr,
    confirmTextColor: Themes.primaryColorLight,
    cancelTextColor: Get.isDarkMode ? Themes.textColorDark : null,
    onConfirm: () {
      Get.back();
      onConfirm();
    },
    textCancel: cancel ?? 'stay'.tr,
  );
}
