import 'package:get/get.dart';
import 'package:the_academy/controller/models_controller/category_controller.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';

import 'package:the_academy/controller/screens_controllers/main_screen_controller.dart';

class MainScreenBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<CourseController>(() => CourseController());

    Get.lazyPut<MainScreenController>(() => MainScreenController());
  }
}
