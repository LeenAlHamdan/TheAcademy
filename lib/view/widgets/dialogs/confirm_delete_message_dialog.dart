import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/themes.dart';

Future<bool?> confirmDeleteMessageDialog({String? title}) async {
  return await Get.defaultDialog(
    title: 'confirm'.tr,
    titleStyle: TextStyle(
        color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
    content: Text(
      title ?? 'do_you_want_to_delete_this_message'.tr,
      style: TextStyle(
          color: Get.isDarkMode ? Themes.primaryColorLightDark : null),
      textAlign: TextAlign.center,
    ),
    confirmTextColor: Themes.primaryColorLight,
    cancelTextColor: Get.isDarkMode ? Themes.textColorDark : null,
    onCancel: () {
      return null;
    },
    onConfirm: () {
      Get.back(result: true);
    },
    textCancel: 'cancel'.tr,
    textConfirm: 'delete'.tr,
  );
}
