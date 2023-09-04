import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../model/themes.dart';
import '../custom_widgets/my_edit_text.dart';
import 'error_dialog.dart';

Future<void> addPollDialog(Function _sendPoll) async {
  final _pollTextController = TextEditingController();
  List<TextEditingController> _optionsTextControllers = [
    TextEditingController(),
  ];

  return Get.defaultDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyEditText(
          title: 'title'.tr,
          prefixIcon: Icons.title_rounded,
          textController: _pollTextController,
        ),
        StatefulBuilder(builder: (context, setState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: Get.height * 0.5,
            ),
            width: Get.width * 0.9,
            child: ListView.builder(
              itemBuilder: (context, index) => ListTile(
                title: MyEditText(
                  title: 'option'.tr,
                  prefixIcon: Icons.title_rounded,
                  textController: _optionsTextControllers[index],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_optionsTextControllers.firstWhereOrNull(
                          (element) => element.text.isEmpty,
                        ) !=
                        null) return;
                    _optionsTextControllers.add(TextEditingController());
                    setState(() {});
                  },
                ),
              ),
              shrinkWrap: true,
              itemCount: _optionsTextControllers.length,
            ),
          );
        }),
      ],
    ),
    barrierDismissible: false,
    title: 'add_poll'.tr,
    textConfirm: 'send'.tr,
    titleStyle: TextStyle(
        color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
    confirmTextColor: Themes.primaryColorLight,
    cancelTextColor: Get.isDarkMode ? Themes.textColorDark : null,
    onConfirm: () {
      if (_pollTextController.text.isEmpty ||
          _optionsTextControllers.firstWhereOrNull(
                (element) => element.text.isNotEmpty,
              ) ==
              null) {
        var errorMessage = 'fill_all_info'.tr;
        showErrorDialog(
          errorMessage,
        );
        return;
      }
      _sendPoll(_pollTextController.text, _optionsTextControllers);
      Get.back();

      //changePass(userController);
    },
    textCancel: 'cancel'.tr,
  );
}
