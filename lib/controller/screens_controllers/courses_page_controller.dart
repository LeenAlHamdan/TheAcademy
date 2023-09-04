import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import '../../model/course.dart';
import '../../utils/refresh.dart';
import 'main_screen_controller.dart';

class CoursesPageController extends GetxController {
  final CourseController _courseController = Get.find();
  final UserController _userController = Get.find();
  final MainScreenController _mainScreenController = Get.find();

  final serchTextController = TextEditingController();

  final ScrollController horizontalScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  final ScrollController horizontalMyOwnCoursesScrollController =
      ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  final scrollController = ScrollController();

  bool _canLoadMyCourses = true;
  bool _loadMoreMyCourses = false;
  int _pageNumMyCourses = 0;

  bool get _lastPageMyCourses =>
      _courseController.myCourses.length == _courseController.myCoursesTotal;
  bool get loadMoreMyCourses => _loadMoreMyCourses && !_lastPageMyCourses;

  bool _canLoadCoachCourses = true;
  bool _loadMoreCoachCourses = false;
  int _pageNumCoachCourses = 0;

  bool get _lastPageCoachCourses =>
      _courseController.coachCourses.length ==
      _courseController.coachCoursesTotal;

  bool get loadMoreCoachCourses =>
      _loadMoreCoachCourses && !_lastPageCoachCourses;

  bool _canLoadCourses = true;
  bool _loadMoreCourses = false;
  int _pageNumCourses = 0;
  int _pageNumSearchedCourses = 0;

  bool get _lastPageCourses =>
      (!isSearching &&
          _courseController.courses.length == _courseController.total) ||
      (isSearching &&
          _courseController.searched.length == _courseController.totalSearched);

  bool get loadMoreCourses => _loadMoreCourses && !_lastPageCourses;

  bool isLoading = false;

  bool isSearching = false;

  String searchText = '';

  toggleSearch(bool s) {
    _canLoadCourses = true;
    if (!s) {
      isSearching = s;
      serchTextController.clear();
      update();
    }
  }

  MainScreenController get mainScreenController => _mainScreenController;
  CourseController get courseController => _courseController;
  UserController get userController => _userController;

  bool userInTheCourse(Course course) =>
      course.coachId == userController.userId ||
      course.users.firstWhereOrNull(
            (element) => element == userController.userId,
          ) !=
          null;

  onChangeSearchText(String text) {
    if (text.isEmpty && text.removeAllWhitespace.isEmpty) {
      isSearching = false;
      update();
      return;
    }
    isSearching = true;
    if (text != searchText) {
      searchText = text;
      _search();
    }
  }

  @override
  void onInit() {
    super.onInit();

    horizontalScrollController.addListener(() {
      if (horizontalScrollController.position.pixels ==
          horizontalScrollController.position.maxScrollExtent) {
        _myCoursesPagination();
      }
    });

    horizontalMyOwnCoursesScrollController.addListener(() {
      if (horizontalMyOwnCoursesScrollController.position.pixels ==
          horizontalMyOwnCoursesScrollController.position.maxScrollExtent) {
        _coachCoursesPagination();
      }
    });

    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300) {
        _coursePagination();
      }
    });
  }

  void _myCoursesPagination() async {
    if (_canLoadMyCourses) {
      _loadMoreMyCourses = true;
      update();

      _canLoadMyCourses = false;
      _getMyCourses();
    }
  }

  void _coursePagination() {
    if (_canLoadCourses) {
      _loadMoreCourses = true;
      update();

      _canLoadCourses = false;
      _getCourses();
    }
  }

  void _coachCoursesPagination() async {
    if (_canLoadCoachCourses) {
      _loadMoreCoachCourses = true;
      update();

      _canLoadCoachCourses = false;
      _getCoachCourses();
    }
  }

  Future<void> _getCoachCourses() async {
    if (_lastPageCoachCourses) {
      _canLoadCoachCourses = true;
      _loadMoreCoachCourses = false;
      update();

      return;
    }
    try {
      await _courseController.fetchAndSetPublicCourses(
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

  Future<void> _getMyCourses() async {
    if (_lastPageMyCourses) {
      _canLoadMyCourses = true;
      _loadMoreMyCourses = false;
      update();

      return;
    }
    try {
      await _courseController.fetchAndSetMyCourses(
          ++_pageNumMyCourses, _userController.userId);
      _canLoadMyCourses = true;
    } on HttpException catch (error) {
      _pageNumMyCourses--;
      _canLoadMyCourses = true;

      showErrorDialog('error'.tr);
      _loadMoreMyCourses = false;
      update();
      throw error;
    } catch (error) {
      _pageNumMyCourses--;
      _canLoadMyCourses = true;

      showErrorDialog('error'.tr);
      _loadMoreMyCourses = false;
      update();
      throw error;
    }
    _loadMoreMyCourses = false;
    update();
  }

  Future<void> _getCourses() async {
    if (_lastPageCourses) {
      _canLoadCourses = false;
      _loadMoreCourses = false;
      update();

      return;
    }

    try {
      isSearching
          ? await _courseController.search(
              searchText,
              ++_pageNumSearchedCourses,
              _userController.userId,
            )
          : await _courseController.fetchAndSetCourses(
              ++_pageNumCourses,
            );
      _canLoadCourses = true;
    } on HttpException catch (error) {
      isSearching ? _pageNumSearchedCourses-- : _pageNumCourses--;
      _canLoadCourses = true;

      showErrorDialog('error'.tr);
      _loadMoreCourses = false;
      update();
      throw error;
    } catch (error) {
      isSearching ? _pageNumSearchedCourses-- : _pageNumCourses--;
      _canLoadCourses = true;

      showErrorDialog('error'.tr);
      _loadMoreCourses = false;
      update();
      throw error;
    }
    _loadMoreCourses = false;
    update();
  }

  Future<void> _search({bool withLoad = true}) async {
    if (withLoad) {
      isLoading = true;
      update();
    }

    try {
      await _courseController.search(
        searchText,
        0,
        _userController.userId,
        isRefresh: true,
      );
      _pageNumSearchedCourses = 0;
    } on HttpException catch (_) {
      showErrorDialog(
        'error'.tr,
      );
      isSearching = false;
      serchTextController.clear();
    } catch (error) {
      showErrorDialog(
        'error'.tr,
      );
      isSearching = false;
      serchTextController.clear();
    }
    isLoading = false;
    update();
  }

  Future<void> refreshData() async {
    _canLoadMyCourses = false;
    _canLoadCourses = false;

    try {
      if (isSearching) {
        await _search(withLoad: false);
        _pageNumSearchedCourses = 0;
      }
      await refreshDataFunction(_userController,
          courseController: _courseController,
          refreshCoureses: true,
          refreshCategories: true);
      _pageNumMyCourses = 0;
      _pageNumCourses = 0;
      _canLoadCourses = true;
      _canLoadMyCourses = true;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr);
      _canLoadMyCourses = true;
      _canLoadCourses = true;
    } catch (error) {
      showErrorDialog('error'.tr);
      _canLoadMyCourses = true;
      _canLoadCourses = true;
    }
  }

  @override
  void dispose() {
    serchTextController.dispose();
    scrollController.dispose();
    horizontalScrollController.dispose();
    super.dispose();
  }
}
