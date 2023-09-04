import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/my_button.dart';
import 'package:the_academy/view/widgets/screens_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomPaint(
          painter: ScreenBackgoundPainter(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: Get.height * 0.09),
                  child: Image.asset(
                    'assets/images/welcome_page_img.png',
                    height: Get.height * 0.26,
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.033,
                ),
                Image.asset(
                  'assets/images/logo.png',
                  height: Get.height * 0.095,
                ),
                SizedBox(
                  height: Get.height * 0.014,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.width * 0.11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'join_the_academy'.tr,
                        textAlign: TextAlign.center,
                        style: Get.textTheme.headlineMedium?.copyWith(
                            color: Get.isDarkMode
                                ? Themes.textColorDark
                                : Themes.textColor),
                      ),
                      SizedBox(
                        height: Get.height * 0.04,
                      ),
                      Text('join_the_academy_subtitle'.tr,
                          textAlign: TextAlign.center,
                          style: Get.textTheme.titleLarge?.copyWith(
                            color: Get.isDarkMode
                                ? Themes.primaryColorLightDark
                                : Themes.primaryColorDark,
                          )),
                      SizedBox(
                        height: Get.height * 0.063,
                      ),
                      MyButton(
                        onTap: () => Get.toNamed('/sign-up'),
                        backgroundColor: Themes.primaryColor,
                        shadowColor: Themes.primaryColor.withOpacity(0.2),
                        title: 'sign_up_with_email'.tr,
                        textColor: Themes.primaryColorLight,
                      ),
                      SizedBox(
                        height: Get.height * 0.018,
                      ),
                      MyButton(
                        onTap: () => Get.toNamed(
                          '/login',
                        ),
                        backgroundColor: Themes.primaryColorLight,
                        shadowColor: Themes.primaryColorDark.withOpacity(0.2),
                        title: 'login'.tr,
                        textColor: Themes.textColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
