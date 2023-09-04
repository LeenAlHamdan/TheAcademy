import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../controller/screens_controllers/feed_page_controller.dart';
import '../../../model/themes.dart';
import '../custom_widgets/my_edit_text.dart';
import 'error_dialog.dart';

Future<LatLng?> locationPickerDialog(
  FeedPageController controller,
  TextEditingController _titleController,
) async {
  int pageNum = 0;
  return await Get.dialog(StatefulBuilder(
    builder: (context, setState) => AlertDialog(
      title: Text(
          pageNum == 0 ? 'first_add_a_title'.tr : 'choose_a_location'.tr,
          style: TextStyle(
              color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          pageNum == 0
              ? MyEditText(
                  title: 'title'.tr,
                  prefixIcon: Icons.title_rounded,
                  textController: _titleController,
                )
              : SizedBox(
                  width: Get.width * 0.7,
                  height: Get.height * 0.3,
                  child: FlutterMap(
                      options: MapOptions(
                        center: controller.selectedLocation.value,
                        keepAlive: true,
                        zoom: 18,
                        interactiveFlags:
                            InteractiveFlag.all & ~InteractiveFlag.rotate,
                        onTap: (_, latlang) =>
                            controller.handleTap(latlang, setState),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: ['a', 'b', 'c'],
                          userAgentPackageName:
                              'dev.fleaflet.flutter_map.example',
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            width: 20,
                            height: 20,
                            point: controller.selectedLocation.value,
                            builder: (ctx) => Icon(
                              Icons.pin_drop,
                              color: Themes.textColor,
                            ),
                          )
                        ])
                      ]),
                ),
        ],
      ),
      actions: [
        TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Get.theme.colorScheme.secondary,
                      width: 2,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(
              "previous".tr,
              style: TextStyle(
                  color: Get.isDarkMode ? Themes.textColorDark : null),
            ),
            onPressed: () {
              if (pageNum == 1) {
                setState(() {
                  pageNum--;
                });

                return;
              }
            }),
        TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Get.theme.colorScheme.secondary,
                      width: 2,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(
              "cancel".tr,
              style: TextStyle(
                  color: Get.isDarkMode ? Themes.textColorDark : null),
            ),
            onPressed: () {
              Get.back(result: null);
            }),
        TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: Get.theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(
              pageNum == 0 ? 'next'.tr : 'select'.tr,
              style: TextStyle(color: Themes.primaryColorLight),
            ),
            onPressed: () {
              if (pageNum == 0) {
                setState(() {
                  pageNum++;
                });

                return;
              }
              if (_titleController.text.isEmpty) {
                var errorMessage = 'fill_all_info'.tr;
                showErrorDialog(
                  errorMessage,
                );
                return;
              }
              Get.back(result: controller.selectedLocation.value);
            })
      ],
    ),
  ));

  /* Get.defaultDialog(
    title: pageNum == 0 ? 'first_add_a_title'.tr : 'choose_a_location'.tr,
    content: StatefulBuilder(
      builder: (context, setState) {
        setState1 = setState;
        return Column(
          children: [
            pageNum == 0
                ? MyEditText(
                    title: 'title'.tr,
                    prefixIcon: Icon(
                      Icons.title_rounded,
                    ),
                    textController: _titleController,
                  )
                : SizedBox(
                    width: Get.width * 0.7,
                    height: Get.height * 0.3,
                    child: FlutterMap(
                        options: MapOptions(
                          center: controller.selectedLocation.value,
                          keepAlive: true,
                          zoom: 18,
                          interactiveFlags:
                              InteractiveFlag.all & ~InteractiveFlag.rotate,
                          onTap: (_, latlang) =>
                              controller.handleTap(latlang, setState),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: ['a', 'b', 'c'],
                            userAgentPackageName:
                                'dev.fleaflet.flutter_map.example',
                          ),
                          MarkerLayer(markers: [
                            Marker(
                              width: 20,
                              height: 20,
                              point: controller.selectedLocation.value,
                              builder: (ctx) => const Icon(Icons.pin_drop),
                            )
                          ])
                        ]),
                  ),
          ],
        );
      },
    ),
    textConfirm: pageNum == 0 ? 'next'.tr : 'select'.tr,
    textCancel: 'cancel'.tr,
    confirmTextColor: Themes.primaryColorLight,
    actions: [
      TextButton(
          style: TextButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Get.theme.colorScheme.secondary,
                    width: 2,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(100)),
          ),
          child: Text(
            "previous".tr,
            style: TextStyle(color: Get.theme.colorScheme.background),
          ),
          onPressed: () {
            if (pageNum == 1) {
              setState1(() {
                pageNum++;
              });

              return;
            }
          })
    ],
    onConfirm: () {
      if (pageNum == 0) {
        setState1(() {
          pageNum++;
        });

        return;
      }
      if (_titleController.text.isEmpty) {
        var errorMessage = 'fill_all_info'.tr;
        showErrorDialog(
          errorMessage,
        );
        return;
      }
      Get.back(result: controller.selectedLocation.value);
    },
    onCancel: () {
      return null;
    },
  ) */
}
