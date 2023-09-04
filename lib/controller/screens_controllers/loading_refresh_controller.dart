import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class LoadingRefreshController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController bellController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
  late Timer timer;

  @override
  void onInit() {
    super.onInit();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      bellController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    bellController.dispose();
    timer.cancel();
    super.dispose();
  }
}
