import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/sign_up_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/loading_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/my_button.dart';
import 'package:the_academy/view/widgets/custom_widgets/my_edit_text.dart';
import 'package:the_academy/view/widgets/screens_background.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomPaint(
          painter: ScreenBackgoundPainter(),
          child: SingleChildScrollView(
            child: SizedBox(
              height: Get.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: Get.height * 0.088),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: Get.height * 0.095,
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.058,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.07),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.046),
                          child: Text(
                            'sign_up_subtitle'.tr,
                            style: Get.textTheme.headlineSmall?.copyWith(
                                color: Get.isDarkMode
                                    ? Themes.textColorDark
                                    : Themes.textColor),
                          ),
                        ),
                        SizedBox(
                          height: Get.height * 0.027,
                        ),
                        GetBuilder<SignUpController>(
                          init: SignUpController(),
                          builder: (controller) {
                            return Form(
                              key: controller.form,
                              child: Column(
                                children: [
                                  MyEditText(
                                      title: 'full_name'.tr,
                                      prefixIcon: Icons.person_outline_rounded,
                                      enabled: !controller.isLoading,
                                      textController: controller.nameController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'field_required'.tr;
                                        }
                                        if (value.length < 3)
                                          return 'name_is_too_short'.tr;
                                        return null;
                                      },
                                      onSubmitted: (_) => FocusScope.of(context)
                                          .requestFocus(
                                              controller.emailFocusNode)),
                                  SizedBox(
                                    height: Get.height * 0.028,
                                  ),
                                  MyEditText(
                                      title: 'email'.tr,
                                      prefixIcon: Icons.email_outlined,
                                      textDirection: TextDirection.ltr,
                                      enabled: !controller.isLoading,
                                      textFocusNode: controller.emailFocusNode,
                                      textController:
                                          controller.emailController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'field_required'.tr;
                                        }
                                        if (!value.removeAllWhitespace.isEmail)
                                          return 'INVALID_EMAIL'.tr;

                                        return null;
                                      },
                                      onSubmitted: (_) => FocusScope.of(context)
                                          .requestFocus(
                                              controller.passwordFocusNode)),
                                  SizedBox(
                                    height: Get.height * 0.028,
                                  ),
                                  MyEditText(
                                      title: 'password'.tr,
                                      prefixIcon: Icons.lock_outline,
                                      suffixIcon: IconButton(
                                        onPressed: () =>
                                            controller.onShowPasswordClick(),
                                        icon: Icon(controller.passwordIsVisible
                                            ? Icons.remove_red_eye
                                            : Icons.remove_red_eye_outlined),
                                      ),
                                      textDirection: TextDirection.ltr,
                                      enabled: !controller.isLoading,
                                      obscureText:
                                          !controller.passwordIsVisible,
                                      textFocusNode:
                                          controller.passwordFocusNode,
                                      textController:
                                          controller.passwordController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'field_required'.tr;
                                        }
                                        if (value.length < 8)
                                          return 'WEAK_PASSWORD'.tr;

                                        return null;
                                      },
                                      onSubmitted: (_) => FocusScope.of(context)
                                          .requestFocus(controller
                                              .confirmPasswordFocusNode)),
                                  SizedBox(
                                    height: Get.height * 0.028,
                                  ),
                                  MyEditText(
                                    title: 'confirm_new_password'.tr,
                                    prefixIcon: Icons.lock_outline,
                                    textDirection: TextDirection.ltr,
                                    enabled: !controller.isLoading,
                                    obscureText: !controller.passwordIsVisible,
                                    textFocusNode:
                                        controller.confirmPasswordFocusNode,
                                    textController:
                                        controller.confirmPasswordController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'field_required'.tr;
                                      }
                                      if (controller.passwordController.text
                                              .compareTo(value) !=
                                          0) return 'not_matching_passwords'.tr;

                                      return null;
                                    },
                                    onSubmitted: (_) => controller.submitData(),
                                  ),
                                  SizedBox(
                                    height: Get.height * 0.038,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        GetBuilder<SignUpController>(builder: (controller) {
                          return controller.isLoading
                              ? LoadingWidget(
                                  auth: true,
                                )
                              : MyButton(
                                  onTap: () => controller.submitData(),
                                  backgroundColor: Themes.primaryColor,
                                  shadowColor:
                                      Themes.primaryColor.withOpacity(0.2),
                                  title: 'sign_up'.tr,
                                  textColor: Themes.primaryColorLight,
                                );
                        }),
                      ],
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${'have_account'.tr} ',
                        style: Get.textTheme.titleLarge?.copyWith(
                            color: Get.isDarkMode
                                ? Themes.primaryColorLightDark
                                : Themes.textColor),
                      ),
                      GestureDetector(
                        onTap: () => Get.offNamed('/login'),
                        child: Text(
                          'sign_in'.tr,
                          style: Get.textTheme.titleLarge!.copyWith(
                            color: Themes.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Get.height * 0.066,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
