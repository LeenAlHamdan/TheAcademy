import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:the_academy/model/themes.dart';

import 'load_dialog.dart';

Future<void> confirmSignOutDialog({
  Function? signOut,
}) async {
  await Get.defaultDialog(
    title: 'confirm'.tr,
    titleStyle: TextStyle(
        color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
    content: Text(
      'we_will_miss_you'.tr,
      style: TextStyle(
          color: Get.isDarkMode ? Themes.primaryColorLightDark : null),
      textAlign: TextAlign.center,
    ),
    textConfirm: 'exit'.tr,
    confirmTextColor: Themes.primaryColorLight,
    cancelTextColor: Get.isDarkMode ? Themes.textColorDark : null,
    onConfirm: signOut != null
        ? () async {
            Get.back();
            showLoadDialog();

            await signOut();
            Get.back();
            Get.until((route) => route.isFirst);
            Get.offNamed('/welcome');
            //  Restart.restartApp();

            /*  Get.offUntil(
              MaterialPageRoute(builder: (context) => MyApp()),

            );

            Navigator.pushAndRemoveUntil(
              context,
            );
            //Get.clearRouteTree();
            //Get.offAllNamed('/welcome');
            Get.until((route) => route.isFirst); */
            //      Get.toNamed('/welcome');
          }
        : () {
            SystemNavigator.pop(); // Close the entire app

//            Get.back();
//            Get.clearRouteTree();
//            Navigator.of(context).pop();
//
            //SystemNavigator.pop();
            /*          _showLoadDialog();
                  final userProv =
                      Provider.of<UserProvider>(context, listen: false);

                  if (userProv.isAdmin()) {
                    await widget.fcm.unsubscribeFromTopic('admin_topic'.tr);
                  }
                  await widget.fcm.unsubscribeFromTopic(
                      '${userProv.userId}-${Get.locale!.languageCode}');
                  await signOut();

                   Get.back(),
                   
                  Navigator.of(context).pushReplacementNamed(
                      MainScreen.routeName,
                      arguments: {'signed': 'true'}); */
          },
    textCancel: 'stay'.tr,
    //onCancel: () => Get.back(),
  );
}
