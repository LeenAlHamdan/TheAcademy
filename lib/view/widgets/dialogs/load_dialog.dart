import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/loading_widget.dart';

Future<void> showLoadDialog() async {
  Get.defaultDialog(
    title: 'loading'.tr,
    titleStyle: TextStyle(
        color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
    content: LoadingWidget(
      isDefault: true,
    ),
    barrierDismissible: false,
    confirmTextColor: Themes.primaryColorLight,
  );
}
