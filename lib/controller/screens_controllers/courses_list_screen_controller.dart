import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/model/course.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/model/subject.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import 'main_screen_controller.dart';

class CoursesListScreenController extends GetxController {
  var isLoading = false;

  Subject? subject;
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

  final defaultFilter = 'all';
  late String dropDownFilterValue = defaultFilter;
  final List<String> dropDownFilterSpinner = [
    'all',
    'un_accepted',
    'active',
    'inactive',
  ];

  bool get loadMoreCourses => !_lastPage && _loadMoreCourses;
  bool get _lastPage => ((!isSearching &&
              (isMyCourses &&
                  _courseController.myCourses.length ==
                      _courseController.myCoursesTotal) ||
          (!isMyCourses &&
              _courseController.subjectCourses.length ==
                  _courseController.subjectTotal)) ||
      (isSearching &&
          _courseController.searched.length ==
              _courseController.totalSearched));

  MainScreenController get mainScreenController => _mainScreenController;
  CourseController get courseController => _courseController;
  UserController get userController => _userController;

  bool get isMyCourses => subject == null;

  List<Course> get courseList => isSearching || dropDownFilterValue != 'all'
      ? _courseController.searched
      : isMyCourses
          ? _courseController.myCourses
          : _courseController.subjectCourses;

  onChangeFilterValue(String? filter) {
    if (filter == null || filter == dropDownFilterValue) return;
    final prev = dropDownFilterValue;
    dropDownFilterValue = filter;
    update();
    if (dropDownFilterValue == 'all') return;

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
    if (Get.arguments != null) {
      subject = Get.arguments;
      isLoading = true;
    }
    super.onInit();

    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300) {
        _coursePagination();
      }
    });
    if (subject != null) {
      Future.delayed(Duration.zero).then((_) async {
        isLoading = true;
        update();
        try {
          await _courseController.fetchAndSetCourses(0,
              subjectId: subject?.id, isRefresh: true);

          isLoading = false;

          update();
        } on HttpException catch (_) {
          showErrorDialog('error'.tr).then((_) => Get.back());
        } catch (error) {
          showErrorDialog('error'.tr).then((_) => Get.back());
        }
      });
    }
  }

  Future<void> refreshData() async {
    _canLoadCourses = false;
    try {
      if (isSearching) {
        await _search(withLoad: false);
        _pageNumSearchedCourses = 0;
      }
      isMyCourses
          ? await _courseController.fetchAndSetMyCourses(
              ++_pageNumCourses,
              _userController.userId,
              isRefresh: true,
            )
          : await _courseController.fetchAndSetCourses(
              ++_pageNumCourses,
              subjectId: subject?.id,
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
    if (_canLoadCourses && !_lastPage) {
      _loadMoreCourses = true;
      update();

      _canLoadCourses = false;
      _getCourses();
    }
  }

  Future<void> _getCourses() async {
    if (_lastPage) {
      _canLoadCourses = true; //todo
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
              isMyCourses: isMyCourses,
              subjectId: subject?.id,
              isUnAccepted: dropDownFilterValue == 'un_accepted' ? true : null,
              isActive: dropDownFilterValue == 'active'
                  ? true
                  : dropDownFilterValue == 'inactive'
                      ? false
                      : null,
              isMyPendingCourses: dropDownFilterValue == 'un_accepted',
            )
          : isMyCourses
              ? await _courseController.fetchAndSetMyCourses(
                  ++_pageNumCourses, _userController.userId)
              : await _courseController.fetchAndSetCourses(++_pageNumCourses,
                  subjectId: subject?.id);
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
        isMyCourses: isMyCourses,
        subjectId: subject?.id,
        isRefresh: true,
        isUnAccepted: dropDownFilterValue == 'un_accepted' ? true : null,
        isActive: dropDownFilterValue == 'active'
            ? true
            : dropDownFilterValue == 'inactive'
                ? false
                : null,
        isMyPendingCourses: dropDownFilterValue == 'un_accepted',
      );
      _pageNumSearchedCourses = 0;
    } on HttpException catch (_) {
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
