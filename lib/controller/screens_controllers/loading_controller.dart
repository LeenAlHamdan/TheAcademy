import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class LoadingController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController bellController;
  @override
  void onInit() {
    super.onInit();
    bellController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
  }

  @override
  void dispose() {
    bellController.dispose();
    super.dispose();
  }
}
