import 'dart:async';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/exam.dart';
import 'package:the_academy/model/question.dart';
import 'package:the_academy/model/themes.dart';

import '../../model/http_exception.dart';
import '../../services/user_controller.dart';
import '../../view/widgets/dialogs/error_dialog.dart';
import '../../view/widgets/flutter_timer_countdown/functions.dart';
import '../models_controller/exam_controller.dart';

class OneExamScreenController extends GetxController
    with GetTickerProviderStateMixin {
  bool isOpend = false;
  bool isTheCoach = false;
  bool isStarted = false; //.obs;
  var isLoading = false;
  var timerEnded = false;

  int _durationInMinute = 0;
  String time = '00:00';

  int durationInMinuteToStart = 0;
  int? durationInDaysToStart;
  DateTime? _endTime;

  final CarouselController _carouselController = CarouselController();
  final UserController _userController = Get.find();
  final ExamController _examController = Get.find();

  late final AnimationController animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 10));

  late String _examId;
  ExamFullData? examFullData;

  String selectedFilter = 'users';
  List<RxString?> answers = [];
  double result = 0;
  late double _questionMark;
  int currentQuestion = 0;
  int answerdQuestions = 0;

  List<dynamic>? userAnswers;

  ExamController get examController => _examController;
  UserController get userController => _userController;
  CarouselController get carouselController => _carouselController;

  DateTime get endTime => _endTime = _endTime ??
      DateTime.now().add(
        Duration(
          minutes: _durationInMinute,
        ),
      );

  radioColor(Question question, int i) {
    if (userAnswers == null) return null;
    if (examFullData!.status != 2) return Colors.grey;
    final choice = question.choices
        .firstWhereOrNull((element) => element.id == answers[i]?.value);
    if (choice != null && choice.isTrueAnswer != null && choice.isTrueAnswer!) {
      return Colors.green;
    }
    return Colors.red;
  }

  bool get showTrueAnswers => userAnswers != null && examFullData!.status == 2;

  updateStatus() {
    examFullData!.status = 1;
    update();
  }

  @override
  void onInit() {
    if (Get.arguments != null) {
      _examId = Get.arguments['id'];
      isTheCoach = Get.arguments['isTheCoach'];
      userAnswers = Get.arguments['answers'];
    }
    super.onInit();
    Future.delayed(Duration.zero).then((_) async {
      isLoading = true;
      update();
      try {
        examFullData = await _examController.getExamFullData(_examId);

        _questionMark = 100 / examFullData!.questions.length;
        answers.addAll(examFullData!.questions.map((e) {
          if (userAnswers != null) {
            final ques = userAnswers!.firstWhereOrNull(
              (element) => element['questionId'] == e.id,
            );
            return ques?['choiceId'].toString().obs;
          }
          return null;
        }));

        if (examFullData?.status == 0 && !isTheCoach) {
          var startDate = DateTime.parse(examFullData!.startDate).toLocal();
          var currentTime = DateTime.now().toLocal();
          var difference = startDate.difference(currentTime);
          durationInMinuteToStart = difference.inMinutes;
          if (difference.inDays > 0) {
            durationInDaysToStart = difference.inDays;
          }
        } else if (examFullData?.status == 2 || isTheCoach) {
          var endDate = DateTime.parse(examFullData!.endDate).toLocal();
          var startDate = DateTime.parse(examFullData!.startDate).toLocal();
          var difference = endDate.difference(startDate);
          _durationInMinute = difference.inMinutes;
          final countdownHours = durationToStringHours(difference, difference);
          final countdownMinutes =
              durationToStringMinutes(difference, difference);
          final countdownSeconds =
              durationToStringSeconds(difference, difference);
          time = countdownHours.toString().padLeft(2, "0") +
              ":" +
              countdownMinutes.toString().padLeft(2, "0") +
              ":" +
              countdownSeconds.toString().padLeft(2, "0");
          /*  time = durationInMinute.toString().padLeft(2, "0") +
              ":" +
              0.toString().padLeft(2, "0"); */
        }
        isLoading = false;
        update();
      } on HttpException catch (_) {
        showErrorDialog('error'.tr).then((_) => Get.back());
      } catch (error) {
        showErrorDialog('error'.tr).then((_) => Get.back());
      }
    });
  }

  void changeAnswer(int index, String value) {
    if (answers[index] == null) answerdQuestions++;
    answers[index] = value.obs;
    update();
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

  startTheExam() {
    _endTime = examFullData!.status == 1
        ? DateTime.parse(examFullData!.endDate).toLocal()
        : DateTime.now().add(
            Duration(
              minutes: _durationInMinute,
            ),
          );
    isStarted = true /* .obs */;
    timerEnded = false;

    if (examFullData?.status != 2) {
      var endDate = DateTime.parse(examFullData!.endDate).toLocal();
      var currentTime = DateTime.now().toLocal();

      final difference = endDate.difference(currentTime);

      _durationInMinute = difference.inMinutes;

      final countdownHours = durationToStringHours(difference, difference);
      final countdownMinutes = durationToStringMinutes(difference, difference);
      final countdownSeconds = durationToStringSeconds(difference, difference);
      time = countdownHours.toString().padLeft(2, "0") +
          ":" +
          countdownMinutes.toString().padLeft(2, "0") +
          ":" +
          countdownSeconds.toString().padLeft(2, "0");
    }

    update();
  }

  timerEnd() {
    timerEnded = true;
    if (!isStarted) update();
    submitExam();
  }

  submitExam() async {
    if (examFullData!.status == 2 || isTheCoach) {
      result = 0;
      for (int i = 0; i < examFullData!.questions.length; i++) {
        final choice = examFullData!.questions[i].choices
            .firstWhereOrNull((element) => element.id == answers[i]?.value);

        if (choice != null &&
            choice.isTrueAnswer != null &&
            choice.isTrueAnswer!) {
          result += _questionMark;
        }
      }
    } else {
      List<Map<String, dynamic>> userAnswers = [];
      for (int i = 0; i < examFullData!.questions.length; i++) {
        final choice = examFullData!.questions[i].choices
            .firstWhereOrNull((element) => element.id == answers[i]?.value);
        if (answers[i]?.value != null)
          userAnswers.add({
            'questionId': examFullData?.questions[i].id,
            'choiceId': choice?.id
          });
      }
      try {
        await _attendExam(userAnswers);
      } on HttpException catch (error) {
        debugPrint(error.toString());

        showErrorDialog('try_again'.tr, cancel: true);
        isLoading = false;
        update();
        return;
      } catch (error) {
        debugPrint(error.toString());
        showErrorDialog('try_again'.tr, cancel: true);
        isLoading = false;
        update();
        return;
      }
    }
    examFullData!.userMark = result;

    Get.defaultDialog(
        title: result >= 70
            ? 'congratulations'.tr
            : result >= 40
                ? 'good_job'.tr
                : 'hard_luck'.tr,
        titleStyle: TextStyle(
            color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
        middleText: '${'your_result_is'.tr} $result',
        middleTextStyle: TextStyle(
            color: Get.isDarkMode ? Themes.primaryColorLightDark : null),
        textConfirm: 'ok'.tr,
        confirmTextColor: Themes.primaryColorLight,
        barrierDismissible: false,
        onConfirm: () {
          Get.back();
          Get.back();
        });
  }

  bool get showQuestions {
    if (isTheCoach) return true;
    if (userAnswers != null) return true;
    if (examFullData!.status != 2 && !isStarted /* .value */) {
      return false;
    }
    return true;
  }

  onPageChanged(int index) {
    currentQuestion = index;
    update();
  }

  bool nextPageFunction() {
    return examFullData != null &&
            currentQuestion < examFullData!.questions.length
        ? true
        : false;
  }

  nextPage() {
    _carouselController.animateToPage(++currentQuestion);
    update();
  }

  bool previousPageFunction() {
    return currentQuestion != 0 ? true : false;
  }

  previousPage() {
    _carouselController.animateToPage(--currentQuestion);
    update();
  }

  _attendExam(List<Map<String, dynamic>> answers) async {
    isLoading = true;
    update();
    try {
      result = await _examController.attendExam(_examId, answers);
      isLoading = false;
      update();
    } on HttpException catch (error) {
      debugPrint(error.toString());
      throw error;
    } catch (error) {
      debugPrint(error.toString());

      throw error;
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
