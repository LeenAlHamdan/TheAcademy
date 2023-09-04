import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/my_edit_text.dart';

import '../../controller/screens_controllers/add_course_screen_controller.dart';
import '../widgets/custom_widgets/app_bar.dart';
import '../widgets/custom_widgets/loading_widget.dart';
import '../widgets/custom_widgets/multi_image_input.dart';
import '../widgets/custom_widgets/my_button.dart';

class AddCourseScreen extends StatelessWidget {
  const AddCourseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddCourseScreenController>(
      init: AddCourseScreenController(),
      builder: (screenController) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: MyAppBar(
          title: Text(
              screenController.courseFullData != null
                  ? 'edit_course'.tr
                  : 'add_course'.tr,
              textAlign: TextAlign.center,
              style: Get.textTheme.titleLarge?.copyWith(
                  color:
                      Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
                  fontWeight: FontWeight.bold)),
          isUserImage: false,
          trailing: GestureDetector(
            onTap: screenController.submitData,
            child: Icon(
              Icons.save,
              color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
            ),
          ),
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios_outlined,
              color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                  top: Get.height * 0.028,
                  left: Get.width * 0.03,
                  right: Get.width * 0.03),
              child: screenController.isLoading
                  ? LoadingWidget()
                  : Form(
                      key: screenController.form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MyEditText(
                              title: 'name_ar'.tr,
                              prefixIcon: Icons.abc_rounded,
                              enabled: !screenController.isLoadingButton,
                              textController: screenController.nameArController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'field_required'.tr;
                                }
                                return null;
                              },
                              onSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(
                                      screenController.nameEnFocusNode)),
                          SizedBox(
                            height: Get.height * 0.028,
                          ),
                          MyEditText(
                              title: 'name_en'.tr,
                              prefixIcon: Icons.abc_rounded,
                              textDirection: TextDirection.ltr,
                              enabled: !screenController.isLoadingButton,
                              textFocusNode: screenController.nameEnFocusNode,
                              textController: screenController.nameEnController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'field_required'.tr;
                                }
                                return null;
                              },
                              onSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(
                                      screenController.descriptionArFocusNode)),
                          SizedBox(
                            height: Get.height * 0.028,
                          ),
                          MyEditText(
                              title: 'description_ar'.tr,
                              prefixIcon: Icons.description_rounded,
                              enabled: !screenController.isLoadingButton,
                              textFocusNode:
                                  screenController.descriptionArFocusNode,
                              textController:
                                  screenController.descriptionArController,
                              multiLine: true,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'field_required'.tr;
                                }
                                return null;
                              },
                              onSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(
                                      screenController.descriptionEnFocusNode)),
                          SizedBox(
                            height: Get.height * 0.028,
                          ),
                          MyEditText(
                            title: 'description_en'.tr,
                            prefixIcon: Icons.description_rounded,
                            textDirection: TextDirection.ltr,
                            multiLine: true,
                            enabled: !screenController.isLoadingButton,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'field_required'.tr;
                              }
                              return null;
                            },
                            textFocusNode:
                                screenController.descriptionEnFocusNode,
                            textController:
                                screenController.descriptionEnController,
                          ),
                          SizedBox(
                            height: Get.height * 0.028,
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: /*  Get.isDarkMode
                                  ? Get.theme.colorScheme.background
                                  : */
                                  Themes.buttonColor,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: SearchableDropdown<String>.paginated(
                              searchHintText: 'search'.tr,
                              hintText: Text(
                                screenController.selectedSubjectValue != null
                                    ? Get.locale == const Locale('ar')
                                        ? screenController
                                            .selectedSubjectValue!.nameAr
                                        : screenController
                                            .selectedSubjectValue!.nameEn
                                    : 'choose_subject'.tr,
                                style: Get.textTheme.titleMedium?.copyWith(
                                    /*  color: Get.isDarkMode
                                        ? Themes.primaryColorLight
                                        : null, */
                                    fontWeight: FontWeight.normal),
                              ),
                              noRecordText: Text('no_items_to_show'.tr),
                              margin: const EdgeInsets.all(15),
                              paginatedRequest:
                                  (int page, String? searchKey) async {
                                await screenController.paginatedRequest(
                                    page, searchKey);
                                return screenController.subjectsList
                                    .map((item) => SearchableDropdownMenuItem(
                                        value: item.id,
                                        label: Get.locale == const Locale('ar')
                                            ? item.nameAr
                                            : item.nameEn,
                                        child: Text(
                                            Get.locale == const Locale('ar')
                                                ? item.nameAr
                                                : item.nameEn,
                                            style: Get.textTheme.titleSmall
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.normal))))
                                    .toList();
                              },
                              trailingIcon: Icon(
                                Icons.arrow_drop_down,
                                color: Themes.textColor,
                              ),
                              requestItemCount: 10,
                              onChanged: screenController.onChanged,
                            ),
                          ),
                          SizedBox(
                            height: Get.height * 0.028,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Get.isDarkMode
                                      ? Get.theme.colorScheme.background
                                      : Themes.buttonColor,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: Get.locale == const Locale('ar')
                                              ? 20.0
                                              : 5,
                                          right:
                                              Get.locale == const Locale('ar')
                                                  ? 5
                                                  : 20.0),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'private'.tr,
                                          style: TextStyle(
                                              color: Get.isDarkMode
                                                  ? Themes.primaryColorLightDark
                                                  : Themes.primaryColorDark,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    Checkbox(
                                        value: screenController.isPrivate,
                                        activeColor: Themes.primaryColor,
                                        onChanged:
                                            screenController.checkboxChanged),
                                  ],
                                ),
                              ),
                              MultiImageInput(
                                screenController.selectMultiImage,
                                images: screenController.image != null
                                    ? [screenController.image!]
                                    : [],
                                limit: 1,
                                imagePath: screenController.imagePath,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
            ),
          ),
        ),
        persistentFooterButtons: [
          MyButton(
              onTap: screenController.submitData,
              shadowColor: Themes.primaryColor.withOpacity(0.2),
              textColor: Themes.primaryColorLight,
              backgroundColor: Themes.primaryColor,
              titleWidget: screenController.isLoadingButton
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Themes.primaryColorLight,
                    ))
                  : null,
              title: 'save'.tr)
        ],
      ),
    );
  }
}
