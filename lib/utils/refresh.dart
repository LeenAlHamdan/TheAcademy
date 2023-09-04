import 'package:get/get.dart';
import 'package:the_academy/main.dart';

import '../controller/models_controller/category_controller.dart';
import '../controller/models_controller/course_controller.dart';
import '../controller/models_controller/generals_controller.dart';
import '../controller/models_controller/permission_controller.dart';
import '../model/http_exception.dart';
import '../services/user_controller.dart';
import '../view/widgets/dialogs/error_dialog.dart';

Future<void> refreshDataFunction(
  UserController userController, {
  bool refreshCategories = false,
  bool refreshCoureses = false,
  bool refreshUser = false,
  bool refreshAll = false,
  PermissionController? permissionController,
  GeneralsController? generalsController,
  CategoryController? categoryController,
  CourseController? courseController,
}) async {
  try {
    if (refreshAll || refreshUser) {
      await userController.fetchProfile();
      //print('fetchProfile');
      if (userController.isUser || !userController.userIsSigned) {
        await permissionController?.fetchAndSetCoachPermission();
        //print('fetchAndSetCoachPermission');
      }
      await generalsController?.fetchAndSetGenerals();
      //print('fetchAndSetGenerals');
    }

    if (refreshCategories || refreshAll) {
      await categoryController?.fetchAndSetCategories(0, isRefresh: true);
      //print('fetchAndSetCategories');
    }

    if (refreshCoureses || refreshAll) {
      await courseController?.fetchAndSetCourses(0, isRefresh: true);
      //print('fetchAndSetCourses');
      await courseController?.fetchAndSetPublicCourses(0, isRefresh: true);
      //print('fetchAndSetPublicCourses');
      if (userController.userCanEditCourse)
        await courseController?.fetchAndSetCoachCourses(0, isRefresh: true);
      //print('fetchAndSetCoachCourses');

      await courseController?.fetchAndSetMyCourses(0, userController.userId,
          isRefresh: true);
      //print('fetchAndSetMyCourses');
    }
    if (refreshAll && userController.userIsSigned) {
      MyApp.createSocketConnection();
    }
  } on HttpException catch (_) {
    showErrorDialog(
      'error'.tr,
    );

    throw HttpException('error');
  } catch (error) {
    showErrorDialog(
      'error'.tr,
    );

    throw error;
  }
}
