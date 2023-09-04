import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/screens_controllers/one_exam_screen_controller.dart';
import '../../../model/question.dart';
import '../../../model/themes.dart';

class QuestionItem extends StatelessWidget {
  const QuestionItem({
    Key? key,
    required this.item,
    this.ignoring,
    this.radioColor,
    required this.groupValue,
    required this.onChanged,
    required this.showTrueAnswers,
  }) : super(key: key);

  final Question item;
  final groupValue;
  final Function? onChanged;
  final bool? ignoring;
  final bool showTrueAnswers;
  final Color? radioColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(8),
      color: Themes.primaryColor.withOpacity(0.2),
      child: ignoring != null && ignoring!
          ? Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  top: BorderSide(color: Colors.transparent),
                  bottom: BorderSide(color: Colors.transparent),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTileTheme.merge(
                    child: ListTile(
                      title: Text(
                        item.text,
                        style: Get.textTheme.titleMedium?.copyWith(
                            color: Get.isDarkMode
                                ? Themes.textColorDark
                                : Themes.textColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  ClipRect(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: item.choices
                            .map((choice) => ListTile(
                                  title: Text(
                                    choice.text,
                                    style: TextStyle(
                                        color: showTrueAnswers &&
                                                (choice.isTrueAnswer ?? false)
                                            ? Themes.greenColor
                                            : Get.isDarkMode
                                                ? Themes.primaryColorLightDark
                                                : null),
                                  ),
                                  leading: GetBuilder<OneExamScreenController>(
                                    builder: (_) => Radio(
                                      value: choice.id,
                                      groupValue: groupValue,
                                      onChanged: onChanged != null
                                          ? (value) => onChanged!(value)
                                          : null,
                                      fillColor: MaterialStateProperty
                                          .resolveWith<Color>((states) {
                                        /* if (states
                                            .contains(MaterialState.disabled)) {
                                          return Colors.red.withOpacity(.32);
                                        } */
                                        return radioColor ??
                                            Themes.primaryColor;
                                      }),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ExpansionTile(
              title: Text(
                item.text,
                style: TextStyle(
                    color: Get.isDarkMode
                        ? Themes.textColorDark
                        : Themes.textColor),
              ),
              children: item.choices
                  .map((choice) => ListTile(
                        title: Text(
                          choice.text,
                          style: TextStyle(
                              color: Get.isDarkMode
                                  ? Themes.primaryColorLightDark
                                  : null),
                        ),
                        leading: GetBuilder<OneExamScreenController>(
                          builder: (_) => Radio(
                            value: choice.id,
                            groupValue: groupValue,
                            onChanged: onChanged != null
                                ? (value) => onChanged!(value)
                                : null,
                          ),
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}
