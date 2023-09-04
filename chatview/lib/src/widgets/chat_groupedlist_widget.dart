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
import '../../chatview.dart';
import '../extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import 'chat_bubble_widget.dart';
import 'chat_group_header.dart';

class ChatGroupedListWidget extends StatefulWidget {
  const ChatGroupedListWidget({
    Key? key,
    required this.showPopUp,
    required this.scrollController,
    required this.chatBackgroundConfig,
    required this.replyMessage,
    required this.assignReplyMessage,
    required this.onChatListTap,
    this.messageConfig,
    this.chatBubbleConfig,
    this.swipeToReplyConfig,
    this.repliedMessageConfig,
    this.ltr,
    required this.imageWidget,
    required this.onLongPress,
    required this.emptyWidget,
    required this.incomingTextColor,
    required this.incomingbackgroundColor,
  }) : super(key: key);

  final Color? incomingbackgroundColor;

  final Color? incomingTextColor;

  final Widget emptyWidget;

  final MessageCallBack? onLongPress;

  final Function imageWidget;

  final bool? ltr;

  /// Allow user to swipe to see time while reaction pop is not open.
  final bool showPopUp;

  final ScrollController scrollController;

  /// Allow user to give customisation to background of chat
  final ChatBackgroundConfiguration chatBackgroundConfig;

  /// Allow user to giving customisation different types
  /// messages
  final MessageConfiguration? messageConfig;

  /// Allow user to giving customisation to chat bubble
  final ChatBubbleConfiguration? chatBubbleConfig;

  /// Allow user to giving customisation to profile circle

  /// Allow user to giving customisation to swipe to reply
  final SwipeToReplyConfiguration? swipeToReplyConfig;
  final RepliedMessageConfiguration? repliedMessageConfig;

  /// Provides reply message if actual message is sent by replying any message.
  final ReplyMessage replyMessage;

  /// Provides callback for assigning reply message when user swipe on chat bubble.
  final MessageCallBack assignReplyMessage;

  /// Provides callback when user tap anywhere on whole chat.
  final VoidCallBack onChatListTap;

  @override
  State<ChatGroupedListWidget> createState() => _ChatGroupedListWidgetState();
}

