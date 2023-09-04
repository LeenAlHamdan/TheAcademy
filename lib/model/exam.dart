import 'package:the_academy/model/question.dart';

class Exam {
  String id;

  String nameAr;
  String nameEn;
  String language;
  String startDate;
  String endDate;
  int status;

  String courseId;
  String courseNameAr;
  String courseNameEn;
  UserExam? userExam;
  Exam({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.language,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.courseId,
    required this.courseNameAr,
    required this.courseNameEn,
    required this.userExam,
  });
}

class ExamFullData {
  String id;

  String nameAr;
  String nameEn;
  String language;
  String startDate;
  String endDate;
  int status; //0 in future 1 going now 2 ended
  double? userMark;
  List<Question> questions;

  String courseId;
  String courseNameAr;
  String courseNameEn;
  ExamFullData({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.language,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.userMark,
    required this.questions,
    required this.courseId,
    required this.courseNameAr,
    required this.courseNameEn,
  });
}

class UserExam {
  String id;

  String examId;
  String examNameAr;
  String examNameEn;

  double mark;

  String createdAt;

  List<dynamic> answers;

  String userId;
  String userName;
  String userImage;

  UserExam({
    required this.id,
    required this.examId,
    required this.examNameAr,
    required this.examNameEn,
    required this.mark,
    required this.createdAt,
    required this.answers,
    required this.userId,
    required this.userName,
    required this.userImage,
  });
}
