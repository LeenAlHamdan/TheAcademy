import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/model/course.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import '../../model/subject.dart';
import '../../model/themes.dart';
import '../../utils/compress_file.dart';
import '../../view/widgets/dialogs/confirm_payment_dialog.dart';
import '../models_controller/generals_controller.dart';
import '../models_controller/subject_controller.dart';

class AddCourseScreenController extends GetxController {
  RxString courseId = ''.obs;
  String? subjectId;
  String? subjectNameAr;
  String? subjectNameEn;
  CourseFullData? courseFullData;
  var isLoading = false;
  var isLoadingButton = false;

  final form = GlobalKey<FormState>();

  Subject? selectedSubjectValue;
  List<Subject> subjectsList = [];
  var prevSearchKey = '';

  bool isPrivate = false;

  final SubjectController _subjectController = Get.find();
  final CourseController _courseController = Get.find();
  final UserController _userController = Get.find();
  final GeneralsController _generalsController = Get.find();

  CourseController get courseController => _courseController;
  UserController get userController => _userController;
  SubjectController get subjectController => _subjectController;

  final nameArController = TextEditingController();
  final nameEnController = TextEditingController();
  final descriptionArController = TextEditingController();
  final descriptionEnController = TextEditingController();

  final nameEnFocusNode = FocusNode();
  final descriptionArFocusNode = FocusNode();
  final descriptionEnFocusNode = FocusNode();

  Asset? image;
  String? imagePath;

  void selectMultiImage(List<Asset> images) {
    image = images.first;
    update();
  }

  @override
  void onInit() {
    if (Get.arguments != null) {
      if (Get.arguments['id'] != null) courseId.value = Get.arguments['id'];
      subjectId = Get.arguments['subjectId'];
      subjectNameAr = Get.arguments['subjectNameAr'];
      subjectNameEn = Get.arguments['subjectNameEn'];
      if (subjectId != null) {
        selectedSubjectValue = Subject(
          id: subjectId!,
          nameAr: subjectNameAr!,
          nameEn: subjectNameEn!,
          image: '',
          categoryId: '',
        );
      }

      //courseId.value = Get.arguments;
    }
    super.onInit();
    if (courseId.isNotEmpty) getData();

    ever(courseId, (_) {
      if (courseId.isNotEmpty) {
        getData();
      }
    });
  }

  Future<void> getData() async {
    isLoading = true;
    update();
    try {
      courseFullData = await _courseController.getCourseFullData(
          courseId.value, userController.userId);
      nameArController.text = courseFullData!.nameAr;
      nameEnController.text = courseFullData!.nameEn;
      descriptionArController.text = courseFullData!.descriptionAr;
      descriptionEnController.text = courseFullData!.descriptionEn;
      isPrivate = courseFullData!.isPrivate;
      imagePath = courseFullData!.image;
      selectedSubjectValue = Subject(
          categoryId: '',
          image: '',
          id: courseFullData!.subjectId,
          nameAr: courseFullData!.subjectNameAr,
          nameEn: courseFullData!.subjectNameEn);

      isLoading = false;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr).then((_) => Get.back());
    } catch (error) {
      showErrorDialog('error'.tr).then((_) => Get.back());
    }
  }

  Future<void> submitData() async {
    final isValid = form.currentState?.validate();
    if (isValid == null || !isValid) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(
        errorMessage,
      );
      return;
    }
    if (nameArController.text.isEmpty ||
        nameEnController.text.isEmpty ||
        descriptionArController.text.isEmpty ||
        descriptionEnController.text.isEmpty ||
        selectedSubjectValue == null ||
        (courseFullData == null && image == null)) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(
        errorMessage,
      );
      return;
    }

    if (courseFullData == null && isPrivate) {
      final result =
          await confirPaymentDialog(_generalsController.privateCourseFee);
      if (result == null || !result) {
        return;
      }
    }
    isLoadingButton = true;
    update();
    try {
      if (courseFullData != null) {
        final updateNameAr = nameArController.text != courseFullData!.nameAr;
        final updateNameEn = nameEnController.text != courseFullData!.nameEn;
        final updateDescriptionAr =
            descriptionArController.text != courseFullData!.descriptionAr;
        final updateDescriptionEn =
            descriptionEnController.text != courseFullData!.descriptionEn;
        final updateImage = image != null;
        final updatePrivate = isPrivate != courseFullData!.isPrivate;
        final updateSubjectId =
            selectedSubjectValue!.id != courseFullData!.subjectId;
        if (updateNameAr ||
            updateNameEn ||
            updateDescriptionAr ||
            updateDescriptionEn ||
            updateImage ||
            updatePrivate ||
            updateSubjectId)
          await courseController.updateCourseData(
            courseId.value,
            nameAr: updateNameAr ? nameArController.text : null,
            nameEn: updateNameEn ? nameEnController.text : null,
            descriptionAr:
                updateDescriptionAr ? descriptionArController.text : null,
            descriptionEn:
                updateDescriptionEn ? descriptionEnController.text : null,
            image: updateImage ? (await getImage(image!))! : null,
            isPrivate: updatePrivate ? isPrivate : null,
            subjectId: updateSubjectId ? selectedSubjectValue!.id : null,
          );
      } else {
        await courseController.addCourse(
          nameAr: nameArController.text,
          nameEn: nameEnController.text,
          descriptionAr: descriptionArController.text,
          descriptionEn: descriptionEnController.text,
          image: (await getImage(image!))!,
          isPrivate: isPrivate,
          subjectId: selectedSubjectValue!.id,
        );
      }

      isLoadingButton = false;
      update();
      Get.back();
      Get.showSnackbar(GetSnackBar(
          backgroundColor: Themes.primaryColorDark,
          messageText: Text(
            courseFullData != null ? 'course_edited'.tr : 'course_added'.tr,
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
        ? await subjectController.fetchAndSetSubjects(
            page,
          )
        : await subjectController.search(searchKey, page,
            isRefresh: prevSearchKey != searchKey);
    subjectsList = searchKey == null
        ? subjectController.subjects
        : subjectController.searched;
    if (searchKey != null) {
      prevSearchKey = searchKey;
    }
    update();
  }

  onChanged(String? value) {
    debugPrint('$value');
    prevSearchKey = '';

    if (value == null) {
      selectedSubjectValue = null;
    } else {
      selectedSubjectValue =
          subjectsList.firstWhere((element) => element.id == value);
    }
    update();
  }

  checkboxChanged(bool? val) {
    isPrivate = val!;

    update();
  }

// Method to update productId when a new product is selected
  updateCourseId(
    String newCourseId,
  ) {
    if (courseId.value == newCourseId) {
      getData();
    }
    courseId.value = newCourseId;
    update();
  }

  @override
  void onClose() {
    // Reset or cleanup logic
    courseId = ''.obs;
    super.onClose();
  }

  @override
  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    descriptionArController.dispose();
    descriptionEnController.dispose();
    nameEnFocusNode.dispose();
    descriptionArFocusNode.dispose();
    descriptionEnFocusNode.dispose();
    super.dispose();
  }
}
