import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/one_exam_screen_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/app_bar.dart';
import 'package:the_academy/view/widgets/custom_widgets/drawer.dart';
import 'package:the_academy/view/widgets/custom_widgets/my_button.dart';
import 'package:the_academy/view/widgets/dialogs/confirm_leave_the_exam_dialog.dart';

import '../widgets/custom_widgets/loading_widget.dart';
import '../widgets/flutter_timer_countdown/timer_countdown.dart';
import '../widgets/lists_items/question_item.dart';

class OneExamScreen extends StatelessWidget {
  OneExamScreen({Key? key}) : super(key: key);
  final OneExamScreenController screenController = Get.find();

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
              if (screenController.isStarted /* .value */) {
                confirmLeaveTheExamDialog(screenController.submitExam);

                return false;
              }
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
                  body: SafeArea(
                    child: AppDrawer(
                      screenController.userController.currentUser.name,
                      screenController
                          .userController.currentUser.profileImageUrl,
                      screenController,
                      isCoach:
                          screenController.userController.userCanEditCourse,
                      needPop: true,
                    ),
                  ),
                ),
                Transform(
                  transform: Matrix4.identity()
                    ..translate(slide)
                    ..scale(scale),
                  alignment: Alignment.center,
                  child: GetBuilder<OneExamScreenController>(
                    builder:
                        (_) =>
                            screenController.isLoading ||
                                    screenController.examFullData == null
                                ? Scaffold(
                                    body: Container(
                                        constraints: BoxConstraints(
                                            minHeight: Get.size.height,
                                            minWidth: Get.size.width),
                                        child: LoadingWidget(exam: true)),
                                  )
                                : Scaffold(
                                    appBar: MyAppBar(
                                      onMenuTap: () {
                                        if (screenController
                                            .isStarted /* .value */) {
                                          confirmLeaveTheExamDialog(
                                              screenController.submitExam);
                                          return false;
                                        }
                                        screenController.toggleAnimation();
                                      },
                                      isOpend: screenController.isOpend,
                                      title: Text(
                                          Get.locale == const Locale('ar')
                                              ? screenController
                                                  .examFullData!.nameAr
                                              : screenController
                                                  .examFullData!.nameEn,
                                          textAlign: TextAlign.center,
                                          style: Get.textTheme.titleLarge
                                              ?.copyWith(
                                                  color: Get.isDarkMode
                                                      ? Themes.textColorDark
                                                      : Themes.textColor,
                                                  fontWeight: FontWeight.bold)),
                                      isUserImage: true,
                                    ),
                                    persistentFooterButtons: screenController
                                                    .examFullData ==
                                                null ||
                                            screenController.userAnswers !=
                                                null ||
                                            screenController
                                                    .examFullData!.status ==
                                                0 ||
                                            screenController.isTheCoach
                                        ? null
                                        : [
                                            GetBuilder<OneExamScreenController>(
                                                builder: (_) => MyButton(
                                                    onTap: screenController
                                                                    .examFullData!
                                                                    .status ==
                                                                0 &&
                                                            !screenController
                                                                .isTheCoach
                                                        ? () {}
                                                        : () => !screenController
                                                                .isStarted /* .value */
                                                            ? screenController
                                                                .startTheExam()
                                                            : screenController
                                                                .submitExam(),
                                                    shadowColor: Themes
                                                        .primaryColor
                                                        .withOpacity(0.2),
                                                    textColor: Themes
                                                        .primaryColorLight,
                                                    backgroundColor:
                                                        Themes.primaryColor,
                                                    title: !screenController
                                                            .isStarted /* .value */
                                                        ? screenController
                                                                        .examFullData!
                                                                        .status ==
                                                                    1 &&
                                                                !screenController
                                                                    .isTheCoach
                                                            ? 'take_the_exam'.tr
                                                            : 'take_the_exam_virtual'
                                                                .tr
                                                        : 'submit'.tr))
                                          ],
                                    body: SafeArea(
                                      child:
                                          GetBuilder<OneExamScreenController>(
                                              builder: (_) => AbsorbPointer(
                                                    absorbing: screenController
                                                            .isOpend ||
                                                        !screenController
                                                            .showQuestions,
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Stack(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              /*  GetBuilder<
                                                                  OneExamScreenController>(
                                                                builder: (_) => */
                                                              screenController
                                                                      .isStarted
                                                                  ? TimerCountdown(
                                                                      format: CountDownTimerFormat
                                                                          .hoursMinutesSeconds,
                                                                      enableDescriptions:
                                                                          false,
                                                                      timeTextStyle:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            30,
                                                                        color: Get.isDarkMode
                                                                            ? Themes.textColorDark
                                                                            : Themes.textColor,
                                                                      ),
                                                                      endTime:
                                                                          screenController
                                                                              .endTime,
                                                                      onEnd: screenController
                                                                          .timerEnd,
                                                                    )
                                                                  : Center(
                                                                      child:
                                                                          Text(
                                                                        screenController
                                                                            .time,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              30,
                                                                          color: Get.isDarkMode
                                                                              ? Themes.textColorDark
                                                                              : Themes.textColor,
                                                                        ),
                                                                      ),
                                                                    ),
                                                              //  ),
                                                              CarouselSlider(
                                                                carouselController:
                                                                    screenController
                                                                        .carouselController,
                                                                options:
                                                                    CarouselOptions(
                                                                  autoPlay:
                                                                      false,
                                                                  reverse:
                                                                      false,
                                                                  enableInfiniteScroll:
                                                                      false,
                                                                  height:
                                                                      Get.height *
                                                                          0.6,
                                                                  padEnds:
                                                                      false,
                                                                  //pageSnapping: false,
                                                                  aspectRatio:
                                                                      1,
                                                                  /*  scrollPhysics:
                                                    NeverScrollableScrollPhysics(),
                                                */
                                                                  viewportFraction:
                                                                      1,
                                                                  onPageChanged: (index,
                                                                          _) =>
                                                                      screenController
                                                                          .onPageChanged(
                                                                              index),
                                                                ),
                                                                items: [
                                                                  ...screenController
                                                                      .examFullData!
                                                                      .questions
                                                                      .asMap()
                                                                      .map((index,
                                                                          item) {
                                                                        return MapEntry(
                                                                            index,
                                                                            Center(
                                                                              child: QuestionItem(
                                                                                item: item,
                                                                                ignoring: true,
                                                                                groupValue: screenController.answers[index] != null ? screenController.answers[index]?.value : null,
                                                                                onChanged: !screenController.isStarted /* .value */ || screenController.timerEnded ? null : (value) => screenController.changeAnswer(index, value as String),
                                                                                radioColor: screenController.radioColor(item, index),
                                                                                showTrueAnswers: screenController.showTrueAnswers,
                                                                              ),
                                                                            ));
                                                                      })
                                                                      .values
                                                                      .toList(),
                                                                  //review
                                                                  ListView
                                                                      .builder(
                                                                          itemCount: screenController.examFullData!.questions.length +
                                                                              1,
                                                                          shrinkWrap:
                                                                              true,
                                                                          itemBuilder:
                                                                              (_, index) {
                                                                            if (index ==
                                                                                screenController.examFullData!.questions.length)
                                                                              return screenController.userAnswers != null
                                                                                  ? SizedBox()
                                                                                  : Center(
                                                                                      child: Text(
                                                                                      '${'answerd'.tr}  ${screenController.answerdQuestions}  ${'of'.tr}  ${screenController.examFullData!.questions.length} ',
                                                                                      style: Get.textTheme.titleLarge?.copyWith(color: Themes.offerColor),
                                                                                    ));
                                                                            final item =
                                                                                screenController.examFullData!.questions[index];

                                                                            return QuestionItem(
                                                                              item: item,
                                                                              groupValue: screenController.answers[index] != null ? screenController.answers[index]?.value : null,
                                                                              onChanged: !screenController.isStarted /* .value */ || screenController.timerEnded ? null : (value) => screenController.changeAnswer(index, value as String),
                                                                              radioColor: screenController.radioColor(item, index),
                                                                              showTrueAnswers: screenController.showTrueAnswers,
                                                                            );
                                                                          })
                                                                ],
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    ElevatedButton(
                                                                      onPressed: screenController
                                                                              .previousPageFunction()
                                                                          ? screenController
                                                                              .previousPage
                                                                          : null,
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Icon(Icons
                                                                              .navigate_before_rounded),
                                                                          SizedBox(
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          Text('previous'
                                                                              .tr),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      screenController.currentQuestion ==
                                                                              screenController.examFullData!.questions.length
                                                                          ? 'review'.tr
                                                                          : '${screenController.currentQuestion + 1}   ${'from'.tr}   ${screenController.examFullData!.questions.length}',
                                                                      style: TextStyle(
                                                                          color: Get.isDarkMode
                                                                              ? Themes.textColorDark
                                                                              : Themes.textColor),
                                                                    ),
                                                                    ElevatedButton(
                                                                      onPressed: screenController
                                                                              .nextPageFunction()
                                                                          ? screenController
                                                                              .nextPage
                                                                          : null,
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Text('next'
                                                                              .tr),
                                                                          SizedBox(
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          Icon(Icons
                                                                              .navigate_next_rounded),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          !screenController
                                                                  .showQuestions
                                                              ? BackdropFilter(
                                                                  filter: new ImageFilter
                                                                          .blur(
                                                                      sigmaX:
                                                                          10.0,
                                                                      sigmaY:
                                                                          10.0),
                                                                  child:
                                                                      Container(
                                                                    width: Get
                                                                        .width,
                                                                    height: Get
                                                                            .height -
                                                                        (Get.height *
                                                                                0.047 +
                                                                            Get.height *
                                                                                0.043 *
                                                                                2.5),
                                                                    decoration: new BoxDecoration(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade200
                                                                            .withOpacity(0.5)),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        screenController.durationInDaysToStart !=
                                                                                null
                                                                            ? Container(
                                                                                height: Get.height * 0.25,
                                                                                width: Get.width / 2,
                                                                                alignment: Alignment.center,
                                                                                decoration: BoxDecoration(gradient: Themes.linearGradient, shape: BoxShape.circle),
                                                                                child: Text(
                                                                                  '${Get.locale == const Locale('ar') ? 'left'.tr : ''} ${screenController.durationInDaysToStart} ${'days'.tr} ${Get.locale != const Locale('ar') ? 'left'.tr : ''}',
                                                                                  style: TextStyle(fontSize: Get.textTheme.headlineMedium?.fontSize, color: Themes.primaryColorLight, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              )
                                                                            : screenController.durationInMinuteToStart == 0
                                                                                ? Image.asset(
                                                                                    'assets/images/logo.png',
                                                                                    height: Get.height * 0.25,
                                                                                  )
                                                                                : CircularCountDownTimer(
                                                                                    duration: screenController.durationInMinuteToStart * 60,
                                                                                    width: Get.width / 2.5,
                                                                                    height: Get.height * 0.25,
                                                                                    ringColor: Themes.buttonColor,
                                                                                    backgroundGradient: Themes.linearGradient,
                                                                                    fillColor: Themes.gradientMerged,
                                                                                    strokeWidth: Get.width * 0.05,
                                                                                    strokeCap: StrokeCap.round,
                                                                                    textStyle: TextStyle(fontSize: Get.textTheme.headlineMedium?.fontSize, color: Themes.primaryColorLight, fontWeight: FontWeight.bold),
                                                                                    textFormat: CountdownTextFormat.HH_MM_SS,
                                                                                    isReverse: true,
                                                                                    isReverseAnimation: false,
                                                                                    isTimerTextShown: true,
                                                                                    autoStart: true,
                                                                                    onComplete: screenController.updateStatus,
                                                                                  ),
                                                                        SizedBox(
                                                                          height:
                                                                              Get.height * 0.1,
                                                                        ),
                                                                        Text(
                                                                          'get_ready'
                                                                              .tr,
                                                                          style: Get
                                                                              .textTheme
                                                                              .headlineMedium
                                                                              ?.copyWith(color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor, fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              : SizedBox(),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
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
