import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/models_controller/chat_controller.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/controller/models_controller/exam_controller.dart';
import 'package:the_academy/main.dart';
import 'package:the_academy/model/course.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';
import 'package:chatview/chatview.dart' as chatview;

import '../../utils/app_contanants.dart';

class OneCourseOfMineScreenController extends GetxController
    with GetTickerProviderStateMixin {
  bool isOpend = false;
  late final AnimationController animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 10));
  final scrollController = ScrollController();
  RxString courseId = ''.obs;
  String title = '';
  String image = '';
  int _initTab = 0;
  CourseFullData? courseFullData;
  late TabController tabController;
  CourseController _courseController = Get.find();
  ExamController _examController = Get.find();
  ChatController _chatController = Get.find();
  UserController _userController = Get.find();

  var isLoading = false;

  static var chatTabIndex = 1;
  static var examTabIndex = 2;
  RxInt selectedIndex = 0.obs;
  get chatMessages => _chatController.coureChatMessages;

  bool get canEditCourse =>
      courseFullData!.coachId == userController.userId &&
      _userController.userCanEditExams;

  UserController get userController => _userController;

  @override
  void onInit() {
    /* if (Get.arguments != null) {
      courseId.value = Get.arguments['id'];
      title = Get.arguments['title'];
      image = Get.arguments['image'];
      _initTab = Get.arguments['initTab'] ?? 0;
      selectedIndex.value = _initTab;
      update();
    } */
    tabController = TabController(
      initialIndex: selectedIndex.value,
      length: 3,
      vsync: this,
    );

    super.onInit();

    // Listen for changes to the productId
    ever(courseId, (_) {
      if (courseId.isNotEmpty) {
        getData();
      }
    });
  }

  Future<void> getData() async {
    currentCousrse = courseId.value;
    isLoading = true;
    update();
    // print('start isLoading');

    try {
      //   print('start getData');

      courseFullData = await _courseController.getCourseFullData(
          courseId.value, userController.userId);
      // print('getCourseFullData');

      /*  title = Get.locale == Locale('ar')
          ? courseFullData!.nameAr
          : courseFullData!.nameEn;

      image = courseFullData!.image;
      update(); */
      //print('image');

      await _examController.fetchAndSetExams(0, courseId.value,
          isRefresh: true);
      // print('fetchAndSetExams');

      await _chatController.getCoureChatMessages(0,
          course: courseFullData, isRefresh: true);
      //   print('getCoureChatMessages');

      await _chatController.getFeedMessages(0,
          userId: _userController.userId,
          courseId: courseId.value,
          isRefresh: true);
      //print('getFeedMessages');

      isLoading = false;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr).then((_) => Get.back());
    } catch (error) {
      debugPrint('$error');
      showErrorDialog('error'.tr).then((_) => Get.back());
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    animationController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void toggleAnimation() {
    if (animationController.isDismissed) {
      FocusManager.instance.primaryFocus?.unfocus();

      //todo لأنو بينمسح اش كان عم يكتب
      changeTab(0);
      animationController.forward();
      isOpend = true;
    } else {
      animationController.reverse();
      isOpend = false;
    }

    update();
  }

  String initialSelectedTab() {
    if (_initTab == 0) return "feeds".tr;
    if (_initTab == 1) return "chat".tr;
    return "exams".tr;
  }

  void changeTab(int value) {
    selectedIndex.value = value;
    update();

    tabController.index = selectedIndex.value;
    update();
  }

  List<chatview.ChatUser> get chatUsers {
    List<chatview.ChatUser> users = [];
    if (courseFullData != null) {
      users.add(chatview.ChatUser(
          id: courseFullData!.coachId,
          name: courseFullData!.coachName,
          profilePhoto: courseFullData!.coachImage != ''
              ? '${AppConstants.imagesHost}/${courseFullData?.coachImage}'
              : null));
    }
    if (courseFullData?.users != null)
      for (var e in courseFullData!.users) {
        if (e.id != _userController.userId) {
          users.add(chatview.ChatUser(
              id: e.id,
              name: e.name,
              profilePhoto: e.profileImageUrl != ''
                  ? '${AppConstants.imagesHost}/${e.profileImageUrl}'
                  : null));
        }
      }

    return users;
  }

// Method to update productId when a new product is selected
  updateCourseId(String newCourseId, String title, String image,
      {int? initTab}) {
    if (courseId.value == newCourseId) {
      getData();
    }
    courseId.value = newCourseId;

    this.title = title;
    this.image = image;
    changeTab(initTab ?? _initTab);
    update();
  }

  @override
  void onClose() {
    // Reset or cleanup logic
    courseId = ''.obs;
    currentCousrse = null;
    isLoading = false;

    super.onClose();
  }
}
