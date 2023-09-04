import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/exam.dart';
import '../../model/themes.dart';
import '../../services/user_controller.dart';
import '../../view/widgets/dialogs/error_dialog.dart';
import '../models_controller/exam_controller.dart';

class ExamPageController extends GetxController {
  final String courseId;
  final bool canEditCourse;
  final bool userIsTheOwner;
  ExamPageController(this.courseId, this.canEditCourse, this.userIsTheOwner);

  final scrollController = ScrollController();
  var isLoading = false;

  final UserController _userController = Get.find();
  final ExamController _examController = Get.find();

  bool _canLoad = true;
  bool _loadMore = false;
  int _pageNum = 0;
  List<String> loadingItems = [];

  UserController get userController => _userController;
  ExamController get examController => _examController;

  List<Exam> get exams => _examController.exams;

  bool get loadMore => _loadMore && !_lastPage;
  bool get _lastPage => _examController.exams.length != _examController.total;
  @override
  void onInit() {
    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300) {
        _examPagination();
      }
    });
    super.onInit();
  }

  void _examPagination() async {
    if (_canLoad) {
      _loadMore = true;
      update();

      _canLoad = false;
      _getExams();
    }
  }

  oneExamTaped(Exam item) async {
    if (userIsTheOwner) {
      final result = await _showPicker();
      if (result == true) {
        Get.toNamed('/exam-screen',
            arguments: {'isTheCoach': canEditCourse, 'id': item.id});
      } else {
        Get.toNamed('/all-users-exam-screen', arguments: {
          'id': item.id,
          'title': Get.locale == const Locale('ar') ? item.nameAr : item.nameEn
        });
      }
    } else if (item.userExam == null) {
      Get.toNamed('/exam-screen',
          arguments: {'isTheCoach': canEditCourse, 'id': item.id});
    } else {
      Get.toNamed('/exam-screen', arguments: {
        'id': item.id,
        'isTheCoach': false,
        'answers': item.userExam?.answers,
      });
    }
  }

  Future<bool> _showPicker() async {
    return await Get.bottomSheet(
      Wrap(
        children: <Widget>[
          ListTile(
              leading: const Icon(Icons.slideshow),
              title: Text('show_the_exam'.tr),
              onTap: () {
                Get.back(result: true);
              }),
          ListTile(
            leading: const Icon(Icons.view_column_rounded),
            title: Text('show_users_exams'.tr),
            onTap: () {
              Get.back(result: false);
            },
          ),
        ],
      ),
      backgroundColor: Themes.primaryColorLight,
    );
  }

  Future<void> _getExams() async {
    if (_lastPage) {
      _canLoad = true;
      _loadMore = false;
      update();

      return;
    }
    try {
      await _examController.fetchAndSetExams(++_pageNum, courseId);
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
      await _examController.fetchAndSetExams(0, courseId, isRefresh: true);

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

  Future<void> deleteExam(String id) async {
    loadingItems.add(id);
    update();
    try {
      await examController.deleteExam(id);

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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
