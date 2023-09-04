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
import '../extensions/extensions.dart';

import '../../chatview.dart';
import 'message_view.dart';
import 'reply_message_widget.dart';
import 'swipe_to_reply.dart';

class ChatBubbleWidget extends StatefulWidget {
  const ChatBubbleWidget({
    // required GlobalKey key,
    //required ValueKey key,
    Key? key,
    required this.message,
    required this.onSwipe,
    this.chatBubbleConfig,
    this.repliedMessageConfig,
    this.swipeToReplyConfig,
    this.messageTimeTextStyle,
    this.messageTimeIconColor,
    this.messageConfig,
    this.onReplyTap,
    this.shouldHighlight = false,
    this.ltr = true,
    required this.imageWidget,
    required this.onLongPress,
    required this.incomingTextColor,
    required this.incomingbackgroundColor,
  }) : super(key: key);

  final Color? incomingbackgroundColor;

  final Color? incomingTextColor;

  final MessageCallBack? onLongPress;

  final Function imageWidget;

  final bool ltr;

  /// Represent current instance of message.
  final Message message;

  /// Provides configurations related to chat bubble such as padding, margin, max
  /// width etc.
  final ChatBubbleConfiguration? chatBubbleConfig;

  /// Provides configurations related to replied message such as textstyle
  /// padding, margin etc. Also, this widget is located upon chat bubble.
  final RepliedMessageConfiguration? repliedMessageConfig;

  /// Provides configurations related to swipe chat bubble which triggers
  /// when user swipe chat bubble.
  final SwipeToReplyConfiguration? swipeToReplyConfig;

  /// Provides textStyle of message created time when user swipe whole chat.
  final TextStyle? messageTimeTextStyle;

  /// Provides default icon color of message created time view when user swipe
  /// whole chat.
  final Color? messageTimeIconColor;

  /// Provides slide animation when user swipe whole chat.

  /// Provides configuration of all types of messages.
  final MessageConfiguration? messageConfig;

  /// Provides callback of when user swipe chat bubble for reply.
  final MessageCallBack onSwipe;

  /// Provides callback when user tap on replied message upon chat bubble.
  final Function(String)? onReplyTap;

  /// Flag for when user tap on replied message and highlight actual message.
  final bool shouldHighlight;

  @override
  State<ChatBubbleWidget> createState() => _ChatBubbleWidgetState();
}

class _ChatBubbleWidgetState extends State<ChatBubbleWidget> {
  String get replyMessage => widget.message.replyMessage.content;

  bool get isMessageBySender => widget.message.senderId == currentUser?.id;

