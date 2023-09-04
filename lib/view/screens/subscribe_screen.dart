import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/subscribe_controller.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/utils/get_double_number.dart';
import 'package:the_academy/view/widgets/custom_widgets/loading_widget.dart';
import 'package:the_academy/view/widgets/custom_widgets/my_button.dart';
import 'package:the_academy/view/widgets/screens_background.dart';

class SubscribeScreen extends StatelessWidget {
  SubscribeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscribeController>(
      init: SubscribeController(),
      builder: (screenController) => Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        resizeToAvoidBottomInset: true,
        body: WillPopScope(
          onWillPop: screenController.onPop,
          child: SafeArea(
            child: CustomPaint(
              painter: ScreenBackgoundPainter(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      height: Get.height * 0.8,
                      reverse: false,
                      onPageChanged: (index, _) =>
                          screenController.onPageChanged(),
                    ),
                    items: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SingleChildScrollView(
                            child: SizedBox(
                              height: Get.height * 0.8,
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  color: Themes.primaryColorLight,
                                  elevation: 15,
                                  shadowColor:
                                      Themes.primaryColorDark.withOpacity(0.2),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: Get.height * 0.047),
                                        child: Container(
                                          decoration: BoxDecoration(boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0, 10),
                                              blurRadius: 24,
                                              color: Themes.primaryColorDark
                                                  .withOpacity(0.2),
                                            ),
                                          ]),
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor:
                                                Themes.primaryColorLight,
                                            child: Image.asset(
                                              'assets/images/register_as_coach.png',
                                              height: Get.height * 0.03,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Get.height * 0.01,
                                      ),
                                      Text(
                                        'coach_plan'.tr,
                                        textAlign: TextAlign.center,
                                        style: Get.textTheme.headlineMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.normal,
                                                color: Themes.textColor),
                                      ),
                                      SizedBox(
                                        height: Get.height * 0.017,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: Get.width * 0.1,
                                        ),
                                        child: Text(
                                          'coach_plan_subtitle'.tr,
                                          textAlign: TextAlign.center,
                                          style: Get.textTheme.headlineSmall
                                              ?.copyWith(
                                                  color:
                                                      Themes.primaryColorDark,
                                                  fontWeight:
                                                      FontWeight.normal),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Get.height * 0.017,
                                      ),
                                      /* RichText(
                                              text: TextSpan(
                                                text: '0 ',
                                                style: Get
                                                    .textTheme
                                                    .headline5
                                                    ?.copyWith(color: Themes.textColor),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: 's.p'.tr,
                                                    style: Get
                                                        .textTheme
                                                        .headline5
                                                        ?.copyWith(
                                                            color: Themes.textColor),
                                                  ),
                                                  TextSpan(
                                                    text: ' /',
                                                    style: Get
                                                        .textTheme
                                                        .subtitle1
                                                        ?.copyWith(
                                                            color: Themes
                                                                .primaryColorDark),
                                                  ),
                                                  TextSpan(
                                                    text: 'month'.tr,
                                                    style: Get
                                                        .textTheme
                                                        .subtitle1
                                                        ?.copyWith(
                                                            color: Themes
                                                                .primaryColorDark),
                                                  ),
                                                ],
                                              ),
                                            ) */
                                      Text(
                                        '${getDoubleNumber(screenController.generalsController.coachSubscriptionFee)} ${'ls'.tr}',

                                        //'free'.tr,
                                        style: Get.textTheme.headlineSmall
                                            ?.copyWith(color: Themes.textColor),
                                      ),
                                      SizedBox(
                                        height: Get.height * 0.043,
                                      ),
                                      ...screenController.coachPermissions
                                          .map((e) => Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: Get.height * 0.017,
                                                  left: Get.width * 0.089,
                                                  right: Get.width * 0.089,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.check,
                                                      color: Themes.greenColor,
                                                    ),
                                                    SizedBox(
                                                      width: Get.width * 0.06,
                                                    ),
                                                    SizedBox(
                                                      width: Get.width * 0.44,
                                                      child: Text(
                                                        Get.locale ==
                                                                const Locale(
                                                                    'ar')
                                                            ? e.nameAr
                                                            : e.nameEn,
                                                        style: Get.textTheme
                                                            .headlineSmall
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                      Spacer(),
                                      Padding(
                                          padding: EdgeInsets.only(
                                            bottom: Get.height * 0.04,
                                            left: Get.width * 0.081,
                                            right: Get.width * 0.081,
                                          ),
                                          child: screenController.isLoading
                                              ? LoadingWidget()
                                              : MyButton(
                                                  onTap: () => screenController
                                                      .subscribe(),
                                                  backgroundColor:
                                                      Themes.primaryColor,
                                                  shadowColor: Themes
                                                      .primaryColor
                                                      .withOpacity(0.2),
                                                  title: 'subscribe'.tr,
                                                  textColor:
                                                      Themes.primaryColorLight,
                                                )),
                                    ],
                                  )),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Themes.offerColor,
                                borderRadius: BorderRadius.circular(19.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              child: Text(
                                'limited_offer'.tr,
                                style: Get.textTheme.bodySmall
                                    ?.copyWith(color: Themes.primaryColorLight),
                                textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: false),
                                softWrap: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Themes.primaryColor),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(top: Get.height * 0.037),
          child: FloatingActionButton(
            elevation: 0,
            heroTag: "sub-exit-btn",
            onPressed: screenController.onClosePress,
            backgroundColor: Themes.primaryColorLight,
            child: Icon(
              Icons.close,
              color: Themes.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