class _ChatGroupedListWidgetState extends State<ChatGroupedListWidget>
    with TickerProviderStateMixin {
  ChatBackgroundConfiguration get chatBackgroundConfig =>
      widget.chatBackgroundConfig;

  bool get showPopUp => widget.showPopUp;

  bool highlightMessage = false;
  String? _replyId;

  ChatBubbleConfiguration? get chatBubbleConfig => widget.chatBubbleConfig;

  FeatureActiveConfig? featureActiveConfig;

  ChatController? chatController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      featureActiveConfig = provide!.featureActiveConfig;
      chatController = provide!.chatController;
    }
  }

  @override
  Widget build(BuildContext context) {
    return chatController!.initialMessageList.isEmpty
        ? Center(child: widget.emptyWidget)
        : SingleChildScrollView(
            reverse: true,
            // When reaction popup is being appeared at that user should not scroll.
            physics: showPopUp ? const NeverScrollableScrollPhysics() : null,
            padding: const EdgeInsets.only(bottom: 0),
            controller: widget.scrollController,
            child: Column(
              children: [
                GestureDetector(
                  onTap: widget.onChatListTap,
                  child: _chatStreamBuilder,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width *
                      (widget.replyMessage.content.isNotEmpty ? 0.3 : 0.14),
                ),
              ],
            ),
          );
  }

  /*//todo Future<void> _onReplyTap(String id, List<Message>? messages) async {
    // Finds the replied message if exists
    final repliedMessages = messages?.firstWhere((message) => id == message.id);

    // Scrolls to replied message and highlights
    if (repliedMessages != null && repliedMessages.key.currentState != null) {
      await Scrollable.ensureVisible(
        repliedMessages.key.currentState!.context,
        // This value will make widget to be in center when auto scrolled.
        alignment: 0.5,
        curve: widget.repliedMessageConfig?.repliedMsgAutoScrollConfig
                .highlightScrollCurve ??
            Curves.easeIn,
        duration: widget.repliedMessageConfig?.repliedMsgAutoScrollConfig
                .highlightDuration ??
            const Duration(milliseconds: 300),
      );
      if (widget.repliedMessageConfig?.repliedMsgAutoScrollConfig
              .enableHighlightRepliedMsg ??
          false) {
        _replyId = id;
        if (mounted) setState(() {});

        Future.delayed(
          widget.repliedMessageConfig?.repliedMsgAutoScrollConfig
                  .highlightDuration ??
              const Duration(milliseconds: 300),
          () {
            _replyId = null;
            if (mounted) setState(() {});
          },
        );
      }
    }
  } */

  Widget get _chatStreamBuilder {
    return GroupedListView<Message, String>(
      shrinkWrap: true,
      elements: chatController!.initialMessageList,
      reverse: true,
      groupBy: (element) =>
          DateTime.parse(element.createdAt).getDateFromDateTime,
      itemComparator: (message1, message2) =>
          message1.content.compareTo(message2.content),
      physics: const NeverScrollableScrollPhysics(),
      order: chatBackgroundConfig.groupedListOrder,
      sort: chatBackgroundConfig.sortEnable,
      groupSeparatorBuilder: (separator) =>
          featureActiveConfig?.enableChatSeparator ?? false
              ? _GroupSeparatorBuilder(
                  separator: separator,
                  defaultGroupSeparatorConfig:
                      chatBackgroundConfig.defaultGroupSeparatorConfig,
                  groupSeparatorBuilder:
                      chatBackgroundConfig.groupSeparatorBuilder,
                )
              : const SizedBox.shrink(),
      indexedItemBuilder: (context, message, index) {
        return ChatBubbleWidget(
          //todokey: message.key,
          key: ValueKey(index),
          incomingTextColor: widget.incomingTextColor,
          incomingbackgroundColor: widget.incomingbackgroundColor,

          messageTimeTextStyle: chatBackgroundConfig.messageTimeTextStyle,
          messageTimeIconColor: chatBackgroundConfig.messageTimeIconColor,
          message: message,
          onLongPress: widget.onLongPress,
          messageConfig: widget.messageConfig,
          chatBubbleConfig: chatBubbleConfig,
          swipeToReplyConfig: widget.swipeToReplyConfig,
          repliedMessageConfig: widget.repliedMessageConfig,
          ltr: widget.ltr ?? true,
          onSwipe: widget.assignReplyMessage,
          shouldHighlight: _replyId == message.id,
          imageWidget: widget.imageWidget,
          /*//todo  onReplyTap: widget
                                .repliedMessageConfig
                                ?.repliedMsgAutoScrollConfig
                                .enableScrollToRepliedMsg ??
                            false
                        ? (replyId) => _onReplyTap(replyId, snapshot.data)
                        : null, */
        );
      },
    );
    /* StreamBuilder<List<Message>>(
      //stream: chatController?.stream,
      stream: chatController?.messageStreamController.stream,
      builder: (context, snapshot) {
        return !snapshot.hasData
            ? GroupedListView<Message, String>(
                shrinkWrap: true,
                elements: snapshot.data!,
                reverse: true,
                groupBy: (element) =>
                    DateTime.parse(element.createdAt).getDateFromDateTime,
                itemComparator: (message1, message2) =>
                    message1.content.compareTo(message2.content),
                physics: const NeverScrollableScrollPhysics(),
                order: chatBackgroundConfig.groupedListOrder,
                sort: chatBackgroundConfig.sortEnable,
                groupSeparatorBuilder: (separator) =>
                    featureActiveConfig?.enableChatSeparator ?? false
                        ? _GroupSeparatorBuilder(
                            separator: separator,
                            defaultGroupSeparatorConfig: chatBackgroundConfig
                                .defaultGroupSeparatorConfig,
                            groupSeparatorBuilder:
                                chatBackgroundConfig.groupSeparatorBuilder,
                          )
                        : const SizedBox.shrink(),
                indexedItemBuilder: (context, message, index) {
                  return ChatBubbleWidget(
                    //todokey: message.key,
                    key: ValueKey(index),
                    messageTimeTextStyle:
                        chatBackgroundConfig.messageTimeTextStyle,
                    messageTimeIconColor:
                        chatBackgroundConfig.messageTimeIconColor,
                    message: message,
                    messageConfig: widget.messageConfig,
                    chatBubbleConfig: chatBubbleConfig,
                    profileCircleConfig: profileCircleConfig,
                    swipeToReplyConfig: widget.swipeToReplyConfig,
                    repliedMessageConfig: widget.repliedMessageConfig,
                    slideAnimation: _slideAnimation,
                    ltr: widget.ltr ?? true,
                    onLongPress: (yCoordinate, xCoordinate) => longPresShowTime
                        ? _onHorizontalDrag()
                        : widget.onChatBubbleLongPress(
                            yCoordinate,
                            xCoordinate,
                            message,
                          ),
                    onSwipe: widget.assignReplyMessage,
                    shouldHighlight: _replyId == message.id,
                    /*//todo  onReplyTap: widget
                                .repliedMessageConfig
                                ?.repliedMsgAutoScrollConfig
                                .enableScrollToRepliedMsg ??
                            false
                        ? (replyId) => _onReplyTap(replyId, snapshot.data)
                        : null, */
                  );
                },
              )
            : Container(
                //child: chatBackgroundConfig.loadingWidget ??
                //    const CircularProgressIndicator(),
                );
      },
    ) */
  }
}

class _GroupSeparatorBuilder extends StatelessWidget {
  const _GroupSeparatorBuilder({
    Key? key,
    required this.separator,
    this.groupSeparatorBuilder,
    this.defaultGroupSeparatorConfig,
  }) : super(key: key);
  final String separator;
  final StringWithReturnWidget? groupSeparatorBuilder;
  final DefaultGroupSeparatorConfiguration? defaultGroupSeparatorConfig;

  @override
  Widget build(BuildContext context) {
    return groupSeparatorBuilder != null
        ? groupSeparatorBuilder!(separator)
        : ChatGroupHeader(
            day: DateTime.parse(separator),
            groupSeparatorConfig: defaultGroupSeparatorConfig,
          );
  }
}
