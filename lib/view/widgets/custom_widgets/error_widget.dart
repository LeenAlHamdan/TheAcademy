import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/themes.dart';

import 'load_refresh_widget.dart';

class MyErrorWidget extends StatelessWidget {
  const MyErrorWidget({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: Get.height, minWidth: Get.width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'check_connection'.tr,
            textAlign: TextAlign.center,
            style: Get.textTheme.headlineMedium?.copyWith(
              color: Themes.primaryColor,
            ),
          ),
          IconButton(onPressed: () => onPressed(), icon: LoadRefreshWidget()),
        ],
      ),
    );
  }
}
