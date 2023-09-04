import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/login_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/loading_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/my_button.dart';
import 'package:the_academy/view/widgets/custom_widgets/my_edit_text.dart';
import 'package:the_academy/view/widgets/screens_background.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

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
                    padding: EdgeInsets.only(top: Get.height * 0.12),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: Get.height * 0.095,
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.07,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.07),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'login_subtitle'.tr,
                          textAlign: TextAlign.center,
                          style: Get.textTheme.headlineSmall?.copyWith(
                              color: Get.isDarkMode
                                  ? Themes.textColorDark
                                  : Themes.textColor),
                        ),
                        SizedBox(
                          height: Get.height * 0.047,
                        ),
                        GetBuilder<LoginController>(
                          init: LoginController(),
                          builder: (controller) {
                            return Form(
                              key: controller.form,
                              child: Column(
                                children: [
                                  MyEditText(
                                      title: 'email'.tr,
                                      prefixIcon: Icons.email_outlined,
                                      textDirection: TextDirection.ltr,
                                      enabled: !controller.isLoading,
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
                                    height: Get.height * 0.031,
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
                                    obscureText: !controller.passwordIsVisible,
                                    textFocusNode: controller.passwordFocusNode,
                                    textController:
                                        controller.passwordController,
                                    onSubmitted: (_) {
                                      controller.submitData();
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'field_required'.tr;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: Get.height * 0.039,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.039),
                          child: GestureDetector(
                            onTap: () {
                              Get.toNamed('/forget-passowrd');
                            },
                            child: Text(
                              'forget_password'.tr,
                              textAlign: TextAlign.end,
                              style: Get.textTheme.titleLarge?.copyWith(
                                  color: Get.isDarkMode
                                      ? Themes.textColorDark
                                      : Themes.textColor),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Get.height * 0.039,
                        ),
                        GetBuilder<LoginController>(builder: (controller) {
                          return controller.isLoading
                              ? LoadingWidget(auth: true)
                              : MyButton(
                                  onTap: () => controller.submitData(),
                                  shadowColor:
                                      Themes.primaryColor.withOpacity(0.2),
                                  title: 'login_to_accont'.tr,
                                  textColor: Themes.primaryColorLight,
                                  backgroundColor: Themes.primaryColor,
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
                        '${'no_account'.tr} ',
                        style: Get.textTheme.titleLarge?.copyWith(
                            color: Get.isDarkMode
                                ? Themes.primaryColorLightDark
                                : Themes.textColor),
                      ),
                      GestureDetector(
                        onTap: () => Get.offNamed('/sign-up'),
                        child: Text(
                          'sign_up'.tr,
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
