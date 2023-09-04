import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/utils/get_double_number.dart';

import '../../../model/themes.dart';

Future<bool?> confirPaymentDialog(double price) async {
  return await Get.defaultDialog(
    title: 'confirm'.tr,
    titleStyle: TextStyle(
        color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
    middleText:
        '${'this_will_cost_you'.tr} ${getDoubleNumber(price)} ${'s.p'.tr}',
    textConfirm: 'continue'.tr,
    middleTextStyle:
        TextStyle(color: Get.isDarkMode ? Themes.primaryColorLightDark : null),
    onCancel: () {
      return null;
    },
    confirmTextColor: Themes.primaryColorLight,
    cancelTextColor: Get.isDarkMode ? Themes.textColorDark : null,
    onConfirm: () {
      Get.back(result: true);
    },
    textCancel: 'cancel'.tr,
  );
}
