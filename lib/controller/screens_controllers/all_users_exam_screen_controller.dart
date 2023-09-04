import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/exam.dart';
import '../../view/widgets/dialogs/error_dialog.dart';
import '../models_controller/exam_controller.dart';

class AllUsersExamScreenController extends GetxController {
  late String examId;
  late String title;

  final scrollController = ScrollController();
  var isLoading = false;

  final ExamController _examController = Get.find();

  bool _canLoad = true;
  bool _loadMore = false;
  int _pageNum = 0;

  List<UserExam> get exams => _examController.allUsersExam;

  bool get loadMore => _loadMore && !_lastPage;
  bool get _lastPage =>
      _examController.allUsersExam.length != _examController.allUsersExamTotal;
  @override
  void onInit() {
    if (Get.arguments != null) {
      examId = Get.arguments['id'];
      title = Get.arguments['title'];
    }
    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300) {
        _examPagination();
      }
    });
    super.onInit();
    Future.delayed(Duration.zero).then((_) => getData());
  }

  Future<void> getData() async {
    isLoading = true;
    update();

    try {
      await _examController.fetchAndSetAllUserExams(0, examId, isRefresh: true);
      isLoading = false;
      update();
    } on HttpException catch (error) {
      showErrorDialog('error'.tr).then(
        (value) => Get.back(),
      );
      isLoading = false;
      update();
      throw error;
    } catch (error) {
      showErrorDialog('error'.tr).then(
        (value) => Get.back(),
      );
      isLoading = false;
      update();
      throw error;
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
      await _examController.fetchAndSetAllUserExams(
        ++_pageNum,
        examId,
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

  Future<void> refreshData() async {
    _canLoad = false;
    try {
      await _examController.fetchAndSetAllUserExams(0, examId, isRefresh: true);

      _pageNum = 0;
      _canLoad = true;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr);
      _canLoad = true;
    } catch (error) {
      showErrorDialog('error'.tr);
      _canLoad = true;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
