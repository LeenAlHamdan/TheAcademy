import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/one_course_of_mine_screen_controller.dart';
import 'package:the_academy/main.dart';
import 'package:the_academy/model/themes.dart';
import '../../controller/screens_controllers/one_course_controller.dart';
import 'one_course_pages/feeds_page.dart';
import 'package:the_academy/view/widgets/custom_widgets/app_bar.dart';
import 'package:the_academy/view/widgets/custom_widgets/drawer.dart';
import 'package:the_academy/view/widgets/custom_widgets/loading_widget.dart';
import 'package:the_academy/view/widgets/motion_tab_bar/motion-badge.widget.dart';
import 'package:the_academy/view/widgets/motion_tab_bar/motion-tab-bar.dart';

import 'one_course_pages/chat_page.dart';
import 'one_course_pages/exams_page.dart';

class OneCourseOfMineScreen extends StatelessWidget {
  final OneCourseOfMineScreenController screenController = Get.find();

  OneCourseOfMineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //print(screenController.isLoading);
    final rightSlide = Get.width * 0.6;
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
              currentCousrse = null;

              return true;
            },
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: Themes.primaryColor,
                  body: SafeArea(
                    child: AppDrawer(
                      screenController.userController.currentUser.name,
                      screenController
                          .userController.currentUser.profileImageUrl,
                      screenController,
                      isCoach:
                          screenController.userController.userCanEditCourse,
                      needPop: true,
                    ),
                  ),
                ),
                Transform(
                    transform: Matrix4.identity()
                      ..translate(slide)
                      ..scale(scale),
                    alignment: Alignment.center,
                    child: GetBuilder<OneCourseOfMineScreenController>(
                      builder: (_) {
                        return Scaffold(
                          resizeToAvoidBottomInset: true,
                          appBar: MyAppBar(
                            onMenuTap: () => screenController.toggleAnimation(),
                            isOpend: screenController.isOpend,
                            title: Text(screenController.title,
                                textAlign: TextAlign.center,
                                style: Get.textTheme.titleLarge?.copyWith(
                                    color: Get.isDarkMode
                                        ? Themes.textColorDark
                                        : Themes.textColor,
                                    fontWeight: FontWeight.bold)),
                            image: screenController.image,
                            isUserImage: false,
                            onImageTap: () {
                              final oneCourseScreenController =
                                  Get.put(OneCourseScreenController());
                              //print('Get.put(OneCourseScreenController())');
                              (oneCourseScreenController).updateCourseId(
                                  screenController.courseId.value,
                                  isFromMine: true);
                              //print('updateCourseId oneCourse');

                              Get.toNamed(
                                '/one-course-screen', /* arguments: {
                              'id': screenController.courseId.value
                            } */
                              );
                            },
                          ),
                          body: SafeArea(
                              child: screenController.isLoading ||
                                      screenController.courseFullData == null
                                  ? Container(
                                      constraints: BoxConstraints(
                                          minHeight: Get.size.height,
                                          minWidth: Get.size.width),
                                      child: LoadingWidget())
                                  : AbsorbPointer(
                                      absorbing: screenController.isOpend,
                                      child: Scaffold(
                                        appBar: PreferredSize(
                                            child: Obx(
                                              () => Padding(
                                                padding: EdgeInsets.only(
                                                  top: Get.height * 0.02,
                                                ),
                                                child: MotionTabBar(
                                                  initialSelectedTab:
                                                      screenController
                                                          .initialSelectedTab(),
                                                  labels: [
                                                    "feeds".tr,
                                                    "chat".tr,
                                                    "exams".tr,
                                                  ],
                                                  icons: const [
                                                    Icons.feed_rounded,
                                                    Icons.chat_rounded,
                                                    Icons.list_alt_rounded,
                                                  ],
                                                  badges: [
                                                    const MotionBadgeWidget(
                                                      isIndicator: false,
                                                      color: Colors
                                                          .red, // optional, default to Colors.red
                                                      size:
                                                          5, // optional, default to 5,
                                                      show:
                                                          true, // true / false
                                                    ),
                                                    // Default Motion Badge Widget with indicator only
                                                    const MotionBadgeWidget(
                                                      isIndicator: true,
                                                      color: Colors
                                                          .red, // optional, default to Colors.red
                                                      size:
                                                          5, // optional, default to 5,
                                                      show:
                                                          false, // true / false
                                                    ),
                                                    // Default Motion Badge Widget with indicator only
                                                    const MotionBadgeWidget(
                                                      isIndicator: false,
                                                      color: Colors
                                                          .red, // optional, default to Colors.red
                                                      size:
                                                          5, // optional, default to 5,
                                                      show:
                                                          true, // true / false
                                                    ),
                                                  ],
                                                  tabSize: Get.height * 0.06,
                                                  tabBarHeight:
                                                      Get.height * 0.07,
                                                  textStyle: Get
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                          color: Themes
                                                              .primaryColorLight),
                                                  tabIconColor:
                                                      Themes.primaryColor,
                                                  tabIconSize:
                                                      Get.height * 0.035,
                                                  tabIconSelectedSize:
                                                      Get.height * 0.04,
                                                  tabSelectedColor:
                                                      Themes.offerColor,
                                                  tabIconSelectedColor:
                                                      Themes.primaryColorLight,
                                                  tabBarColor: Themes
                                                      .primaryColorDarkLighted,
                                                  useSafeArea: true,
                                                  selectedInd: screenController
                                                      .selectedIndex.value,
                                                  onTabItemSelected:
                                                      (int value) =>
                                                          screenController
                                                              .changeTab(value),
                                                ),
                                              ),
                                            ),
                                            preferredSize: Size.fromHeight(
                                                Get.height * 0.07 +
                                                    Get.height * 0.02)),
                                        body: TabBarView(
                                          physics:
                                              NeverScrollableScrollPhysics(), // swipe navigation handling is not supported
                                          controller:
                                              screenController.tabController,
                                          children: <Widget>[
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    top: Get.height * 0.02),
                                                child: FeedsPage(
                                                    screenController
                                                        .courseId.value,
                                                    screenController
                                                        .canEditCourse,
                                                    screenController
                                                            .courseFullData!
                                                            .coachId ==
                                                        screenController
                                                            .userController
                                                            .userId)),
                                            ChatPage(
                                              chatController: ChatController(
                                                initialMessageList:
                                                    screenController
                                                        .chatMessages,
                                                /* stream: screenController
                                                .socketService.getResponse
                                                .asBroadcastStream(), */
                                                // scrollController: screenController
                                                //     .scrollController,
                                                chatUsers:
                                                    screenController.chatUsers,
                                              ),
                                              course: screenController
                                                  .courseFullData,
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    top: Get.height * 0.02),
                                                child: ExamsPage(
                                                    screenController
                                                        .courseId.value,
                                                    screenController
                                                        .courseFullData!.nameAr,
                                                    screenController
                                                        .courseFullData!.nameEn,
                                                    screenController
                                                        .canEditCourse,
                                                    screenController
                                                            .courseFullData!
                                                            .coachId ==
                                                        screenController
                                                            .userController
                                                            .userId)),
                                          ],
                                        ),
                                      ),
                                    )),
                        );
                      },
                    )),
              ],
            ),
          );
        });
  }
}
