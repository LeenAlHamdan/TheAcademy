// ignore_for_file: use_rethrow_when_possible

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/models_controller/generals_controller.dart';
import '../../controller/screens_controllers/show_privacy_plocity_controller.dart';
import '../../model/themes.dart';

class ShowPrivacyPlocityScreen extends StatelessWidget {
  final GeneralsController generalsController = Get.find();

  final bool fromMain;

  ShowPrivacyPlocityScreen({
    Key? key,
    this.fromMain = false,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShowPrivacyPlocityScreenController>(
      init: ShowPrivacyPlocityScreenController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('privacy_policy'.tr,
                  style: Get.textTheme.headlineSmall?.copyWith(
                      color: Get.isDarkMode
                          ? Themes.textColorDark
                          : Themes.textColor))),
          leading: fromMain
              ? null
              : IconButton(
                  onPressed: () => controller.backPressed(fromMain, false),
                  icon: Icon(Icons.arrow_back_ios_outlined,
                      color: Get.isDarkMode ? Themes.textColorDark : null),
                ),
          elevation: 2,
          backgroundColor: Get.isDarkMode
              ? Get.theme.colorScheme.background
              : Themes.primaryColorLight,
          centerTitle: true,
        ),
        bottomNavigationBar: fromMain
            ? Container(
                decoration: BoxDecoration(
                    border:
                        Border(top: BorderSide(color: Get.theme.focusColor))),
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: controller.agree,
                  child: Ink(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Themes.primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'agree'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, color: Themes.primaryColorLight),
                      ),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ),
              )
            : null,
        body: WillPopScope(
          onWillPop: () => controller.backPressed(fromMain, true),
          child: SingleChildScrollView(
            child: Container(
              //color: Theme.of(context).backgroundColor,
              padding: EdgeInsets.only(
                top: 15,
                left: Get.locale == const Locale('ar') ? 2 : 15,
                right: Get.locale == const Locale('ar') ? 15 : 2,
              ),
              child: Column(
                children: [
                  Text(generalsController.privacyPolicy,
                      style: Get.textTheme.headlineSmall?.copyWith(
                          color: Get.isDarkMode
                              ? Themes.primaryColorLight
                              : Themes.primaryColorDark)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
