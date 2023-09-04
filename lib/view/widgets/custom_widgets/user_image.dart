import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/utils/app_contanants.dart';

import 'load_more_horizontal_widget.dart';

class UserImage extends StatelessWidget {
  final String image;
  final double? size;
  final bool noSize;
  final bool withHost;
  final bool hasOnTap;
  final Color? color;
  final Function()? onTap;
  UserImage(
    this.image, {
    this.size,
    this.noSize = false,
    this.withHost = false,
    this.hasOnTap = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          (hasOnTap
              ? () {
                  {
                    Get.toNamed('/profile-screen');
                  }
                }
              : null),
      child: ClipOval(
        child: noSize
            ? widgetItem()
            : SizedBox.fromSize(
                size: Size(
                  size ?? (!withHost ? Get.height * 0.06 : Get.height * 0.07),
                  size ?? (!withHost ? Get.height * 0.06 : Get.height * 0.07),
                ),
                child: widgetItem(),
              ),
      ),
    );
  }

  Widget widgetItem() {
    return image != ''
        ? CachedNetworkImage(
            imageUrl: withHost ? '${AppConstants.imagesHost}/$image' : image,
            imageBuilder: (context, imageProvider) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            placeholder: (context, url) => const LoadMoreHorizontalWidget(
              isDefault: true,
            ),
            fit: BoxFit.cover,

            //     height: widget.height,
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        : Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color ?? Themes.primaryColor,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: SvgPicture.asset(
                'assets/images/user_image.svg',
                color: color ?? Themes.primaryColor,
              ),
            ),
          );
  }
}
