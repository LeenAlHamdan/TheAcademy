import 'package:the_academy/model/user.dart';

class Course {
  String id;

  String nameAr;
  String nameEn;
  String descriptionAr;
  String descriptionEn;
  String image;
  bool isPrivate;
  bool active;
  bool accepted;

  String coachId;
  String coachName;
  String subjectId;
  String subjectNameAr;
  String subjectNameEn;
  List<String> users;
  List<String> pendingUsers;

  Course({
    required this.id,
    required this.image,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.isPrivate,
    required this.active,
    required this.accepted,
    required this.subjectId,
    required this.subjectNameAr,
    required this.subjectNameEn,
    required this.coachId,
    required this.coachName,
    required this.users,
    required this.pendingUsers,
  });
}

class CourseFullData {
  String id;

  String nameAr;
  String nameEn;
  String descriptionAr;
  String descriptionEn;
  String image;
  bool isPrivate;
  bool active;
  bool accepted;

  String coachId;
  String coachName;
  String coachImage;
  String subjectId;
  String subjectNameAr;
  String subjectNameEn;
  List<CourseUser> users;
  List<CourseUser> pendingUsers;
  UserEvaluation? userEvaluation;

  CourseFullData({
    required this.id,
    required this.image,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.isPrivate,
    required this.active,
    required this.accepted,
    required this.subjectId,
    required this.subjectNameAr,
    required this.subjectNameEn,
    required this.coachId,
    required this.coachName,
    required this.coachImage,
    required this.users,
    required this.pendingUsers,
    required this.userEvaluation,
  });
}

class UserEvaluation {
  double markSum;
  int examCount;
  int examsCount;
  double evaluation;

  String userId;
  String userName;
  String userImage;

  UserEvaluation({
    required this.markSum,
    required this.examCount,
    required this.examsCount,
    required this.evaluation,
    required this.userId,
    required this.userName,
    required this.userImage,
  });
}
