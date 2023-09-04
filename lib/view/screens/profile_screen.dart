import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import 'package:the_academy/controller/screens_controllers/profile_page_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/switch.dart';
import 'package:the_academy/view/widgets/dialogs/confirm_sign_out_dialog.dart';
import 'package:the_academy/view/widgets/lists_items/profile_item_widget.dart';

import '../widgets/custom_widgets/app_bar.dart';
import '../widgets/custom_widgets/drawer.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rightSlide = Get.width * 0.6;
    return GetBuilder<ProfilePageController>(
      init: ProfilePageController(),
      builder: (screenController) => AnimatedBuilder(
          animation: screenController.animationController,
          builder: (context, child) {
            double slide =
                rightSlide * screenController.animationController.value;
            if (Get.locale == const Locale('ar')) slide *= -1;
            double scale =
                1 - (screenController.animationController.value * 0.3);

            return WillPopScope(
              onWillPop: () async {
                if (screenController.isOpend) {
                  screenController.toggleAnimation();
                  return false;
                }
                return true;
              },
              child: Stack(
                children: [
                  Scaffold(
                    backgroundColor: Themes.primaryColor,
                    body: AppDrawer(
                      screenController.userController.currentUser.name,
                      screenController
                          .userController.currentUser.profileImageUrl,
                      screenController,
                      isCoach:
                          screenController.userController.userCanEditCourse,
                      selectedLabel: 'my_account',
                      needPop: true,
                    ),
                  ),
                  Transform(
                    transform: Matrix4.identity()
                      ..translate(slide)
                      ..scale(scale),
                    alignment: Alignment.center,
                    child: Scaffold(
                      appBar: MyAppBar(
                        onMenuTap: () => screenController.toggleAnimation(),
                        isOpend: screenController.isOpend,
                        title: Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'hello'.tr,
                              style: Get.textTheme.titleMedium?.copyWith(
                                  color: Get.isDarkMode
                                      ? Themes.primaryColorLight
                                      : Themes.primaryColorDark),
                              children: <TextSpan>[
                                TextSpan(
                                    text: screenController
                                        .userController.currentUser.name
                                        .split(' ')
                                        .first,
                                    style: Get.textTheme.titleMedium?.copyWith(
                                        color: Get.isDarkMode
                                            ? Themes.primaryColorLight
                                            : Themes.primaryColorDark,
                                        fontWeight: FontWeight.bold)),
                                TextSpan(text: ' 👋!'),
                              ],
                            ),
                          ),
                        ),
                        isUserImage: true,
                        hasOnTap: false,
                      ),
                      body: AbsorbPointer(
                        absorbing: screenController.isOpend,
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: Get.height,
                          ),
                          child: Stack(
                            children: [
                              RefreshIndicator(
                                onRefresh: () => screenController.refreshData(),
                                child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Get.isDarkMode
                                                  ? Themes.primaryColorLight
                                                  : Themes.primaryColorDark
                                                      .withOpacity(0.25),
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            children: [
                                              Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: GestureDetector(
                                                      onLongPress:
                                                          screenController
                                                              .showPicker,
                                                      child: CircleAvatar(
                                                        radius: 50,
                                                        backgroundColor:
                                                            screenController
                                                                .getUserImageBackground,
                                                        child: screenController
                                                            .getUserImage,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: IconButton(
                                                      onPressed:
                                                          screenController
                                                              .showPicker,
                                                      icon: Icon(
                                                          Icons.add_a_photo,
                                                          size: 30,
                                                          color: Themes
                                                              .primaryColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0,
                                                    left: 8,
                                                    right: 8),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      screenController
                                                          .userController
                                                          .currentUser
                                                          .name,
                                                      style: Get.textTheme
                                                          .headlineSmall
                                                          ?.copyWith(
                                                              color: Themes
                                                                  .textColor),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                        screenController
                                                            .getUserType,
                                                        style: Get.textTheme
                                                            .titleLarge
                                                            ?.copyWith(
                                                          color: Themes
                                                              .primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ListTile(
                                          title: Text(
                                            'language'.tr,
                                            style: Get.textTheme.titleLarge
                                                ?.copyWith(
                                                    color: Get.isDarkMode
                                                        ? Themes
                                                            .primaryColorLightDark
                                                        : null,
                                                    fontWeight:
                                                        FontWeight.normal),
                                          ),
                                          trailing: MeySwitch(
                                            onText: 'ع',
                                            offText: 'E',
                                            onChange: (val) => screenController
                                                .toggleLanguage(val),
                                            initVal: Get.locale ==
                                                const Locale('ar'),
                                          ),
                                        ),
                                        ListTile(
                                          title: Text(
                                            'theme'.tr,
                                            style: Get.textTheme.titleLarge
                                                ?.copyWith(
                                                    color: Get.isDarkMode
                                                        ? Themes
                                                            .primaryColorLightDark
                                                        : null,
                                                    fontWeight:
                                                        FontWeight.normal),
                                          ),
                                          trailing: MeySwitch(
                                            isIcons: true,
                                            onIcon: Icons.brightness_4_outlined,
                                            offIcon: Icons.dark_mode_outlined,
                                            onColor: Themes.offerColor,
                                            offColor: Themes.primaryColorDark,
                                            awaitFun: true,
                                            onChange: (val) async {
                                              Get.changeTheme(
                                                Get.isDarkMode
                                                    ? ThemeData.light()
                                                    : ThemeData.dark(),
                                              );

                                              Get.changeThemeMode(
                                                val
                                                    ? ThemeMode.light
                                                    : ThemeMode.dark,
                                              );
                                              Get.toNamed('/splash');

                                              await screenController
                                                  .changeTheme(val);

                                              Restart.restartApp();

                                              //                            await Future.delayed(Duration(seconds: 2));
                                              //                            Get.back();
                                            },
                                            initVal: !Get.isDarkMode,
                                          ),
                                        ),
                                        ProfileItemWidget(
                                            title: 'change_password'.tr,
                                            onTap: () => screenController
                                                .changePaddwordDialog()),
                                        const Divider(
                                          thickness: 2,
                                          height: 2,
                                        ),
                                        ProfileItemWidget(
                                            title: 'transactions'.tr,
                                            onTap: () => Get.toNamed(
                                                '/transactions-screen')),
                                        if (!screenController
                                            .userController.userCanEditCourse)
                                          ProfileItemWidget(
                                              title: 'subscriptions'.tr,
                                              onTap: () => Get.toNamed(
                                                      '/subscribe',
                                                      arguments: {
                                                        'canPop': true,
                                                      })),
                                        ProfileItemWidget(
                                            title: 'privacy_policy'.tr,
                                            onTap: () => Get.toNamed(
                                                '/privacy-policy-screen')),
                                        ProfileItemWidget(
                                            title: 'about_us'.tr,
                                            onTap:
                                                screenController.aboutUsDialog),
                                        ProfileItemWidget(
                                            title: 'contact_us'.tr,
                                            onTap: screenController
                                                .contactUsDialog),
                                        const Divider(
                                          thickness: 2,
                                          height: 2,
                                        ),
                                        ProfileItemWidget(
                                            title: 'log_out'.tr,
                                            onTap: () async {
                                              await confirmSignOutDialog(
                                                signOut:
                                                    screenController.logOut,
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              screenController.isLoadingPass
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: Themes.primaryColor,
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
