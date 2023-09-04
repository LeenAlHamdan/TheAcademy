import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/view/widgets/custom_widgets/user_image.dart';

class UserListWidget extends StatelessWidget {
  final String name;
  final String image;
  final IconData? trailingImage;
  final Widget? trailingWidget;
  final Function? onTap;
  final Function? onLongTap;
  final bool? isOnline;

  UserListWidget({
    required this.name,
    required this.image,
    this.trailingImage,
    this.trailingWidget,
    this.onTap,
    this.onLongTap,
    this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!() : null,
      onLongPress: onLongTap != null ? () => onLongTap!() : null,
      child: Container(
          height: Get.height * 0.077,
          margin: EdgeInsets.only(top: Get.height * 0.018),
          decoration: BoxDecoration(
            color: Themes.primaryColorLight,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
                width: 1.0, color: Themes.primaryColorDark.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Themes.primaryColorDark.withOpacity(0.1),
                offset: Offset(0, 16),
                blurRadius: 20,
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              name,
              style:
                  Get.textTheme.titleMedium?.copyWith(color: Themes.textColor),
            ),
            leading: isOnline != null
                ? Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      UserImage(
                        image,
                        withHost: true,
                        size: Get.height * 0.05,
                      ),
                      Positioned(
                        bottom: -2,
                        right: Get.locale == const Locale('ar') ? -2 : null,
                        left: Get.locale == const Locale('ar') ? null : -2,
                        child: Icon(
                          Icons.circle,
                          size: 14,
                          color: isOnline!
                              ? Themes.greenColor
                              : Themes.primaryColorDark,
                        ),
                      )
                    ],
                  )
                : UserImage(
                    image,
                    withHost: true,
                    size: Get.height * 0.05,
                  ),
            trailing: trailingImage != null
                ? Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Themes.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      trailingImage,
                      color: Themes.primaryColorLight,
                    ),
                  )
                : trailingWidget ?? null,
          )),
    );
  }
}
