import 'package:get/get.dart';
import 'package:the_academy/locale/locale_controller.dart';
import 'package:the_academy/services/user_controller.dart';

import 'firebase_message_handler.dart';

Future<void> logOutFunction(UserController userController,
    List<String> myCoursesIds, MyLocaleController localeController) async {
  try {
    final languageCode = Get.locale!.languageCode;
    await unsubscribeFromMultipleTopics([
      'all_topic'.tr,
      userController.userId,
      '${userController.userId}-$languageCode'
    ]);
    userController.signOut();

    await unsubscribeFromMultipleTopicsWithLan(myCoursesIds, languageCode);
    //  mainScreenController.loadData.value = true;
    localeController.userSigned.value = false;
    localeController.futureExecuted = false;
  } catch (_) {}
}
