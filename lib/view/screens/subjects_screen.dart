import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/subjects_screen_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/app_bar.dart';
import 'package:the_academy/view/widgets/custom_widgets/load_more_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/loading_widget.dart';
import 'package:the_academy/view/widgets/lists_items/subject_item.dart';
import 'package:the_academy/view/widgets/searchbar_animation/searchbar.dart';

import '../widgets/custom_widgets/empty_widget.dart';

class SubjectsScreen extends StatelessWidget {
  SubjectsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubjectsScreenController>(
      init: SubjectsScreenController(),
      builder: (screenController) => Scaffold(
        appBar: MyAppBar(
          title: Text(
              Get.locale == const Locale('ar')
                  ? screenController.category.nameAr
                  : screenController.category.nameEn,
              textAlign: TextAlign.center,
              style: Get.textTheme.titleLarge?.copyWith(
                  color:
                      Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
                  fontWeight: FontWeight.bold)),
          isUserImage: true,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios_outlined,
              color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
            ),
          ),
          hasOnTap: true,
        ),
        body: SafeArea(
          child: Container(
            constraints: BoxConstraints(
              minHeight: Get.height,
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Get.width * 0.07,
                  ),
                  child: screenController.isLoading
                      ? LoadingWidget()
                      : RefreshIndicator(
                          onRefresh: () =>
                              screenController.getData(refresh: true),
                          child: SingleChildScrollView(
                            controller: screenController.scrollController,
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                (screenController.isSearching &&
                                            screenController.subjectController
                                                .searched.isEmpty) ||
                                        (!screenController.isSearching &&
                                            screenController.subjectController
                                                .subjects.isEmpty)
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: Get.height * 0.05),
                                        child: EmptyWidget(),
                                      )
                                    : GridView.builder(
                                        itemCount: screenController.isSearching
                                            ? screenController.subjectController
                                                .searched.length
                                            : screenController.subjectController
                                                .subjects.length,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical:
                                                screenController.isSearching
                                                    ? Get.height * 0.1
                                                    : 2),
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (_, index) {
                                          final subject =
                                              screenController.isSearching
                                                  ? screenController
                                                      .subjectController
                                                      .searched[index]
                                                  : screenController
                                                      .subjectController
                                                      .subjects[index];

                                          return SubjectItem(
                                            subject,
                                            () => Get.toNamed(
                                                '/courses-list-screen',
                                                arguments: subject),
                                          );
                                        },
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                /*  maxCrossAxisExtent:
                                                    Get.width * 0.6,
                                                mainAxisExtent:
                                                    Get.height * 0.18, */
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10),
                                      ),
                                screenController.loadMoreSubjects
                                    ? const LoadMoreWidget()
                                    : SizedBox()
                              ],
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 0,
                  left: Get.locale == const Locale('ar')
                      ? null
                      : Get.width * 0.04,
                  right: Get.locale == const Locale('ar')
                      ? Get.width * 0.04
                      : null,
                  child: SearchBarAnimation(
                    textEditingController: screenController.serchTextController,
                    isOriginalAnimation: false,
                    searchBoxWidth: Get.width - Get.width * 0.1,
                    buttonBorderColour: Colors.black45,
                    buttonWidget: Icon(
                      Icons.search,
                      color: Themes.textColor,
                    ),
                    secondaryButtonWidget:
                        Icon(Icons.close, color: Themes.textColor),
                    trailingWidget: Icon(
                      Icons.search,
                      color: Themes.primaryColor,
                    ),
                    hintText: 'search'.tr,
                    onPressButton: screenController.toggleSearch,
                    textAlignToRight: Get.locale == const Locale('ar'),
                    onChanged: screenController.onChangeSearchText,
                    onFieldSubmitted: screenController.onChangeSearchText,
                    onCollapseComplete: () {
                      Get.focusScope?.unfocus();
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
