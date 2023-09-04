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
import '../utils/style.dart';
import '../widgets/chat_list_widget.dart';
import '../widgets/chat_view_inherited_widget.dart';

import 'package:flutter/material.dart';

import 'send_message_widget.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    Key? key,
    required this.chatController,
    required this.currentUser,
    this.hasEmoji = true,
    required this.noRecentText,
    this.onSendTap,
    this.chatBubbleConfig,
    this.repliedMessageConfig,
    this.swipeToReplyConfig,
    this.loadMoreData,
    this.loadingWidget,
    this.messageConfig,
    this.isLastPage,
    ChatBackgroundConfiguration? chatBackgroundConfig,
    this.sendMessageConfig,
    required this.chatViewState,
    this.featureActiveConfig = const FeatureActiveConfig(),
    this.onTextFieldTap,
    this.ltr,
    this.hasCorners = true,
    PackageStrings? packageStrings,
    this.sendMessageBuilder,
    required this.imageWidget,
    required this.hasAttach,
    required this.onAttach,
    required this.onLongPress,
    required this.emptyWidget,
    required this.incomingTextColor,
    required this.incomingbackgroundColor,
  })  : chatBackgroundConfig =
            chatBackgroundConfig ?? const ChatBackgroundConfiguration(),
        super(key: key);
  final Color? incomingbackgroundColor;

  final Color? incomingTextColor;

  final Widget emptyWidget;

  final MessageCallBack? onLongPress;

  final bool hasAttach;
  final Function? onAttach;

  final Function imageWidget;

  final Function()? onTextFieldTap;
  final bool? ltr;
  final bool hasCorners;

  /// Provides configuration related to user profile circle avatar.

  /// Provides configurations related to chat bubble such as padding, margin, max
  /// width etc.
  final ChatBubbleConfiguration? chatBubbleConfig;

  /// Allow user to giving customisation different types
  /// messages.
  final MessageConfiguration? messageConfig;

  /// Provides configuration for replied message view which is located upon chat
  /// bubble.
  final RepliedMessageConfiguration? repliedMessageConfig;

  /// Provides configurations related to swipe chat bubble which triggers
  /// when user swipe chat bubble.
  final SwipeToReplyConfiguration? swipeToReplyConfig;

  /// Provides configuration for reply snack bar's appearance and options.

  /// Allow user to give customisation to background of chat
  final ChatBackgroundConfiguration chatBackgroundConfig;

  /// Provides callback when user actions reaches to top and needs to load more
  /// chat
  final VoidCallBackWithFuture? loadMoreData;

  /// Provides widget for loading view while pagination is enabled.
  final Widget? loadingWidget;

  /// Provides flag if there is no more next data left in list.
  final bool? isLastPage;

  /// Provides call back when user tap on send button in text field. It returns
  /// message, reply message and message type.
  final StringMessageCallBack? onSendTap;

  /// Provides builder which helps you to make custom text field and functionality.
  final ReplyMessageWithReturnWidget? sendMessageBuilder;

  /// Provides controller for accessing few function for running chat.
  final ChatController chatController;

  /// Provides configuration of default text field in chat.
  final SendMessageConfiguration? sendMessageConfig;

  final String noRecentText;
  final bool hasEmoji;

  /// Provides current state of chat.
  final ChatViewState chatViewState;

  /// Provides current user which is sending messages.
  final ChatUser currentUser;

  /// Provides configuration for turn on/off specific features.
  final FeatureActiveConfig featureActiveConfig;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SendMessageWidgetState> _sendMessageKey = GlobalKey();
  ReplyMessage replyMessage = const ReplyMessage();

  ScrollController scrollController = ScrollController();

  ChatController get chatController => widget.chatController;

  ChatBackgroundConfiguration get chatBackgroundConfig =>
      widget.chatBackgroundConfig;

  ChatViewState get chatViewState => widget.chatViewState;

  FeatureActiveConfig get featureActiveConfig => widget.featureActiveConfig;

  @override
  void initState() {
    super.initState();
    // Adds current user in users list.
    chatController.chatUsers.add(widget.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    // Scroll to last message on in hasMessages state.
    /* if (showTypingIndicator && chatViewState.hasMessages) {
      chatController.scrollToLastMessage();
    } */
    return ChatViewInheritedWidget(
      chatController: chatController,
      featureActiveConfig: featureActiveConfig,
      currentUser: widget.currentUser,
      child: Container(
        height:
            chatBackgroundConfig.height ?? MediaQuery.of(context).size.height,
        width: chatBackgroundConfig.width ?? MediaQuery.of(context).size.width,
        decoration: chatBackgroundConfig.backgroundColor != null
            ? BoxDecoration(color: chatBackgroundConfig.backgroundColor)
            : BoxDecoration(
                //  color: chatBackgroundConfig.backgroundColor ?? Colors.white,
                image: chatBackgroundConfig.backgroundImage != null
                    ? DecorationImage(
                        fit: BoxFit.fill,
                        image:
                            NetworkImage(chatBackgroundConfig.backgroundImage!),
                      )
                    : null,
                boxShadow: S.innerBoxShadow(),
                borderRadius: widget.hasCorners
                    ? BorderRadius.only(
                        topLeft: Radius.circular(S.radius38(context)),
                        topRight: Radius.circular(S.radius38(context)),
                      )
                    : null,
              ),
        padding: chatBackgroundConfig.padding,
        margin: chatBackgroundConfig.margin,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  /* if (chatViewState.isLoading)
                    ChatViewStateWidget(
                      chatViewStateWidgetConfig:
                          chatViewStateConfig?.loadingWidgetConfig,
                      chatViewState: chatViewState,
                    )
                  else */

                  if (chatViewState.hasMessages)
                    ChatListWidget(
                      scrollController: scrollController,
                      replyMessage: replyMessage,
                      incomingTextColor: widget.incomingTextColor,
                      incomingbackgroundColor: widget.incomingbackgroundColor,
                      chatController: widget.chatController,
                      chatBackgroundConfig: widget.chatBackgroundConfig,
                      chatBubbleConfig: widget.chatBubbleConfig,
                      loadMoreData: widget.loadMoreData,
                      isLastPage: widget.isLastPage,
                      loadingWidget: widget.loadingWidget,
                      messageConfig: widget.messageConfig,
                      repliedMessageConfig: widget.repliedMessageConfig,
                      swipeToReplyConfig: widget.swipeToReplyConfig,
                      featureActiveConfig: widget.featureActiveConfig,
                      ltr: widget.ltr,
                      onLongPress: widget.onLongPress,
                      assignReplyMessage: (message) => _sendMessageKey
                          .currentState
                          ?.assignReplyMessage(message),
                      imageWidget: widget.imageWidget,
                      emptyWidget: widget.emptyWidget,
                    ),
                  if (featureActiveConfig.enableTextField)
                    SendMessageWidget(
                      key: _sendMessageKey,
                      chatController: chatController,
                      sendMessageBuilder: widget.sendMessageBuilder,
                      sendMessageConfig: widget.sendMessageConfig,
                      hasEmoji: widget.hasEmoji,
                      noRecentText: widget.noRecentText,
                      hasAttach: widget.hasAttach,
                      onAttach: widget.onAttach,
                      backgroundColor: chatBackgroundConfig.backgroundColor,
                      onSendTap: _onSendTap,
                      onTextFieldTap: widget.onTextFieldTap,
                      onReplyCallback: (reply) =>
                          setState(() => replyMessage = reply),
                      onReplyCloseCallback: () =>
                          setState(() => replyMessage = const ReplyMessage()),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageTypes messageType,
  ) {
    if (widget.sendMessageBuilder == null) {
      if (widget.onSendTap != null) {
        widget.onSendTap!(message, replyMessage, messageType);
      }
      _assignReplyMessage();
    }
    chatController.scrollToLastMessage(scrollController);
  }

  void _assignReplyMessage() {
    if (replyMessage.content.isNotEmpty) {
      setState(() => replyMessage = const ReplyMessage());
    }
  }
}
