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

import 'package:chatview/chatview.dart';

class ReplyMessage {
  /// Provides reply message.
  final String content;

  /// Provides user id of who replied message.
  final String replyBy;

  /// Provides user id of whom to reply.
  final String replyTo;
  final String messageType;

  /// Provides max duration for recorded voice message.
  final Duration? voiceMessageDuration;

  /// Id of message, it replies to.
  final String messageId;

  const ReplyMessage({
    this.messageId = '',
    this.content = '',
    this.replyTo = '',
    this.replyBy = '',
    this.messageType = 'text',
    this.voiceMessageDuration,
  });

  factory ReplyMessage.fromJson(Map<String, dynamic> json) => ReplyMessage(
        content: json['message'],
        replyBy: json['replyBy'],
        replyTo: json['replyTo'],
        messageType: json["message_type"],
        messageId: json["id"],
        voiceMessageDuration: json["voiceMessageDuration"],
      );

  Map<String, dynamic> toJson() => {
        'message': content,
        'replyBy': replyBy,
        'replyTo': replyTo,
        'message_type': messageType,
        'id': messageId,
        'voiceMessageDuration': voiceMessageDuration,
      };
}

/// Extension on MessageType for checking specific message type
extension ReplyMessageType on ReplyMessage {
  bool get isImage => this.messageType == MessageTypes.image.name;

  bool get isText => this.messageType == MessageTypes.text.name;

  bool get isVoice => this.messageType == MessageTypes.voice.name;

  //bool get isCustom => this == MessageType.custom;
  MessageTypes get messageType => MessageTypes.values.firstWhere(
        (element) => element.name == this.messageType,
      );
}
