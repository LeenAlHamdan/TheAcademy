/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'package:flutter/material.dart';

import '../models/models.dart';

import '../utils/chat_bubble_clipper.dart';
import 'link_preview.dart';

class TextMessageView extends StatelessWidget {
  const TextMessageView({
    Key? key,
    required this.isMessageBySender,
    required this.message,
    this.outgoingChatBubbleConfig,
    this.highlightMessage = false,
    this.highlightColor,
    this.ltr = true,
    required this.incomingTextColor,
    required this.incomingbackgroundColor,
  }) : super(key: key);

  final Color? incomingbackgroundColor;

  final bool ltr;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides message instance of chat.
  final Message message;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Represents message should highlight.
  final bool highlightMessage;

  /// Allow user to set color of highlighted message.
  final Color? highlightColor;

  final Color? incomingTextColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final String textMessage = message.content;
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
          child: Uri.parse(textMessage).isAbsolute
              ? LinkPreview(
                  url: textMessage,
                )
              : Text(
                  textMessage,
                  style: textTheme.bodyMedium!.copyWith(
                    color: isMessageBySender ? Colors.white : incomingTextColor,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
    /* return Container(
      constraints: BoxConstraints(maxWidth: chatBubbleMaxWidth ?? w * 0.75),
      padding: _padding ??
          EdgeInsets.symmetric(
            horizontal: 0.04 * w,
            vertical: 0.025 * w,
          ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0.06 * w),
          bottomLeft: isMessageBySender
              ? Radius.circular(0.06 * w)
              : Radius.circular(0.02 * w),
          bottomRight: !isMessageBySender
              ? Radius.circular(0.06 * w)
              : Radius.circular(0.012 * w),
          topRight: Radius.circular(0.06 * w),
        ),
        color: _color,
        boxShadow: isMessageBySender
            ? S.pinkShadow(shadow: _color.withOpacity(.1))
            : [S.boxShadow(context, opacity: .05)],
      ),
      /* constraints: BoxConstraints(
          maxWidth:
              chatBubbleMaxWidth ?? MediaQuery.of(context).size.width * 0.75),
      padding: _padding ??
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
      margin: _margin ??
          const EdgeInsets.fromLTRB(
              5,
              0,
              6,
              //message.reaction.reactions.isNotEmpty ? 15 :
              2),
      decoration: BoxDecoration(
        color: highlightMessage ? highlightColor : _color,
        borderRadius: _borderRadius(textMessage),
      ), */
      child: Uri.parse(textMessage).isAbsolute
          ? LinkPreview(
              linkPreviewConfig: _linkPreviewConfig,
              url: textMessage,
            )
          : Text(
              textMessage,
              style: _textStyle ??
                  textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
            ),
    ); */
  }

  EdgeInsets setPadding() {
    if (isMessageBySender) {
      return EdgeInsets.only(
          top: 10, bottom: 10, left: ltr ? 10 : 20, right: ltr ? 20 : 10);
    } else {
      return EdgeInsets.only(
          top: 10, bottom: 10, left: ltr ? 20 : 10, right: ltr ? 10 : 20);
    }
  }

  Color get _color => isMessageBySender
      ? outgoingChatBubbleConfig?.color ?? Colors.purple
      : incomingbackgroundColor ?? Colors.white;
  //Colors.grey.shade500;
}
