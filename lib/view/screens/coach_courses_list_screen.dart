import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/app_bar.dart';
import 'package:the_academy/view/widgets/custom_widgets/load_more_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/loading_widget.dart';
import 'package:the_academy/view/widgets/lists_items/course_item.dart';
import 'package:the_academy/view/widgets/searchbar_animation/searchbar.dart';

import '../../controller/screens_controllers/coach_courses_list_screen_controller .dart';
import '../widgets/custom_widgets/empty_widget.dart';
import '../widgets/searchbar_animation/const/colours.dart';
import '../widgets/searchbar_animation/const/dimensions.dart';

class CoachCoursesListScreen extends StatelessWidget {
  CoachCoursesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoachCoursesListScreenController>(
      init: CoachCoursesListScreenController(),
      builder: (screenController) => Scaffold(
        appBar: MyAppBar(
          title: Text('my_own_courses_title'.tr,
              textAlign: TextAlign.center,
              style: Get.textTheme.titleLarge?.copyWith(
                  color:
                      Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
                  fontWeight: FontWeight.bold)),
          isUserImage: true,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios_outlined,
              color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
            ),
          ),
          hasOnTap: true,
        ),
        body: SafeArea(
          child: Container(
            constraints: BoxConstraints(
              minHeight: Get.height,
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Get.width * 0.07,
                  ),
                  child: RefreshIndicator(
                    onRefresh: () => screenController.refreshData(),
                    child: SingleChildScrollView(
                      controller: screenController.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Themes.primaryColorLight,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColours.black26,
                                  spreadRadius: -Dimensions.d10,
                                  blurRadius: Dimensions.d10,
                                  offset: Offset(Dimensions.d0, Dimensions.d10),
                                ),
                              ],
                            ),
                            width: Get.width / 2.5,
                            child: DropdownButton<String>(
                              items: screenController.dropDownFilterSpinner
                                  .map((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: screenController
                                                  .dropDownFilterValue ==
                                              value
                                          ? Themes.primaryColor
                                          : null,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    width: Get.width / 2.5,
                                    child: Text(value.tr,
                                        style: Get.theme.textTheme.titleLarge
                                            ?.copyWith(
                                          color: screenController
                                                      .dropDownFilterValue ==
                                                  value
                                              ? Themes.primaryColorLight
                                              : Get.isDarkMode
                                                  ? Themes.textColorDark
                                                  : Themes.textColor,
                                        )),
                                  ),
                                );
                              }).toList(),
                              selectedItemBuilder: (context) => screenController
                                  .dropDownFilterSpinner
                                  .map((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Text(value.tr,
                                        style: Get.theme.textTheme.titleLarge
                                            ?.copyWith(
                                          color: screenController
                                                      .dropDownFilterValue ==
                                                  value
                                              ? Themes.textColor
                                              : Get.isDarkMode
                                                  ? Themes.textColorDark
                                                  : Themes.textColor,
                                        )),
                                  ),
                                );
                              }).toList(),
                              icon: Icon(Icons.arrow_drop_down,
                                  color:
                                      Get.isDarkMode ? Themes.textColor : null),
                              elevation: 2,
                              underline: SizedBox(),
                              style: const TextStyle(color: Colors.deepPurple),
                              isExpanded: true,
                              onChanged: (value) =>
                                  screenController.onChangeFilterValue(value),
                              value: screenController.dropDownFilterValue,
                            ),
                          ),
                          screenController.isLoading
                              ? LoadingWidget()
                              : screenController.courseList.isEmpty
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: screenController.isSearching
                                              ? Get.height * 0.1
                                              : 8),
                                      child: EmptyWidget(
                                        title: screenController
                                                    .dropDownFilterValue ==
                                                screenController.defaultFilter
                                            ? 'you_dont_own_any_courses_yet'.tr
                                            : null,
                                      ),
                                    )
                                  : GetBuilder<CourseController>(
                                      builder: (_) => ListView.builder(
                                        itemCount:
                                            screenController.courseList.length,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical:
                                                screenController.isSearching
                                                    ? Get.height * 0.1
                                                    : 2),
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (_, index) {
                                          var course = screenController
                                              .courseList[index];
                                          return CourseItem(
                                            item: course,
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
                                                      'id': course.id
                                                    });
                                            },
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
                                            fitWidth: true,
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
                  left: Get.locale == const Locale('ar')
                      ? null
                      : Get.width * 0.04,
                  right: Get.locale == const Locale('ar')
                      ? Get.width * 0.04
                      : null,
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
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: !screenController.userController.userCanEditCourse
            ? null
            : FloatingActionButton(
                heroTag: "btn3",
                onPressed: () => Get.toNamed('/add-course-screen'),
                child: Icon(Icons.add),
              ),
      ),
    );
  }
}
