import 'package:chatview/chatview.dart';

class PollOptions {
  String text;
  String id;
  List<dynamic> chosenBy;
  bool isChosedByUser;

  PollOptions({
    required this.text,
    required this.id,
    required this.chosenBy,
    required this.isChosedByUser,
  });
}

class Location extends Message {
  String latitude;
  String longitude;
  Location({
    required String id,
    required String? consultancyId,
    required String? courseId,
    required String createdAt,
    required String? seenAt,
    required String senderId,
    required String senderUserProfileImageUrl,
    required String senderName,
    required String type,
    required String content,
    required this.latitude,
    required this.longitude,
  }) : super(
          id: id,
          consultancyId: consultancyId,
          courseId: courseId,
          createdAt: createdAt,
          content: content,
          type: type,
          seenAt: seenAt,
          senderId: senderId,
          senderUserProfileImageUrl: senderUserProfileImageUrl,
          senderName: senderName,
        );
}

class Poll extends Message {
  List<PollOptions> poolOptions;
  int totalVotes;
  bool userHasVoted;

  Poll({
    required String id,
    required String? consultancyId,
    required String? courseId,
    required String createdAt,
    required String content,
    required String? seenAt,
    required String senderId,
    required String senderUserProfileImageUrl,
    required String senderName,
    required String type,
    required this.poolOptions,
    required this.totalVotes,
    required this.userHasVoted,
  }) : super(
          id: id,
          consultancyId: consultancyId,
          courseId: courseId,
          createdAt: createdAt,
          content: content,
          type: type,
          seenAt: seenAt,
          senderId: senderId,
          senderUserProfileImageUrl: senderUserProfileImageUrl,
          senderName: senderName,
        );
}

class MyFile extends Message {
  String? path;
  MyFile({
    required String id,
    required String? consultancyId,
    required String? courseId,
    required String createdAt,
    required String content,
    required String? seenAt,
    required String senderId,
    required String senderUserProfileImageUrl,
    required String senderName,
    required String type,
    required this.path,
  }) : super(
          id: id,
          consultancyId: consultancyId,
          courseId: courseId,
          createdAt: createdAt,
          content: content,
          type: type,
          seenAt: seenAt,
          senderId: senderId,
          senderUserProfileImageUrl: senderUserProfileImageUrl,
          senderName: senderName,
        );
}

class Slide extends Message {
  List<String> images;
  Slide({
    required String id,
    required String? consultancyId,
    required String? courseId,
    required String createdAt,
    required String content,
    required String? seenAt,
    required String senderId,
    required String senderUserProfileImageUrl,
    required String senderName,
    required String type,
    required this.images,
  }) : super(
          id: id,
          consultancyId: consultancyId,
          courseId: courseId,
          createdAt: createdAt,
          content: content,
          type: type,
          seenAt: seenAt,
          senderId: senderId,
          senderUserProfileImageUrl: senderUserProfileImageUrl,
          senderName: senderName,
        );
}

/// Extension on MessageType for checking specific message type
extension MessageTypes on Message {
  bool get isImage => this.type == MyMessageType.image.name;

  bool get isText => this.type == MyMessageType.text.name;

  bool get isVoice => this.type == MyMessageType.voice.name;

  bool get isPoll => this.type == MyMessageType.poll.name;

  bool get isSlides => this.type == MyMessageType.slides.name;

  bool get isFile => this.type == MyMessageType.file.name;

  bool get isLocation => this.type == MyMessageType.location.name;

  //bool get isCustom => this == MessageType.custom;
  MyMessageType get messageType => MyMessageType.values.firstWhere(
        (element) => element.name == this.type,
      );
}

MyMessageType messageType(String type) {
  return MyMessageType.values.firstWhere(
    (element) => element.name == type,
  );
}

enum MyMessageType {
  text,
  image,
  voice,
  file,
  location,
  slides,
  poll,
}
