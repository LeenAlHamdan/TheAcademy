import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/one_course_of_mine_screen_controller.dart';

import 'package:the_academy/controller/screens_controllers/my_chats_screen_controller.dart';
import 'package:the_academy/model/course.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/lists_items/user_list_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/tap_widget.dart';

import '../../../controller/screens_controllers/chat_screen_controller.dart';
import '../../../model/chat.dart';
import '../../widgets/custom_widgets/empty_widget.dart';
import '../../widgets/custom_widgets/load_more_widget.dart';
import '../../widgets/custom_widgets/loading_widget.dart';

class MyChatsPage extends StatelessWidget {
  MyChatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyChatsScreenController>(
        init: MyChatsScreenController(),
        builder: (screenController) {
          return RefreshIndicator(
            onRefresh: () => screenController.getData(refresh: true),
            child: screenController.isLoading
                ? LoadingWidget(
                    chat: true,
                  )
                : SingleChildScrollView(
                    controller: screenController.scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: Get.height * 0.018,
                            left: Get.width * 0.018,
                            right: Get.width * 0.018,
                          ),
                          child: Container(
                            height: Get.height * 0.071,
                            decoration: BoxDecoration(
                              color: Themes.primaryColorLight,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                  width: 1.0,
                                  color:
                                      Themes.primaryColorDark.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Themes.primaryColorDark.withOpacity(0.1),
                                  offset: Offset(0, 16),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TapWidget(
                                  name: 'courses'.tr,
                                  isSelected: screenController.selectedFilter ==
                                      'courses',
                                  iconData: Icons.groups_rounded,
                                  tapsNum: 3,
                                  onTap: () => screenController
                                      .toggleSelectedFilter('courses'),
                                ),
                                if (screenController
                                    .userController.userCanEditCourse)
                                  TapWidget(
                                    name: 'own_courses'.tr,
                                    isSelected:
                                        screenController.selectedFilter ==
                                            'my-own-courses',
                                    iconData: Icons.person_rounded,
                                    tapsNum: 3,
                                    onTap: () => screenController
                                        .toggleSelectedFilter('my-own-courses'),
                                  ),
                                TapWidget(
                                  name: 'private'.tr,
                                  isSelected: screenController.selectedFilter ==
                                      'private',
                                  iconData: Icons.person_rounded,
                                  tapsNum: 3,
                                  onTap: () => screenController
                                      .toggleSelectedFilter('private'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        screenController.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: Get.height * 0.05),
                                child: EmptyWidget(),
                              )
                            : ListView.builder(
                                itemCount: screenController.itemList.length,
                                physics: NeverScrollableScrollPhysics(),
                                padding:
                                    EdgeInsets.only(top: 16, left: 8, right: 8),
                                shrinkWrap: true,
                                itemBuilder: (_, index) {
                                  if (screenController.selectedFilter ==
                                          'courses' ||
                                      screenController.selectedFilter ==
                                          'my-own-courses') {
                                    final item = screenController
                                        .itemList[index] as Course;
                                    return UserListWidget(
                                      name: Get.locale == const Locale('ar')
                                          ? item.nameAr
                                          : item.nameEn,
                                      image: item.image,
                                      onLongTap: () {},
                                      onTap: () {
                                        final oneCourseOfMineScreenController =
                                            Get.put(
                                                OneCourseOfMineScreenController());
                                        (oneCourseOfMineScreenController)
                                            .updateCourseId(
                                          item.id,
                                          Get.locale == const Locale('ar')
                                              ? item.nameAr
                                              : item.nameEn,
                                          item.image,
                                          initTab:
                                              OneCourseOfMineScreenController
                                                  .chatTabIndex,
                                        );

                                        Get.toNamed(
                                          '/one-course-of-mine-screen',
                                          /* arguments: {
                                              'id': item.id,
                                              'title': Get.locale ==
                                                      const Locale('ar')
                                                  ? item.nameAr
                                                  : item.nameEn,
                                              'image': item.image,
                                              'initTab':
                                                  OneCourseOfMineScreenController
                                                      .chatTabIndex,
                                            } */
                                        );
                                      },
                                    );
                                  } else {
                                    final item = screenController
                                        .itemList[index] as Chat;

                                    final secondUser = item.users
                                        .firstWhereOrNull((element) =>
                                            element.id !=
                                            screenController
                                                .userController.currentUser.id);
                                    if (secondUser == null) {
                                      return SizedBox();
                                    }
                                    return UserListWidget(
                                      name: secondUser.name,
                                      image: secondUser.profileImageUrl,
                                      isOnline: secondUser.isOnline,
                                      onLongTap: () => screenController
                                          .deleteChat(item.id, secondUser.name),
                                      onTap: () {
                                        final oneChatScreenController =
                                            Get.put(ChatScreenController());
                                        (oneChatScreenController).updateUserId(
                                            secondUser.id,
                                            secondUser.name,
                                            secondUser.profileImageUrl,
                                            conversationId: item.id);

                                        Get.toNamed(
                                          '/chat-screen', /* arguments: {
                                          'conversationId': item.id,
                                          'userId': secondUser.id,
                                          'title': secondUser.name,
                                          'image': secondUser.profileImageUrl,
                                        } */
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                        screenController.selectedFilter == 'courses' &&
                                screenController.loadMoreCourses
                            ? const LoadMoreWidget()
                            : SizedBox(),
                        screenController.selectedFilter != 'courses' &&
                                screenController.loadMoreChats
                            ? const LoadMoreWidget(
                                chat: true,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
          );
        });
  }
}
