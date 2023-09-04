import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/controller/screens_controllers/main_screen_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/custom_widgets/user_image.dart';
import 'package:the_academy/view/widgets/dialogs/confirm_sign_out_dialog.dart';

import '../../../locale/locale_controller.dart';
import '../../../utils/log_out_function.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userImage;
  final bool isCoach;
  final bool needPop;
  final screenController;
  final String selectedLabel;

  AppDrawer(
    this.userName,
    this.userImage,
    this.screenController, {
    this.needPop = false,
    required this.isCoach,
    this.selectedLabel = '',
  });
  final MyLocaleController localeController = Get.find();
  final MainScreenController mainScreenController = Get.find();
  final UserController userController = Get.find();
  final CourseController courseController = Get.find();

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawer = [
      DrawerItem(
        name: 'home'.tr,
        isSelected: selectedLabel == 'home',
        icon: Icon(
          Icons.home_outlined,
          color: Themes.primaryColorLight,
        ),
        onTap: () {
          if (needPop)
            Get.until((route) => route.isFirst);
          else
            screenController.toggleAnimation();

          mainScreenController.goToPage(0);
        },
      ),
      DrawerItem(
        name: 'my_account'.tr,
        isSelected: selectedLabel == 'my_account',
        icon: SvgPicture.asset(
          'assets/images/user_image.svg',
          color: Themes.primaryColorLight,
        ),
        onTap: () {
          Get.toNamed('/profile-screen');
          /* if (needPop)
            Get.until((route) => route.isFirst);
          else
            screenController.toggleAnimation();

          mainScreenController.goToPage(3); */
        },
      ),
      DrawerItem(
        name: 'categories'.tr,
        isSelected: selectedLabel == 'categories',
        icon: SvgPicture.asset(
          'assets/images/settings_image.svg',
          color: Themes.primaryColorLight,
        ),
        onTap: () {
          Get.toNamed('/categories-screen');

          /*  if (needPop)
            Get.until((route) => route.isFirst);
          else
            screenController.toggleAnimation();

          mainScreenController.goToPage(2); */
        },
      ),
      DrawerItem(
        name: 'courses'.tr,
        isSelected: selectedLabel == 'courses',
        icon: SvgPicture.asset(
          'assets/images/cources_image.svg',
          color: Themes.primaryColorLight,
        ),
        onTap: () {
          if (needPop)
            Get.until((route) => route.isFirst);
          else
            screenController.toggleAnimation();

          mainScreenController.goToPage(1);
        },
      ),
      DrawerItem(
        name: 'exams'.tr,
        isSelected: selectedLabel == 'exams',
        icon: SvgPicture.asset(
          'assets/images/exams_image.svg',
          color: Themes.primaryColorLight,
        ),
        onTap: () {
          if (needPop)
            Get.until((route) => route.isFirst);
          else
            screenController.toggleAnimation();

          mainScreenController.goToPage(2);
          /*     screenController.toggleAnimation();
          Get.toNamed('/my-exams-screen'); */
        },
      ),
      DrawerItem(
        name: 'my_courses_title'.tr,
        isSelected: selectedLabel == 'my_courses_title',
        icon: Icon(
          Icons.book_outlined,
          color: Themes.primaryColorLight,
        ),
        onTap: () {
          screenController.toggleAnimation();

          Get.toNamed('/courses-list-screen');
        },
      ),
      if (isCoach)
        DrawerItem(
          name: 'my_own_courses_title'.tr,
          isSelected: selectedLabel == 'my_own_courses_title',
          icon: Icon(
            Icons.book_outlined,
            color: Themes.primaryColorLight,
          ),
          onTap: () {
            screenController.toggleAnimation();

            Get.toNamed('/coach-courses-list-screen');
          },
        ),
      if (!isCoach)
        DrawerItem(
          name: 'subscriptions'.tr,
          isSelected: selectedLabel == 'subscriptions',
          icon: SvgPicture.asset(
            'assets/images/subscriptions_icon.svg',
            color: Themes.primaryColorLight,
          ),
          onTap: () {
            screenController.toggleAnimation();
            Get.toNamed('/subscribe', arguments: {
              'canPop': true,
            });
          },
        ),
      DrawerItem(
        name: 'my_exams'.tr,
        isSelected: selectedLabel == 'my_exams',
        icon: SvgPicture.asset(
          'assets/images/exams_image.svg',
          color: Themes.primaryColorLight,
        ),
        onTap: () {
          screenController.toggleAnimation();
          Get.toNamed('/my-exams-screen');
        },
      ),
      DrawerItem(
        name: 'my_chats'.tr,
        isSelected: selectedLabel == 'my_chats',
        icon: SvgPicture.asset(
          'assets/images/message_icon.svg',
          color: Themes.primaryColorLight,
        ),
        onTap: () {
          /*  screenController.toggleAnimation();
          Get.toNamed('/my-chats-screen'); */
          if (needPop)
            Get.until((route) => route.isFirst);
          else
            screenController.toggleAnimation();

          mainScreenController.goToPage(3);
        },
      ),
    ];
    return Padding(
      padding: EdgeInsets.only(
        top: Get.height * 0.043,
        left: Get.width * 0.07,
        right: Get.width * 0.07,
      ),
      child: SingleChildScrollView(
        child: SizedBox(
          height: Get.height * 0.95,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: Get.height * 0.043,
                ),
                child: Row(
                  children: [
                    UserImage(
                      userImage,
                      withHost: true,
                      color: Themes.primaryColorLight,
                      onTap: () {
                        Get.toNamed('/profile-screen');

                        /*  if (needPop)
                          Get.until((route) => route.isFirst);
                        else
                          screenController.toggleAnimation();

                        mainScreenController.goToPage(3); */
                      },
                    ),
                    SizedBox(
                      width: Get.width * 0.04,
                    ),
                    Text(
                      userName,
                      style: Get.textTheme.titleMedium
                          ?.copyWith(color: Themes.primaryColorLight),
                    )
                  ],
                ),
              ),
              ListView.builder(
                  itemCount: drawer.length,
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    return InkWell(
                      onTap: () => drawer[index].onTap(),
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        color: drawer[index].isSelected
                            ? Themes.primaryColorLight.withOpacity(0.2)
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: drawer[index].icon,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: Get.width / 3,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    drawer[index].name,
                                    style: Get.textTheme.titleMedium?.copyWith(
                                        color: Themes.primaryColorLight),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
              Spacer(),
              GestureDetector(
                onTap: () async {
                  await confirmSignOutDialog(
                    signOut: () async {
                      screenController.toggleAnimation();

                      await logOutFunction(userController,
                          courseController.myCoursesIds, localeController);
                    },
                  );
                  /*  if (!userController.userIsSigned) {
                    mainScreenController.goToPage(0);
                  } else {
                    //     Get.offAllNamed('/welcome');
                  } */
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: Get.height * 0.043,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Themes.primaryColorLight,
                      ),
                      SizedBox(
                        width: Get.width * 0.025,
                      ),
                      Text(
                        'log_out'.tr,
                        style: Get.textTheme.titleMedium
                            ?.copyWith(color: Themes.primaryColorLight),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerItem {
  final String name;
  final Widget icon;
  final Function onTap;
  final bool isSelected;
  const DrawerItem({
    required this.name,
    required this.icon,
    required this.onTap,
    required this.isSelected,
  });
}
