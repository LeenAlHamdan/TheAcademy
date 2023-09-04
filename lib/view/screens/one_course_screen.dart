import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/one_course_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/model/user.dart';
import 'package:the_academy/utils/app_contanants.dart';
import 'package:the_academy/view/widgets/custom_widgets/load_more_horizontal_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/loading_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/user_image.dart';
import 'package:the_academy/view/widgets/dialogs/confirm_leave_the_course_dialog.dart';
import 'package:the_academy/view/widgets/lists_items/user_list_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/tap_widget.dart';

class OneCourseScreen extends StatelessWidget {
  OneCourseScreen({Key? key}) : super(key: key);
  final OneCourseScreenController screenController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OneCourseScreenController>(
      builder: (_) => Scaffold(
        resizeToAvoidBottomInset: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        body: SafeArea(
          child: GetBuilder<OneCourseScreenController>(
            builder: (_) => screenController.isLoading ||
                    screenController.courseFullData == null
                ? LoadingWidget()
                : WillPopScope(
                    onWillPop: screenController.onWillPop,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                                '${AppConstants.imagesHost}/${screenController.courseFullData!.image}',
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(15.0),
                                  ),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            placeholder: (context, url) =>
                                const LoadMoreHorizontalWidget(image: true),
                            fit: BoxFit.contain,
                            height: Get.height * 0.383,

                            //     height: widget.height,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Get.width * 0.07),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: Get.height * 0.033),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (!screenController.userIsTheCoach)
                                            screenController
                                                .showUserInformation(CourseUser(
                                              id: screenController
                                                  .courseFullData!.coachId,
                                              profileImageUrl: screenController
                                                  .courseFullData!.coachImage,
                                              name: screenController
                                                  .courseFullData!.coachName,
                                              email: '',
                                              isOnline: false,
                                            ));
                                        },
                                        child: Row(
                                          children: [
                                            UserImage(
                                                screenController
                                                    .courseFullData!.coachImage,
                                                withHost: true),
                                            SizedBox(
                                              width: Get.width * 0.04,
                                            ),
                                            Text(
                                              screenController
                                                  .courseFullData!.coachName,
                                              style: Get.textTheme.titleMedium
                                                  ?.copyWith(
                                                color: Get.isDarkMode
                                                    ? Themes.textColorDark
                                                    : Themes.textColor,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            screenController
                                                    .courseFullData!.isPrivate
                                                ? Icons.lock
                                                : Icons.lock_open,
                                            color: Themes.offerColor,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: Get.height * 0.018),
                                  child: Text(
                                    Get.locale == const Locale('ar')
                                        ? screenController
                                            .courseFullData!.nameAr
                                        : screenController
                                            .courseFullData!.nameEn,
                                    style: Get.textTheme.headlineSmall
                                        ?.copyWith(
                                            color: Get.isDarkMode
                                                ? Themes.textColorDark
                                                : Themes.textColor),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: Get.height * 0.009),
                                  child: Text(
                                    Get.locale == const Locale('ar')
                                        ? screenController
                                            .courseFullData!.subjectNameAr
                                        : screenController
                                            .courseFullData!.subjectNameEn,
                                    style: Get.textTheme.titleLarge?.copyWith(
                                        color: Get.isDarkMode
                                            ? Themes.primaryColorLightDark
                                            : Themes.primaryColorDark),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: Get.height * 0.018),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: screenController
                                                .userController
                                                .userCanEditCourse
                                            ? () => screenController
                                                .toggleActiveCourse()
                                            : () {},
                                        icon: Icon(
                                          screenController
                                                      .courseFullData!.active &&
                                                  screenController
                                                      .courseFullData!.accepted
                                              ? Icons.offline_pin_rounded
                                              : Icons.pending_outlined,
                                          color: screenController
                                                      .courseFullData!.active &&
                                                  screenController
                                                      .courseFullData!.accepted
                                              ? Themes.offerColor
                                              : Get.isDarkMode
                                                  ? Themes.primaryColorLight
                                                  : Themes.primaryColorDark,
                                        ),
                                      ),
                                      Text(
                                          !screenController
                                                  .courseFullData!.accepted
                                              ? 'this_course_is_in_pending'.tr
                                              : !screenController
                                                      .courseFullData!.active
                                                  ? 'this_course_isnt_statred_yet'
                                                      .tr
                                                  : 'this_course_is_statred'.tr,
                                          style: Get.textTheme.titleMedium
                                              ?.copyWith(
                                            color: Get.isDarkMode
                                                ? Themes.gradientMerged
                                                : null,
                                          )),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: Get.height * 0.018),
                                  child: Text(
                                    'about_this_course'.tr,
                                    style: Get.textTheme.titleMedium
                                        ?.copyWith(color: Themes.primaryColor),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: Get.height * 0.009),
                                  child: Text(
                                    Get.locale == const Locale('ar')
                                        ? screenController
                                            .courseFullData!.descriptionAr
                                        : screenController
                                            .courseFullData!.descriptionEn,
                                    style: Get.textTheme.bodyLarge?.copyWith(
                                        color: Get.isDarkMode
                                            ? Themes.primaryColorLight
                                            : Themes.primaryColorDark),
                                  ),
                                ),
                                !screenController.courseFullData!.accepted ||
                                        screenController.userIsTheCoach
                                    ? SizedBox()
                                    : screenController.userInThisCourse
                                        ? Center(
                                            child: screenController
                                                    .isLoadingButton
                                                ? LoadingWidget(
                                                    isDefault: true,
                                                  )
                                                : ElevatedButton(
                                                    onPressed: () =>
                                                        confirmLeaveTheCourseDialog(
                                                            screenController
                                                                .leaveTheCourse),
                                                    child: Text(
                                                        'leave_the_course'.tr)),
                                          )
                                        : Center(
                                            child: screenController
                                                    .isLoadingButton
                                                ? LoadingWidget()
                                                : ElevatedButton(
                                                    onPressed: () =>
                                                        screenController
                                                            .askToJoin(),
                                                    child: Text(
                                                        'join_the_course'.tr)),
                                          ),
                                if (screenController.userInPending)
                                  Center(
                                    child: Text('your_request_is_pending'.tr,
                                        style:
                                            Get.textTheme.titleMedium?.copyWith(
                                          color: Get.isDarkMode
                                              ? Themes.gradientMerged
                                              : Themes.primaryColorDark,
                                        )),
                                  ),
                                (screenController.courseFullData!.isPrivate &&
                                            !screenController
                                                .userAcceptedInThisCourse &&
                                            (!screenController
                                                .userIsTheCoach)) ||
                                        (screenController.courseFullData!.users
                                                .isEmpty &&
                                            screenController.courseFullData!
                                                .pendingUsers.isEmpty &&
                                            !screenController
                                                .userInThisCourse) ||
                                        (!screenController.userIsTheCoach &&
                                            screenController
                                                .courseFullData!.users.isEmpty)
                                    ? SizedBox()
                                    : Padding(
                                        padding: EdgeInsets.only(
                                            top: Get.height * 0.018),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Container(
                                              height: Get.height * 0.071,
                                              decoration: BoxDecoration(
                                                color: Themes.primaryColorLight,
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                                border: Border.all(
                                                    width: 1.0,
                                                    color: Themes
                                                        .primaryColorDark
                                                        .withOpacity(0.1)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Themes
                                                        .primaryColorDark
                                                        .withOpacity(0.1),
                                                    offset: Offset(0, 16),
                                                    blurRadius: 20,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  screenController
                                                          .courseFullData!
                                                          .users
                                                          .isNotEmpty
                                                      ? TapWidget(
                                                          name: 'users'.tr,
                                                          tapsNum: 2,
                                                          isSelected:
                                                              screenController
                                                                      .selectedFilter ==
                                                                  'users',
                                                          image:
                                                              'assets/images/user_image.svg',
                                                          onTap: () =>
                                                              screenController
                                                                  .toggleSelectedFilter(
                                                                      'users'),
                                                        )
                                                      : SizedBox(),
                                                  screenController
                                                              .courseFullData!
                                                              .pendingUsers
                                                              .isNotEmpty &&
                                                          (screenController
                                                              .userIsTheCoach)
                                                      ? TapWidget(
                                                          tapsNum: 2,
                                                          name: 'pending_users'
                                                              .tr,
                                                          isSelected: screenController
                                                                  .selectedFilter ==
                                                              'pending_users',
                                                          image:
                                                              'assets/images/pending_image.svg',
                                                          onTap: () => screenController
                                                              .toggleSelectedFilter(
                                                                  'pending_users'),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              ),
                                            ),
                                            ...screenController
                                                .getUsersList()
                                                .map((e) => UserListWidget(
                                                      name: e.name,
                                                      image: e.profileImageUrl,
                                                      trailingImage:
                                                          screenController
                                                                      .selectedFilter ==
                                                                  'users'
                                                              ? Icons.check
                                                              : Icons
                                                                  .more_horiz,
                                                      onTap: () {
                                                        if (e.id !=
                                                            screenController
                                                                .userController
                                                                .userId)
                                                          screenController
                                                              .showUserInformation(
                                                                  e);
                                                      },
                                                      onLongTap: screenController
                                                              .userController
                                                              .userCanRemoveCourseUsers
                                                          ? screenController
                                                                      .selectedFilter ==
                                                                  'users'
                                                              ? () =>
                                                                  confirmLeaveTheCourseDialog(
                                                                    () => screenController
                                                                        .leaveTheCourse(
                                                                            userId:
                                                                                e.id),
                                                                    title:
                                                                        'are_you_sure_delete_the_user'
                                                                            .tr,
                                                                    confirm:
                                                                        'delete'
                                                                            .tr,
                                                                    cancel:
                                                                        'cancel'
                                                                            .tr,
                                                                  )
                                                              : () => screenController
                                                                  .attchFilePicker(
                                                                      e.id)
                                                          : null,
                                                    ))
                                                .toList(),
                                            SizedBox(
                                              height: Get.height * 0.018,
                                            )
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(top: Get.height * 0.037),
          child: FloatingActionButton(
            elevation: 0,
            heroTag: "one-course-back-btn",
            onPressed: () async {
              final result = await screenController.onWillPop();
              if (result) Get.back();
            },
            backgroundColor: Get.isDarkMode
                ? Themes.primaryColorDark
                : Themes.primaryColorLight,
            child: Icon(
              Icons.arrow_back_ios_outlined,
              color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
