import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/my_exams_screen_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/app_bar.dart';
import 'package:the_academy/view/widgets/custom_widgets/drawer.dart';
import 'package:the_academy/view/widgets/lists_items/exam_item_widget.dart';

import '../../utils/get_double_number.dart';
import '../widgets/custom_widgets/empty_widget.dart';
import '../widgets/custom_widgets/load_more_widget.dart';
import '../widgets/custom_widgets/loading_widget.dart';

class MyExamsScreen extends StatelessWidget {
  final MyExamsScreenController screenController = Get.find();

  MyExamsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rightSlide = Get.width * 0.6;

    return AnimatedBuilder(
        animation: screenController.animationController,
        builder: (context, child) {
          double slide =
              rightSlide * screenController.animationController.value;
          if (Get.locale == const Locale('ar')) slide *= -1;
          double scale = 1 - (screenController.animationController.value * 0.3);
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
                    screenController.userController.currentUser.profileImageUrl,
                    screenController,
                    needPop: true,
                    isCoach: screenController.userController.userCanEditCourse,
                    selectedLabel: 'my_exams',
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
                      title: Text('my_exams'.tr,
                          textAlign: TextAlign.center,
                          style: Get.textTheme.titleLarge?.copyWith(
                              color: Get.isDarkMode
                                  ? Themes.textColorDark
                                  : Themes.textColor,
                              fontWeight: FontWeight.bold)),
                      isUserImage: true,
                      hasOnTap: true,
                    ),
                    body: AbsorbPointer(
                      absorbing: screenController.isOpend,
                      child: GetBuilder<MyExamsScreenController>(
                        builder: (_) => RefreshIndicator(
                          onRefresh: () =>
                              screenController.getData(refresh: true),
                          child: screenController.isLoading
                              ? LoadingWidget(exam: true)
                              : SingleChildScrollView(
                                  controller: screenController.scrollController,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    children: [
                                      screenController
                                              .examController.userExams.isEmpty
                                          ? ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxHeight: Get.height * 0.8),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        Get.height * 0.05),
                                                child: EmptyWidget(),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: screenController
                                                  .examController
                                                  .userExams
                                                  .length,
                                              padding: EdgeInsets.only(
                                                  top: 16, left: 8, right: 8),
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemBuilder: (_, index) {
                                                final item = screenController
                                                    .examController
                                                    .userExams[index];
                                                return ExamItemWidget(
                                                  onTap: () => Get.toNamed(
                                                      '/exam-screen',
                                                      arguments: {
                                                        'id': item.examId,
                                                        'isTheCoach': false,
                                                        'answers': item.answers,
                                                      }),
                                                  name: Get.locale ==
                                                          const Locale('ar')
                                                      ? item.examNameAr
                                                      : item.examNameEn,
                                                  trailingText:
                                                      getDoubleNumber(item.mark)
                                                          .toString(),
                                                  textColor: Get.isDarkMode
                                                      ? Themes.textColorDark
                                                      : null,
                                                  backgroundColor: Get
                                                          .isDarkMode
                                                      ? Themes.gradientColor1
                                                          .withOpacity(0.2)
                                                      : Themes.greenColor
                                                          .withOpacity(0.2),
                                                );
                                              },
                                            ),
                                      screenController.loadMore
                                          ? const LoadMoreWidget(
                                              exam: true,
                                            )
                                          : SizedBox()
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
