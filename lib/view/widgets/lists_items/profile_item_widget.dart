import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/themes.dart';

class ProfileItemWidget extends StatelessWidget {
  const ProfileItemWidget({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  final String title;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Get.textTheme.titleLarge?.copyWith(
            color: Get.isDarkMode ? Themes.primaryColorLightDark : null,
            fontWeight: FontWeight.normal),
      ),
      onTap: () => onTap(),
    );
  }
}
