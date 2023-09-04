import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:lottie/lottie.dart';
import '../../../utils/lottie_files.dart';

import '../../../controller/screens_controllers/loading_controller.dart';

class LoadMoreWidget extends StatelessWidget {
  final bool auth;
  final bool exam;
  final bool chat;
  final bool isDefault;
  final bool image;
  const LoadMoreWidget(
      {Key? key,
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
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              height: 50,
              repeat: true,
              animate: true,
              fit: BoxFit.cover),
        ),
      ),
    );
  }
}
