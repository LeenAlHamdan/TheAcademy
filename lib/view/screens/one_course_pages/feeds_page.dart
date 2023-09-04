import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
//import 'package:flutter_map/flutter_map.dart';
//import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/message.dart';
import 'package:the_academy/utils/get_double_number.dart';
import 'package:the_academy/view/widgets/lists_items/file_item.dart';
import 'package:the_academy/view/widgets/lists_items/slides_item.dart';

import '../../../controller/screens_controllers/feed_page_controller.dart';
import '../../../model/themes.dart';
import '../../../utils/style.dart';
import '../../widgets/custom_widgets/empty_widget.dart';
import '../../widgets/custom_widgets/expandable_floationg_action_button.dart';
import '../../widgets/custom_widgets/load_more_widget.dart';
import '../../widgets/lists_items/location_item.dart';
import '../../widgets/lists_items/poll_item.dart';

class FeedsPage extends StatelessWidget {
  final String courseId;
  final bool isTheCoach;
  final bool userIsTheOwner;

  FeedsPage(this.courseId, this.isTheCoach, this.userIsTheOwner);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedPageController>(
      init: FeedPageController(courseId, isTheCoach),
      builder: (screenController) => Scaffold(
        body: RefreshIndicator(
          onRefresh: () async => await screenController.refreshData(),
          child: SingleChildScrollView(
            controller: screenController.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                top: Get.height * 0.017,
              ),
              child: Column(
                children: [
                  screenController.isLoading <= 0
                      ? Container()
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: screenController.isLoading,
                          itemBuilder: (context, index) => Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            elevation: 0,
                            color: Get.isDarkMode
                                ? Themes.primaryColorLight
                                : Themes.primaryColorDark.withOpacity(0.2),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: Get.height * 0.026,
                                horizontal: Get.width * 0.061,
                              ),
                              child: Column(children: [
                                Text('uploading_new_object'.tr),
                                LinearProgressIndicator(),
                              ]),
                            ),
                          ),
                        ),
                  !userIsTheOwner
                      ? SizedBox()
                      : Padding(
                          padding: EdgeInsets.only(
                            bottom: Get.height * 0.017,
                          ),
                          child: TextButton(
                            child: Text(
                              'show_users_evaluations'.tr,
                              style: TextStyle(
                                  fontSize:
                                      Get.theme.textTheme.titleLarge?.fontSize),
                            ),
                            onPressed: () => Get.toNamed(
                                '/all-users-evaluation-screen',
                                arguments: {
                                  'id': screenController.courseId,
                                  'title': Get.locale == const Locale('ar')
                                      ? screenController
                                          .oneCourseOfMineScreenController
                                          .courseFullData
                                          ?.nameAr
                                      : screenController
                                          .oneCourseOfMineScreenController
                                          .courseFullData
                                          ?.nameEn
                                }),
                          ),
                        ),
                  screenController.oneCourseOfMineScreenController
                              .courseFullData?.userEvaluation ==
                          null
                      ? SizedBox()
                      : Padding(
                          padding: EdgeInsets.only(
                            bottom: Get.height * 0.017,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            elevation: 0,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: AlignmentDirectional.topEnd,
                                  focalRadius: 5,
                                  focal: AlignmentDirectional.topEnd,
                                  colors: [
                                    Themes.primaryColor.withOpacity(0.5),
                                    Themes.primaryColor.withOpacity(0.3),
                                  ],
                                  stops: [0.9, 0.0],
                                ),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: Get.height * 0.026,
                                  horizontal: Get.width * 0.061,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: Get.width * 0.53,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'your_current_evaluation'.tr,
                                            textAlign: TextAlign.start,
                                            style: Get.textTheme.headlineSmall
                                                ?.copyWith(
                                                    /* color: Themes
                                                        .primaryColorLight, */
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: Get.height * 0.005,
                                            ),
                                            child: Text(
                                              '${'you_have_take'.tr} ${screenController.oneCourseOfMineScreenController.courseFullData?.userEvaluation?.examCount} ${screenController.oneCourseOfMineScreenController.courseFullData!.userEvaluation!.examCount > 1 ? 'exam-s'.tr : 'exam'.tr} ${'of'.tr} ${screenController.oneCourseOfMineScreenController.courseFullData?.userEvaluation?.examsCount} ${'and_your_evaluation_is'.tr}',
                                              textAlign: TextAlign.start,
                                              style: Get.textTheme.titleLarge
                                                  ?.copyWith(
                                                      color: Themes
                                                          .primaryColorLight,
                                                      fontWeight:
                                                          FontWeight.normal),
                                            ),
                                          ),
                                          Text(
                                            '${getDoubleNumber(screenController.oneCourseOfMineScreenController.courseFullData!.userEvaluation!.evaluation)} %',
                                            textAlign: TextAlign.center,
                                            style: Get.textTheme.headlineSmall
                                                ?.copyWith(
                                                    color: Themes
                                                        .primaryColorLight,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: Themes.primaryColor,
                                          border: Border.all(
                                            color: Get.isDarkMode
                                                ? Themes.primaryColorLight
                                                : Themes.primaryColorDark
                                                    .withAlpha(50),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0, 10),
                                              blurRadius: 24,
                                              color: Get.isDarkMode
                                                  ? Themes.primaryColorLight
                                                  : Themes.primaryColorDark
                                                      .withOpacity(0.2),
                                            ),
                                          ],
                                          shape: BoxShape.circle),
                                      child: ClipOval(
                                        child: Icon(
                                            Icons.star_purple500_outlined,
                                            color: Themes.primaryColorLight),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  screenController.feedMessages.isEmpty
                      ? EmptyWidget(title: 'no_feeds_yet'.tr)
                      : ListView.builder(
                          padding: EdgeInsets.only(
                            bottom: Get.height * 0.017,
                          ),
                          itemCount: screenController.feedMessages.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final item = screenController.feedMessages[index];
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 0.04 * Get.width,
                                vertical: 0.025 * Get.width,
                              ),
                              decoration: BoxDecoration(
                                color: Themes.primaryColorLight,
                                borderRadius: BorderRadius.circular(25.0),
                                border: Border.all(
                                    color: Themes.primaryColor, width: 2),
                                boxShadow: [
                                  S.boxShadow(color: Themes.primaryColor)
                                ],
                              ),
                              child: GestureDetector(
                                onLongPress: () =>
                                    screenController.deleteItem(item),
                                child: getWidget(
                                    item: item,
                                    groupValue:
                                        screenController.answers[index] != null
                                            ? screenController
                                                .answers[index]?.value
                                            : null,
                                    style: Get.textTheme.titleMedium!
                                        .copyWith(color: Themes.textColor),
                                    onChanged: (value) {
                                      item as Poll;
                                      screenController.changeAnswer(
                                        item,
                                        index,
                                        value as String,
                                      );
                                    }),
                              ),
                            );

