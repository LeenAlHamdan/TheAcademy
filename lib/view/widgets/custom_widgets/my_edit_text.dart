import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';

class MyEditText extends StatelessWidget {
  const MyEditText({
    Key? key,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.onSubmitted,
    this.textFocusNode,
    this.textInputAction,
    this.textDirection,
    required this.textController,
    required this.title,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.hintStyle,
    this.textAlign,
    this.validator,
    this.multiLine = false,
    //this.color,
    this.onTap,
    this.onTapOutSide,
  }) : super(key: key);
  final Function()? onTap;
  final Function()? onTapOutSide;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final TextEditingController textController;
  final FocusNode? textFocusNode;
  final Function? onSubmitted;
  final String title;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextStyle? hintStyle;
  final TextAlign? textAlign;
  final String? Function(String?)? validator;
  final bool multiLine;
  //final Color? color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: /*  color ?? */
            (Get.isDarkMode
                ? Get.theme.colorScheme.background
                : Themes.buttonColor),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        cursorColor: Themes.primaryColor,
        textAlignVertical: TextAlignVertical.center,
        textAlign: textAlign ?? TextAlign.start,
        decoration: InputDecoration(
          hintText: title,
          prefixIcon: Icon(prefixIcon,
              color: Get.isDarkMode ? Themes.textColorDark : null),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          hintStyle: hintStyle ??
              TextStyle(
                color: Get.isDarkMode ? Themes.textColorDark : null,
              ),
          errorStyle: TextStyle(
            color: Get.theme.colorScheme.error,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Get.isDarkMode
                      ? Themes.primaryColorLight
                      : Themes.primaryColorDark)),
        ),
        enabled: enabled,
        style: TextStyle(
            color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
        textDirection: textDirection,
        focusNode: textFocusNode,
        controller: textController,
        onTap: onTap ?? _moveCursorToEnd,
        obscureText: obscureText,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        onFieldSubmitted:
            onSubmitted != null ? (value) => onSubmitted!(value) : (_) {},
        autofocus: autofocus,
        validator: validator,
        onEditingComplete: onTapOutSide,
        onTapOutside: (_) {
          if (onTapOutSide != null) onTapOutSide!();
        },
        onSaved: (_) {
          if (onTapOutSide != null) onTapOutSide!();
        },
        maxLines: multiLine ? null : 1,
      ),
    );
  }

  void _moveCursorToEnd() {
    if (textController.text.length <= 1) {
      textController.selection = TextSelection.fromPosition(
        TextPosition(offset: textController.text.length),
      );
    }
  }
}
