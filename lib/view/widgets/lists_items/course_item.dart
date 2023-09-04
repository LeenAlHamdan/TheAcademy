import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/course.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/utils/app_contanants.dart';

import '../custom_widgets/load_more_horizontal_widget.dart';

class CourseItem extends StatelessWidget {
  final Course item;
  final Function() onTap;
  final Function() onLongTap;
  final Function changeActive;
  final bool isLoading;
  final bool fitWidth;

  const CourseItem({
    required this.item,
    required this.onTap,
    required this.onLongTap,
    required this.changeActive,
    required this.isLoading,
    this.fitWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongTap,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 2,
          shadowColor: Get.isDarkMode
              ? Themes.primaryColorLight
              : Themes.primaryColorDark.withOpacity(0.2),
          child: Container(
            constraints: BoxConstraints(
              minHeight: Get.height * 0.28,
            ),
            width: fitWidth ? Get.width : Get.width * 0.7,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Get.isDarkMode
                    ? Themes.primaryColorDark
                    : Themes.primaryColorLight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: '${AppConstants.imagesHost}/${item.image}',
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    );
                  },
                  placeholder: (context, url) =>
                      const LoadMoreHorizontalWidget(),
                  fit: BoxFit.fitWidth,
                  width: fitWidth ? Get.width : Get.width * 0.7,
                  height: Get.height * 0.14,

                  //     height: widget.height,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: Get.height * 0.013,
                      left: Get.width * 0.04,
                      right: Get.width * 0.04),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (fitWidth ? Get.width : Get.width * 0.7) / 1.5,
                          child: Text(
                            Get.locale == const Locale('ar')
                                ? item.nameAr
                                : item.nameEn,
                            // maxLines: 2,
                            style: Get.textTheme.titleLarge?.copyWith(
                              color: Get.isDarkMode
                                  ? Themes.textColorDark
                                  : Themes.textColor,
                            ),
                          ),
                        ),
                        isLoading
                            ? LoadMoreHorizontalWidget(withPadding: false)
                            : IconButton(
                                onPressed: () => changeActive(),
                                icon: Icon(
                                  item.active
                                      ? Icons.offline_pin_rounded
                                      : Icons.pending_outlined,
                                  color: item.active
                                      ? Themes.offerColor
                                      : Get.isDarkMode
                                          ? Themes.primaryColorLight
                                          : Themes.primaryColorDark,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: Get.height * 0.013,
                      left: Get.width * 0.04,
                      right: Get.width * 0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.subject,
                        size: 20,
                        color: Get.isDarkMode
                            ? Themes.primaryColorLightDark
                            : Themes.primaryColorDark,
                      ),
                      Text(
                        Get.locale == const Locale('ar')
                            ? item.subjectNameAr
                            : item.subjectNameEn,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Get.isDarkMode
                              ? Themes.primaryColorLightDark
                              : Themes.primaryColorDark,
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.04,
                      ),
                      Icon(
                        Icons.person,
                        size: 20,
                        color: Get.isDarkMode
                            ? Themes.primaryColorLightDark
                            : Themes.primaryColorDark,
                      ),
                      Text(
                        item.coachName,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Get.isDarkMode
                              ? Themes.primaryColorLightDark
                              : Themes.primaryColorDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
