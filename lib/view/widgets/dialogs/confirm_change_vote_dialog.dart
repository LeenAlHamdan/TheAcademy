import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/themes.dart';

Future<bool?> confirmChangeVoteDialog(String previousVote) async {
  return await Get.defaultDialog(
    title: 'confirm'.tr,
    titleStyle: TextStyle(
        color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
    content: Text(
      '${'your_pervious_vote'.tr} ($previousVote) ${'will_be_discard'.tr}',
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
    textConfirm: 'change'.tr,
  );
}
