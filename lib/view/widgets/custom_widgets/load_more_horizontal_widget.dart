import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../controller/screens_controllers/loading_controller.dart';
import '../../../utils/lottie_files.dart';

class LoadMoreHorizontalWidget extends StatelessWidget {
  final bool withPadding;
  final bool auth;
  final bool exam;
  final bool chat;
  final bool isDefault;
  final bool image;

  const LoadMoreHorizontalWidget(
      {Key? key,
      this.withPadding = true,
      this.auth = false,
      this.exam = false,
      this.chat = false,
      this.isDefault = false,
      this.image = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoadingController>(
      init: LoadingController(),
      builder: (controller) => Padding(
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
                              : image
                                  ? LottieFiles
                                      .$9354_image_viewer_icon_animation
                                  : LottieFiles.$48508_book_icon,
              controller: controller.bellController,
              height: 20,
              repeat: true,
              animate: true,
              fit: BoxFit.cover),
        ),
      ),
    );
  }
}
