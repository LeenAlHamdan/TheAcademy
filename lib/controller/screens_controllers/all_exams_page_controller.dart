import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../services/user_controller.dart';
import '../../view/widgets/dialogs/error_dialog.dart';
import '../models_controller/exam_controller.dart';

class AllExamsPageController extends GetxController {
  final scrollController = ScrollController();
  var isLoading = false;

  final ExamController _examController = Get.find();
  final UserController _userController = Get.find();

  bool _canLoad = true;
  bool _loadMore = false;
  int _pageNum = 0;

  bool get loadMore => _loadMore && !_lastPage;
  bool get _lastPage =>
      _examController.allExams.length == _examController.allExamsTotal;

  ExamController get examController => _examController;
  UserController get userController => _userController;

  @override
  void onInit() {
    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300) {
        _examPagination();
      }
    });
    super.onInit();
    Future.delayed(Duration.zero).then((_) => getData());
  }

  Future<void> getData({bool refresh = false}) async {
    refresh ? _canLoad = false : isLoading = true;
    update();
    try {
      await _examController.fetchAndSetAllExams(0, isRefresh: true);

      _pageNum = 0;
      isLoading = false;
      _canLoad = true;

      update();
    } on HttpException catch (_) {
      _pageNum = 0;
      isLoading = false;
      _canLoad = true;

      update();
      showErrorDialog('error'.tr).then((_) => Get.back());
    } catch (error) {
      _pageNum = 0;
      isLoading = false;
      _canLoad = true;

      update();
      showErrorDialog('error'.tr).then((_) => Get.back());
    }
  }

  void _examPagination() async {
    if (_canLoad) {
      _loadMore = true;
      update();

      _canLoad = false;
      _getExams();
    }
  }

  Future<void> _getExams() async {
    if (_lastPage) {
      _canLoad = true;
      _loadMore = false;
      update();

      return;
    }
    try {
      await _examController.fetchAndSetAllExams(
        ++_pageNum,
      );
      _canLoad = true;
    } on HttpException catch (error) {
      _pageNum--;
      _canLoad = true;

      showErrorDialog('error'.tr);
      _loadMore = false;
      update();
      throw error;
    } catch (error) {
      _pageNum--;
      _canLoad = true;

      showErrorDialog('error'.tr);
      _loadMore = false;
      update();
      throw error;
    }
    _loadMore = false;
    update();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
