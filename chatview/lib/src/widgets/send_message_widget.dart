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
import 'package:audio_waveforms/audio_waveforms.dart' show DurationExtension;
import '../widgets/chatui_textfield.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../chatview.dart';
import '../extensions/extensions.dart';

import '../utils/constants.dart';

class SendMessageWidget extends StatefulWidget {
  const SendMessageWidget({
    Key? key,
    required this.onSendTap,
    required this.chatController,
    this.sendMessageConfig,
    this.backgroundColor,
    this.sendMessageBuilder,
    this.onReplyCallback,
    this.onReplyCloseCallback,
    this.onTextFieldTap,
    required this.hasAttach,
    required this.onAttach,
    required this.noRecentText,
    required this.hasEmoji,
  }) : super(key: key);

  final bool hasAttach;
  final Function? onAttach;

  final Function()? onTextFieldTap;

  /// Provides call back when user tap on send button on text field.
  final StringMessageCallBack onSendTap;

  /// Provides configuration for text field appearance.
  final SendMessageConfiguration? sendMessageConfig;

  final String noRecentText;
  final bool hasEmoji;

  /// Allow user to set background colour.
  final Color? backgroundColor;

  /// Allow user to set custom text field.
  final ReplyMessageWithReturnWidget? sendMessageBuilder;

  /// Provides callback when user swipes chat bubble for reply.
  final ReplyMessageCallBack? onReplyCallback;

  /// Provides call when user tap on close button which is showed in reply pop-up.
  final VoidCallBack? onReplyCloseCallback;

  /// Provides controller for accessing few function for running chat.
  final ChatController chatController;

  @override
  State<SendMessageWidget> createState() => SendMessageWidgetState();
}

class SendMessageWidgetState extends State<SendMessageWidget> {
  ReplyMessage _replyMessage = const ReplyMessage();

  ChatUser get repliedUser =>
      widget.chatController.getUserFromId(_replyMessage.replyTo);

  String get _replyTo => _replyMessage.replyTo == currentUser?.id
      ? PackageStrings.you
      : repliedUser.name;

