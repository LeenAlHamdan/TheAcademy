import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/models_controller/subject_controller.dart';
import 'package:the_academy/model/category.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

class SubjectsScreenController extends GetxController {
  late Category category;
  var isLoading = false;
  final SubjectController _subjectController = Get.find();
  final UserController _userController = Get.find();

  final scrollController = ScrollController();

  bool _canLoadSubjects = true;
  bool _loadMoreSubjects = false;
  int _pageNumSubjects = 0;

  bool get loadMoreSubjects => _loadMoreSubjects && !_lastPage;
  bool get _lastPage =>
      _subjectController.subjects.length == _subjectController.total;

  bool isSearching = false;

  String _searchText = '';
  final serchTextController = TextEditingController();
  int _pageNumSearchedSubjects = 0;

  UserController get userController => _userController;
  SubjectController get subjectController => _subjectController;

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
      category = Get.arguments;
    }
    super.onInit();

    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300) {
        _subjectPagination();
      }
    });

    Future.delayed(Duration.zero).then((_) => getData());
  }

  Future<void> getData({bool refresh = false}) async {
    refresh ? _canLoadSubjects = false : isLoading = true;
    update();
    try {
      if (isSearching) {
        await _search(withLoad: false);
        _pageNumSearchedSubjects = 0;
      }
      await _subjectController.fetchAndSetSubjects(0, categoryId: category.id);
      _pageNumSubjects = 0;
      _canLoadSubjects = true;
      isLoading = false;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr).then(
          (_) => refresh ? {_canLoadSubjects = true, update()} : Get.back());
    } catch (error) {
      showErrorDialog('error'.tr).then(
          (_) => refresh ? {_canLoadSubjects = true, update()} : Get.back());
    }
  }

  void _subjectPagination() async {
    if (_canLoadSubjects) {
      _loadMoreSubjects = true;
      update();

      _canLoadSubjects = false;
      _getSubjects();
    }
  }

  Future<void> _getSubjects() async {
    if (_lastPage) {
      _canLoadSubjects = true;
      _loadMoreSubjects = false;
      update();

      return;
    }
    try {
      isSearching
          ? await _subjectController.search(
              _searchText, ++_pageNumSearchedSubjects, categoryId: category.id)
          : await _subjectController.fetchAndSetSubjects(++_pageNumSubjects,
              categoryId: category.id);
      _canLoadSubjects = true;
    } on HttpException catch (error) {
      isSearching ? _pageNumSearchedSubjects-- : _pageNumSubjects--;
      _canLoadSubjects = true;

      showErrorDialog('error'.tr);
      _loadMoreSubjects = false;
      update();
      throw error;
    } catch (error) {
      isSearching ? _pageNumSearchedSubjects-- : _pageNumSubjects--;
      _canLoadSubjects = true;

      showErrorDialog('error'.tr);
      _loadMoreSubjects = false;
      update();
      throw error;
    }
    _loadMoreSubjects = false;
    update();
  }

  Future<void> _search({bool withLoad = true}) async {
    if (withLoad) {
      isLoading = true;
      update();
    }
    try {
      await _subjectController.search(
        _searchText,
        0,
        categoryId: category.id,
        isRefresh: true,
      );
      _pageNumSearchedSubjects = 0;
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

  @override
  void dispose() {
    scrollController.dispose();
    serchTextController.dispose();
    super.dispose();
  }
}