                            //return Text(screenController.pools[index].content);
                          },
                        ),
                  screenController.loadMore
                      ? const LoadMoreWidget(isDefault: true)
                      : SizedBox()
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(right: Get.width * 0.08),
          child: ExpandableFab(
            distance: 112,
            children: [
              ActionButton(
                onPressed: screenController.showPollDialog,
                icon: const Icon(Icons.poll_rounded),
              ),
              ActionButton(
                onPressed: screenController.addSlidesDialog,
                icon: const Icon(Icons.play_circle_rounded),
              ),
              ActionButton(
                onPressed: screenController.addFile,
                icon: const Icon(Icons.file_present_rounded),
              ),
              ActionButton(
                onPressed: screenController.addLocation,
                icon: const Icon(Icons.location_on_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getWidget({
    required Message item,
    required String? groupValue,
    required TextStyle style,
    required Function onChanged,
  }) {
    if (item.isPoll) {
      item as Poll;
      return PollItem(
        title: item.content,
        groupValue: groupValue,
        onChanged: onChanged,
        options: item.poolOptions,
        totalVotes: item.totalVotes,
        isTheCoach: isTheCoach,
        userHasVoted: item.userHasVoted,
      );
    } else if (item.isSlides) {
      item as Slide;

      return SlideItem(
        images: item.images,
        title: item.content,
        style: style,
      );
    } else if (item.isFile) {
      item as MyFile;
      return FileItem(id: item.id, url: item.content, path: item.path);
    } else if (item.isLocation) {
      item as Location;

      ///return Text(item.content);

      return LocationItem(
          title: item.content,
          style: style,
          latitude: double.parse(item.latitude),
          longitude: double.parse(item.longitude));
    } else {
      return Text(item.content);
    }
  }
}
