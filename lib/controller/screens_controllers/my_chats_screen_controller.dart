import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../model/http_exception.dart';
import '../../services/user_controller.dart';
import '../../view/widgets/dialogs/confirm_delete_dialog.dart';
import '../../view/widgets/dialogs/error_dialog.dart';
import '../models_controller/chat_controller.dart';
import '../models_controller/course_controller.dart';

class MyChatsScreenController extends GetxController {
  final scrollController = ScrollController();
  String selectedFilter = 'courses';
  List<String> loadingItems = [];

  var isLoading = false;

  final ChatController _chatController = Get.find();
  final CourseController _courseController = Get.find();
  final UserController _userController = Get.find();

  bool _canLoadChats = true;
  bool _loadMoreChats = false;
  int _pageNumChats = 0;

  bool get loadMoreChats => _loadMoreChats && !_lastPageChats;
  bool get _lastPageChats =>
      _chatController.userPrivateChats.length ==
      _chatController.userPrivateChatsTotal;

  bool _canLoadCourses = true;
  bool _loadMoreCourses = false;
  int _pageNumCourses = 0;

  bool get loadMoreCourses => _loadMoreCourses && !_lastPageCourses;
  bool get _lastPageCourses =>
      _courseController.myCourses.length == _courseController.myCoursesTotal;

  bool _canLoadCoachCourses = true;
  bool _loadMoreCoachCourses = false;
  int _pageNumCoachCourses = 0;

  bool get loadMoreCoachCourse =>
      _loadMoreCoachCourses && !_lastPageCoachCourse;
  bool get _lastPageCoachCourse =>
      _courseController.coachCourses.length ==
      _courseController.coachCoursesTotal;

  bool get isEmpty => itemList.isEmpty;
  List<dynamic> get itemList => selectedFilter == 'courses'
      ? courseController.myActiveCourses
      : selectedFilter == 'my-own-courses'
          ? courseController.coachCourses
          : chatController.userPrivateChats;

  ChatController get chatController => _chatController;
  CourseController get courseController => _courseController;
  UserController get userController => _userController;

  @override
  void onInit() {
    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300) {
        if (selectedFilter == 'courses')
          _coursePagination();
        else if (selectedFilter == 'my-own-courses')
          _coachCoursePagination();
        else
          _chatPagination();
      }
    });
    super.onInit();
    Future.delayed(Duration.zero).then((_) => getData());
  }

  deleteChat(String id, String title) async {
    final result = await confirmDeleteDialog(title);
    if (result == null || !result) return;

    loadingItems.add(id);
    update();
    try {
      await _chatController.deleteOneConversation(id);
      _chatController.userPrivateChats.removeWhere(
        (element) => element.id == id,
      );
      loadingItems.remove(id);
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr);
      loadingItems.remove(id);
      update();
    } catch (error) {
      showErrorDialog('error'.tr);
      loadingItems.remove(id);
      update();
    }
  }

  Future<void> getData({bool refresh = false}) async {
    if (refresh) {
      _canLoadChats = false;
      _canLoadCourses = false;
    } else {
      isLoading = true;
    }

    update();
    try {
      await _chatController.fetchAndSetUserPrivateChats(0, isRefresh: true);
      if (refresh) {
        await _courseController.fetchAndSetMyCourses(
            ++_pageNumCourses, _userController.userId,
            isRefresh: true);
        _pageNumCourses = 0;
      }
      _pageNumChats = 0;
      isLoading = false;
      _canLoadChats = true;
      _canLoadCourses = true;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr).then((_) => refresh
          ? {
              isLoading = false,
              _canLoadChats = true,
              _canLoadCourses = true,
              update()
            }
          : Get.back());
    } catch (error) {
      showErrorDialog('error'.tr).then((_) => refresh
          ? {
              isLoading = false,
              _canLoadChats = true,
              _canLoadCourses = true,
              update()
            }
          : Get.back());
    }
  }

  toggleSelectedFilter(String value) {
    selectedFilter = value;
    update();
  }

  void _chatPagination() async {
    if (_canLoadChats) {
      _loadMoreChats = true;
      update();

      _canLoadChats = false;
      _getChats();
    }
  }

  Future<void> _getChats() async {
    if (_lastPageChats) {
      _canLoadChats = true;
      _loadMoreChats = false;
      update();

      return;
    }
    try {
      await _chatController.fetchAndSetUserPrivateChats(
        ++_pageNumChats,
      );
      _canLoadChats = true;
    } on HttpException catch (error) {
      _pageNumChats--;
      _canLoadChats = true;

      showErrorDialog('error'.tr);
      _loadMoreChats = false;
      update();
      throw error;
    } catch (error) {
      _pageNumChats--;
      _canLoadChats = true;

      showErrorDialog('error'.tr);
      _loadMoreChats = false;
      update();
      throw error;
    }
    _loadMoreChats = false;
    update();
  }

  void _coursePagination() async {
    if (_canLoadCourses) {
      _loadMoreCourses = true;
      update();

      _canLoadCourses = false;
      _getCourses();
    }
  }

  void _coachCoursePagination() async {
    if (_canLoadCoachCourses) {
      _loadMoreCoachCourses = true;
      update();

      _canLoadCoachCourses = false;
      _getCoachCourses();
    }
  }

  Future<void> _getCoachCourses() async {
    if (_lastPageCoachCourse) {
      _canLoadCoachCourses = true;
      _loadMoreCoachCourses = false;
      update();

      return;
    }
    try {
      await _courseController.fetchAndSetCoachCourses(
        ++_pageNumCoachCourses,
      );
      _canLoadCoachCourses = true;
    } on HttpException catch (error) {
      _pageNumCoachCourses--;
      _canLoadCoachCourses = true;

      showErrorDialog('error'.tr);
      _loadMoreCoachCourses = false;
      update();
      throw error;
    } catch (error) {
      _pageNumCoachCourses--;
      _canLoadCoachCourses = true;

      showErrorDialog('error'.tr);
      _loadMoreCoachCourses = false;
      update();
      throw error;
    }
    _loadMoreCoachCourses = false;
    update();
  }

  Future<void> _getCourses() async {
    if (_lastPageCourses) {
      _canLoadCourses = true;
      _loadMoreCourses = false;
      update();

      return;
    }
    try {
      await _courseController.fetchAndSetMyCourses(
          ++_pageNumCourses, _userController.userId);
      _canLoadCourses = true;
    } on HttpException catch (error) {
      _pageNumCourses--;
      _canLoadCourses = true;

      showErrorDialog('error'.tr);
      _loadMoreCourses = false;
      update();
      throw error;
    } catch (error) {
      _pageNumCourses--;
      _canLoadCourses = true;

      showErrorDialog('error'.tr);
      _loadMoreCourses = false;
      update();
      throw error;
    }
    _loadMoreCourses = false;
    update();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
