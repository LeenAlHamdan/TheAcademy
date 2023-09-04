import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyButton extends StatelessWidget {
  final Function onTap;
  final Color shadowColor;
  final Color backgroundColor;
  final Color textColor;
  final String title;
  final Widget? titleWidget;

  MyButton({
    required this.onTap,
    required this.shadowColor,
    required this.backgroundColor,
    required this.textColor,
    required this.title,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 10),
                blurRadius: 24,
                color: shadowColor,
              ),
            ]),
        child: titleWidget ??
            Text(title,
                textAlign: TextAlign.center,
                style: Get.textTheme.titleLarge?.copyWith(color: textColor)),
      ),
    );
  }
}
