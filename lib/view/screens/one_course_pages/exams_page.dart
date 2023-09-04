import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/lists_items/exam_item_widget.dart';

import '../../../controller/models_controller/exam_controller.dart';
import '../../../controller/screens_controllers/exams_page_controller.dart';
import '../../../utils/get_double_number.dart';
import '../../widgets/custom_widgets/empty_widget.dart';
import '../../widgets/custom_widgets/load_more_widget.dart';
import '../../widgets/dialogs/confirm_leave_the_course_dialog.dart';

class ExamsPage extends StatelessWidget {
  final bool canEditCourse;
  final bool userIsTheOwner;
  final String courseId;
  final String courseNameAr;
  final String courseNameEn;
  ExamsPage(this.courseId, this.courseNameAr, this.courseNameEn,
      this.canEditCourse, this.userIsTheOwner);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamPageController>(
      init: ExamPageController(courseId, canEditCourse, userIsTheOwner),
      builder: (screenController) => Scaffold(
        body: RefreshIndicator(
          onRefresh: () => screenController.refreshData(),
          child: SingleChildScrollView(
            controller: screenController.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                GetBuilder<ExamController>(
                  builder: (examController) => examController.exams.isEmpty
                      ? EmptyWidget()
                      : ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: examController.exams.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 8),
                          itemBuilder: (_, index) {
                            final item = examController.exams[index];
                            return screenController.loadingItems
                                    .contains(item.id)
                                ? LoadMoreWidget(
                                    isDefault: true,
                                  )
                                : ExamItemWidget(
                                    onTap: () =>
                                        screenController.oneExamTaped(item),
                                    onLongTap: canEditCourse
                                        ? () => confirmLeaveTheCourseDialog(
                                              () => screenController
                                                  .deleteExam(item.id),
                                              title:
                                                  'are_you_sure_delete_this_exam'
                                                      .tr,
                                              confirm: 'delete'.tr,
                                              cancel: 'cancel'.tr,
                                            )
                                        : null,
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
                                    trailingText: /* index == 3
                                        ? 60.toString()
                                        : */
                                        item.userExam != null
                                            ? getDoubleNumber(
                                                    item.userExam!.mark)
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
                                                : Themes.offerColor
                                                    .withOpacity(0.2)
                                            : Get.isDarkMode
                                                ? Themes.gradientColor1
                                                    .withOpacity(0.2)
                                                : Themes.greenColor
                                                    .withOpacity(0.2),
                                  );
                          }),
                ),
                screenController.loadMore
                    ? const LoadMoreWidget(isDefault: true)
                    : SizedBox()
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: !canEditCourse
            ? null
            : FloatingActionButton(
                heroTag: "btn5",
                onPressed: () => Get.toNamed('/add-exam-screen', arguments: {
                  'courseId': courseId,
                  'courseNameAr': courseNameAr,
                  'courseNameEn': courseNameEn,
                }),
                child: Icon(Icons.add),
              ),
      ),
    );
  }
}
