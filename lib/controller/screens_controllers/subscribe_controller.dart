import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/model/permission.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import '../../locale/locale_controller.dart';
import '../../model/themes.dart';
import '../../utils/log_out_function.dart';
import '../../view/widgets/dialogs/confirm_payment_dialog.dart';
import '../models_controller/course_controller.dart';
import '../models_controller/generals_controller.dart';

class SubscribeController extends GetxController {
  bool _canPop = false;
  bool? _loadData;
  List<Permission> coachPermissions = [
    Permission(
        id: 'EDIT_COURSE', nameAr: "إعداد الدورات", nameEn: "Control courses"),
    Permission(
        id: 'EDIT_EXAM', nameAr: "إعداد الامتحانات", nameEn: "Edit exams"),
    //Permission(id: ,nameAr: ,nameEn: ),
  ];
  //final PermissionController _permissionController = Get.find();
  final GeneralsController _generalsController = Get.find();
  final MyLocaleController _localeController = Get.find();
  final CourseController _courseController = Get.find();
  final UserController _userController = Get.find();

  bool isLoading = false;

  UserController get userController => _userController;
  GeneralsController get generalsController => _generalsController;

  @override
  void onInit() {
    if (Get.arguments != null) {
      _canPop = Get.arguments['canPop'] ?? false;
      _loadData = Get.arguments['loadData'] ?? false;
    }

    //   coachPermissions = _permissionController.coachPermissions;
    super.onInit();
  }

  void onPageChanged() {
    /*   Future.delayed(const Duration(seconds: 3)).then((value) {
      if (!_canPop && !isLoading) {
        onClosePress(withMessage: false);

        //Get.offAllNamed('/main-screen', arguments: _loadData);
      }
    });

    update(); */
  }

  void onClosePress({bool withMessage = true}) {
    if (isLoading) {
      if (withMessage)
        showErrorDialog('please_wait_loading'.tr, title: 'wait'.tr);

      return;
    }
    if (_canPop) {
      Get.back();
    } else {
      if (Get.currentRoute != '/main-screen')
        Get.offAllNamed('/main-screen', arguments: _loadData);
    }
  }

  Future<bool> onPop() async {
    if (isLoading) {
      showErrorDialog('please_wait_loading'.tr, title: 'wait'.tr);
      return false;
    } else {
      if (!_canPop) {
        onClosePress(withMessage: false);

        //    Get.offAllNamed('/main-screen', arguments: _loadData);
        return false;
      }
      return true;
    }
  }

  void subscribe() async {
    final result =
        await confirPaymentDialog(_generalsController.coachSubscriptionFee);
    if (result == null || !result) {
      return;
    }

    isLoading = true;
    update();

    try {
      await _userController.registerAsCoach();
      //

      // Get.offAllNamed('/login', arguments: _loadData);
      await logOutFunction(
          _userController, _courseController.myCoursesIds, _localeController);
      Get.until((route) => route.isFirst);
      Get.offNamed('/welcome');
      Get.showSnackbar(GetSnackBar(
          backgroundColor: Themes.primaryColorDark,
          messageText: Text(
            'subscribed_login_again'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: Themes.primaryColorLight),
          ),
          duration: const Duration(seconds: 2)));
      isLoading = false;
      update();
    } on HttpException catch (error) {
      var errorMessage = 'error'.tr;

      if (error.toString().contains('Not_enough_funds')) {
        errorMessage = 'Not_enough_funds'.tr;
      }

      showErrorDialog(errorMessage);
      //   .then((_) => Get.offAllNamed('/main-screen', arguments: _loadData));
      isLoading = false;
      update();
    } catch (error) {
      var errorMessage = 'error'.tr;
      if (error.toString().contains('Not_enough_funds')) {
        errorMessage = 'Not_enough_funds'.tr;
      }

      showErrorDialog(errorMessage);
      //.then((_) => Get.offAllNamed('/main-screen', arguments: _loadData));
      isLoading = false;
      update();
    }
  }
}
