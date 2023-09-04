import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/utils/app_contanants.dart';

import 'load_more_horizontal_widget.dart';

class CircleCachedImage extends StatelessWidget {
  const CircleCachedImage({
    Key? key,
    required this.image,
    this.radius,
  }) : super(key: key);

  final String? image;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: image != null ? null : Get.theme.colorScheme.secondary,
      child: image != null
          ? CachedNetworkImage(
              imageUrl: '${AppConstants.imagesHost}/$image',
              imageBuilder: (context, imageProvider) {
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: imageProvider,
                );
              },
              placeholder: (context, url) =>
                  const LoadMoreHorizontalWidget(image: true),
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
          : SvgPicture.asset(
              'assets/images/user_profile.svg',
              color: Themes.primaryColor,
            ),
    );
  }
}
