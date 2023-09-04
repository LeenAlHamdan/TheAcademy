import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/controller/models_controller/exam_controller.dart';
import 'package:the_academy/main.dart';
import 'package:the_academy/model/course.dart';
import 'package:the_academy/model/exam.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import '../../model/themes.dart';
import '../../utils/compress_file.dart';
import '../../view/widgets/dialogs/choose_date_time_dialog.dart';

class AddExamScreenController extends GetxController {
  RxString examId = ''.obs;
  String? courseId;
  String? courseNameAr;
  String? courseNameEn;
  ExamFullData? examFullData;
  var isLoading = false;
  var isLoadingButton = false;

  int page = 0;

  Course? selectedCourseValue;
  List<Course> coursesList = [];
  int? tappedQuestion;
  var prevSearchKey = '';

  bool isPrivate = false;

  final formPageOne = GlobalKey<FormState>();
  final formPageTwo = GlobalKey<FormState>();

  final ExamController _examController = Get.find();
  final CourseController _courseController = Get.find();
  final UserController _userController = Get.find();

  CourseController get courseController => _courseController;
  UserController get userController => _userController;
  ExamController get examController => _examController;

  final nameArController = TextEditingController();
  final nameEnController = TextEditingController();

  final nameEnFocusNode = FocusNode();
  DateTime selectedStartTime = DateTime.now();
  DateTime? selectedEndTimeInit;
  late DateTime selectedEndTime = selectedStartTime;

  List<QuestionItem> questionsItemsList = [
    QuestionItem(),
  ];

  Asset? image;
  String? imagePath;

  String dropDownFilterValue = '';
  final List<String> dropDownFilterSpinner = [
    'ar',
    'en',
  ];

  changeTappedQuestion(int? index) {
    tappedQuestion = index;
    update();
  }

  void selectMultiImage(List<Asset> images) {
    image = images.first;
    update();
  }

  onChangeFilterValue(String? filter) {
    if (filter == null || filter == dropDownFilterValue) return;
    dropDownFilterValue = filter;
    update();
  }

  addQuestionTextController() {
    formPageTwo.currentState?.validate();

    if (questionsItemsList.firstWhereOrNull(
          (element) => element.title.text.isEmpty,
        ) !=
        null) return;
    questionsItemsList.add(QuestionItem());
    update();
  }

  removeQuestion(int index) {
    questionsItemsList.removeAt(index);
    update();
  }

  removeQuestionOptin(int questionIndex, int index) {
    questionsItemsList[questionIndex].options.removeAt(index);
    if (questionsItemsList[questionIndex].trueAnswer == index)
      questionsItemsList[questionIndex].trueAnswer = 0;
    update();
  }

  addOptionTextController(int index) {
    formPageTwo.currentState?.validate();
    if (questionsItemsList[index].options.firstWhereOrNull(
              (element) => element.text.isEmpty,
            ) !=
        null) return;
    questionsItemsList[index].options.add(TextEditingController());
    update();
  }

  changeTrueAnswer(int index, int? val) {
    if (val == null) return;
    questionsItemsList[index].trueAnswer = val;
    update();
  }

  @override
  void onInit() {
    if (Get.arguments != null) {
      courseId = Get.arguments['courseId'];
      courseNameAr = Get.arguments['courseNameAr'];
      courseNameEn = Get.arguments['courseNameEn'];
      examId.value = Get.arguments['id'] ?? '';
      if (courseId != null) {
        selectedCourseValue = Course(
            id: courseId!,
            nameAr: courseNameAr!,
            nameEn: courseNameEn!,
            image: '',
            accepted: false,
            active: false,
            coachId: '',
            coachName: '',
            descriptionAr: '',
            descriptionEn: '',
            isPrivate: false,
            subjectId: '',
            subjectNameAr: '',
            subjectNameEn: '',
            pendingUsers: [],
            users: []);
      }

      //courseId.value = Get.arguments;
    }
    super.onInit();
    //if (examId.isNotEmpty) getData();

    ever(examId, (_) {
      if (examId.isNotEmpty) {
        getData();
      }
    });
  }

