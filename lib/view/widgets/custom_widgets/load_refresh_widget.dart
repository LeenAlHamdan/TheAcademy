import 'package:flutter/material.dart';
import '../../../model/themes.dart';
import '../../../utils/lottie_files.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:the_academy/controller/screens_controllers/loading_refresh_controller.dart';

class LoadRefreshWidget extends StatelessWidget {
  final bool withPadding;

  const LoadRefreshWidget({
    Key? key,
    this.withPadding = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoadingRefreshController>(
      init: LoadingRefreshController(),
      builder: (controller) => Padding(
        padding: withPadding ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            Get.isDarkMode
                ? Themes.textColorDark
                : Themes.textColor, // Set your desired color here
            BlendMode.srcATop,
          ),
          child: Center(
            child: Lottie.asset(LottieFiles.$34454_download_icon,
                controller: controller.bellController,
                height: 20,

                //  repeat: false,
                //  reverse: true,
                fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
