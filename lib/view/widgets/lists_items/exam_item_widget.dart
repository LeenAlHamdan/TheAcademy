import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';

class ExamItemWidget extends StatelessWidget {
  final String name;
  final IconData? trailingImage;
  final String? trailingText;
  final Color backgroundColor;
  final Color? textColor;
  final Function onTap;
  final Function()? onLongTap;

  ExamItemWidget({
    required this.name,
    required this.backgroundColor,
    required this.onTap,
    this.onLongTap,
    this.trailingImage,
    this.trailingText,
    this.textColor,
  }) : assert(trailingImage != null || trailingText != null);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: Get.height * 0.077,
        margin: EdgeInsets.only(top: Get.height * 0.018),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
              width: 1.0,
              color: Get.isDarkMode
                  ? Themes.primaryColorLight
                  : Themes.primaryColorDark.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Themes.primaryColorDark.withOpacity(0.1),
              offset: Offset(0, 16),
              blurRadius: 20,
            ),
          ],
        ),
        child: ListTile(
          onTap: () => onTap(),
          onLongPress: onLongTap,
          title: Text(
            name,
            style: Get.textTheme.titleMedium?.copyWith(color: textColor),
          ),
          leading: Icon(
            Icons.app_registration_rounded,
            color: Themes.primaryColor,
          ),
          trailing: Container(
            padding: EdgeInsets.all(8),
            constraints: BoxConstraints(
                minHeight: Get.width * 0.1, minWidth: Get.width * 0.1),
            decoration: BoxDecoration(
              color: Themes.primaryColor,
              shape: BoxShape.circle,
            ),
            child: trailingImage != null
                ? Icon(
                    trailingImage,
                    color: Themes.primaryColorLight,
                  )
                : Text(
                    trailingText!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Themes.primaryColorLight,
                    ),
                  ),
          ),
        ));
  }
}
