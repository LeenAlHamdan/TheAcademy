import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/models_controller/category_controller.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import '../../utils/refresh.dart';
import 'main_screen_controller.dart';

class HomePageController extends GetxController {
  final CourseController _courseController = Get.find();
  final CategoryController _categoryController = Get.find();
  final UserController _userController = Get.find();
  final MainScreenController _mainScreenController = Get.find();

  final ScrollController horizontalMyCoursesScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  final ScrollController horizontalPublicCoursesScrollController =
      ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  final ScrollController horizontalMyOwnCoursesScrollController =
      ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  final ScrollController horizontalCategoryScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  bool _canLoadMyCourses = true;
  bool _loadMoreMyCourses = false;
  int _pageNumMyCourses = 0;

  bool get loadMoreMyCourses => _loadMoreMyCourses && !_lastPageMyCourses;
  bool get _lastPageMyCourses =>
      _courseController.myCourses.length == _courseController.myCoursesTotal;

  bool _canLoadPublicCourses = true;
  bool _loadMorePublicCourses = false;
  int _pageNumPublicCourses = 0;

  bool get loadMorePublicCourses =>
      _loadMorePublicCourses && !_lastPagePublicCourses;
  bool get _lastPagePublicCourses =>
      _courseController.publicCourses.length == _courseController.publicTotal;

  bool _canLoadCoachCourses = true;
  bool _loadMoreCoachCourses = false;
  int _pageNumCoachCourses = 0;

  bool get loadMoreCoachCourses =>
      _loadMoreCoachCourses && !_lastPageCoachCourses;
  bool get _lastPageCoachCourses =>
      _courseController.coachCourses.length ==
      _courseController.coachCoursesTotal;

  bool _canLoadCategories = true;
  bool _loadMoreCategories = false;
  int _pageNumCategories = 0;

  bool get loadMoreCategories => _loadMoreCategories && !_lastPageCategories;
  bool get _lastPageCategories =>
      _categoryController.categories.length == _categoryController.total;

  MainScreenController get mainScreenController => _mainScreenController;
  CourseController get courseController => _courseController;
  UserController get userController => _userController;
  CategoryController get categoryController => _categoryController;

  @override
  void onInit() {
    super.onInit();

    horizontalMyCoursesScrollController.addListener(() {
      if (horizontalMyCoursesScrollController.position.pixels ==
          horizontalMyCoursesScrollController.position.maxScrollExtent) {
        _myCoursesPagination();
      }
    });

    horizontalPublicCoursesScrollController.addListener(() {
      if (horizontalPublicCoursesScrollController.position.pixels ==
          horizontalPublicCoursesScrollController.position.maxScrollExtent) {
        _publicCoursesPagination();
      }
    });

    horizontalMyOwnCoursesScrollController.addListener(() {
      if (horizontalMyOwnCoursesScrollController.position.pixels ==
          horizontalMyOwnCoursesScrollController.position.maxScrollExtent) {
        _coachCoursesPagination();
      }
    });

    horizontalCategoryScrollController.addListener(() {
      if (horizontalCategoryScrollController.position.pixels ==
          horizontalCategoryScrollController.position.maxScrollExtent) {
        _categoryPagination();
      }
    });
  }

  void _categoryPagination() async {
    if (_canLoadCategories) {
      _loadMoreCategories = true;
      update();

      _canLoadCategories = false;
      _getCategories();
    }
  }

  void _myCoursesPagination() async {
    if (_canLoadMyCourses) {
      _loadMoreMyCourses = true;
      update();

      _canLoadMyCourses = false;
      _getMyCourses();
    }
  }

  void _publicCoursesPagination() async {
    if (_canLoadPublicCourses) {
      _loadMorePublicCourses = true;
      update();

      _canLoadPublicCourses = false;
      _getPublicCourses();
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

  Future<void> _getPublicCourses() async {
    if (_lastPagePublicCourses) {
      _canLoadPublicCourses = true;
      _loadMorePublicCourses = false;
      update();

      return;
    }
    try {
      await _courseController.fetchAndSetPublicCourses(
        ++_pageNumPublicCourses,
      );
      _canLoadPublicCourses = true;
    } on HttpException catch (error) {
      _pageNumPublicCourses--;
      _canLoadPublicCourses = true;

      showErrorDialog('error'.tr);
      _loadMorePublicCourses = false;
      update();
      throw error;
    } catch (error) {
      _pageNumPublicCourses--;
      _canLoadPublicCourses = true;

      showErrorDialog('error'.tr);
      _loadMorePublicCourses = false;
      update();
      throw error;
    }
    _loadMorePublicCourses = false;
    update();
  }

  Future<void> _getCategories() async {
    if (_lastPageCategories) {
      _canLoadCategories = true;
      _loadMoreCategories = false;
      update();

      return;
    }
    try {
      await _categoryController.fetchAndSetCategories(
        ++_pageNumCategories,
      );
      _canLoadCategories = true;
    } on HttpException catch (error) {
      _pageNumCategories--;
      _canLoadCategories = true;

      showErrorDialog('error'.tr);
      _loadMoreCategories = false;
      update();
      throw error;
    } catch (error) {
      _pageNumCategories--;
      _canLoadCategories = true;

      showErrorDialog('error'.tr);
      _loadMoreCategories = false;
      update();
      throw error;
    }
    _loadMoreCategories = false;
    update();
  }

  Future<void> refreshData() async {
    _canLoadCategories = false;
    _canLoadMyCourses = false;
    _canLoadPublicCourses = false;
    try {
      await refreshDataFunction(_userController,
          categoryController: _categoryController,
          courseController: _courseController,
          refreshCoureses: true,
          refreshCategories: true);
      _pageNumMyCourses = 0;
      _pageNumPublicCourses = 0;
      _pageNumCategories = 0;
      _canLoadCategories = true;
      _canLoadMyCourses = true;
      _canLoadPublicCourses = true;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr);
      _canLoadCategories = true;
      _canLoadMyCourses = true;
      _canLoadPublicCourses = true;
    } catch (error) {
      showErrorDialog('error'.tr);
      _canLoadCategories = true;
      _canLoadMyCourses = true;
      _canLoadPublicCourses = true;
    }
  }

  @override
  void dispose() {
    horizontalCategoryScrollController.dispose();
    horizontalMyCoursesScrollController.dispose();
    horizontalPublicCoursesScrollController.dispose();
    horizontalMyOwnCoursesScrollController.dispose();
    super.dispose();
  }
}
