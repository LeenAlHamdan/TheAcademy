import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/categories_page_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/load_more_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/loading_widget.dart';
import 'package:the_academy/view/widgets/lists_items/category_item.dart';
import 'package:the_academy/view/widgets/searchbar_animation/searchbar.dart';

import '../widgets/custom_widgets/app_bar.dart';
import '../widgets/custom_widgets/drawer.dart';
import '../widgets/custom_widgets/empty_widget.dart';

class CategoriesScreen extends StatelessWidget {
  CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rightSlide = Get.width * 0.6;

    return GetBuilder<CategoriesPageController>(
      init: CategoriesPageController(),
      builder: (screenController) => AnimatedBuilder(
          animation: screenController.animationController,
          builder: (context, child) {
            double slide =
                rightSlide * screenController.animationController.value;
            if (Get.locale == const Locale('ar')) slide *= -1;
            double scale =
                1 - (screenController.animationController.value * 0.3);

            return WillPopScope(
              onWillPop: () async {
                if (screenController.isOpend) {
                  screenController.toggleAnimation();
                  return false;
                }
                return true;
              },
              child: Stack(
                children: [
                  Scaffold(
                    backgroundColor: Themes.primaryColor,
                    body: AppDrawer(
                      screenController.userController.currentUser.name,
                      screenController
                          .userController.currentUser.profileImageUrl,
                      screenController,
                      isCoach:
                          screenController.userController.userCanEditCourse,
                      selectedLabel: 'categories',
                      needPop: true,
                    ),
                  ),
                  Transform(
                    transform: Matrix4.identity()
                      ..translate(slide)
                      ..scale(scale),
                    alignment: Alignment.center,
                    child: Scaffold(
                      appBar: MyAppBar(
                        onMenuTap: () => screenController.toggleAnimation(),
                        isOpend: screenController.isOpend,
                        title: Text('categories'.tr,
                            textAlign: TextAlign.center,
                            style: Get.textTheme.titleLarge?.copyWith(
                                color: Get.isDarkMode
                                    ? Themes.textColorDark
                                    : Themes.textColor,
                                fontWeight: FontWeight.bold)),
                        isUserImage: true,
                        hasOnTap: false,
                      ),
                      body: AbsorbPointer(
                        absorbing: screenController.isOpend,
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: Get.height,
                          ),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    right: Get.width * 0.07,
                                    left: Get.width * 0.07,
                                    top: Get.height * 0.05),
                                child: screenController.isLoading
                                    ? LoadingWidget()
                                    : RefreshIndicator(
                                        onRefresh: () =>
                                            screenController.refreshData(),
                                        child: SingleChildScrollView(
                                          controller:
                                              screenController.scrollController,
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          child: Column(
                                            children: [
                                              screenController.isEmpty
                                                  ? Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical:
                                                                  Get.height *
                                                                      0.05),
                                                      child: EmptyWidget(),
                                                    )
                                                  : GridView.builder(
                                                      itemCount:
                                                          screenController
                                                              .categories
                                                              .length,
                                                      padding: EdgeInsets.zero,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemBuilder: (_, index) {
                                                        final category =
                                                            screenController
                                                                    .categories[
                                                                index];
                                                        return CategoryItem(
                                                          category,
                                                          false,
                                                          () => Get.toNamed(
                                                              '/subjects-screen',
                                                              arguments:
                                                                  category),
                                                        );
                                                      },
                                                      gridDelegate:
                                                          SliverGridDelegateWithMaxCrossAxisExtent(
                                                        maxCrossAxisExtent:
                                                            Get.width * 0.6,
                                                        /*  mainAxisExtent:
                                                            Get.height * 0.18, */
                                                      ),
                                                    ),
                                              screenController
                                                      .loadMoreCategories
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
                                  textEditingController:
                                      screenController.serchTextController,
                                  isOriginalAnimation: false,
                                  searchBoxWidth: Get.width - Get.width * 0.1,
                                  buttonBorderColour: Colors.black45,
                                  buttonWidget: Icon(
                                    Icons.search,
                                    color: Themes.textColor,
                                  ),
                                  secondaryButtonWidget: Icon(Icons.close,
                                      color: Themes.textColor),
                                  trailingWidget: Icon(
                                    Icons.search,
                                    color: Themes.primaryColor,
                                  ),
                                  hintText: 'search'.tr,
                                  onPressButton: screenController.toggleSearch,
                                  textAlignToRight:
                                      Get.locale == const Locale('ar'),
                                  onChanged:
                                      screenController.onChangeSearchText,
                                  onFieldSubmitted:
                                      screenController.onChangeSearchText,
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
                  ),
                ],
              ),
            );
          }),
    );
  }
}
