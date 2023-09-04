import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/model/course.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import '../../model/themes.dart';
import '../../model/user.dart';
import '../../view/widgets/custom_widgets/user_image.dart';
import '../../view/widgets/dialogs/load_dialog.dart';
import 'chat_screen_controller.dart';

class OneCourseScreenController extends GetxController {
  RxString courseId = ''.obs;
  bool isFromMine = false;
  CourseFullData? courseFullData;
  String selectedFilter = 'users';
  var isLoading = false;
  var isLoadingButton = false;

  final CourseController _courseController = Get.find();
  final UserController _userController = Get.find();

  CourseController get courseController => _courseController;
  UserController get userController => _userController;

  @override
  void onInit() {
    /*  if (Get.arguments != null) {
      courseId.value = Get.arguments['id'];
      update();

      //courseId.value = Get.arguments;
    } */
    super.onInit();

    ever(courseId, (_) {
      if (courseId.isNotEmpty) {
        getData();
      }
    });
  }

  Future<void> getData() async {
    //print('getData');

    isLoading = true;
    update();
    try {
      // print('getCourseFullData');

      courseFullData = await _courseController.getCourseFullData(
          courseId.value, userController.userId);
      //   print('courseFullData?.nameAr');
      selectedFilter = courseFullData!.users.isEmpty &&
              (_userController.isAdmin ||
                  courseFullData!.coachId == _userController.userId)
          ? 'pending_users'
          : 'users';

      isLoading = false;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr).then((_) => Get.back());
    } catch (error) {
      showErrorDialog('error'.tr).then((_) => Get.back());
    }
  }

  toggleSelectedFilter(String value) {
    selectedFilter = value;
    update();
  }

  bool get userInThisCourse => userAcceptedInThisCourse || userInPending;

  bool get userAcceptedInThisCourse =>
      courseFullData!.users
          .firstWhereOrNull((user) => user.id == _userController.userId) !=
      null;

  bool get userInPending =>
      courseFullData!.pendingUsers
          .firstWhereOrNull((user) => user.id == _userController.userId) !=
      null;

  bool get userIsTheCoach => courseFullData!.coachId == userController.userId;

  List<CourseUser> getUsersList() {
    if (selectedFilter == 'users')
      return courseFullData!.users;
    else
      return courseFullData!.pendingUsers;
  }

  void askToJoin() async {
    isLoadingButton = true;
    update();
    try {
      await _courseController.askToJoinToCourse(courseId.value);
      courseFullData = await _courseController.getCourseFullData(
          courseId.value, userController.userId);
      await _courseController.fetchAndSetMyCourses(0, _userController.userId,
          isRefresh: true);
      if (!courseFullData!.isPrivate) {
        _courseController.updateCourseUsers(
            courseFullData!.id, _userController.userId, true);
      }

      Future.delayed(Duration(seconds: 1)).then(
        (value) {
          FirebaseMessaging.instance.subscribeToTopic(courseId.value);
          FirebaseMessaging.instance.subscribeToTopic(
              '${courseId.value}-${Get.locale!.languageCode}');
        },
      );

      isLoadingButton = false;
      update();
      Get.showSnackbar(GetSnackBar(
          backgroundColor: Themes.primaryColorDark,
          messageText: Text(
            'joined'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: Themes.primaryColorLight),
          ),
          duration: const Duration(seconds: 2)));
    } on HttpException catch (_) {
      var errorMessage = 'error'.tr;

      isLoadingButton = false;
      update();
      showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'error'.tr;

      isLoadingButton = false;
      update();
      showErrorDialog(
        errorMessage,
      );
    }
  }

  Future<void> leaveTheCourse({String? userId}) async {
    if (userId != null) {
      Get.back();
      showLoadDialog();
    } else {
      isLoadingButton = true;
      update();
    }
    try {
      if (userId == null) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(courseId.value);
        await FirebaseMessaging.instance
            .unsubscribeFromTopic('${courseId.value}-ar');
        await FirebaseMessaging.instance
            .unsubscribeFromTopic('${courseId.value}-en');
      }
      await _courseController.leaveTheCourse(
          courseId.value, userId ?? _userController.userId);

      courseFullData = await _courseController.getCourseFullData(
          courseId.value, userController.userId);
      if (userId == null) {
        await _courseController.fetchAndSetMyCourses(0, _userController.userId,
            isRefresh: true);
        _courseController.updateCourseUsers(
            courseFullData!.id, _userController.userId, false);
      } else {
        Get.back();
      }

      isLoadingButton = false;
      update();
      Get.showSnackbar(GetSnackBar(
          backgroundColor: Themes.primaryColorDark,
          messageText: Text(
            userId == null ? 'leaved'.tr : 'removed'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: Themes.primaryColorLight),
          ),
          duration: const Duration(seconds: 2)));
    } on HttpException catch (_) {
      var errorMessage = 'error'.tr;

      isLoadingButton = false;
      update();
      showErrorDialog(errorMessage);
      if (userId == null) {
        await FirebaseMessaging.instance.subscribeToTopic(courseId.value);
        await FirebaseMessaging.instance
            .subscribeToTopic('${courseId.value}-ar');
        await FirebaseMessaging.instance
            .subscribeToTopic('${courseId.value}-en');
      }
    } catch (error) {
      var errorMessage = 'error'.tr;

      isLoadingButton = false;
      update();
      showErrorDialog(
        errorMessage,
      );
      if (userId == null) {
        await FirebaseMessaging.instance.subscribeToTopic(courseId.value);
        await FirebaseMessaging.instance
            .subscribeToTopic('${courseId.value}-ar');
        await FirebaseMessaging.instance
            .subscribeToTopic('${courseId.value}-en');
      }
    }
  }

  Future<void> acceptUserInCourse(String userId) async {
    Get.back();
    showLoadDialog();
    try {
      await _courseController.acceptUserInCourse(courseId.value, userId);
      courseFullData = await _courseController.getCourseFullData(
          courseId.value, userController.userId);
      if (courseFullData!.pendingUsers.isEmpty) selectedFilter = 'users';
      update();
      Get.back();

      Get.showSnackbar(GetSnackBar(
          backgroundColor: Themes.primaryColorDark,
          messageText: Text(
            'accept-ed'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: Themes.primaryColorLight),
          ),
          duration: const Duration(seconds: 2)));
    } on HttpException catch (_) {
      var errorMessage = 'error'.tr;

      showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'error'.tr;

      showErrorDialog(
        errorMessage,
      );
    }
  }

  void toggleActiveCourse() async {
    if (courseFullData!.coachId != _userController.userId) return;
    isLoading = true;
    update();
    try {
      await _courseController.toggleActiveCourse(
          courseId.value, !courseFullData!.active);
      courseFullData!.active = !courseFullData!.active;
      isLoading = false;
      update();
    } on HttpException catch (_) {
      var errorMessage = 'error'.tr;

      isLoading = false;
      update();
      showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'error'.tr;

      isLoading = false;
      update();
      showErrorDialog(
        errorMessage,
      );
    }
  }

  Future<void> attchFilePicker(String userId) async {
    return await Get.bottomSheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              leading: Icon(Icons.add,
                  color: Get.isDarkMode ? Themes.textColor : null),
              title: Text('accept'.tr),
              onTap: () => acceptUserInCourse(userId)),
          ListTile(
              leading: Icon(Icons.remove,
                  color: Get.isDarkMode ? Themes.textColor : null),
              title: Text('remove'.tr),
              onTap: () => leaveTheCourse(userId: userId)),
        ],
      ),
      backgroundColor: Themes.primaryColorLight,
    );
    /*  WidgetsBinding.instance.addPostFrameCallback((_) {
      
    }); */
  }

  void showUserInformation(CourseUser e) {
    Get.bottomSheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              e.name,
              style: Get.textTheme.headlineSmall?.copyWith(
                  color:
                      Get.isDarkMode ? Themes.textColor : Themes.textColorDark,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                UserImage(
                  e.profileImageUrl,
                  size: Get.height * 0.1,
                  withHost: true,
                ),
                Positioned(
                  bottom: -2,
                  right: Get.locale == const Locale('ar') ? 4 : null,
                  left: Get.locale == const Locale('ar') ? null : 4,
                  child: Icon(
                    Icons.circle,
                    size: 14,
                    color: e.isOnline
                        ? Themes.greenColor
                        : Themes.primaryColorDark,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                final oneChatScreenController = Get.put(ChatScreenController());
                (oneChatScreenController).updateUserId(
                  e.id,
                  e.name,
                  e.profileImageUrl,
                );

                Get.toNamed(
                  '/chat-screen', /* arguments: {
                  'userId': e.id,
                  'title': e.name,
                  'image': e.profileImageUrl,
                } */
                );
              },
              child: Text(
                'start_chatting'.tr,
                style: Get.textTheme.titleLarge,
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Themes.primaryColorLight.withOpacity(0.5),
                  elevation: 2,
                  shadowColor: Themes.gradientColor2.withOpacity(0.5)),
            ),
          )
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 16,
      enableDrag: false,
      backgroundColor: Themes.customLightTheme.colorScheme.background,
      //Get.theme.colorScheme.background,
    );
  }

// Method to update productId when a new product is selected
  updateCourseId(
    String newCourseId, {
    bool isFromMine = false,
  }) {
    if (courseId.value == newCourseId) {
      getData();
    }
    this.isFromMine = isFromMine;
    courseId.value = newCourseId;
    update();
  }

  @override
  void onClose() {
    // Reset or cleanup logic
    courseId = ''.obs;
    isFromMine = false;
    super.onClose();
  }

  Future<bool> onWillPop() async {
    if (isFromMine && !userInThisCourse) {
      Get.back();
      Get.back();
      return false;
    }
    return true;
  }
}
