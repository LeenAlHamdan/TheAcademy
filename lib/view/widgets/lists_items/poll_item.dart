import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/utils/get_double_number.dart';

import '../../../controller/screens_controllers/feed_page_controller.dart';
import '../../../model/message.dart';
import '../../../model/themes.dart';

class PollItem extends StatelessWidget {
  const PollItem({
    Key? key,
    required this.title,
    required this.options,
    required this.groupValue,
    required this.onChanged,
    required this.totalVotes,
    required this.isTheCoach,
    required this.userHasVoted,
  }) : super(key: key);

  final String title;
  final String? groupValue;
  final List<PollOptions> options;
  final Function? onChanged;
  final int totalVotes;
  final bool isTheCoach;
  final bool userHasVoted;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Themes.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
            child: ListTileTheme.merge(
              child: ListTile(
                title: Text(
                  title,
                  style: Get.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          ClipRect(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: options
                    .map((choice) => ListTile(
                          title: Text(
                            choice.text,
                          ),
                          trailing: userHasVoted || isTheCoach
                              ? Text(
                                  '${getDoubleNumber(getNumber(choice.chosenBy.length))}% ',
                                  style: Get.theme.textTheme.titleMedium
                                      ?.copyWith(
                                          color: Themes.primaryColor,
                                          fontWeight: FontWeight.bold),
                                )
                              : SizedBox(),
                          leading: GetBuilder<FeedPageController>(
                            builder: (_) => Radio(
                              value: choice.id,
                              groupValue: groupValue,
                              onChanged:
                                  //!choice.isChosedByUser &&
                                  onChanged != null
                                      ? (value) => onChanged!(value)
                                      : null,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getNumber(int count) {
    return (count / totalVotes) * 100;
  }
}
