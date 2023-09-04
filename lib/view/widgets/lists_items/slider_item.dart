import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../custom_widgets/load_more_horizontal_widget.dart';

class SliderItem extends StatefulWidget {
  final String image;

  const SliderItem(this.image, {Key? key}) : super(key: key);

  @override
  State<SliderItem> createState() => _SliderItemState();
}

class _SliderItemState extends State<SliderItem> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.image,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.fitWidth,
            ),
          ),
        );
      },
      placeholder: (context, url) => const LoadMoreHorizontalWidget(
        isDefault: true,
      ),
      fit: BoxFit.fitWidth,
      height: Get.height * 0.3,
      width: double.infinity,

      //     height: widget.height,
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
