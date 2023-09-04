import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

class ForgetPasswordController extends GetxController
    with GetTickerProviderStateMixin {
  late final _animationController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );
  late final Animation<Offset> animation =
      Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero)
          .animate(_animationController);

  final formPageOne = GlobalKey<FormState>();
  final formPageTwo = GlobalKey<FormState>();

  bool passwordIsVisible = false;
  bool isLoading = false;
  bool codeSended = false;
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final codeFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  final UserController _userController = Get.find();

  @override
  void onInit() {
    super.onInit();
    animation.addListener(() => update());
  }

  void onShowPasswordClick() {
    passwordIsVisible = !passwordIsVisible;
    update();
  }

  void requestCode() async {
    final isValid = formPageTwo.currentState?.validate();

    if (emailController.text.isEmpty) {
      var errorMessage = 'fill_all_info'.tr;
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
    final email = emailController.text.removeAllWhitespace;

    isLoading = true;
    update();
    try {
      await _userController.requestPasswordCode(email);
      codeSended = true;
      _animationController.forward();
      isLoading = false;
      update();
      if (isValid == null || !isValid) return;
    } on HttpException catch (error) {
      isLoading = false;
      update();
      var errorMessage = 'authentication_failed'.tr;
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'EMAIL_NOT_FOUND'.tr;
      } else if (error.toString().contains('ERROR')) {
        errorMessage = 'error_message'.tr;
      }
      showErrorDialog(
        errorMessage,
      );

      codeSended = false;
      update();
    } catch (error) {
      isLoading = false;
      update();
      var errorMessage = 'error_message'.tr;
      showErrorDialog(
        errorMessage,
      );
      codeSended = false;
      update();
    }
  }

  void restPassword() async {
    final isValid = formPageOne.currentState?.validate();

    if (emailController.text.isEmpty ||
        codeController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(
        errorMessage,
      );
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
    if (!emailController.text.removeAllWhitespace.isEmail) {
      var errorMessage = 'INVALID_EMAIL'.tr;
      showErrorDialog(
        errorMessage,
      );
      return;
    }

    if (passwordController.text.length < 8) {
      var errorMessage = 'WEAK_PASSWORD'.tr;
      showErrorDialog(
        errorMessage,
      );
      return;
    }
    if (isValid == null || !isValid) return;

    final email = emailController.text.removeAllWhitespace;
    final password = passwordController.text;
    final code = codeController.text;

    isLoading = true;
    update();

    try {
      await _userController.restPasswordWithCode(email, password, code);
      Get.back();
      isLoading = false;
      update();
    } on HttpException catch (error) {
      isLoading = false;
      update();
      var errorMessage = 'authentication_failed'.tr;
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'EMAIL_NOT_FOUND'.tr;
      } else if (error.toString().contains('INVAILD_CODE')) {
        errorMessage = 'INVAILD_CODE'.tr;
      } else if (error.toString().contains('ERROR')) {
        errorMessage = 'error_message'.tr;
      }
      showErrorDialog(
        errorMessage,
      );
    } catch (error) {
      isLoading = false;
      update();
      var errorMessage = 'error_message'.tr;
      showErrorDialog(
        errorMessage,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    codeFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