  ChatUser? currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      currentUser = provide!.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.sendMessageBuilder != null
        ? Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: widget.sendMessageBuilder!(_replyMessage),
          )
        : Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: 0,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height /
                          ((!kIsWeb && Platform.isIOS) ? 24 : 28),
                      //color: widget.backgroundColor ?? Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      bottomPadding4,
                      bottomPadding4,
                      bottomPadding4,
                      _bottomPadding,
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        if (_replyMessage.content.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: widget.sendMessageConfig
                                      ?.textFieldBackgroundColor ??
                                  Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14)),
                            ),
                            margin: const EdgeInsets.only(
                              bottom: 17,
                              right: 0.4,
                              left: 0.4,
                            ),
                            padding: const EdgeInsets.fromLTRB(
                              leftPadding,
                              leftPadding,
                              leftPadding,
                              30,
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: widget
                                        .sendMessageConfig?.replyDialogColor ??
                                    Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${PackageStrings.replyTo} $_replyTo",
                                        style: TextStyle(
                                          color: widget.sendMessageConfig
                                                  ?.replyTitleColor ??
                                              Colors.deepPurple,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.25,
                                        ),
                                      ),
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          Icons.close,
                                          color: widget.sendMessageConfig
                                                  ?.closeIconColor ??
                                              Colors.black,
                                          size: 16,
                                        ),
                                        onPressed: _onCloseTap,
                                      ),
                                    ],
                                  ),
                                  _replyMessage.messageType ==
                                          MessageTypes.voice.name
                                      ? Row(
                                          children: [
                                            Icon(
                                              Icons.mic,
                                              color: widget.sendMessageConfig
                                                  ?.micIconColor,
                                            ),
                                            const SizedBox(width: 4),
                                            if (_replyMessage
                                                    .voiceMessageDuration !=
                                                null)
                                              Text(
                                                _replyMessage
                                                    .voiceMessageDuration!
                                                    .toHHMMSS(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: widget
                                                          .sendMessageConfig
                                                          ?.replyMessageColor ??
                                                      Colors.black,
                                                ),
                                              ),
                                          ],
                                        )
                                      : _replyMessage.messageType ==
                                              MessageTypes.image.name
                                          ? Row(
                                              children: [
                                                Icon(
                                                  Icons.photo,
                                                  size: 20,
                                                  color: widget
                                                          .sendMessageConfig
                                                          ?.replyMessageColor ??
                                                      Colors.grey.shade700,
                                                ),
                                                Text(
                                                  PackageStrings.photo,
                                                  style: TextStyle(
                                                    color: widget
                                                            .sendMessageConfig
                                                            ?.replyMessageColor ??
                                                        Colors.black,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              _replyMessage.content,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: widget.sendMessageConfig
                                                        ?.replyMessageColor ??
                                                    Colors.black,
                                              ),
                                            ),
                                ],
                              ),
                            ),
                          ),
                        ChatUITextField(
                          focusNode: widget.chatController.focusNode,
                          textEditingController:
                              widget.chatController.textEditingController,
                          onPressed: _onPressed,
                          onTextFieldTap: widget.onTextFieldTap,
                          sendMessageConfig: widget.sendMessageConfig,
                          noRecentText: widget.noRecentText,
                          hasEmoji: widget.hasEmoji,
                          onRecordingComplete: _onRecordingComplete,
                          onImageSelected: _onImageSelected,
                          onFileSelected: _onFileSelected,
                          hasAttach: widget.hasAttach,
                          onAttach: widget.onAttach,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void _onRecordingComplete(String? path) {
    if (path != null) {
      widget.onSendTap.call(path, _replyMessage, MessageTypes.voice);
      _assignRepliedMessage();
    }
  }

  void _onImageSelected(String imagePath, String error) {
    debugPrint('Call in Send Message Widget');
    if (imagePath.isNotEmpty) {
      widget.onSendTap.call(imagePath, _replyMessage, MessageTypes.image);
      _assignRepliedMessage();
    }
  }

  void _onFileSelected(String imagePath, String error) {
    debugPrint('Call in Send Message Widget');
    if (imagePath.isNotEmpty) {
      widget.onSendTap.call(imagePath, _replyMessage, MessageTypes.file);
      _assignRepliedMessage();
    }
  }

  void _assignRepliedMessage() {
    if (_replyMessage.content.isNotEmpty) {
      setState(() => _replyMessage = const ReplyMessage());
    }
  }

  void _onPressed() {
    if (widget.chatController.textEditingController.text.isNotEmpty &&
        !widget.chatController.textEditingController.text.startsWith('\n')) {
      widget.onSendTap.call(
        widget.chatController.textEditingController.text.trim(),
        _replyMessage,
        MessageTypes.text,
      );
      _assignRepliedMessage();
      widget.chatController.textEditingController.clear();
    }
  }

  void assignReplyMessage(Message message) {
    if (currentUser != null) {
      setState(() {
        _replyMessage = ReplyMessage(
          content: message.content,
          replyBy: currentUser!.id,
          replyTo: message.senderId,
          messageType: message.messageType.name,
          messageId: message.id,
          voiceMessageDuration: message.voiceMessageDuration,
        );
      });
    }
    FocusScope.of(context).requestFocus(widget.chatController.focusNode);
    if (widget.onReplyCallback != null) widget.onReplyCallback!(_replyMessage);
  }

  void _onCloseTap() {
    setState(() => _replyMessage = const ReplyMessage());
    if (widget.onReplyCloseCallback != null) widget.onReplyCloseCallback!();
  }

  double get _bottomPadding => (!kIsWeb && Platform.isIOS)
      ? (widget.chatController.focusNode.hasFocus
          ? bottomPadding1
          : View.of(context).viewPadding.bottom > 0
              ? bottomPadding2
              : bottomPadding3)
      : bottomPadding3;

  @override
  void dispose() {
    widget.chatController.textEditingController.clear();
    widget.chatController.focusNode.unfocus();
    super.dispose();
  }
}
