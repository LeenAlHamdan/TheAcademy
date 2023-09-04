import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/model/course.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import 'main_screen_controller.dart';

class CoachCoursesListScreenController extends GetxController {
  var isLoading = false;

  final CourseController _courseController = Get.find();
  final UserController _userController = Get.find();
  final MainScreenController _mainScreenController = Get.find();

  final scrollController = ScrollController();

  bool _canLoadCourses = true;
  bool _loadMoreCourses = false;
  int _pageNumCourses = 0;

  bool isSearching = false;

  String _searchText = '';
  final serchTextController = TextEditingController();
  int _pageNumSearchedCourses = 0;

  final defaultFilter = 'accepted';
  late String dropDownFilterValue = defaultFilter;
  final List<String> dropDownFilterSpinner = [
    'accepted',
    'un_accepted',
    'active',
    'inactive',
    'private'
  ];

  bool get loadMoreCourses => !_lastPage && _loadMoreCourses;
  bool get _lastPage => ((!isSearching &&
          _courseController.coachCourses.length ==
              _courseController.coachCoursesTotal) ||
      (isSearching &&
          _courseController.searched.length ==
              _courseController.totalSearched));

  MainScreenController get mainScreenController => _mainScreenController;
  CourseController get courseController => _courseController;
  UserController get userController => _userController;

  List<Course> get courseList =>
      isSearching || dropDownFilterValue != 'accepted'
          ? _courseController.searched
          : _courseController.coachCourses;

  onChangeFilterValue(String? filter) {
    if (filter == null || filter == dropDownFilterValue) return;
    final prev = dropDownFilterValue;
    dropDownFilterValue = filter;
    update();
    if (dropDownFilterValue == 'accepted') return;
    _search(prev: prev);
  }

  toggleSearch(bool s) {
    if (!s) {
      isSearching = s;
      serchTextController.clear();
      update();
    }
  }

  onChangeSearchText(String text) {
    if (text.isEmpty && text.removeAllWhitespace.isEmpty) {
      isSearching = false;
      update();
      return;
    }
    isSearching = true;
    if (text != _searchText) {
      _searchText = text;
      _search();
    }
  }

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300) {
        _coursePagination();
      }
    });
    Future.delayed(Duration.zero).then((_) async {
      isLoading = true;
      update();
      try {
        await _courseController.fetchAndSetCoachCourses(0, isRefresh: true);

        isLoading = false;

        update();
      } on HttpException catch (_) {
        showErrorDialog('error'.tr).then((_) => Get.back());
      } catch (error) {
        showErrorDialog('error'.tr).then((_) => Get.back());
      }
    });
  }

  Future<void> refreshData() async {
    _canLoadCourses = false;
    try {
      if (isSearching) {
        await _search(withLoad: false);
        _pageNumSearchedCourses = 0;
      }
      await _courseController.fetchAndSetCoachCourses(
        ++_pageNumCourses,
        isRefresh: true,
      );

      _pageNumCourses = 0;
      _canLoadCourses = true;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr);
      _canLoadCourses = true;
    } catch (error) {
      showErrorDialog('error'.tr);
      _canLoadCourses = true;
    }
  }

  void _coursePagination() async {
    if (_canLoadCourses) {
      _loadMoreCourses = true;
      update();

      _canLoadCourses = false;
      _getCourses();
    }
  }

  Future<void> _getCourses() async {
    if (_lastPage) {
      _canLoadCourses = true;
      _loadMoreCourses = false;
      update();

      return;
    }
    try {
      isSearching
          ? await _courseController.search(
              _searchText,
              ++_pageNumSearchedCourses,
              _userController.userId,
              isUnAccepted: dropDownFilterValue == 'un_accepted' ? true : null,

              // isMyCourses: isMyCourses,
              // subjectId: subject?.id,
              isActive: dropDownFilterValue == 'active'
                  ? true
                  : dropDownFilterValue == 'inactive'
                      ? false
                      : null,
              isPrivate: dropDownFilterValue == 'private' ? true : null,
              isCoach: true,
            )
          : await _courseController.fetchAndSetCoachCourses(
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

  Future<void> _search({String? prev, bool withLoad = true}) async {
    if (withLoad) {
      isLoading = true;
      update();
    }
    try {
      await _courseController.search(
        _searchText,
        0,
        _userController.userId,
        isPrivate: dropDownFilterValue == 'private' ? true : null,
        isUnAccepted: dropDownFilterValue == 'un_accepted' ? true : null,
        isCoach: true,
        isRefresh: true,
        isActive: dropDownFilterValue == 'active'
            ? true
            : dropDownFilterValue == 'inactive'
                ? false
                : null,
        isMyPendingCourses: dropDownFilterValue == 'un_accepted',
      );
      _pageNumSearchedCourses = 0;
    } on HttpException catch (error) {
      debugPrint('$error');
      if (prev != null) {
        dropDownFilterValue = prev;
        update();
      }
      showErrorDialog(
        'error'.tr,
      );
      isSearching = false;
      serchTextController.clear();
    } catch (error) {
      debugPrint('$error');

      if (prev != null) {
        dropDownFilterValue = prev;
        update();
      }
      showErrorDialog(
        'error'.tr,
      );
      isSearching = false;
      serchTextController.clear();
    }
    isLoading = false;
    update();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
