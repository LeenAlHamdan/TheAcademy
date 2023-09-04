import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/themes.dart';

Future<bool?> confirmChangeActiveDialog(bool active) async {
  return await Get.defaultDialog(
    title: 'confirm'.tr,
    titleStyle: TextStyle(
        color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
    content: Text(
      '${'the_course_status_will_change_from'.tr} ${active ? 'active'.tr : 'inactive'.tr} ${'to'.tr} ${active ? 'inactive'.tr : 'active'.tr}',
      style: TextStyle(
          color: Get.isDarkMode ? Themes.primaryColorLightDark : null),
      textAlign: TextAlign.center,
    ),
    onCancel: () {
      return null;
    },
    confirmTextColor: Themes.primaryColorLight,
    cancelTextColor: Get.isDarkMode ? Themes.textColorDark : null,
    onConfirm: () {
      Get.back(result: true);
    },
    textCancel: 'cancel'.tr,
    textConfirm: 'change'.tr,
  );
}
