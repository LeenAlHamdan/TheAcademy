import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/data/api/api_client.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import '../../main.dart';
import '../../utils/firebase_message_handler.dart';
import 'main_screen_controller.dart';

class SignUpController extends GetxController {
  bool passwordIsVisible = false;
  bool isLoading = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();
  final MainScreenController _mainScreenController = Get.find();

  final form = GlobalKey<FormState>();

  void onShowPasswordClick() {
    passwordIsVisible = !passwordIsVisible;
    update();
  }

  //final PermissionController permissionController = Get.find();
  final UserController _userController = Get.find();
  final ApiClient _apiClient = Get.find();

  void submitData() async {
    final isValid = form.currentState?.validate();
    /* if (isValid == null || !isValid) {
        var errorMessage = 'fill_all_info'.tr;
        showErrorDialog(
          errorMessage,
        );
        return;
      } */

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(errorMessage);
      return;
    }

    if (nameController.text.length < 3) {
      var errorMessage = 'name_is_too_short'.tr;
      showErrorDialog(errorMessage);
      return;
    }

    if (passwordController.text.compareTo(confirmPasswordController.text) !=
        0) {
      var errorMessage = 'not_matching_passwords'.tr;
      showErrorDialog(
        errorMessage,
      );
      return;
    }

    /* RegExp exp = RegExp(
        '^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@\$!%*?&])[A-Za-z\\d@\$!%*?&]{8,}\$');
    String str = _passwordController.text;
    final m = exp.matchAsPrefix(str);
 */
    if (passwordController.text.length < 8) {
      var errorMessage = 'WEAK_PASSWORD'.tr;
      showErrorDialog(
        errorMessage,
      );
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
    final name = nameController.text;
    final password = passwordController.text;
    isLoading = true;
    update();
    try {
      await _userController.signup(email, password, name);

      _apiClient.updateHeader(_userController.token);
      MyApp.createSocketConnection();

      /*   await permissionController
          .fetchAndSetCoachPermission(userController.token);
 */
      await subscribeTopics(Get.find());
      _mainScreenController.updateLoadData(true);
      Get.offAllNamed('/subscribe', arguments: {
        'loadData': true,
      });
      isLoading = false;
      update();
    } on HttpException catch (error) {
      isLoading = false;
      update();
      var errorMessage = 'authentication_failed';
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'EMAIL_NOT_FOUND';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'INVALID_PASSWORD';
      } else if (error.toString().contains('EMAIL_OR_PHONE_EXISTS')) {
        errorMessage = 'EMAIL_OR_PHONE_EXISTS';
      }
      showErrorDialog(errorMessage.tr);
    } catch (error) {
      isLoading = false;
      update();
      var errorMessage = 'authentication_failed';
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'EMAIL_NOT_FOUND';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'INVALID_PASSWORD';
      } else if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'EMAIL_EXISTS';
      }
      showErrorDialog(errorMessage.tr);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
