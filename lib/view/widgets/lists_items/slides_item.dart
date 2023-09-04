import 'package:flutter/material.dart';

import '../../../model/themes.dart';
import '../custom_widgets/items_slider.dart';

class SlideItem extends StatelessWidget {
  final List<String> images;
  final String title;
  final TextStyle style;
  const SlideItem({
    Key? key,
    required this.title,
    required this.images,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ItemsSliderWidget(
          images: images,
        ),
        title != ''
            ? Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: Themes.primaryColorLight.withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                width: double.infinity,
                child: Text(
                  title,
                  style: style,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
