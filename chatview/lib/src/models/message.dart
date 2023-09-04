import '../../chatview.dart';

class Message {
  String id;
  final String senderId;
  final String senderUserProfileImageUrl;
  final String senderName;
  final bool? senderIsOnline;
  final String? consultancyId;
  final String? courseId;
  String createdAt;
  String? seenAt;
  String content;
  String type;
  bool sended;
  ReplyMessage replyMessage;
  Duration? voiceMessageDuration;
  String? path;
  final Map<String, dynamic>? config;

  //final GlobalKey key;

  Message({
    required this.id,
    required this.consultancyId,
    required this.courseId,
    required this.createdAt,
    required this.content,
    required this.type,
    required this.seenAt,
    required this.senderId,
    required this.senderUserProfileImageUrl,
    required this.senderName,
    this.config,
    this.senderIsOnline,
    this.sended = true,
    this.replyMessage = const ReplyMessage(),
    this.voiceMessageDuration,
    this.path,
  }); // key = GlobalKey();
}

extension MessageType on Message {
  bool get isImage => type == MessageTypes.image.name;

  bool get isText => type == MessageTypes.text.name;

  bool get isVoice => type == MessageTypes.voice.name;

  bool get isCustom =>
      (type != MessageTypes.image.name) &&
      (type != MessageTypes.text.name) &&
      type != MessageTypes.voice.name;

  //bool get isCustom => this == MessageType.custom;
  MessageTypes get messageType => MessageTypes.values.firstWhere(
        (element) => element.name == type,
      );
}
