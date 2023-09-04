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
import 'dart:convert';
import 'dart:io';

import '../extensions/extensions.dart';
import '../models/models.dart';
import 'package:flutter/material.dart';

class ImageMessageView extends StatelessWidget {
  const ImageMessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    this.imageMessageConfig,
    this.highlightImage = false,
    this.highlightScale = 1.2,
    this.outgoingChatBubbleConfig,
    required this.incomingbackgroundColor,
  }) : super(key: key);

  final Color? incomingbackgroundColor;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration for image message appearance.
  final ImageMessageConfiguration? imageMessageConfig;

  /// Represents flag of highlighting image when user taps on replied image.
  final bool highlightImage;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  String get imageUrl => message.content;

  Color get _color => isMessageBySender
      ? outgoingChatBubbleConfig?.color ?? Colors.purple
      : incomingbackgroundColor ?? Colors.white;
//Colors.grey.shade500;

  EdgeInsets setPadding() {
    if (isMessageBySender) {
      return const EdgeInsets.only(right: 20);
    } else {
      return const EdgeInsets.only(
        left: 20,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _color, width: 2)),
      child: GestureDetector(
        onTap: () => imageMessageConfig?.onTap != null
            ? imageMessageConfig?.onTap!(imageUrl, message.senderName)
            : null,
        child: Transform.scale(
          scale: highlightImage ? highlightScale : 1.0,
          alignment: Alignment.center,
          //      isMessageBySender ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: imageMessageConfig?.padding ?? EdgeInsets.zero,
            margin: imageMessageConfig?.margin ?? EdgeInsets.zero,
            height: imageMessageConfig?.height ?? 200,
            width: imageMessageConfig?.width ?? 150,
            child: ClipRRect(
              borderRadius:
                  imageMessageConfig?.borderRadius ?? BorderRadius.circular(14),
              child: (() {
                if (imageUrl.isUrl) {
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.fitHeight,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  );
                } else if (imageUrl.fromMemory) {
                  return Image.memory(
                    base64Decode(
                        imageUrl.substring(imageUrl.indexOf('base64') + 7)),
                    fit: BoxFit.fitHeight,
                  );
                } else {
                  return Image.file(
                    File(imageUrl),
                    fit: BoxFit.fitHeight,
                  );
                }
              }()),
            ),
          ),
        ),
      ),
    );
    /* return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          isMessageBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        //if (isMessageBySender) iconButton,
        Stack(
          children: [
            GestureDetector(
              onTap: () => imageMessageConfig?.onTap != null
                  ? imageMessageConfig?.onTap!(imageUrl)
                  : null,
              child: Transform.scale(
                scale: highlightImage ? highlightScale : 1.0,
                alignment: isMessageBySender
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding: imageMessageConfig?.padding ?? EdgeInsets.zero,
                  margin: imageMessageConfig?.margin ??
                      EdgeInsets.only(
                        top: 6,
                        right: isMessageBySender ? 6 : 0,
                        left: isMessageBySender ? 0 : 6,
                        bottom:
                            //message.reaction.reactions.isNotEmpty ? 15 :
                            0,
                      ),
                  height: imageMessageConfig?.height ?? 200,
                  width: imageMessageConfig?.width ?? 150,
                  child: ClipRRect(
                    borderRadius: imageMessageConfig?.borderRadius ??
                        BorderRadius.circular(14),
                    child: (() {
                      if (imageUrl.isUrl) {
                        return Image.network(
                          imageUrl,
                          fit: BoxFit.fitHeight,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        );
                      } else if (imageUrl.fromMemory) {
                        return Image.memory(
                          base64Decode(imageUrl
                              .substring(imageUrl.indexOf('base64') + 7)),
                          fit: BoxFit.fill,
                        );
                      } else {
                        return Image.file(
                          File(imageUrl),
                          fit: BoxFit.fill,
                        );
                      }
                    }()),
                  ),
                ),
              ),
            ),
            /* if (message.reaction.reactions.isNotEmpty)
              ReactionWidget(
                isMessageBySender: isMessageBySender,
                reaction: message.reaction,
                messageReactionConfig: messageReactionConfig,
              ), */
          ],
        ),
        //if (!isMessageBySender) iconButton,
      ],
    ); */
  }
}