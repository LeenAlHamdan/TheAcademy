import '../../chatview.dart';
import 'package:flutter/material.dart';

import '../utils/chat_bubble_clipper.dart';

class CustomMessageView extends StatelessWidget {
  const CustomMessageView(
      {Key? key,
      required this.customMessage,
      required this.isMessageBySender,
      this.outgoingChatBubbleConfig,
      required this.incomingbackgroundColor,
      this.ltr = true})
      : super(key: key);

  final Color? incomingbackgroundColor;

  final bool ltr;

  /// Provides message instance of chat.
  final Widget customMessage;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;

    return Container(
      constraints: BoxConstraints(maxWidth: w * 0.75),
      alignment: ltr
          ? isMessageBySender
              ? Alignment.topRight
              : Alignment.topLeft
          : isMessageBySender
              ? Alignment.topLeft
              : Alignment.topRight,
      child: PhysicalShape(
        clipper: ChatBubbleClipper3(
          type: ltr
              ? isMessageBySender
                  ? BubbleType.sendBubble
                  : BubbleType.receiverBubble
              : isMessageBySender
                  ? BubbleType.receiverBubble
                  : BubbleType.sendBubble,
        ),
        elevation: 2,
        color: _color,
        shadowColor: /*  _color ?? */ Colors.grey.shade200,
        child: Padding(
          padding: /* _padding ?? */ setPadding(),
          child: customMessage,
        ),
      ),
    );
  }

  Color get _color => isMessageBySender
      ? outgoingChatBubbleConfig?.color ?? Colors.purple
      : incomingbackgroundColor ?? Colors.white;

  EdgeInsets setPadding() {
    if (isMessageBySender) {
      return EdgeInsets.only(right: ltr ? 20 : 0, left: ltr ? 0 : 20);
    } else {
      return EdgeInsets.only(left: ltr ? 20 : 0, right: ltr ? 0 : 20);
    }
  }
}
