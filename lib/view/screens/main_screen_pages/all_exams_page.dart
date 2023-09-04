import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/lists_items/exam_item_widget.dart';

import '../../../controller/screens_controllers/all_exams_page_controller.dart';
import '../../../utils/get_double_number.dart';
import '../../widgets/custom_widgets/empty_widget.dart';
import '../../widgets/custom_widgets/load_more_widget.dart';
import '../../widgets/custom_widgets/loading_widget.dart';

class AllExamsPage extends StatelessWidget {
  AllExamsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllExamsPageController>(
      init: AllExamsPageController(),
      builder: (screenController) => RefreshIndicator(
        onRefresh: () => screenController.getData(refresh: true),
        child: screenController.isLoading
            ? LoadingWidget(exam: true)
            : SingleChildScrollView(
                controller: screenController.scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    screenController.examController.allExams.isEmpty
                        ? ConstrainedBox(
                            constraints:
                                BoxConstraints(maxHeight: Get.height * 0.8),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: Get.height * 0.05),
                              child: EmptyWidget(),
                            ),
                          )
                        : ListView.builder(
                            itemCount:
                                screenController.examController.allExams.length,
                            padding:
                                EdgeInsets.only(top: 16, left: 8, right: 8),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (_, index) {
                              final item = screenController
                                  .examController.allExams[index];
                              return ExamItemWidget(
                                onTap: () => item.userExam == null
                                    ? Get.toNamed('/exam-screen', arguments: {
                                        'id': item.id,
                                        'isTheCoach': false,
                                        //todo  'isTheCoach':item.courseId,
                                      })
                                    : () =>
                                        Get.toNamed('/exam-screen', arguments: {
                                          'id': item.id,
                                          'isTheCoach': false,
                                          'answers': item.userExam?.answers,
                                        }),
                                name: Get.locale == const Locale('ar')
                                    ? item.nameAr
                                    : item.nameEn,
                                trailingImage: item.userExam != null
                                    ? null
                                    : item.status == 0
                                        ? Icons.login_rounded
                                        : item.status == 1
                                            ? Icons.more_horiz
                                            : Icons.slideshow,
                                trailingText: item.userExam != null
                                    ? getDoubleNumber(item.userExam!.mark)
                                        .toString()
                                    : null,
                                textColor: Get.isDarkMode
                                    ? item.status == 0
                                        ? Themes.primaryColorDark
                                        : Themes.textColorDark
                                    : null,
                                backgroundColor: item.status == 0
                                    ? Get.isDarkMode
                                        ? Themes.primaryColorLightDark
                                        : Themes.primaryColorLight
                                    : item.status == 1
                                        ? Get.isDarkMode
                                            ? Themes.gradientMerged
                                                .withOpacity(0.8)
                                            : Themes.offerColor.withOpacity(0.2)
                                        : Get.isDarkMode
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
    );
  }
}
