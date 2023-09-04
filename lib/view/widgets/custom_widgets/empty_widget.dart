import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/themes.dart';

class EmptyWidget extends StatelessWidget {
  final String? title;
  const EmptyWidget({this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title ?? 'no_items_to_show'.tr,
          textAlign: TextAlign.center,
          style: Get.textTheme.titleLarge?.copyWith(
              color: Themes.primaryColor, fontWeight: FontWeight.normal)),
    );
  }
}
