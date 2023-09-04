import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/courses_page_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/load_more_horizontal_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/load_more_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/loading_widget.dart';
import 'package:the_academy/view/widgets/lists_items/course_item.dart';
import 'package:the_academy/view/widgets/searchbar_animation/searchbar.dart';

import '../../../controller/models_controller/course_controller.dart';
import '../../widgets/custom_widgets/empty_widget.dart';

class CoursesPage extends StatelessWidget {
  CoursesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoursesPageController>(
      init: CoursesPageController(),
      builder: (screenController) => Container(
        constraints: BoxConstraints(
          minHeight: Get.height,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Get.width * 0.07, vertical: Get.height * 0.05),
              child: screenController.isLoading
                  ? LoadingWidget()
                  : RefreshIndicator(
                      onRefresh: () => screenController.refreshData(),
                      child: SingleChildScrollView(
                        controller: screenController.scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        child: screenController.isSearching
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: Get.height * 0.05),
                                child: Column(
                                  children: [
                                    screenController
                                            .courseController.searched.isEmpty
                                        ? EmptyWidget()
                                        : GetBuilder<CourseController>(
                                            builder: (_) => ListView.builder(
                                              itemCount: screenController
                                                  .courseController
                                                  .searched
                                                  .length,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemBuilder: (_, index) {
                                                var course = screenController
                                                    .courseController
                                                    .searched[index];
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
                                                    userInTheCourse:
                                                        screenController
                                                            .userInTheCourse(
                                                                course),
                                                  ),
                                                  changeActive: screenController
                                                          .mainScreenController
                                                          .canToggleActiveCourse(
                                                              course.coachId)
                                                      ? () => screenController
                                                          .mainScreenController
                                                          .toggleActiveCourse(
                                                              course.id,
                                                              course.active)
                                                      : () {},
                                                  isLoading: screenController
                                                          .mainScreenController
                                                          .isLoadingActiveCourse ==
                                                      course.id,
                                                );
                                              },
                                            ),
                                          ),
                                    screenController.loadMoreCourses
                                        ? const LoadMoreWidget()
                                        : SizedBox()
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  screenController.userController
                                              .userCanEditCourse &&
                                          screenController.courseController
                                              .coachCourses.isNotEmpty
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: Get.height * 0.028,
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      'my_own_courses'.tr,
                                                      style: Get
                                                          .textTheme.headlineSmall
                                                          ?.copyWith(
                                                              color: Get
                                                                      .isDarkMode
                                                                  ? Themes
                                                                      .textColorDark
                                                                  : Themes
                                                                      .textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                  GestureDetector(
                                                    onTap: () => Get.toNamed(
                                                        '/coach-courses-list-screen'),
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      height:
                                                          Get.height * 0.047,
                                                      width: Get.height * 0.047,
                                                      decoration: BoxDecoration(
                                                          color: Themes
                                                              .primaryColorLight,
                                                          border: Border.all(
                                                            color: Get
                                                                    .isDarkMode
                                                                ? Themes
                                                                    .primaryColorLight
                                                                : Themes
                                                                    .primaryColorDark
                                                                    .withAlpha(
                                                                        50),
                                                          ),
                                                          shape:
                                                              BoxShape.circle),
                                                      child: ClipOval(
                                                        child:
                                                            SizedBox.fromSize(
                                                          size: Size(
                                                              Get.height *
                                                                  0.022,
                                                              Get.height *
                                                                  0.022),
                                                          child:
                                                              SvgPicture.asset(
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
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  controller: screenController
                                                      .horizontalMyOwnCoursesScrollController,
                                                  child: GetBuilder<
                                                      CourseController>(
                                                    builder: (_) => Row(
                                                      children: [
                                                        ...screenController
                                                            .courseController
                                                            .coachCourses
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
                                                                      "id": course
                                                                          .id,
                                                                    });
                                                            },
                                                            onTap: () =>
                                                                screenController
                                                                    .mainScreenController
                                                                    .goToOneCourseScreen(
                                                              courseId:
                                                                  course.id,
                                                              title: Get.locale ==
                                                                      const Locale(
                                                                          'ar')
                                                                  ? course
                                                                      .nameAr
                                                                  : course
                                                                      .nameEn,
                                                              image:
                                                                  course.image,
                                                              isActive:
                                                                  course.active,
                                                              isAccepted: course
                                                                  .accepted,
                                                              userInTheCourse:
                                                                  screenController
                                                                      .userInTheCourse(
                                                                          course),
                                                            ),
                                                            changeActive: screenController
                                                                    .mainScreenController
                                                                    .canToggleActiveCourse(
                                                                        course
                                                                            .coachId)
                                                                ? () =>
                                                                    screenController
                                                                        .mainScreenController
                                                                        .toggleActiveCourse(
                                                                      course.id,
                                                                      course
                                                                          .active,
                                                                    )
                                                                : () {},
                                                            isLoading: screenController
                                                                    .mainScreenController
                                                                    .isLoadingActiveCourse ==
                                                                course.id,
                                                          );
                                                        }).toList(),
                                                        screenController
                                                                .loadMoreCoachCourses
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
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: Get.height * 0.028,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('my_courses'.tr,
                                                  style: Get
                                                      .textTheme.headlineSmall
                                                      ?.copyWith(
                                                          color: Get.isDarkMode
                                                              ? Themes
                                                                  .textColorDark
                                                              : Themes
                                                                  .textColor,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                              GestureDetector(
                                                onTap: () => Get.toNamed(
                                                    '/courses-list-screen'),
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  height: Get.height * 0.047,
                                                  width: Get.height * 0.047,
                                                  decoration: BoxDecoration(
                                                      color: Themes
                                                          .primaryColorLight,
                                                      border: Border.all(
                                                        color: Get.isDarkMode
                                                            ? Themes
                                                                .primaryColorLight
                                                            : Themes
                                                                .primaryColorDark
                                                                .withAlpha(50),
                                                      ),
                                                      shape: BoxShape.circle),
                                                  child: ClipOval(
                                                    child: SizedBox.fromSize(
                                                      size: Size(
                                                          Get.height * 0.022,
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
                                            builder: (courseController) =>
                                                Padding(
                                              padding: EdgeInsets.only(
                                                top: Get.height * 0.028,
                                              ),
                                              child: courseController
                                                      .myCourses.isEmpty
                                                  ? EmptyWidget(
                                                      title:
                                                          'you_dont_have_courses_yet'
                                                              .tr,
                                                    )
                                                  : SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      controller: screenController
                                                          .horizontalScrollController,
                                                      child: GetBuilder<
                                                          CourseController>(
                                                        builder: (_) => Row(
                                                          children: [
                                                            ...courseController
                                                                .myCourses
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
                                                                          "id":
                                                                              course.id,
                                                                        });
                                                                },
                                                                onTap: () =>
                                                                    screenController
                                                                        .mainScreenController
                                                                        .goToOneCourseScreen(
                                                                  courseId:
                                                                      course.id,
                                                                  title: Get.locale ==
                                                                          const Locale(
                                                                              'ar')
                                                                      ? course
                                                                          .nameAr
                                                                      : course
                                                                          .nameEn,
                                                                  image: course
                                                                      .image,
                                                                  isActive: course
                                                                      .active,
                                                                  isAccepted: course
                                                                      .accepted,
                                                                  userInTheCourse:
                                                                      screenController
                                                                          .userInTheCourse(
                                                                              course),
                                                                ),
                                                                changeActive: screenController
                                                                        .mainScreenController
                                                                        .canToggleActiveCourse(course
                                                                            .coachId)
                                                                    ? () => screenController
                                                                        .mainScreenController
                                                                        .toggleActiveCourse(
                                                                            course.id,
                                                                            course.active)
                                                                    : () {},
                                                                isLoading: screenController
                                                                        .mainScreenController
                                                                        .isLoadingActiveCourse ==
                                                                    course.id,
                                                              );
                                                            }).toList(),
                                                            screenController
                                                                    .loadMoreMyCourses
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
                                  Text('courses'.tr,
                                      textAlign: TextAlign.start,
                                      style: Get.textTheme.headlineSmall
                                          ?.copyWith(
                                              color: Get.isDarkMode
                                                  ? Themes.textColorDark
                                                  : Themes.textColor,
                                              fontWeight: FontWeight.bold)),
                                  screenController
                                          .courseController.courses.isEmpty
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: Get.height * 0.05),
                                          child: EmptyWidget(),
                                        )
                                      : GetBuilder<CourseController>(
                                          builder: (_) => ListView.builder(
                                            itemCount: screenController
                                                .courseController
                                                .courses
                                                .length,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemBuilder: (_, index) {
                                              var course = screenController
                                                  .courseController
                                                  .courses[index];
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
                                                fitWidth: true,
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
                                                  userInTheCourse:
                                                      screenController
                                                          .userInTheCourse(
                                                              course),
                                                ),
                                                changeActive: screenController
                                                        .mainScreenController
                                                        .canToggleActiveCourse(
                                                            course.coachId)
                                                    ? () => screenController
                                                        .mainScreenController
                                                        .toggleActiveCourse(
                                                            course.id,
                                                            course.active)
                                                    : () {},
                                                isLoading: screenController
                                                        .mainScreenController
                                                        .isLoadingActiveCourse ==
                                                    course.id,
                                              );
                                            },
                                          ),
                                        ),
                                  screenController.loadMoreCourses
                                      ? const LoadMoreWidget()
                                      : SizedBox()
                                ],
                              ),
                      ),
                    ),
            ),
            Positioned(
              top: 0,
              left: Get.locale == const Locale('ar') ? null : Get.width * 0.04,
              right: Get.locale == const Locale('ar') ? Get.width * 0.04 : null,
              child: SearchBarAnimation(
                textEditingController: screenController.serchTextController,
                isOriginalAnimation: false,
                searchBoxWidth: Get.width - Get.width * 0.1,
                buttonBorderColour: Colors.black45,
                buttonWidget: Icon(
                  Icons.search,
                  color: Themes.textColor,
                ),
                secondaryButtonWidget:
                    Icon(Icons.close, color: Themes.textColor),
                trailingWidget: Icon(
                  Icons.search,
                  color: Themes.primaryColor,
                ),
                hintText: 'search'.tr,
                onPressButton: screenController.toggleSearch,
                textAlignToRight: Get.locale == const Locale('ar'),
                onChanged: screenController.onChangeSearchText,
                onFieldSubmitted: screenController.onChangeSearchText,
                onCollapseComplete: () {
                  Get.focusScope?.unfocus();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
