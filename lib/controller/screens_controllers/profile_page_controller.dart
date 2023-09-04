import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_academy/data/api/api_client.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/utils/app_contanants.dart';
import 'package:the_academy/view/widgets/custom_widgets/load_more_horizontal_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/my_edit_text.dart';
import 'package:the_academy/view/widgets/dialogs/error_dialog.dart';

import '../../locale/locale_controller.dart';
import '../../utils/compress_file.dart';
import '../../utils/crop_image.dart';
import '../../utils/firebase_message_handler.dart';
import '../../utils/log_out_function.dart';
import '../../utils/refresh.dart';
import '../models_controller/course_controller.dart';
import '../models_controller/generals_controller.dart';
import '../models_controller/permission_controller.dart';

class ProfilePageController extends GetxController
    with GetTickerProviderStateMixin {
  final UserController _userController = Get.find();
  final SharedPreferences _sharedPrefs = Get.find();
  final CourseController _courseController = Get.find();
  final MyLocaleController _localeController = Get.find();
  final PermissionController _permissionController = Get.find();
  final GeneralsController _generalsController = Get.find();

  final ApiClient _apiClient = Get.find();

  File pickedImage = File('');
  bool isLoadingPass = false;
  bool isLoadingImage = false;

  final lastPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final newPasswordFocusNode = FocusNode();

  bool isOpend = false;
  late final AnimationController animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 10));

  CourseController get courseController => _courseController;
  UserController get userController => _userController;

  String get getUserType => _userController.isAdmin
      ? 'admin'.tr
      : _userController.isCoach
          ? 'coach'.tr
          : 'user'.tr;

  Color? get getUserImageBackground =>
      isLoadingImage || _userController.currentUser.profileImageUrl != ''
          ? null
          : Themes.primaryColorLight;

  Widget get getUserImage => _userController.currentUser.profileImageUrl == ''
      ? isLoadingImage
          ? CircularProgressIndicator(
              color: Themes.primaryColor,
            )
          : SvgPicture.asset(
              'assets/images/user_image.svg',
              color: Themes.primaryColor,
              fit: BoxFit.cover,
              height: 50,
            )
      : CachedNetworkImage(
          imageUrl:
              '${AppConstants.imagesHost}/${_userController.currentUser.profileImageUrl}',
          imageBuilder: (context, imageProvider) {
            return CircleAvatar(
              radius: 50,
              backgroundImage: imageProvider,
            );
          },
          placeholder: (context, url) => LoadMoreHorizontalWidget(image: true),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 150,
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );

  void toggleAnimation() {
    if (animationController.isDismissed) {
      animationController.forward();
      isOpend = true;
    } else {
      animationController.reverse();
      isOpend = false;
    }

    update();
  }

  Future<void> logOut() async {
    await logOutFunction(
        _userController, courseController.myCoursesIds, _localeController);

    // Get.offAllNamed('/welcome');
  }

  void changePaddwordDialog() {
    newPasswordController.clear();
    lastPasswordController.clear();
    Get.defaultDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyEditText(
              title: 'last_password'.tr,
              prefixIcon: Icons.access_time_sharp,
              obscureText: true,
              textDirection: TextDirection.ltr,
              textController: lastPasswordController,
              onSubmitted: (_) =>
                  Get.focusScope?.requestFocus(newPasswordFocusNode)),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: MyEditText(
                title: 'new_password'.tr,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                textDirection: TextDirection.ltr,
                textController: newPasswordController,
                textFocusNode: newPasswordFocusNode,
                onSubmitted: (_) {
                  Get.back();

                  _changePass(_userController);
                }),
          ),
        ],
      ),
      barrierDismissible: false,
      title: 'change_password'.tr,
      titleStyle: TextStyle(
          color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
      textConfirm: 'save'.tr,
      confirmTextColor: Themes.primaryColorLight,
      cancelTextColor: Get.isDarkMode ? Themes.textColorDark : null,
      onConfirm: () {
        Get.back();

        _changePass(_userController);
      },
      textCancel: 'cancel'.tr,
      //  onCancel: () => Get.back(),
    );
  }

  void _changePic() async {
    try {
      File? img = await compressFile(pickedImage);

      await _userController.updateProfileImage(img);
      isLoadingImage = false;
      update();
    } on HttpException catch (_) {
      var errorMessage = 'error'.tr;

      isLoadingImage = false;
      update();
      showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'error'.tr;

      isLoadingImage = false;
      update();
      showErrorDialog(
        errorMessage,
      );
    }
  }

  void _changePass(UserController userController) async {
    if (newPasswordController.text.isEmpty ||
        lastPasswordController.text.isEmpty) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(errorMessage);
      return;
    }

    final newPassword = newPasswordController.text;
    final lastPassword = lastPasswordController.text;

    isLoadingPass = true;
    update();
    try {
      await userController.changePassword(lastPassword, newPassword);
      await userController.logIn(userController.currentUser.email, newPassword);
      _apiClient.updateHeader(userController.token);
      isLoadingPass = false;
      update();
      Get.showSnackbar(GetSnackBar(
          backgroundColor: Themes.primaryColorDark,
          messageText: Text(
            'pass_change'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: Themes.primaryColorLight),
          ),
          duration: const Duration(seconds: 2)));
    } on HttpException catch (error) {
      var errorMessage = 'error'.tr;
      if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'INVALID_PASSWORD'.tr;
      }
      isLoadingPass = false;
      update();
      showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'error'.tr;
      if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'INVALID_PASSWORD'.tr;
      }
      isLoadingPass = false;
      update();
      showErrorDialog(
        errorMessage,
      );
    }
  }

  showPicker() async {
    final images = await MultiImagePicker.pickImages(
      maxImages: 1,
      enableCamera: true,
      materialOptions: MaterialOptions(
        actionBarTitle: 'choose_image'.tr,
        actionBarColor: '#2184C7',
        statusBarColor: '#2184C7',
        useDetailsView: false,
      ),
    );
    if (images.isEmpty) {
      return;
    }
    isLoadingImage = true;
    update();
    final byteData = await images.first.getByteData();

    final tempFile =
        File("${(await getTemporaryDirectory()).path}/${images.first.name}");
    pickedImage = await tempFile.writeAsBytes(
      byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );

    final result = await _cropImage();

    if (result)
      _changePic();
    else {
      isLoadingImage = false;
      update();
    }
  }

  Future<bool> _cropImage() async {
    var croppedFile = await cropingImage(pickedImage,
        primaryColor: Themes.primaryColor,
        backgroundColor: Themes.primaryColorLight);
    if (croppedFile != null && croppedFile.path.isNotEmpty) {
      pickedImage = croppedFile;
      return true;
    }
    return false;
  }

  Future<void> refreshData() async {
    try {
      await refreshDataFunction(_userController,
          generalsController: _generalsController,
          permissionController: _permissionController,
          refreshUser: true);

      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr);
    } catch (error) {
      showErrorDialog('error'.tr);
    }
  }

  Future<void> changeTheme(bool isLight) async {
    _sharedPrefs.setString('theme', isLight ? 'light' : 'dark');
  }

  void aboutUsDialog() {
    Get.defaultDialog(
      barrierDismissible: true,
      title: 'about_us'.tr,
      titleStyle: TextStyle(
          color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
      content: SizedBox(
        height: Get.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'about_us_title'.tr,
                      style: Get.textTheme.titleLarge!.copyWith(
                          color: Get.isDarkMode ? Themes.textColorDark : null,
                          fontWeight: FontWeight.bold),
                    ),
                    Center(
                      child: Text(
                        'about_us_content'.tr,
                        style: Get.textTheme.titleMedium!.copyWith(
                            color: Get.isDarkMode
                                ? Themes.gradientMerged
                                : Themes.primaryColor),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'our_message_title'.tr,
                      style: Get.textTheme.titleLarge!.copyWith(
                          color: Get.isDarkMode ? Themes.textColorDark : null,
                          fontWeight: FontWeight.bold),
                    ),
                    Center(
                      child: Text(
                        'our_message_content'.tr,
                        style: Get.textTheme.titleMedium!.copyWith(
                            color: Get.isDarkMode
                                ? Themes.gradientMerged
                                : Themes.primaryColor),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'our_merits_title'.tr,
                      style: Get.textTheme.titleLarge!.copyWith(
                          color: Get.isDarkMode ? Themes.textColorDark : null,
                          fontWeight: FontWeight.bold),
                    ),
                    Center(
                      child: Text(
                        'our_merits_content'.tr,
                        style: Get.textTheme.titleMedium!.copyWith(
                            color: Get.isDarkMode
                                ? Themes.gradientMerged
                                : Themes.primaryColor),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'our_names'.tr,
                      style: Get.textTheme.titleLarge!.copyWith(
                          color: Get.isDarkMode ? Themes.textColorDark : null,
                          fontWeight: FontWeight.bold),
                    ),
                    Center(
                      child: Text(
                        'our_names_content'.tr,
                        style: Get.textTheme.titleMedium!.copyWith(
                            color: Get.isDarkMode
                                ? Themes.gradientMerged
                                : Themes.primaryColor),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      cancelTextColor: Get.isDarkMode ? Themes.textColorDark : null,
      textCancel: 'close'.tr,
    );
  }

  void contactUsDialog() {
    const mobileNum = '+963946966082';
    const companyEmail = 'alhamdanleen@gmail.com';
    const supportEmail = 'support@the-academy.com';

    Get.defaultDialog(
      barrierDismissible: true,
      title: 'contact_us'.tr,
      titleStyle: TextStyle(
          color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${'support_email'.tr}: ',
                    style: Get.textTheme.titleLarge!.copyWith(
                        color: Get.isDarkMode ? Themes.textColorDark : null,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      supportEmail,
                      style: Get.textTheme.titleMedium!.copyWith(
                          color: Get.isDarkMode
                              ? Themes.gradientMerged
                              : Themes.primaryColor),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    '${'company_mobile_num'.tr}: ',
                    style: Get.textTheme.titleLarge!.copyWith(
                        color: Get.isDarkMode ? Themes.textColorDark : null,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      mobileNum,
                      textDirection: TextDirection.ltr,
                      style: Get.textTheme.titleMedium!.copyWith(
                          color: Get.isDarkMode
                              ? Themes.gradientMerged
                              : Themes.primaryColor),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${'company_email'.tr}: ',
                    style: Get.textTheme.titleLarge!.copyWith(
                        color: Get.isDarkMode ? Themes.textColorDark : null,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      companyEmail,
                      textDirection: TextDirection.ltr,
                      style: Get.textTheme.titleMedium!.copyWith(
                          color: Get.isDarkMode
                              ? Themes.gradientMerged
                              : Themes.primaryColor),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      cancelTextColor: Get.isDarkMode ? Themes.textColorDark : null,
      textCancel: 'close'.tr,
    );
  }

  Future<void> toggleLanguage(bool val) async {
    Get.toNamed('/splash');
    // screenController.toggleIsLoadingPass(true);

    final prevLang = Get.locale!.languageCode;
    final prevAll = 'all_topic'.tr;
    await unsubscribeFromMultipleTopics(
        [prevAll, '${userController.userId}-$prevLang']);

    unsubscribeFromMultipleTopicsWithLan(
        _courseController.myCoursesIds, prevLang);

    if (val) {
      await _localeController.updateLanguage('ar');
    } else {
      await _localeController.updateLanguage('en');
    }
//    selectedIndex.value = 0;

    //goToPage(0);
    subscribeFromMultipleTopics([
      'all_topic'.tr,
      '${userController.userId}-${Get.locale!.languageCode}'
    ]);

    subscribeToMultipleTopicsWithLan(
        _courseController.myCoursesIds, Get.locale!.languageCode,
        myCourses: true);
    //  await Future.delayed(Duration(seconds: 1));

    //screenController.update();

    /*  selectedIndex.value = 0;
    update(); */

    Get.back();
    /*  Future.delayed(Duration.zero).then(
      (value) => goToPage(0),
    ); */

    //screenController.toggleIsLoadingPass(false);
  }

  @override
  void dispose() {
    lastPasswordController.dispose();
    newPasswordController.dispose();
    newPasswordFocusNode.dispose();
    animationController.dispose();

    super.dispose();
  }
}
