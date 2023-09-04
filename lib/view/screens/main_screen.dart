import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/main_screen_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/bottom_navigation/bottom_bar_bubble.dart';
import 'package:the_academy/view/widgets/bottom_navigation/bottom_bar_item.dart';
import 'package:the_academy/view/widgets/custom_widgets/app_bar.dart';
import 'package:the_academy/view/widgets/custom_widgets/drawer.dart';
import 'package:the_academy/view/widgets/custom_widgets/loading_widget.dart';
import 'package:the_academy/view/widgets/dialogs/confirm_sign_out_dialog.dart';

import '../widgets/custom_widgets/error_widget.dart';
import 'main_screen_pages/all_exams_page.dart';
import 'main_screen_pages/courses_page.dart';
import 'main_screen_pages/home_page.dart';
import 'main_screen_pages/my_chats_page.dart';

class MainScreen extends StatelessWidget {
  final MainScreenController screenController = Get.find();

  @override
  Widget build(BuildContext context) {
    final rightSlide = Get.width * 0.6;
    //print(screenController.userController.token);

    return AnimatedBuilder(
        animation: screenController.animationController,
        builder: (context, child) {
          double slide =
              rightSlide * screenController.animationController.value;
          if (Get.locale == const Locale('ar')) slide *= -1;
          double scale = 1 - (screenController.animationController.value * 0.3);
          return WillPopScope(
            onWillPop: () async {
              if (screenController.isOpend) {
                screenController.toggleAnimation();
                return false;
              }
              confirmSignOutDialog();
              return false;
            },
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: Themes.primaryColor,
                  body: AppDrawer(
                    screenController.userController.currentUser.name,
                    screenController.userController.currentUser.profileImageUrl,
                    screenController,
                    isCoach: screenController.userController.userCanEditCourse,
                    selectedLabel: screenController.selectedLabel,
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
                      hasOnTap: true,
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.endFloat,
                    floatingActionButton: Obx(() {
                      return screenController.selectedIndex.value == 3 ||
                              screenController.selectedIndex.value == 2 ||
                              !screenController.userController.userCanEditCourse
                          ? SizedBox.shrink()
                          : FloatingActionButton(
                              heroTag: "btn1",
                              onPressed: () =>
                                  Get.toNamed('/add-course-screen'),
                              child: Icon(Icons.add),
                            );
                    }),
                    bottomNavigationBar: Obx(
                      () => BottomBarBubble(
                        isArabic: Get.locale == const Locale('ar'),
                        items: [
                          BottomBarItem(
                              iconBuilder: (_) => SvgPicture.asset(
                                    'assets/images/home_image.svg',
                                    color: Get.isDarkMode
                                        ? Themes.primaryColorLight
                                        : Themes.primaryColorDark,
                                  ),
                              label: 'home'.tr,
                              activeIconBuilder: (_) => SvgPicture.asset(
                                    'assets/images/home_image.svg',
                                    color: Themes.primaryColor,
                                  )),
                          BottomBarItem(
                            iconBuilder: (_) => SvgPicture.asset(
                              'assets/images/cources_image.svg',
                              color: Get.isDarkMode
                                  ? Themes.primaryColorLight
                                  : Themes.primaryColorDark,
                            ),
                            label: 'courses'.tr,
                            activeIconBuilder: (_) => SvgPicture.asset(
                              'assets/images/cources_image.svg',
                              color: Themes.primaryColor,
                            ),
                          ),
                          BottomBarItem(
                            iconBuilder: (_) => SvgPicture.asset(
                              'assets/images/exams_image.svg',
                              color: Get.isDarkMode
                                  ? Themes.primaryColorLight
                                  : Themes.primaryColorDark,
                            ),
                            label: 'exams'.tr,
                            activeIconBuilder: (_) => SvgPicture.asset(
                              'assets/images/exams_image.svg',
                              color: Themes.primaryColor,
                            ),
                          ),
                          BottomBarItem(
                            iconBuilder: (_) => SvgPicture.asset(
                              'assets/images/message_icon.svg',
                              color: Get.isDarkMode
                                  ? Themes.primaryColorLight
                                  : Themes.primaryColorDark,
                            ),
                            label: 'chats'.tr,
                            activeIconBuilder: (_) => SvgPicture.asset(
                              'assets/images/message_icon.svg',
                              color: Themes.primaryColor,
                            ),
                          ),
                        ],
                        backgroundColor: Get.isDarkMode
                            ? Themes.primaryColorDark
                            : Themes.primaryColorLight,
                        unSelectedColor: Get.isDarkMode
                            ? Themes.primaryColorLight
                            : Themes.primaryColorDark,
                        selectedIndex: screenController.selectedIndex.value,
                        onSelect: (index) => screenController.goToPage(index),
                      ),
                    ),
                    body: AbsorbPointer(
                      absorbing: screenController.isOpend,
                      child: GetBuilder<MainScreenController>(
                        builder: (_) => screenController.isLoading
                            ? LoadingWidget()
                            : SafeArea(
                                child: screenController.hasError
                                    ? MyErrorWidget(
                                        onPressed: screenController.refreshData,
                                      )
                                    : PageView(
                                        controller:
                                            screenController.pageController,
                                        physics: NeverScrollableScrollPhysics(),
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Get.width * 0.07),
                                            child: HomePage(),
                                          ),
                                          CoursesPage(),
                                          AllExamsPage(),
                                          MyChatsPage(),
                                          /*   Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Get.width * 0.07),
                                            child: ProfileScreen(),
                                          ), */
                                        ],
                                      ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
