import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/controller/screens_controllers/home_page_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/load_more_horizontal_widget.dart';
import 'package:the_academy/view/widgets/lists_items/category_item.dart';
import 'package:the_academy/view/widgets/lists_items/course_item.dart';

import '../../widgets/custom_widgets/empty_widget.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomePageController>(
      init: HomePageController(),
      builder: (screenController) => RefreshIndicator(
        onRefresh: () => screenController.refreshData(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: Get.width * 0.025,
                  right: Get.width * 0.025,
                  top: Get.height * 0.035,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${'transform_your_life_through'.tr}',
                        style: Get.textTheme.headlineMedium?.copyWith(
                            color: Get.isDarkMode
                                ? Themes.textColorDark
                                : Themes.textColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      'education'.tr,
                      textAlign: TextAlign.center,
                      style: Get.textTheme.headlineMedium?.copyWith(
                          foreground: Paint()
                            ..shader = Themes.linearGradientShader),
                    ),
                  ],
                ),
              ),
              screenController.userController.isUser
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: Get.height * 0.017,
                      ),
                      child: GestureDetector(
                        onTap: () => Get.toNamed('/subscribe', arguments: {
                          'canPop': true,
                        }),
                        child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            elevation: 0,
                            color: Get.isDarkMode
                                ? Themes.primaryColorLight
                                : Themes.primaryColorDark.withOpacity(0.2),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: Get.height * 0.026,
                                horizontal: Get.width * 0.061,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: Get.width * 0.53,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'want_to_train'.tr,
                                          textAlign: TextAlign.start,
                                          style: Get.textTheme.headlineSmall
                                              ?.copyWith(
                                                  color: Themes.textColor,
                                                  fontWeight:
                                                      FontWeight.normal),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: Get.height * 0.005,
                                          ),
                                          child: Text(
                                            'want_to_train_subtitle'.tr,
                                            textAlign: TextAlign.start,
                                            style: Get.textTheme.titleLarge
                                                ?.copyWith(
                                                    color:
                                                        Themes.primaryColorDark,
                                                    fontWeight:
                                                        FontWeight.normal),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    height: Get.height * 0.054,
                                    width: Get.height * 0.054,
                                    decoration: BoxDecoration(
                                        color: Themes.primaryColor,
                                        border: Border.all(
                                          color: Get.isDarkMode
                                              ? Themes.primaryColorLight
                                              : Themes.primaryColorDark
                                                  .withAlpha(50),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(0, 10),
                                            blurRadius: 24,
                                            color: Get.isDarkMode
                                                ? Themes.primaryColorLight
                                                : Themes.primaryColorDark
                                                    .withOpacity(0.2),
                                          ),
                                        ],
                                        shape: BoxShape.circle),
                                    child: ClipOval(
                                      child: Icon(Icons.arrow_forward_ios,
                                          size: Get.height * 0.02,
                                          color: Themes.primaryColorLight),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    )
                  : SizedBox(),
              Column(
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: Get.height * 0.028,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('categories'.tr,
                                  style: Get.textTheme.headlineSmall?.copyWith(
                                      color: Get.isDarkMode
                                          ? Themes.textColorDark
                                          : Themes.textColor,
                                      fontWeight: FontWeight.normal)),
                              GestureDetector(
                                onTap: () => Get.toNamed(
                                    '/categories-screen') /* screenController
                                    .mainScreenController
                                    .goToPage(2) */
                                ,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  height: Get.height * 0.047,
                                  width: Get.height * 0.047,
                                  decoration: BoxDecoration(
                                      color: Themes.primaryColorLight,
                                      border: Border.all(
                                        color: Get.isDarkMode
                                            ? Themes.primaryColorLight
                                            : Themes.primaryColorDark
                                                .withAlpha(50),
                                      ),
                                      shape: BoxShape.circle),
                                  child: ClipOval(
                                    child: SizedBox.fromSize(
                                      size: Size(Get.height * 0.022,
                                          Get.height * 0.022),
                                      child: SvgPicture.asset(
                                        'assets/images/more_icon.svg',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: Get.height * 0.028,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: screenController
                                  .horizontalCategoryScrollController,
                              child: Row(
                                children: [
                                  ...screenController
                                      .categoryController.categories
                                      .map((category) {
                                    return CategoryItem(
                                      category,
                                      category.id ==
                                          screenController.categoryController
                                              .categories.first.id,
                                      () => Get.toNamed('/subjects-screen',
                                          arguments: category),
                                    );
                                  }).toList(),
                                  screenController.loadMoreCategories
                                      ? const LoadMoreHorizontalWidget()
                                      : SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                  screenController.userController.userCanEditCourse &&
                          screenController
                              .courseController.coachCourses.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Get.height * 0.028,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('my_own_courses'.tr,
                                      style: Get.textTheme.headlineSmall
                                          ?.copyWith(
                                              color: Get.isDarkMode
                                                  ? Themes.textColorDark
                                                  : Themes.textColor,
                                              fontWeight: FontWeight.normal)),
                                  GestureDetector(
                                    onTap: () => Get.toNamed(
                                        '/coach-courses-list-screen'),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      height: Get.height * 0.047,
                                      width: Get.height * 0.047,
                                      decoration: BoxDecoration(
                                          color: Themes.primaryColorLight,
                                          border: Border.all(
                                            color: Get.isDarkMode
                                                ? Themes.primaryColorLight
                                                : Themes.primaryColorDark
                                                    .withAlpha(50),
                                          ),
                                          shape: BoxShape.circle),
                                      child: ClipOval(
                                        child: SizedBox.fromSize(
                                          size: Size(Get.height * 0.022,
                                              Get.height * 0.022),
                                          child: SvgPicture.asset(
                                            'assets/images/more_icon.svg',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: Get.height * 0.028,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: screenController
                                      .horizontalMyOwnCoursesScrollController,
                                  child: GetBuilder<CourseController>(
                                    builder: (_) => Row(
                                      children: [
                                        ...screenController
                                            .courseController.coachCourses
                                            .map((course) {
                                          return CourseItem(
                                            item: course,
                                            onLongTap: () {
                                              if (course.coachId ==
                                                      screenController
                                                          .userController
                                                          .userId &&
                                                  screenController
                                                      .userController
                                                      .userCanEditCourse)
                                                Get.toNamed(
                                                    '/add-course-screen',
                                                    arguments: {
                                                      "id": course.id,
                                                    });
                                            },
                                            onTap: () => screenController
                                                .mainScreenController
                                                .goToOneCourseScreen(
                                              courseId: course.id,
                                              title: Get.locale ==
                                                      const Locale('ar')
                                                  ? course.nameAr
                                                  : course.nameEn,
                                              image: course.image,
                                              isActive: course.active,
                                              isAccepted: course.accepted,
                                              userInTheCourse: course.coachId ==
                                                      screenController
                                                          .userController
                                                          .userId ||
                                                  course.users.firstWhereOrNull(
                                                        (element) =>
                                                            element ==
                                                            screenController
                                                                .userController
                                                                .userId,
                                                      ) !=
                                                      null,
                                            ),
                                            changeActive: screenController
                                                    .mainScreenController
                                                    .canToggleActiveCourse(
                                                        course.coachId)
                                                ? () => screenController
                                                        .mainScreenController
                                                        .toggleActiveCourse(
                                                      course.id,
                                                      course.active,
                                                    )
                                                : () {},
                                            isLoading: screenController
                                                    .mainScreenController
                                                    .isLoadingActiveCourse ==
                                                course.id,
                                          );
                                        }).toList(),
                                        screenController.loadMoreCoachCourses
                                            ? const LoadMoreHorizontalWidget()
                                            : SizedBox(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ))
                      : SizedBox(),
                  screenController.courseController.publicCourses.isEmpty
                      ? SizedBox()
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Get.height * 0.028,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('public_courses'.tr,
                                      style: Get.textTheme.headlineSmall
                                          ?.copyWith(
                                              color: Get.isDarkMode
                                                  ? Themes.textColorDark
                                                  : Themes.textColor,
                                              fontWeight: FontWeight.normal)),
                                  GestureDetector(
                                    onTap: () => screenController
                                        .mainScreenController
                                        .goToPage(1),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      height: Get.height * 0.047,
                                      width: Get.height * 0.047,
                                      decoration: BoxDecoration(
                                          color: Themes.primaryColorLight,
                                          border: Border.all(
                                            color: Get.isDarkMode
                                                ? Themes.primaryColorLight
                                                : Themes.primaryColorDark
                                                    .withAlpha(50),
                                          ),
                                          shape: BoxShape.circle),
                                      child: ClipOval(
                                        child: SizedBox.fromSize(
                                          size: Size(Get.height * 0.022,
                                              Get.height * 0.022),
                                          child: SvgPicture.asset(
                                            'assets/images/more_icon.svg',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: Get.height * 0.028,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: screenController
                                      .horizontalPublicCoursesScrollController,
                                  child: GetBuilder<CourseController>(
                                    builder: (_) => Row(
                                      children: [
                                        ...screenController
                                            .courseController.publicCourses
                                            .map((course) {
                                          return CourseItem(
                                            item: course,
                                            onLongTap: () {
                                              if (course.coachId ==
                                                      screenController
                                                          .userController
                                                          .userId &&
                                                  screenController
                                                      .userController
                                                      .userCanEditCourse)
                                                Get.toNamed(
                                                    '/add-course-screen',
                                                    arguments: {
                                                      "id": course.id,
                                                    });
                                            },
                                            onTap: () => screenController
                                                .mainScreenController
                                                .goToOneCourseScreen(
                                              courseId: course.id,
                                              title: Get.locale ==
                                                      const Locale('ar')
                                                  ? course.nameAr
                                                  : course.nameEn,
                                              image: course.image,
                                              isActive: course.active,
                                              isAccepted: course.accepted,
                                              userInTheCourse: course.coachId ==
                                                      screenController
                                                          .userController
                                                          .userId ||
                                                  course.users.firstWhereOrNull(
                                                        (element) =>
                                                            element ==
                                                            screenController
                                                                .userController
                                                                .userId,
                                                      ) !=
                                                      null,
                                            ),
                                            changeActive: screenController
                                                    .mainScreenController
                                                    .canToggleActiveCourse(
                                                        course.coachId)
                                                ? () => screenController
                                                        .mainScreenController
                                                        .toggleActiveCourse(
                                                      course.id,
                                                      course.active,
                                                    )
                                                : () {},
                                            isLoading: screenController
                                                    .mainScreenController
                                                    .isLoadingActiveCourse ==
                                                course.id,
                                          );
                                        }).toList(),
                                        screenController.loadMorePublicCourses
                                            ? const LoadMoreHorizontalWidget()
                                            : SizedBox(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                  Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: Get.height * 0.028,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('my_courses'.tr,
                                  style: Get.textTheme.headlineSmall?.copyWith(
                                      color: Get.isDarkMode
                                          ? Themes.textColorDark
                                          : Themes.textColor,
                                      fontWeight: FontWeight.normal)),
                              GestureDetector(
                                onTap: () =>
                                    Get.toNamed('/courses-list-screen'),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  height: Get.height * 0.047,
                                  width: Get.height * 0.047,
                                  decoration: BoxDecoration(
                                      color: Themes.primaryColorLight,
                                      border: Border.all(
                                        color: Get.isDarkMode
                                            ? Themes.primaryColorLight
                                            : Themes.primaryColorDark
                                                .withAlpha(50),
                                      ),
                                      shape: BoxShape.circle),
                                  child: ClipOval(
                                    child: SizedBox.fromSize(
                                      size: Size(Get.height * 0.022,
                                          Get.height * 0.022),
                                      child: SvgPicture.asset(
                                        'assets/images/more_icon.svg',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GetBuilder<CourseController>(
                            builder: (courseController) => Padding(
                              padding: EdgeInsets.only(
                                top: Get.height * 0.028,
                              ),
                              child: courseController.myCourses.isEmpty
                                  ? EmptyWidget(
                                      title: 'you_dont_have_courses_yet'.tr,
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: screenController
                                          .horizontalMyCoursesScrollController,
                                      child: GetBuilder<CourseController>(
                                        builder: (_) => Row(
                                          children: [
                                            ...courseController.myCourses
                                                .map((course) {
                                              return CourseItem(
                                                item: course,
                                                onLongTap: () {
                                                  if (course.coachId ==
                                                          screenController
                                                              .userController
                                                              .userId &&
                                                      screenController
                                                          .userController
                                                          .userCanEditCourse)
                                                    Get.toNamed(
                                                        '/add-course-screen',
                                                        arguments: {
                                                          "id": course.id,
                                                        });
                                                },
                                                onTap: () => screenController
                                                    .mainScreenController
                                                    .goToOneCourseScreen(
                                                  courseId: course.id,
                                                  title: Get.locale ==
                                                          const Locale('ar')
                                                      ? course.nameAr
                                                      : course.nameEn,
                                                  image: course.image,
                                                  isActive: course.active,
                                                  isAccepted: course.accepted,
                                                  userInTheCourse: course
                                                              .coachId ==
                                                          screenController
                                                              .userController
                                                              .userId ||
                                                      course.users
                                                              .firstWhereOrNull(
                                                            (element) =>
                                                                element ==
                                                                screenController
                                                                    .userController
                                                                    .userId,
                                                          ) !=
                                                          null,
                                                ),
                                                changeActive: screenController
                                                        .mainScreenController
                                                        .canToggleActiveCourse(
                                                            course.coachId)
                                                    ? () => screenController
                                                            .mainScreenController
                                                            .toggleActiveCourse(
                                                          course.id,
                                                          course.active,
                                                        )
                                                    : () {},
                                                isLoading: screenController
                                                        .mainScreenController
                                                        .isLoadingActiveCourse ==
                                                    course.id,
                                              );
                                            }).toList(),
                                            screenController.loadMoreMyCourses
                                                ? const LoadMoreHorizontalWidget()
                                                : SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
