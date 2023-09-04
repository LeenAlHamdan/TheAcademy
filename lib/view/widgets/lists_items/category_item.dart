import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/model/category.dart';
import 'package:the_academy/model/themes.dart';
import 'package:the_academy/utils/app_contanants.dart';

import '../custom_widgets/load_more_horizontal_widget.dart';

class CategoryItem extends StatelessWidget {
  final bool firstItem;
  final Category item;
  final Function onTap;

  const CategoryItem(this.item, this.firstItem, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
          color: Get.isDarkMode ? Get.theme.colorScheme.background : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          elevation: 8,
          shadowColor: Themes.primaryColor.withOpacity(0.2),
          child: Container(
            constraints: BoxConstraints(
              minHeight: Get.height * 0.18,
            ),
            width: Get.width * 0.3,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              vertical: Get.height * 0.026,
              horizontal: Get.width * 0.061,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: firstItem ? Themes.primaryColor : null,
            ),
            child: Column(
              children: [
                ClipOval(
                  child: SizedBox.fromSize(
                    size: Size(Get.height * 0.055, Get.height * 0.055),
                    child: CachedNetworkImage(
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
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                      placeholder: (context, url) => LoadMoreHorizontalWidget(),
                      fit: BoxFit.cover,
                      width: Get.width * 0.7,
                      height: Get.height * 0.14,

                      //     height: widget.height,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: Get.height * 0.013,
                  ),
                  child: SizedBox(
                    width: Get.width * 0.2,
                    child: Text(
                      Get.locale == const Locale('ar')
                          ? item.nameAr
                          : item.nameEn,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: firstItem
                            ? Themes.primaryColorLight
                            : Get.isDarkMode
                                ? Themes.primaryColorLightDark
                                : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
