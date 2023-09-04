import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/my_edit_text.dart';

import '../../controller/screens_controllers/add_exam_screen_controller.dart';
import '../widgets/custom_widgets/app_bar.dart';
import '../widgets/custom_widgets/loading_widget.dart';
import 'package:intl/intl.dart' as intl;
import '../widgets/custom_widgets/my_button.dart';

class AddExamScreen extends StatelessWidget {
  const AddExamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddExamScreenController>(
      init: AddExamScreenController(),
      builder: (screenController) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: MyAppBar(
          title: Text(
              screenController.examFullData != null
                  ? 'edit_exam'.tr
                  : 'add_exam'.tr,
              textAlign: TextAlign.center,
              style: Get.textTheme.titleLarge?.copyWith(
                  color:
                      Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
                  fontWeight: FontWeight.bold)),
          isUserImage: false,
          trailing: GestureDetector(
            onTap: screenController.page == 0
                ? screenController.next
                : screenController.submitData,
            child: Icon(
              screenController.page == 0 ? Icons.next_plan : Icons.save,
              color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              if (screenController.page > 0)
                screenController.previous();
              else
                Get.back();
            },
            child: Icon(
              Icons.arrow_back_ios_outlined,
              color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
            ),
          ),
        ),
        body: WillPopScope(
          onWillPop: () async {
            if (screenController.page > 0) {
              screenController.previous();
              return false;
            } else
              return true;
          },
          child: SafeArea(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                    top: Get.height * 0.028,
                    left: Get.width * 0.03,
                    right: Get.width * 0.03),
                child: screenController.isLoading
                    ? LoadingWidget()
                    : screenController.page == 0
                        ? Form(
                            key: screenController.formPageOne,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MyEditText(
                                    title: 'name_ar'.tr,
                                    //                  color: Themes.buttonColor,
                                    prefixIcon: Icons.abc_rounded,
                                    enabled: !screenController.isLoadingButton,
                                    textController:
                                        screenController.nameArController,
                                    onSubmitted: (_) => FocusScope.of(context)
                                        .requestFocus(
                                            screenController.nameEnFocusNode),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'field_required'.tr;
                                      }
                                      return null;
                                    }),
                                SizedBox(
                                  height: Get.height * 0.028,
                                ),
                                MyEditText(
                                    title: 'name_en'.tr,
                                    //       color: Themes.buttonColor,
                                    prefixIcon: Icons.abc_rounded,
                                    textDirection: TextDirection.ltr,
                                    enabled: !screenController.isLoadingButton,
                                    textFocusNode:
                                        screenController.nameEnFocusNode,
                                    textController:
                                        screenController.nameEnController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'field_required'.tr;
                                      }
                                      return null;
                                    }),
                                SizedBox(
                                  height: Get.height * 0.028,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Themes.buttonColor,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: SearchableDropdown<String>.paginated(
                                    searchHintText: 'search'.tr,
                                    hintText: Text(
                                      screenController.selectedCourseValue !=
                                              null
                                          ? Get.locale == const Locale('ar')
                                              ? screenController
                                                  .selectedCourseValue!.nameAr
                                              : screenController
                                                  .selectedCourseValue!.nameEn
                                          : 'choose_course'.tr,
                                      style: Get.textTheme.titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.normal),
                                    ),
                                    noRecordText: Text('no_items_to_show'.tr),
                                    margin: const EdgeInsets.all(15),
                                    paginatedRequest:
                                        (int page, String? searchKey) async {
                                      await screenController.paginatedRequest(
                                          page, searchKey);
                                      return screenController.coursesList
                                          .map((item) =>
                                              SearchableDropdownMenuItem(
                                                  value: item.id,
                                                  label:
                                                      Get
                                                                  .locale ==
                                                              const Locale('ar')
                                                          ? item.nameAr
                                                          : item.nameEn,
                                                  child: Text(
                                                      Get
                                                                  .locale ==
                                                              const Locale('ar')
                                                          ? item.nameAr
                                                          : item.nameEn,
                                                      style: Get
                                                          .textTheme.titleSmall
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal))))
                                          .toList();
                                    },
                                    requestItemCount: 10,
                                    onChanged: screenController.onChanged,
                                  ),
                                ),
                                SizedBox(
                                  height: Get.height * 0.028,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Themes.buttonColor,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: SearchableDropdown<String>(
                                    searchHintText: 'search'.tr,
                                    hintText: Text(
                                      'language'.tr,
                                      style: Get.textTheme.titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.normal),
                                    ),
                                    items: screenController
                                        .dropDownFilterSpinner
                                        .map(
                                          (e) => SearchableDropdownMenuItem(
                                              label: e.tr,
                                              value: e,
                                              child: Text(e.tr,
                                                  style: Get
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                          fontWeight: FontWeight
                                                              .normal))),
                                        )
                                        .toList(),
                                    margin: const EdgeInsets.all(15),
                                    value: screenController.dropDownFilterValue,
                                    onChanged:
                                        screenController.onChangeFilterValue,
                                  ),
                                ),
                                SizedBox(
                                  height: Get.height * 0.028,
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      screenController.selectStartTime(context),
                                  child: Row(
                                    children: [
                                      Text(
                                        'start_date'.tr,
                                        style: Get.textTheme.titleMedium
                                            ?.copyWith(
                                                color: Themes.primaryColor,
                                                fontWeight: FontWeight.normal),
                                      ),
                                      SizedBox(
                                        width: Get.width * 0.028,
                                      ),
                                      Expanded(
                                        child: MyEditText(
                                            //color: Themes.buttonColor,
                                            textController:
                                                TextEditingController(
                                                    text: (intl.DateFormat(
                                                            'dd/MM/yyyy hh:mm'))
                                                        .format(screenController
                                                            .selectedStartTime)),
                                            title: '',
                                            textDirection: TextDirection.ltr,
                                            enabled: false,
                                            hintStyle: Get.textTheme.titleMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.normal),
                                            textAlign: TextAlign.center,
                                            validator: (value) =>
                                                screenController
                                                    .vaildStartDate()),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: Get.height * 0.028,
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      screenController.selectEndTime(context),
                                  child: Row(
                                    children: [
                                      Text(
                                        'end_date'.tr,
                                        style: Get.textTheme.titleMedium
                                            ?.copyWith(
                                                color: Themes.primaryColor,
                                                fontWeight: FontWeight.normal),
                                      ),
                                      SizedBox(
                                        width: Get.width * 0.028,
                                      ),
                                      Expanded(
                                        child: MyEditText(
                                            // color: Themes.buttonColor,
                                            textController: TextEditingController(
                                                text: screenController
                                                            .selectedEndTimeInit !=
                                                        null
                                                    ? (intl.DateFormat(
                                                            'dd/MM/yyyy hh:mm'))
                                                        .format(screenController
                                                            .selectedEndTime)
                                                    : null),
                                            title: '',
                                            textDirection: TextDirection.ltr,
                                            enabled: false,
                                            hintStyle: Get.textTheme.titleMedium
                                                ?.copyWith(
                                                    color: Get.isDarkMode
                                                        ? Themes.textColor
                                                        : null,
                                                    fontWeight:
                                                        FontWeight.normal),
                                            textAlign: TextAlign.center,
                                            validator: (value) {
                                              if (value!.isEmpty ||
                                                  screenController
                                                          .selectedEndTimeInit ==
                                                      null) {
                                                return 'field_required'.tr;
                                              }
                                              return screenController
                                                  .vaildEndDate();
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Form(
                            key: screenController.formPageTwo,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) => Card(
                                      elevation: 0,
                                      color: Get.isDarkMode
                                          ? Get.theme.colorScheme.background
                                          : Themes.primaryColorDark
                                              .withOpacity(0.2),
                                      child: ExpansionTile(
                                          initiallyExpanded: true,
                                          title: ListTile(
                                            title: MyEditText(
                                              onTap: () => screenController
                                                  .changeTappedQuestion(index),
                                              onTapOutSide: () =>
                                                  screenController
                                                      .changeTappedQuestion(
                                                          null),
                                              onSubmitted: (_) =>
                                                  screenController
                                                      .changeTappedQuestion(
                                                          null),
                                              // color: Themes.buttonColor,
                                              title: 'question'.tr,
                                              prefixIcon: Icons.title_rounded,
                                              textController: screenController
                                                  .questionsItemsList[index]
                                                  .title,
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'field_required'.tr;
                                                }
                                                return null;
                                              },
                                            ),
                                            trailing:
                                                screenController
                                                            .tappedQuestion ==
                                                        index
                                                    ? null
                                                    : IconButton(
                                                        color:
                                                            Themes.buttonColor,
                                                        icon: Icon(
                                                          Icons.remove,
                                                          color: Themes
                                                              .primaryColorDark,
                                                        ),
                                                        onPressed: screenController
                                                                    .questionsItemsList
                                                                    .length ==
                                                                1
                                                            ? () {
                                                                Get.showSnackbar(
                                                                    GetSnackBar(
                                                                        backgroundColor:
                                                                            Themes
                                                                                .primaryColorDark,
                                                                        messageText:
                                                                            Text(
                                                                          'one_question_min'
                                                                              .tr,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(color: Themes.primaryColorLight),
                                                                        ),
                                                                        duration:
                                                                            const Duration(seconds: 2)));
                                                              }
                                                            : () => screenController
                                                                .removeQuestion(
                                                                    index),
                                                      ),
                                          ),
                                          children: [
                                            ...screenController
                                                .questionsItemsList[index]
                                                .options
                                                .asMap()
                                                .map(
                                                  (i, e) => MapEntry(
                                                    i,
                                                    ListTile(
                                                      title: MyEditText(
                                                        //color:
                                                        //    Themes.buttonColor,
                                                        title: 'option'.tr,
                                                        onTap: () =>
                                                            screenController
                                                                .changeTappedQuestion(
                                                                    null),
                                                        prefixIcon:
                                                            Icons.title_rounded,
                                                        textController: e,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'field_required'
                                                                .tr;
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                      trailing: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Radio(
                                                            value: i,
                                                            groupValue:
                                                                screenController
                                                                    .questionsItemsList[
                                                                        index]
                                                                    .trueAnswer,
                                                            onChanged: (int?
                                                                    val) =>
                                                                screenController
                                                                    .changeTrueAnswer(
                                                                        index,
                                                                        val),
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                                Icons.remove),
                                                            onPressed: screenController
                                                                        .questionsItemsList[
                                                                            index]
                                                                        .options
                                                                        .length ==
                                                                    2
                                                                ? () {
                                                                    Get.showSnackbar(GetSnackBar(
                                                                        backgroundColor: Themes.primaryColorDark,
                                                                        messageText: Text(
                                                                          'two_options_min'
                                                                              .tr,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(color: Themes.primaryColorLight),
                                                                        ),
                                                                        duration: const Duration(seconds: 2)));
                                                                  }
                                                                : () => screenController
                                                                    .removeQuestionOptin(
                                                                        index,
                                                                        i),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .values
                                                .toList(),
                                            TextButton.icon(
                                              onPressed: () => screenController
                                                  .addOptionTextController(
                                                      index),
                                              style: TextButton.styleFrom(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .centerStart),
                                              icon: Icon(Icons.add),
                                              label: Text(
                                                'add_new_option'.tr,
                                                style: Get.textTheme.titleLarge
                                                    ?.copyWith(
                                                        color:
                                                            Themes.offerColor),
                                              ),
                                            )
                                          ]),
                                    ),
                                    shrinkWrap: true,
                                    itemCount: screenController
                                        .questionsItemsList.length,
                                  ),
                                  TextButton.icon(
                                    onPressed: screenController
                                        .addQuestionTextController,
                                    style: TextButton.styleFrom(
                                        alignment:
                                            AlignmentDirectional.centerStart),
                                    icon: Icon(Icons.add),
                                    label: Text(
                                      'add_new_question'.tr,
                                      style: Get.textTheme.titleLarge
                                          ?.copyWith(color: Themes.offerColor),
                                    ),
                                  ),
                                ]),
                          ),
              ),
            ),
          ),
        ),
        persistentFooterButtons: [
          MyButton(
              onTap: screenController.page == 0
                  ? screenController.next
                  : screenController.submitData,
              shadowColor: Themes.primaryColor.withOpacity(0.2),
              textColor: Themes.primaryColorLight,
              backgroundColor: Themes.primaryColor,
              titleWidget: screenController.isLoadingButton
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Themes.primaryColorLight,
                    ))
                  : null,
              title: screenController.page == 0 ? 'next'.tr : 'save'.tr)
        ],
      ),
    );
  }
}