  FeatureActiveConfig? featureActiveConfig;
  ChatController? chatController;
  ChatUser? currentUser;
  int? maxDuration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      featureActiveConfig = provide!.featureActiveConfig;
      chatController = provide!.chatController;
      currentUser = provide!.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user from id.
    final messagedUser = chatController?.getUserFromId(widget.message.senderId);
    return Stack(
      children: [
        _chatBubbleWidget(messagedUser),
      ],
    );
  }

  Widget _chatBubbleWidget(ChatUser? messagedUser) {
    return Container(
      padding: const EdgeInsets.only(left: 5.0),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            isMessageBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMessageBySender &&
              (featureActiveConfig?.enableOtherUserProfileAvatar ?? true))
            widget.imageWidget(
              messagedUser?.profilePhoto,
            ),
          //ProfileCircle(
          //  bottomPadding: 2,
          //  imageUrl: messagedUser?.profilePhoto,
          //),
          Expanded(
            child: isMessageBySender
                ? SwipeToReply(
                    onLeftSwipe: featureActiveConfig?.enableSwipeToReply ?? true
                        ? widget.ltr
                            ? () {
                                if (maxDuration != null) {
                                  widget.message.voiceMessageDuration =
                                      Duration(milliseconds: maxDuration!);
                                }
                                if (widget.swipeToReplyConfig?.onLeftSwipe !=
                                    null) {
                                  widget.swipeToReplyConfig?.onLeftSwipe!(
                                      widget.message.content,
                                      widget.message.senderId);
                                }
                                widget.onSwipe(widget.message);
                              }
                            : null
                        : null,
                    onRightSwipe: featureActiveConfig?.enableSwipeToReply ??
                            true
                        ? !widget.ltr
                            ? () {
                                if (maxDuration != null) {
                                  widget.message.voiceMessageDuration =
                                      Duration(milliseconds: maxDuration!);
                                }
                                if (widget.swipeToReplyConfig?.onLeftSwipe !=
                                    null) {
                                  widget.swipeToReplyConfig?.onLeftSwipe!(
                                      widget.message.content,
                                      widget.message.senderId);
                                }
                                widget.onSwipe(widget.message);
                              }
                            : null
                        : null,
                    replyIconColor: widget.swipeToReplyConfig?.replyIconColor,
                    swipeToReplyAnimationDuration:
                        widget.swipeToReplyConfig?.animationDuration,
                    child: _messagesWidgetColumn(messagedUser),
                  )
                : SwipeToReply(
                    onRightSwipe: featureActiveConfig?.enableSwipeToReply ??
                            true
                        ? widget.ltr
                            ? () {
                                if (maxDuration != null) {
                                  widget.message.voiceMessageDuration =
                                      Duration(milliseconds: maxDuration!);
                                }
                                if (widget.swipeToReplyConfig?.onRightSwipe !=
                                    null) {
                                  widget.swipeToReplyConfig?.onRightSwipe!(
                                      widget.message.content,
                                      widget.message.senderId);
                                }
                                widget.onSwipe(widget.message);
                              }
                            : null
                        : null,
                    onLeftSwipe: featureActiveConfig?.enableSwipeToReply ?? true
                        ? !widget.ltr
                            ? () {
                                if (maxDuration != null) {
                                  widget.message.voiceMessageDuration =
                                      Duration(milliseconds: maxDuration!);
                                }
                                if (widget.swipeToReplyConfig?.onRightSwipe !=
                                    null) {
                                  widget.swipeToReplyConfig?.onRightSwipe!(
                                      widget.message.content,
                                      widget.message.senderId);
                                }
                                widget.onSwipe(widget.message);
                              }
                            : null
                        : null,
                    replyIconColor: widget.swipeToReplyConfig?.replyIconColor,
                    swipeToReplyAnimationDuration:
                        widget.swipeToReplyConfig?.animationDuration,
                    child: _messagesWidgetColumn(messagedUser),
                  ),
          ),
          if (isMessageBySender &&
              (featureActiveConfig?.enableCurrentUserProfileAvatar ?? true))
            widget.imageWidget(currentUser?.profilePhoto)
          /*  ProfileCircle(
              bottomPadding: 2,
              imageUrl: currentUser?.profilePhoto,
            ), */
        ],
      ),
    );
  }

  Widget _messagesWidgetColumn(ChatUser? messagedUser) {
    return Column(
      crossAxisAlignment:
          isMessageBySender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if ((chatController?.chatUsers.length ?? 0) >= 1 &&
            !isMessageBySender &&
            replyMessage.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              messagedUser?.name ?? '',
            ),
          ),
        if (replyMessage.isNotEmpty)
          widget.repliedMessageConfig?.repliedMessageWidgetBuilder != null
              ? widget.repliedMessageConfig!
                  .repliedMessageWidgetBuilder!(widget.message.replyMessage)
              : ReplyMessageWidget(
                  message: widget.message,
                  repliedMessageConfig: widget.repliedMessageConfig,
                  onTap: () => widget.onReplyTap
                      ?.call(widget.message.replyMessage.messageId),
                ),
        MessageView(
          onLongPress: widget.onLongPress,
          outgoingChatBubbleConfig:
              widget.chatBubbleConfig?.outgoingChatBubbleConfig,
          message: widget.message,
          incomingTextColor: widget.incomingTextColor,
          isMessageBySender: isMessageBySender,
          messageConfig: widget.messageConfig,
          shouldHighlight: widget.shouldHighlight,
          highlightColor: widget.repliedMessageConfig
                  ?.repliedMsgAutoScrollConfig.highlightColor ??
              Colors.grey,
          highlightScale: widget.repliedMessageConfig
                  ?.repliedMsgAutoScrollConfig.highlightScale ??
              1.1,
          onMaxDuration: _onMaxDuration,
          ltr: widget.ltr,
          incomingbackgroundColor: widget.incomingbackgroundColor,
        ),
      ],
    );
  }

  void _onMaxDuration(int duration) => maxDuration = duration;
}
