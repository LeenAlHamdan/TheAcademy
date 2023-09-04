import 'package:get/get.dart';

import '../../../model/themes.dart';
import '../lists_items/slider_item.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ItemsSliderWidget extends StatefulWidget {
  const ItemsSliderWidget({
    Key? key,
    required this.images,
  }) : super(key: key);

  final List<String> images;

  @override
  State<ItemsSliderWidget> createState() => _ItemsSliderWidgetState();
}

class _ItemsSliderWidgetState extends State<ItemsSliderWidget> {
  int _current1 = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CarouselSlider(
            options: CarouselOptions(
                autoPlay: true,
                viewportFraction: 1,
                height: Get.height * 0.3,
                onPageChanged: (index, _) {
                  if (mounted) {
                    setState(() {
                      _current1 = index;
                    });
                  }
                }),
            items: widget.images.map((item) => SliderItem(item)).toList(),
          ),
          Positioned(
            bottom: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.images
                  .asMap()
                  .map((i, item) => MapEntry(
                      i,
                      Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _current1
                                ? Themes.offerColor
                                : Colors.grey),
                      )))
                  .values
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
