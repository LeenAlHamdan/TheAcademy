// ignore_for_file: prefer_if_null_operators

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import '../../../model/themes.dart';
import '../../../utils/app_contanants.dart';
import 'load_more_horizontal_widget.dart';

class MultiImageInput extends StatefulWidget {
  final Function onSelectMultiImage;
  final int? limit;
  final List<Asset> images;
  final double? size;
  final String? imagePath;

  const MultiImageInput(
    this.onSelectMultiImage, {
    Key? key,
    required this.images,
    this.size,
    this.limit,
    this.imagePath,
  }) : super(key: key);

  @override
  _MultiImageInputState createState() => _MultiImageInputState();
}

class _MultiImageInputState extends State<MultiImageInput> {
  List<Asset> images = [];
  List<File> imagesFiles = [];

  @override
  void initState() {
    images = widget.images;

    super.initState();
  }

  Future<void> pickImages(BuildContext context) async {
    List<Asset> resultList = [];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: widget.limit ?? 50,
        enableCamera: true,
        selectedAssets: images,
        materialOptions: MaterialOptions(
          actionBarTitle: 'multi_image'.tr,
          actionBarColor: '#2184C7',
          statusBarColor: '#2184C7',
          useDetailsView: false,
        ),
      );
    } on Exception catch (_) {}
    if (resultList.isNotEmpty) {
      images = resultList;

      if (mounted) {
        setState(() {
          // ignore: unnecessary_statements
          images;
        });
        widget.onSelectMultiImage(images);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.size != null ? 0 : 8.0),
      width: widget.size ?? 150,
      height: widget.size != null ? widget.size : 150,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => pickImages(context),
        child: images.isNotEmpty
            ? GridView.count(
                crossAxisCount: images.length == 1
                    ? 1
                    : images.length < 5
                        ? 2
                        : 3,
                shrinkWrap: true,
                children: List.generate(images.length, (index) {
                  Asset asset = images[index];
                  return AssetThumb(
                    asset: asset,
                    width: 150,
                    height: 150,
                  );
                }),
              )
            : widget.imagePath != null
                ? CachedNetworkImage(
                    imageUrl: '${AppConstants.imagesHost}/${widget.imagePath}',
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
                    placeholder: (context, url) =>
                        const LoadMoreHorizontalWidget(
                      isDefault: true,
                    ),
                    fit: BoxFit.cover,

                    //     height: widget.height,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )
                : Container(
                    height: widget.size != null ? widget.size : 50,
                    decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? Get.theme.colorScheme.background
                          : Themes.buttonColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                        child: Text(
                      widget.limit != null && widget.limit == 0
                          ? 'plus_image'.tr
                          : 'plus_images'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Get.isDarkMode
                            ? Themes.primaryColorLightDark
                            : Themes.primaryColorDark,
                      ),
                    )),
                  ),
      ),
    );
  }
}
