import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';

class TapWidget extends StatelessWidget {
  final String name;
  final String? image;
  final bool isSelected;
  final Function onTap;
  final IconData? iconData;
  final int tapsNum;

  TapWidget({
    required this.name,
    this.image,
    required this.isSelected,
    required this.onTap,
    required this.tapsNum,
    this.iconData,
  }) : assert(image != null || iconData != null);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(),
        child: Container(
          margin: EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Themes.primaryColor : null,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Themes.primaryColorDark.withOpacity(0.1),
                offset: Offset(0, 16),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              iconData != null
                  ? Icon(
                      iconData,
                      size: Get.textTheme.titleLarge?.fontSize,
                      color: isSelected
                          ? Themes.primaryColorLight
                          : Themes.primaryColorDark,
                    )
                  : SvgPicture.asset(
                      image!,
                      height: Get.textTheme.titleLarge?.fontSize,
                      color: isSelected
                          ? Themes.primaryColorLight
                          : Themes.primaryColorDark,
                    ),
              SizedBox(
                width: Get.width / (tapsNum * 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.titleLarge?.copyWith(
                      color: isSelected
                          ? Themes.primaryColorLight
                          : Themes.primaryColorDark,
                      fontWeight: FontWeight.w500,
                      height: 1.15,
                    ),
                    textHeightBehavior:
                        TextHeightBehavior(applyHeightToFirstAscent: false),
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
