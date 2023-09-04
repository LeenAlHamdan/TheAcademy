import 'package:flutter/material.dart';
import '../../../model/themes.dart';
import '../../../utils/lottie_files.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../controller/screens_controllers/loading_controller.dart';

class LoadingWidget extends StatelessWidget {
  final bool withPadding;
  final bool auth;
  final bool exam;
  final bool chat;
  final bool isDefault;

  const LoadingWidget({
    Key? key,
    this.withPadding = true,
    this.auth = false,
    this.exam = false,
    this.chat = false,
    this.isDefault = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoadingController>(
      init: LoadingController(),
      builder: (controller) => Get.isDarkMode
          ? ColorFiltered(
              colorFilter: ColorFilter.mode(
                Themes.textColorDark,
                BlendMode.srcATop,
              ),
              child: getWidget(controller))
          : getWidget(controller),
    );
  }

  Padding getWidget(LoadingController controller) {
    return Padding(
      padding: withPadding ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
      child: Center(
        child: Lottie.asset(
            auth
                ? LottieFiles.$88276_lock_icon
                : exam
                    ? LottieFiles.$94570_eye_examn_icon
                    : chat
                        ? LottieFiles.$88272_chat_icon
                        : isDefault
                            ? LottieFiles.$6895_loading_icon
                            : LottieFiles.$48508_book_icon,
            controller: controller.bellController,
            height: 60,
            repeat: true,
            fit: BoxFit.cover),

        /*  CircularProgressIndicator(
        color: Themes.primaryColor,
        strokeWidth: 2,
      ) */
      ),
    );
  }
}
