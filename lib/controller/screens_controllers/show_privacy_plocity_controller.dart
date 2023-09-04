import 'package:get/get.dart';
import 'package:the_academy/services/user_controller.dart';

import '../../locale/locale_controller.dart';
import '../../view/widgets/dialogs/error_dialog.dart';

class ShowPrivacyPlocityScreenController extends GetxController {
  bool isLoading = false;

  //final PermissionController permissionController = Get.find();
  final UserController _userController = Get.find();
  MyLocaleController localeController = Get.find();

  agree() {
    {
      localeController.setPrivacyPlocity(true);
      !_userController.isUser
          ? Get.offAllNamed('/main-screen', arguments: true)
          : Get.offAllNamed('/subscribe', arguments: {
              'loadData': true,
            });
    }
  }

  Future<bool> backPressed(bool fromMain, bool onWill) async {
    if (fromMain) {
      if (localeController.showPrivacyPlocity) {
        var errorMessage = 'you_have_to_agree_on_privacy_policy'.tr;
        showErrorDialog(
          errorMessage,
        );
        return false;
      }
    }
    if (onWill) return true;
    Get.back();
    return true;
  }
}
