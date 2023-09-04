import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/all_users_evaluation_screen_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/utils/get_double_number.dart';
import 'package:the_academy/view/widgets/lists_items/user_list_widget.dart';

import '../widgets/custom_widgets/app_bar.dart';
import '../widgets/custom_widgets/empty_widget.dart';
import '../widgets/custom_widgets/loading_widget.dart';

class AllUsersEvaluationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllUsersEvaluationScreenController>(
      init: AllUsersEvaluationScreenController(),
      builder: (screenController) => Scaffold(
        appBar: MyAppBar(
            title: Text(screenController.title,
                textAlign: TextAlign.center,
                style: Get.textTheme.titleLarge?.copyWith(
                    color: Get.isDarkMode
                        ? Themes.textColorDark
                        : Themes.textColor,
                    fontWeight: FontWeight.bold)),
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Icon(
                Icons.arrow_back_ios_outlined,
                color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
              ),
            ),
            isUserImage: true),
        body: RefreshIndicator(
          onRefresh: () => screenController.refreshData(),
          child: screenController.isLoading
              ? LoadingWidget(exam: true)
              : SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: screenController.scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (screenController.exams.isNotEmpty)
                          TextButton(
                            child: Text(
                              '${'total_exams'.tr} ${screenController.exams.first.examsCount}',
                              style: TextStyle(
                                  fontSize:
                                      Get.theme.textTheme.titleLarge?.fontSize),
                            ),
                            onPressed: () {},
                          ),
                        screenController.exams.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: Get.height * 0.05),
                                child: EmptyWidget(),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final item = screenController.exams[index];
                                  return UserListWidget(
                                    image: item.userImage,
                                    name: item.userName,
                                    trailingWidget: Container(
                                      padding: EdgeInsets.all(8),
                                      constraints: BoxConstraints(
                                          minHeight: Get.width * 0.1,
                                          minWidth: Get.width * 0.1),
                                      decoration: BoxDecoration(
                                        color: Themes.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        getDoubleNumber(item.evaluation)
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Themes.primaryColorLight,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: screenController.exams.length,
                              )
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
