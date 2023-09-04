import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/view/widgets/custom_widgets/user_image.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    Key? key,
    this.onMenuTap,
    this.onImageTap,
    this.isOpend,
    required this.title,
    required this.isUserImage,
    this.hasOnTap = false,
    this.image,
    this.leading,
    this.trailing,
  })  : assert((onMenuTap != null && isOpend != null) || leading != null),
        super(key: key);

  final Function? onMenuTap;
  final Function? onImageTap;
  final bool? isOpend;
  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final String? image;
  final bool hasOnTap;
  final bool isUserImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Get.height * 0.043 * 2,
        bottom: 2,
        left: Get.width * 0.07,
        right: Get.width * 0.07,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leading != null
              ? leading!
              : GestureDetector(
                  onTap: () => onMenuTap!(),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    height: Get.height * 0.047,
                    width: Get.height * 0.047,
                    decoration: BoxDecoration(
                        color: Themes.primaryColorLight,
                        border: Border.all(
                          color: Get.isDarkMode
                              ? Themes.primaryColorLight
                              : Themes.primaryColorDark.withAlpha(50),
                        ),
                        shape: BoxShape.circle),
                    child: ClipOval(
                      child: SizedBox.fromSize(
                        size: Size(Get.height * 0.022, Get.height * 0.022),
                        child: isOpend!
                            ? Icon(
                                Icons.close,
                                size: Get.height * 0.022,
                                color: Themes.textColor,
                              )
                            : SvgPicture.asset(
                                'assets/images/drawer_icon.svg',
                              ),
                      ),
                    ),
                  ),
                ),
          SizedBox(
              width: (Get.width /
                  (leading != null && (trailing != null || image != null)
                      ? 2.5
                      : 2)),
              child: title),
          isUserImage
              ? GetBuilder<UserController>(
                  builder: (userController) => GestureDetector(
                      onTap: onImageTap != null ? () => onImageTap!() : () {},
                      child: UserImage(
                        userController.currentUser
                            .profileImageUrl, //size: Get.height * 0.047
                        withHost: true,
                        hasOnTap: hasOnTap,
                      )))
              : image != null
                  ? GestureDetector(
                      onTap: onImageTap != null ? () => onImageTap!() : () {},
                      child: UserImage(
                        image!, //size: Get.height * 0.047
                        withHost: true,
                        hasOnTap: hasOnTap,
                      ))
                  : trailing ?? SizedBox(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(AppBar().preferredSize.height + Get.height * 0.043);
}
