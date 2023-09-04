import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/data/api/api_client.dart';
import 'package:the_academy/main.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import '../../utils/firebase_message_handler.dart';
import 'main_screen_controller.dart';

class LoginController extends GetxController {
  bool passwordIsVisible = false;
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordFocusNode = FocusNode();

  final form = GlobalKey<FormState>();

  void onShowPasswordClick() {
    passwordIsVisible = !passwordIsVisible;
    update();
  }

  final MainScreenController _mainScreenController = Get.find();
  final UserController _userController = Get.find();
  //final PermissionController permissionController = Get.find();
  final ApiClient _apiClient = Get.find();

  void submitData() async {
    final isValid = form.currentState?.validate();

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(errorMessage);
      return;
    }

    if (!emailController.text.removeAllWhitespace.isEmail) {
      var errorMessage = 'INVALID_EMAIL'.tr;
      showErrorDialog(
        errorMessage,
      );
      return;
    }
    if (isValid == null || !isValid) return;

    final email = emailController.text.removeAllWhitespace;
    final password = passwordController.text;

    isLoading = true;
    update();
    try {
      await _userController.logIn(email, password);

      _apiClient.updateHeader(_userController.token);
      MyApp.createSocketConnection();
      /*  await permissionController
          .fetchAndSetCoachPermission(userController.token); */
      await subscribeTopics(Get.find());

      _mainScreenController.updateLoadData(true);
      _userController.isUser
          ? Get.offAllNamed('/subscribe', arguments: {
              'loadData': true,
            })
          : Get.offAllNamed('/main-screen', arguments: true);
      isLoading = false;
      update();
    } on HttpException catch (error) {
      isLoading = false;
      update();
      var errorMessage = 'authentication_failed'.tr;
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'EMAIL_NOT_FOUND'.tr;
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'INVALID_PASSWORD'.tr;
      } else if (error.toString().contains('ERROR')) {
        errorMessage = 'error_message'.tr;
      }
      showErrorDialog(errorMessage);
    } catch (error) {
      debugPrint(error.toString());
      isLoading = false;
      update();
      var errorMessage = 'authentication_failed'.tr;
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'EMAIL_NOT_FOUND'.tr;
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'INVALID_PASSWORD'.tr;
      } else if (error.toString().contains('ERROR')) {
        errorMessage = 'error_message'.tr;
      }
      showErrorDialog(
        errorMessage,
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }
}
