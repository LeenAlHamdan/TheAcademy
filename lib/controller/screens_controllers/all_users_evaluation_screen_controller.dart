import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/course.dart';
import '../../view/widgets/dialogs/error_dialog.dart';
import '../models_controller/exam_controller.dart';

class AllUsersEvaluationScreenController extends GetxController {
  late String courseId;
  late String title;

  final scrollController = ScrollController();
  var isLoading = false;

  final ExamController _examController = Get.find();

  ExamController get examController => _examController;

  List<UserEvaluation> get exams => _examController.allUsersExamEvaluation;

  @override
  void onInit() {
    if (Get.arguments != null) {
      courseId = Get.arguments['id'];
      title = Get.arguments['title'];
    }

    super.onInit();
    Future.delayed(Duration.zero).then((_) => getData());
  }

  Future<void> getData() async {
    isLoading = true;
    update();

    try {
      await _examController.fetchAndSetAllUserExamsEvaluation(
        courseId,
      );
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

  Future<void> refreshData() async {
    try {
      await _examController.fetchAndSetAllUserExamsEvaluation(
        courseId,
      );

      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr);
    } catch (error) {
      showErrorDialog('error'.tr);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
