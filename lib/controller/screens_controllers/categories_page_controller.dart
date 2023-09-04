import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/models_controller/category_controller.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import '../../model/category.dart';
import '../../services/user_controller.dart';
import '../../utils/refresh.dart';

class CategoriesPageController extends GetxController
    with GetTickerProviderStateMixin {
  final CategoryController _categoryController = Get.find();
  final UserController _userController = Get.find();

  bool _canLoadCategories = true;
  bool _loadMoreCategories = false;
  int _pageNumCategories = 0;
  int _pageNumSearchedCategories = 0;
  final serchTextController = TextEditingController();

  final scrollController = ScrollController();

  bool isOpend = false;
  late final AnimationController animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 10));

  bool get loadMoreCategories => !_lastPage && _loadMoreCategories;
  bool get _lastPage =>
      (!isSearching &&
          categoryController.categories.length == categoryController.total) ||
      (isSearching &&
          categoryController.searched.length ==
              categoryController.totalSearched);

  UserController get userController => _userController;
  CategoryController get categoryController => _categoryController;

  bool get isEmpty =>
      (isSearching && categoryController.searched.isEmpty) ||
      (!isSearching && categoryController.categories.isEmpty);

  List<Category> get categories => isSearching
      ? _categoryController.searched
      : _categoryController.categories;

  bool isLoading = false;

  bool isSearching = false;

  String searchText = '';

  toggleSearch(bool s) {
    if (!s) {
      isSearching = s;
      serchTextController.clear();
      update();
    }
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
    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300) {
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

  Future<void> _getCategories() async {
    if (_lastPage) {
      _canLoadCategories = true;
      _loadMoreCategories = false;
      update();

      return;
    }
    try {
      isSearching
          ? await categoryController.search(
              searchText,
              ++_pageNumSearchedCategories,
            )
          : await categoryController.fetchAndSetCategories(
              ++_pageNumCategories,
            );
      _canLoadCategories = true;
    } on HttpException catch (error) {
      isSearching ? _pageNumSearchedCategories-- : _pageNumCategories--;
      _canLoadCategories = true;

      showErrorDialog('error'.tr);
      _loadMoreCategories = false;
      update();
      throw error;
    } catch (error) {
      isSearching ? _pageNumSearchedCategories-- : _pageNumCategories--;
      _canLoadCategories = true;

      showErrorDialog('error'.tr);
      _loadMoreCategories = false;
      update();
      throw error;
    }
    _loadMoreCategories = false;
    update();
  }

  Future<void> _search({bool withLoad = true}) async {
    if (withLoad) {
      isLoading = true;
      update();
    }

    try {
      await categoryController.search(
        searchText,
        0,
        isRefresh: true,
      );
      _pageNumSearchedCategories = 0;
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
    _canLoadCategories = false;
    try {
      if (isSearching) {
        await _search(withLoad: false);
        _pageNumSearchedCategories = 0;
      }
      await refreshDataFunction(_userController,
          categoryController: categoryController, refreshCategories: true);
      _pageNumCategories = 0;
      _canLoadCategories = true;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr);
      _canLoadCategories = true;
    } catch (error) {
      showErrorDialog('error'.tr);
      _canLoadCategories = true;
    }
  }

  @override
  void dispose() {
    serchTextController.dispose();
    scrollController.dispose();
    animationController.dispose();

    super.dispose();
  }
}
