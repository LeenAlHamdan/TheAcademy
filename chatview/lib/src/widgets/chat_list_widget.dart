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
import 'dart:io';

import '../extensions/extensions.dart';
import '../widgets/chat_groupedlist_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../chatview.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget({
    Key? key,
    required this.chatController,
    required this.chatBackgroundConfig,
    required this.assignReplyMessage,
    required this.replyMessage,
    required this.featureActiveConfig,
    required this.scrollController,
    this.loadingWidget,
    this.messageConfig,
    this.chatBubbleConfig,
    this.swipeToReplyConfig,
    this.repliedMessageConfig,
    this.loadMoreData,
    this.isLastPage,
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

  final ScrollController scrollController;

  /// Provides controller for accessing few function for running chat.
  final ChatController chatController;

  /// Provides configuration for background of chat.
  final ChatBackgroundConfiguration chatBackgroundConfig;

  /// Provides widget for loading view while pagination is enabled.
  final Widget? loadingWidget;

  /// Provides flag for turn on/off typing indicator.

  /// Provides configuration for reaction pop up appearance.

  /// Provides configuration for customisation of different types
  /// messages.
  final MessageConfiguration? messageConfig;

  /// Provides configuration of chat bubble's appearance.
  final ChatBubbleConfiguration? chatBubbleConfig;

  /// Provides configuration for when user swipe to chat bubble.
  final SwipeToReplyConfiguration? swipeToReplyConfig;

  /// Provides configuration for replied message view which is located upon chat
  /// bubble.
  final RepliedMessageConfiguration? repliedMessageConfig;

  /// Provides configuration of typing indicator's appearance.

  /// Provides reply message when user swipe to chat bubble.
  final ReplyMessage replyMessage;

  /// Provides configuration for reply snack bar's appearance and options.

  /// Provides callback when user actions reaches to top and needs to load more
  /// chat
  final VoidCallBackWithFuture? loadMoreData;

  /// Provides flag if there is no more next data left in list.
  final bool? isLastPage;

  /// Provides callback for assigning reply message when user swipe to chat
  /// bubble.
  final MessageCallBack assignReplyMessage;

  final FeatureActiveConfig? featureActiveConfig;

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget>
    with SingleTickerProviderStateMixin {
  bool _isNextPageLoading = false;
  bool showPopUp = false;

  ChatController get chatController => widget.chatController;

  List<Message> get messageList => chatController.initialMessageList;

  ScrollController get scrollController => widget.scrollController;

  ChatBackgroundConfiguration get chatBackgroundConfig =>
      widget.chatBackgroundConfig;

  FeatureActiveConfig? get featureActiveConfig => widget.featureActiveConfig;
  Function? onLongPress;
  ChatUser? currentUser;

  @override
  void initState() {
    super.initState();

    //_initialize();

    if (featureActiveConfig?.enablePagination ?? false) {
      // When flag is on then it will include pagination logic to scroll
      // controller.

      scrollController.addListener(_pagination);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      //featureActiveConfig = provide!.featureActiveConfig;
      currentUser = provide!.currentUser;
    }
  }

  /* void _initialize() {
    chatController.messageStreamController = StreamController();
    if (!chatController.messageStreamController.isClosed) {
      chatController.messageStreamController.sink.add(messageList);
    }
    //  if (messageList.isNotEmpty) chatController.scrollToLastMessage();
  } */

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isNextPageLoading &&
            (featureActiveConfig?.enablePagination ?? false))
          SizedBox(
            height: Scaffold.of(context).appBarMaxHeight,
            child: Center(
              child: widget.loadingWidget ?? const CircularProgressIndicator(),
            ),
          ),
        Expanded(
          child: ChatGroupedListWidget(
            showPopUp: showPopUp,
            incomingbackgroundColor: widget.incomingbackgroundColor,
            incomingTextColor: widget.incomingTextColor,
            onLongPress: widget.onLongPress,
            scrollController: scrollController,
            chatBackgroundConfig: widget.chatBackgroundConfig,
            assignReplyMessage: widget.assignReplyMessage,
            replyMessage: widget.replyMessage,
            swipeToReplyConfig: widget.swipeToReplyConfig,
            repliedMessageConfig: widget.repliedMessageConfig,
            messageConfig: widget.messageConfig,
            chatBubbleConfig: widget.chatBubbleConfig,
            ltr: widget.ltr,
            onChatListTap: _onChatListTap,
            imageWidget: widget.imageWidget,
            emptyWidget: widget.emptyWidget,
          ),
          /* Stack(
            children: [
              ChatGroupedListWidget(
                showPopUp: showPopUp,
                longPresShowTime: widget.longPresShowTime,
                showTypingIndicator: showTypingIndicator,
                scrollController: scrollController,
                isEnableSwipeToSeeTime:
                    featureActiveConfig?.enableSwipeToSeeTime ?? true,
                chatBackgroundConfig: widget.chatBackgroundConfig,
                assignReplyMessage: widget.assignReplyMessage,
                replyMessage: widget.replyMessage,
                swipeToReplyConfig: widget.swipeToReplyConfig,
                repliedMessageConfig: widget.repliedMessageConfig,
                profileCircleConfig: widget.profileCircleConfig,
                messageConfig: widget.messageConfig,
                chatBubbleConfig: widget.chatBubbleConfig,
                typeIndicatorConfig: widget.typeIndicatorConfig,
                ltr: widget.ltr,
                onChatBubbleLongPress: (yCoordinate, xCoordinate, message) {
                  if (featureActiveConfig?.enableReactionPopup ?? false) {
                    _reactionPopupKey.currentState?.refreshWidget(
                      message: message,
                      xCoordinate: xCoordinate,
                      yCoordinate:
                          yCoordinate < 0 ? -(yCoordinate) - 5 : yCoordinate,
                    );
                    setState(() => showPopUp = true);
                  }
                  if (featureActiveConfig?.enableReplySnackBar ?? false) {
                    _showReplyPopup(
                      message: message,
                      sendByCurrentUser: message.senderId == currentUser?.id,
                    );
                  }
                },
                onChatListTap: _onChatListTap,
              ),
              if (featureActiveConfig?.enableReactionPopup ?? false)
                ReactionPopup(
                  key: _reactionPopupKey,
                  reactionPopupConfig: widget.reactionPopupConfig,
                  onTap: _onChatListTap,
                  showPopUp: showPopUp,
                ),
            ],
          ) */
        ),
      ],
    );
  }

  void _pagination() {
    if (widget.loadMoreData == null || widget.isLastPage == true) {
      return;
    }
    if ((scrollController.position.extentBefore > 200) && !_isNextPageLoading) {
      setState(() => _isNextPageLoading = true);
      widget.loadMoreData!()
          .whenComplete(() => setState(() => _isNextPageLoading = false));
    }
  }

  void _onChatListTap() {
    if (!kIsWeb && Platform.isIOS) FocusScope.of(context).unfocus();
    setState(() => showPopUp = false);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  void dispose() {
    //chatController.messageStreamController.close();
    scrollController.dispose();
    super.dispose();
  }
}
