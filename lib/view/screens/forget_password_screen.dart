import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/forget_password_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/loading_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/my_edit_text.dart';
import 'package:the_academy/view/widgets/screens_background.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetBuilder<ForgetPasswordController>(builder: (controller) {
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: controller.codeSended
                                  ? Get.height * 0.12
                                  : Get.height * 0.2,
                              right: Get.width * 0.07,
                              left: Get.width * 0.07),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  'reset_password'.tr,
                                  style: Get.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Get.isDarkMode
                                          ? Themes.textColorDark
                                          : Themes.textColor,
                                      fontSize: 18),
                                ),
                              ),
                              UnconstrainedBox(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 100,
                                  fit: BoxFit.cover,
                                  width: 100,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.07),
                          child: controller.codeSended
                              ? SlideTransition(
                                  position: controller.animation,
                                  child: Form(
                                    key: controller.formPageOne,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children:
                                          codeSendedWidget(controller, context),
                                    ),
                                  ),
                                )
                              : Form(
                                  key: controller.formPageTwo,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: codeNotSendedWidget(
                                        controller, context),
                                  ),
                                ),
                        ),
                      ],
                    );
                  }),
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

  List<Widget> codeSendedWidget(
      ForgetPasswordController controller, BuildContext context) {
    return [
      MyEditText(
        title: 'email'.tr,
        prefixIcon: Icons.email_outlined,
        textDirection: TextDirection.ltr,
        enabled: false,
        textController: controller.emailController,
        onSubmitted: (_) =>
            FocusScope.of(context).requestFocus(controller.codeFocusNode),
      ),
      SizedBox(
        height: Get.height * 0.028,
      ),
      MyEditText(
          title: 'code'.tr,
          prefixIcon: Icons.password,
          textDirection: TextDirection.ltr,
          enabled: !controller.isLoading,
          textController: controller.codeController,
          textFocusNode: controller.codeFocusNode,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) {
              return 'field_required'.tr;
            }

            return null;
          },
          onSubmitted: (_) => FocusScope.of(context)
              .requestFocus(controller.passwordFocusNode)),
      SizedBox(
        height: Get.height * 0.028,
      ),
      MyEditText(
        title: 'new_password'.tr,
        prefixIcon: Icons.lock_outline,
        suffixIcon: IconButton(
          onPressed: () => controller.onShowPasswordClick(),
          icon: Icon(controller.passwordIsVisible
              ? Icons.remove_red_eye
              : Icons.remove_red_eye_outlined),
        ),
        textDirection: TextDirection.ltr,
        enabled: !controller.isLoading,
        obscureText: !controller.passwordIsVisible,
        textFocusNode: controller.passwordFocusNode,
        textController: controller.passwordController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'field_required'.tr;
          }
          if (value.length < 8) return 'WEAK_PASSWORD'.tr;

          return null;
        },
        onSubmitted: (_) => FocusScope.of(context)
            .requestFocus(controller.confirmPasswordFocusNode),
      ),
      SizedBox(
        height: Get.height * 0.028,
      ),
      MyEditText(
        title: 'confirm_new_password'.tr,
        prefixIcon: Icons.lock_outline,
        textDirection: TextDirection.ltr,
        enabled: !controller.isLoading,
        obscureText: !controller.passwordIsVisible,
        textFocusNode: controller.confirmPasswordFocusNode,
        textController: controller.confirmPasswordController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'field_required'.tr;
          }
          if (controller.passwordController.text.compareTo(value) != 0)
            return 'not_matching_passwords'.tr;

          return null;
        },
        onSubmitted: (_) => controller.restPassword(),
      ),
      if (controller.isLoading)
        LoadingWidget(auth: true)
      else
        Container(
          padding: const EdgeInsets.only(bottom: 8, top: 10),
          margin:
              const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 30),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Themes.primaryColorLight,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 24,
                            color: Themes.primaryColorDark.withOpacity(0.2),
                          ),
                        ]),
                    child: Text(
                      'cancel'.tr,
                      textAlign: TextAlign.center,
                      style: Get.textTheme.bodyLarge,
                    ),
                  ),
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    controller.restPassword();
                  },
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Themes.primaryColor,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 24,
                            color: Themes.primaryColorDark.withOpacity(0.2),
                          ),
                        ]),
                    child: Text(
                      'reset'.tr,
                      textAlign: TextAlign.center,
                      style: Get.textTheme.bodyLarge
                          ?.copyWith(color: Themes.primaryColorLight),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${'no_code'.tr} ',
            style: Get.textTheme.titleLarge?.copyWith(
                color:
                    Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
          ),
          GestureDetector(
            onTap: () {
              controller.requestCode();
            },
            child: Text(
              'resend'.tr,
              style: Get.textTheme.titleLarge!.copyWith(
                color: Themes.primaryColor,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> codeNotSendedWidget(
      ForgetPasswordController controller, BuildContext context) {
    return [
      Padding(
        padding: EdgeInsets.only(
            bottom: 18,
            right: Get.locale == const Locale('ar') ? 24 : 0.0,
            left: Get.locale == const Locale('ar') ? 0 : 24.0),
        child: Text(
          'reset_password_subtitle'.tr,
          textAlign: TextAlign.start,
          style: Get.textTheme.titleLarge?.copyWith(
              color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
        ),
      ),
      MyEditText(
        title: 'email'.tr,
        prefixIcon: Icons.email_outlined,
        textDirection: TextDirection.ltr,
        enabled: !controller.isLoading,
        textController: controller.emailController,
        onSubmitted: (_) => controller.requestCode(),
        validator: (value) {
          if (value!.isEmpty) {
            return 'field_required'.tr;
          }
          if (!value.removeAllWhitespace.isEmail) return 'INVALID_EMAIL'.tr;

          return null;
        },
      ),
      if (controller.isLoading)
        LoadingWidget(auth: true)
      else
        Container(
          padding: const EdgeInsets.only(bottom: 8, top: 50),
          margin:
              const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 50),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  controller.requestCode();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Themes.primaryColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 24,
                          color: Themes.primaryColor.withOpacity(0.2),
                        ),
                      ]),
                  child: Text(
                    'send_code'.tr,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.bodyLarge?.copyWith(
                      color: Themes.primaryColorLight,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: Get.height * 0.018,
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Themes.primaryColorLight,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 24,
                          color: Themes.primaryColorDark.withOpacity(0.2),
                        ),
                      ]),
                  child: Text(
                    'cancel'.tr,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
    ];
  }
}
