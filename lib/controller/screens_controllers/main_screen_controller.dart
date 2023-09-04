import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/models_controller/category_controller.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/main.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import '../../utils/firebase_message_handler.dart';
import '../../utils/refresh.dart';
import '../../view/widgets/dialogs/confirm_change_active_dialog.dart';
import '../../view/widgets/dialogs/not_signed_dialog.dart';
import '../models_controller/generals_controller.dart';
import '../models_controller/permission_controller.dart';
import 'one_course_controller.dart';
import 'one_course_of_mine_screen_controller.dart';

class MainScreenController extends GetxController
    with GetTickerProviderStateMixin {
  final UserController _userController = Get.find();
  final CategoryController _categoryController = Get.find();
  final CourseController _courseController = Get.find();
  final PermissionController _permissionController = Get.find();
  final GeneralsController _generalsController = Get.find();

  bool hasError = false;
  RxBool hasSignedOut = false.obs;

  bool _loadData = false;

  String? isLoadingActiveCourse;

  bool isOpend = false;
  late PageController pageController;
  late final AnimationController animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 10));

  bool isLoading = false;

  RxInt selectedIndex = 0.obs;

  UserController get userController => _userController;

  updateLoadData(bool load) {
    _loadData = isLoading = load;
    update();
    if (_loadData) {
      getData();
    }
  }

  @override
  void onInit() {
    _loadData = isLoading = Get.arguments ?? false;

    pageController = PageController(
      initialPage: selectedIndex.value,
    );
    super.onInit();
    ever(hasSignedOut, (_) {
      if (hasSignedOut.value) {
        //print('hasSignedOut');
        Future.delayed(Duration.zero).then((value) async {
          notSignedDialog(
              title: 'you_are_loged_out'.tr, content: 'please_sign_in'.tr);
        });
      }
    });

    if (_loadData) {
      getData();
    }
  }

  Future<void> getData() async {
    isLoading = true;
    update();
    try {
      //print('main screen GetData');

      var userId = _userController.userId;

      await _categoryController.fetchAndSetCategories(0, isRefresh: true);
      //print('_categoryController');
      await _courseController.fetchAndSetCourses(0, isRefresh: true);
      //print('_courseController');
      await _courseController.fetchAndSetPublicCourses(0, isRefresh: true);
      //print('fetchAndSetPublicCourses');
      if (userController.userCanEditCourse)
        await _courseController.fetchAndSetCoachCourses(0, isRefresh: true);
      //print('fetchAndSetCoachCourses');

      await _courseController.fetchAndSetMyCourses(0, userId, isRefresh: true);
      //print('fetchAndSetMyCourses');
      MyApp.createSocketConnection();
      //print('createSocketConnection');

      final FirebaseMessaging messaging = Get.find();
      //await
      initFirebase(messaging);
      //print('initFirebase');

      //   if (userController.isUser || !userController.userIsSigned) {
      await _permissionController.fetchAndSetCoachPermission();
      // }
      await _generalsController.fetchAndSetGenerals();

      isLoading = false;
      selectedIndex.value = 0;

      update();
      // goToPage(0);
    } on HttpException catch (_) {
      hasError = true;
      isLoading = false;

      update();

      showErrorDialog('error'.tr);
    } catch (error) {
      debugPrint(error.toString());
      hasError = true;
      isLoading = false;

      update();

      showErrorDialog('error'.tr);
    }
  }

  void goToPage(int index) {
    selectedIndex.value = index;
    update();

    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
    update();
  }

  void toggleAnimation() {
    if (animationController.isDismissed) {
      animationController.forward();
      isOpend = true;
    } else {
      animationController.reverse();
      isOpend = false;
    }

    update();
  }

  String get selectedLabel {
    switch (selectedIndex.value) {
      case 0:
        return 'home';
      case 1:
        return 'courses';
      case 2:
        return 'exams';
      case 3:
        return 'my_chats';
      default:
        return 'home';
    }
  }

  bool canToggleActiveCourse(String coachId) {
    return _userController.userCanEditCourse &&
            coachId == _userController.userId
        ? true
        : false;
  }

  void toggleActiveCourse(String courseId, bool active) async {
    final result = await confirmChangeActiveDialog(active);
    if (result == null || !result) return;
    isLoadingActiveCourse = courseId;
    update();
    try {
      await _courseController.toggleActiveCourse(courseId, !active);
      isLoadingActiveCourse = null;
      update();
    } on HttpException catch (_) {
      var errorMessage = 'error'.tr;

      isLoadingActiveCourse = null;
      update();
      showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'error'.tr;

      isLoadingActiveCourse = null;
      update();
      showErrorDialog(
        errorMessage,
      );
    }
  }

  void goToOneCourseScreen({
    required String courseId,
    required String title,
    required String image,
    required bool isActive,
    required bool isAccepted,
    required bool userInTheCourse,
  }) {
    if (isActive && isAccepted && userInTheCourse) {
      //print('oneCourseOfMineScreenController');
      final oneCourseOfMineScreenController =
          Get.put(OneCourseOfMineScreenController());
      (oneCourseOfMineScreenController).updateCourseId(courseId, title, image);
      // print('updateCourseId mine mainScreen');
      /* oneCourseOfMineScreenController.setArgumentData({
        'title': title,
        'id': courseId,
        'image': image,
      }); */
      Get.toNamed(
        '/one-course-of-mine-screen',
        /* arguments: {
          'title': title,
          'id': courseId,
          'image': image,
        }, */
      );
    } else {
      //print('oneCourseScreenController');
      final oneCourseScreenController = Get.put(OneCourseScreenController());
      (oneCourseScreenController).updateCourseId(courseId);
      //print('updateCourseId mainScreen');
      Get.toNamed(
        '/one-course-screen', /* arguments: {'id': courseId} */
      );
    }
  }

  Future<void> refreshData() async {
    isLoading = true;
    hasError = false;

    update();
    try {
      await refreshDataFunction(
        _userController,
        categoryController: _categoryController,
        courseController: _courseController,
        refreshAll: true,
        //generalsController: Get.find(),
        //permissionController: Get.find(),
      );
      isLoading = false;
      selectedIndex.value = 0;

      update();
    } on HttpException catch (_) {
      hasError = true;
      isLoading = false;

      update();

      showErrorDialog('error'.tr);
    } catch (error) {
      debugPrint('$error');
      hasError = true;
      isLoading = false;

      update();
      showErrorDialog('error'.tr);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
