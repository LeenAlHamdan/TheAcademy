import 'package:the_academy/model/user.dart';

class Chat {
  final String id;
  String createdAt;
  List<CourseUser> users;
  final String? courseId;
  final String? courseNameAr;
  final String? courseNameEn;
  final String? courseImage;

  Chat({
    required this.id,
    required this.createdAt,
    required this.users,
    this.courseId,
    this.courseNameAr,
    this.courseNameEn,
    this.courseImage,
  });
}