  bool isAfterIgnoringSeconds(DateTime dateTime1, DateTime dateTime2) {
    DateTime dateTimeWithoutSeconds1 =
        dateTime1.subtract(Duration(seconds: dateTime1.second));
    DateTime dateTimeWithoutSeconds2 =
        dateTime2.subtract(Duration(seconds: dateTime2.second));

    return dateTimeWithoutSeconds1.isAfter(dateTimeWithoutSeconds2);
  }

  String? vaildStartDate() {
    final now = DateTime.now();

    if (isAfterIgnoringSeconds(selectedStartTime, now)) {
      return null;
    } else {
      return "choose_time_in_future".tr;
    }
  }

  String? vaildEndDate() {
    if (isAfterIgnoringSeconds(selectedEndTime, selectedStartTime)) {
      return null;
    } else {
      return "end_time_must_be_after_start_time".tr;
    }
  }

  Future<void> getData() async {
    isLoading = true;
    update();
    try {
      examFullData = await examController.getExamFullData(examId.value);
      nameArController.text = examFullData!.nameAr;
      nameEnController.text = examFullData!.nameEn;
      dropDownFilterValue = examFullData!.language;
      selectedCourseValue = Course(
        id: examFullData!.courseId,
        nameAr: examFullData!.courseNameAr,
        nameEn: examFullData!.courseNameEn,
        image: '',
        accepted: false,
        active: false,
        coachId: '',
        coachName: '',
        descriptionAr: '',
        descriptionEn: '',
        isPrivate: false,
        subjectId: '',
        subjectNameAr: '',
        subjectNameEn: '',
        pendingUsers: [],
        users: [],
      );

      selectedStartTime = DateTime.parse(examFullData!.startDate).toLocal();
      selectedEndTime = DateTime.parse(examFullData!.endDate).toLocal();

      //questionsItemsList = [];
      // for (var question in examFullData!.questions) {}
      isLoading = false;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr).then((_) => Get.back());
    } catch (error) {
      showErrorDialog('error'.tr).then((_) => Get.back());
    }
  }

  Future<void> selectStartTime(BuildContext context) async {
    DateTime? picked = await showChooseDateAndTimeDialog(
        context, selectedStartTime, DateTime.now());

    if (picked != null && picked != selectedStartTime) {
      selectedStartTime = picked;
      update();
    }
  }

  Future<void> selectEndTime(BuildContext context) async {
    DateTime? picked = await showChooseDateAndTimeDialog(
        context,
        selectedEndTime,
        selectedEndTimeInit != null ? selectedEndTime : selectedStartTime);

    selectedEndTimeInit = picked;

    if (picked != null && picked != selectedEndTime) {
      selectedEndTime = picked;
      update();
    }
  }

  Future<void> submitData() async {
    final isValid = formPageTwo.currentState?.validate();
    if (isValid == null || !isValid) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(
        errorMessage,
      );
      return;
    }

    if ((nameArController.text.isEmpty ||
            nameEnController.text.isEmpty ||
            selectedCourseValue == null ||
            dropDownFilterValue == '' ||
            selectedEndTimeInit == null) ||
        questionsItemsList.firstWhereOrNull(
              (element) => !element.valid(),
            ) !=
            null) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(
        errorMessage,
      );
      return;
    }

    isLoadingButton = true;
    update();
    try {
      /* if (examFullData != null) {
        final updateNameAr = nameArController.text != examFullData!.nameAr;
        final updateNameEn = nameEnController.text != examFullData!.nameEn;
        final updateDescriptionAr =
            descriptionArController.text != examFullData!.descriptionAr;
        final updateDescriptionEn =
            descriptionEnController.text != examFullData!.descriptionEn;
        final updateImage = image != null;
        final updatePrivate = isPrivate != examFullData!.isPrivate;
        final updateSubjectId =
            selectedCourseValue!.id != examFullData!.subjectId;
        if (updateNameAr ||
            updateNameEn ||
            updateDescriptionAr ||
            updateDescriptionEn ||
            updateImage ||
            updatePrivate ||
            updateSubjectId)
          await courseController.updateCourseData(
            examId.value,
            nameAr: updateNameAr ? nameArController.text : null,
            nameEn: updateNameEn ? nameEnController.text : null,
            descriptionAr:
                updateDescriptionAr ? descriptionArController.text : null,
            descriptionEn:
                updateDescriptionEn ? descriptionEnController.text : null,
            image: updateImage ? (await getImage(image!))! : null,
            isPrivate: updatePrivate ? isPrivate : null,
            subjectId: updateSubjectId ? selectedCourseValue!.id : null,
          );
      } else*/
      {
        await examController.addExam(
            nameAr: nameArController.text,
            nameEn: nameEnController.text,
            courseId: selectedCourseValue!.id,
            language: dropDownFilterValue,
            endDate: selectedEndTime.toUtc().toIso8601String(),
            startDate: selectedStartTime.toUtc().toIso8601String(),
            questions: questionsItemsList);
        if (currentCousrse == selectedCourseValue!.id) {
          await _examController.fetchAndSetExams(0, selectedCourseValue!.id,
              isRefresh: true);
        }
      }

      isLoadingButton = false;
      update();
      Get.back();
      Get.showSnackbar(GetSnackBar(
          backgroundColor: Themes.primaryColorDark,
          messageText: Text(
            examFullData != null ? 'course_edited'.tr : 'course_added'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: Themes.primaryColorLight),
          ),
          duration: const Duration(seconds: 2)));
    } on HttpException catch (error) {
      var errorMessage = 'error'.tr;
      if (error.toString().contains('Not_enough_funds')) {
        errorMessage = 'Not_enough_funds'.tr;
      }
      isLoadingButton = false;
      update();
      showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'error'.tr;
      if (error.toString().contains('Not_enough_funds')) {
        errorMessage = 'Not_enough_funds'.tr;
      }
      isLoadingButton = false;
      update();
      showErrorDialog(errorMessage);
    }
  }

  Future<File?> getImage(Asset image) async {
    final byteData = await image.getByteData();

    final tempFile =
        File("${(await getTemporaryDirectory()).path}/${image.name}");
    final pickedImage = await tempFile.writeAsBytes(
      byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
    return await compressFile(pickedImage);
  }

  Future<void> paginatedRequest(int page, String? searchKey) async {
    searchKey == null
        ? await courseController.fetchAndSetCoachCourses(
            page,
          )
        : await courseController.search(searchKey, page, userController.userId,
            isCoach: true, isRefresh: prevSearchKey != searchKey);
    coursesList = searchKey == null
        ? courseController.coachCourses
        : courseController.searched;
    if (searchKey != null) {
      prevSearchKey = searchKey;
    }
    update();
  }

  onChanged(String? value) {
    debugPrint('$value');
    prevSearchKey = '';

    if (value == null) {
      selectedCourseValue = null;
    } else {
      selectedCourseValue =
          coursesList.firstWhere((element) => element.id == value);
    }
    update();
  }

  checkboxChanged(bool? val) {
    isPrivate = val!;

    update();
  }

  next() {
    if (page == 0) {
      final isValid = formPageOne.currentState?.validate();
      if (isValid == null || !isValid) {
        var errorMessage = 'fill_all_info'.tr;
        showErrorDialog(
          errorMessage,
        );
        return;
      }
      if (nameArController.text.isEmpty ||
          nameEnController.text.isEmpty ||
          selectedCourseValue == null ||
          dropDownFilterValue == '' ||
          selectedEndTimeInit == null) {
        var errorMessage = 'fill_all_info'.tr;
        showErrorDialog(
          errorMessage,
        );
        return;
      }
    }
    page++;
    update();
  }

  previous() {
    page--;
    update();
  }

// Method to update productId when a new product is selected
  updateExamId(
    String newExamId,
  ) {
    if (examId.value == newExamId) {
      getData();
    }
    examId.value = newExamId;
    update();
  }

  @override
  void onClose() {
    // Reset or cleanup logic
    examId = ''.obs;
    super.onClose();
  }

  @override
  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    nameEnFocusNode.dispose();
    super.dispose();
  }
}

class QuestionItem {
  final TextEditingController title = TextEditingController();
  final List<TextEditingController> options = [
    TextEditingController(),
    TextEditingController()
  ];
  int trueAnswer;
  QuestionItem({this.trueAnswer = 0});

  bool valid() {
    return title.text.isNotEmpty &&
        options.firstWhereOrNull(
              (element) => element.text.isNotEmpty,
            ) !=
            null;
  }
}
