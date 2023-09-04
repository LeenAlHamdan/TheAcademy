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

import '../../chatview.dart';
import '../extensions/extensions.dart';

import '../utils/constants.dart';
import 'custom_message_view.dart';
import 'image_message_view.dart';
import 'text_message_view.dart';
import 'voice_message_view.dart';

class MessageView extends StatefulWidget {
  const MessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    required this.onLongPress,
    required this.incomingTextColor,
    required this.incomingbackgroundColor,
    this.outgoingChatBubbleConfig,
    this.highlightColor = Colors.grey,
    this.shouldHighlight = false,
    this.highlightScale = 1.2,
    this.messageConfig,
    this.onMaxDuration,
    this.ltr,
  }) : super(key: key);

  final Color? incomingbackgroundColor;

  final Color? incomingTextColor;

  final MessageCallBack? onLongPress;

  final bool? ltr;

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Allow users to pass colour of chat bubble when user taps on replied message.
  final Color highlightColor;

  /// Allow users to turn on/off highlighting chat bubble when user tap on replied message.
  final bool shouldHighlight;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  /// Allow user to giving customisation different types
  /// messages.
  final MessageConfiguration? messageConfig;

  /// Allow user to turn on/off long press tap on chat bubble.
  final Function(int)? onMaxDuration;

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView>
    with SingleTickerProviderStateMixin {
  MessageConfiguration? get messageConfig => widget.messageConfig;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: (() {
        return _messageView;
      }()),
    );
  }

  Widget get _messageView {
    final message = widget.message.content;
    return InkWell(
      onLongPress: widget.onLongPress != null
          ? () => widget.onLongPress!(widget.message)
          : null,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: /* widget.message.reaction.reactions.isNotEmpty ? 6 : */ 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.isMessageBySender
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            (() {
              if (message.isAllEmoji) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        leftPadding2,
                        4,
                        leftPadding2,
                        /* widget.message.reaction.reactions.isNotEmpty ? 14 : */ 0,
                      ),
                      child: Transform.scale(
                        scale: widget.shouldHighlight
                            ? widget.highlightScale
                            : 1.0,
                        child: Text(
                          message,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    /* if (widget.message.reaction.reactions.isNotEmpty)
                      ReactionWidget(
                        reaction: widget.message.reaction,
                        messageReactionConfig: messageConfig?.messageReactionConfig,
                        isMessageBySender: widget.isMessageBySender,
                      ), */
                  ],
                );
              } else if (widget.message.isImage) {
                return ImageMessageView(
                  message: widget.message,
                  isMessageBySender: widget.isMessageBySender,
                  imageMessageConfig: messageConfig?.imageMessageConfig,
                  highlightImage: widget.shouldHighlight,
                  highlightScale: widget.highlightScale,
                  outgoingChatBubbleConfig: widget.outgoingChatBubbleConfig,
                  incomingbackgroundColor: widget.incomingbackgroundColor,
                );
              } else if (widget.message.isVoice) {
                return VoiceMessageView(
                  screenWidth: MediaQuery.of(context).size.width,
                  message: widget.message,
                  onMaxDuration: widget.onMaxDuration,
                  isMessageBySender: widget.isMessageBySender,
                  outgoingChatBubbleConfig: widget.outgoingChatBubbleConfig,
                  incomingbackgroundColor: widget.incomingbackgroundColor,
                  ltr: widget.ltr ?? true,
                );
              } else if (widget.message.isCustom &&
                  messageConfig?.customMessageBuilder != null) {
                return CustomMessageView(
                  customMessage:
                      messageConfig!.customMessageBuilder!(widget.message),
                  isMessageBySender: widget.isMessageBySender,
                  outgoingChatBubbleConfig: widget.outgoingChatBubbleConfig,
                  incomingbackgroundColor: widget.incomingbackgroundColor,
                  ltr: widget.ltr ?? true,
                );
              } else {
                return TextMessageView(
                  outgoingChatBubbleConfig: widget.outgoingChatBubbleConfig,
                  isMessageBySender: widget.isMessageBySender,
                  message: widget.message,
                  highlightColor: widget.highlightColor,
                  highlightMessage: widget.shouldHighlight,
                  ltr: widget.ltr ?? true,
                  incomingTextColor: widget.incomingTextColor,
                  incomingbackgroundColor: widget.incomingbackgroundColor,
                );
              }
            }()),
            !widget.isMessageBySender
                ? const Padding(padding: EdgeInsets.only(bottom: 8.0))
                : Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, bottom: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          !widget.message.sended
                              ? Icons.radio_button_off
                              : widget.message.seenAt != null
                                  ? Icons.check_circle
                                  : Icons.check_circle_outlined,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          DateTime.parse(widget.message.createdAt)
                              .toLocal()
                              .getTimeFromDateTime,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
