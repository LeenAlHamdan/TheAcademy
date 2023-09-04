import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';

Future<void> showErrorDialog(
  String message, {
  String? title,
  bool cancel = false,
}) async {
  return Get.defaultDialog(
    title: title ?? 'error_title'.tr,
    titleStyle: TextStyle(
        color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
    content: Text(
      message,
      style: TextStyle(
          color: Get.isDarkMode ? Themes.primaryColorLightDark : null),
      textAlign: TextAlign.center,
    ),
    textConfirm: 'okay'.tr,
    textCancel: cancel ? 'cancel'.tr : null,
    confirmTextColor: Themes.primaryColorLight,
    onConfirm: () => Get.back(),
    onCancel: cancel
        ? () {
            Get.back();
          }
        : null,
  );
}
