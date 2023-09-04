import 'dart:convert';

import 'package:get/get.dart';
import 'package:the_academy/controller/screens_controllers/add_exam_screen_controller.dart';
import 'package:the_academy/model/exam.dart';
import 'package:the_academy/model/question.dart';

import '../../data/api/api_client.dart';
import '../../model/course.dart';
import '../../model/http_exception.dart';
import '../../utils/app_contanants.dart';

class ExamController extends GetxController {
  final ApiClient apiClient = Get.find();
  final int _limit = 10;

  List<Exam> _exams = [];
  List<int> pages = [];
  int _total = 0;

  List<Exam> _allExams = [];
  List<int> allExamsPages = [];
  int _allExamsTotal = 0;

  List<Exam> _searched = [];
  List<int> pagesSearched = [];
  int _totalSearched = 0;

  List<UserExam> _allUsersExam = [];
  List<int> allUsersExamPages = [];
  int _allUsersExamTotal = 0;

  List<UserEvaluation> _allUsersExamEvaluation = [];
  List<int> allUsersExamEvaluationPages = [];
  int _allUsersExamEvaluationTotal = 0;

  List<UserExam> _userExams = [];
  List<int> userExamsPages = [];
  int _userExamsTotal = 0;

  int get allUsersExamTotal => _allUsersExamTotal;
  int get allUsersExamEvaluationTotal => _allUsersExamEvaluationTotal;
  int get userExamsTotal => _userExamsTotal;
  int get total => _total;
  int get allExamsTotal => _allExamsTotal;
  int get totalSearched => _totalSearched;

  List<Exam> get searched => [..._searched];
  List<Exam> get exams => _exams;
  List<Exam> get allExams => _allExams;
  List<UserExam> get userExams => _userExams;
  List<UserExam> get allUsersExam => _allUsersExam;
  List<UserEvaluation> get allUsersExamEvaluation => _allUsersExamEvaluation;

  Future<void> fetchAndSetAllExams(int pageNum, {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      allExamsPages = [];
      _allExams = [];
    }

    if (allExamsPages.contains(pageNum)) {
      return;
    }

    pages.add(pageNum);

    final offest = allExams.length;

    try {
      final response = await apiClient.getData(
        '${AppConstants.exam}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest',
      );

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _allExamsTotal = extractedData['total'] ?? _allExamsTotal;

        final data = extractedData['data'] as List<dynamic>;
        List<Exam> loadedExams = [];

        for (var exam in data) {
          if (exam['_id'] != null &&
              exam['language'] != null &&
              exam['endDate'] != null &&
              exam['startDate'] != null &&
              exam['nameAr'] != null &&
              exam['nameEn'] != null) {
            var startDate = exam['startDate'];
            var endDate = exam['endDate'];
            var startTime = DateTime.parse(startDate).toLocal();
            var endTime = DateTime.parse(endDate).toLocal();
            var currentTime = DateTime.now().toLocal();

            final userExam = exam['userExam'] != null
                ? UserExam(
                    id: exam['userExam']['_id'],
                    userId: exam['userExam']['user'],
                    userName: '',
                    userImage: '',
                    mark: double.parse(
                        (exam['userExam']['mark'] ?? 0).toString()),
                    createdAt: exam['userExam']['createdAt'],
                    answers: exam['userExam']['answers'],
                    examId: exam['_id'],
                    examNameAr: exam['nameAr'],
                    examNameEn: exam['nameEn'],
                  )
                : null;
            loadedExams.add(Exam(
                id: exam['_id'],
                nameAr: exam['nameAr'],
                nameEn: exam['nameEn'],
                language: exam['language'],
                startDate: startDate,
                endDate: endDate,
                courseId: exam['course']['_id'],
                courseNameAr: exam['course']['nameAr'],
                courseNameEn: exam['course']['nameEn'],
                userExam: userExam,
                status: currentTime.isBefore(startTime)
                    ? 0
                    : currentTime.isAfter(endTime)
                        ? 2
                        : 1));
          }
        }

        if (loadedExams.isNotEmpty) {
          _allExams.addAll(loadedExams);
        } else {
          allExamsPages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      allExamsPages.remove(pageNum);

      rethrow;
    }
  }

  Future<void> fetchAndSetExams(int pageNum, String courseId,
      {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      pages = [];
      _exams = [];
    }

    if (pages.contains(pageNum)) {
      return;
    }

    pages.add(pageNum);

    final offest = exams.length;
    final course = '&${AppConstants.courseId}=$courseId';

    try {
      final response = await apiClient.getData(
          '${AppConstants.exam}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest$course');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _total = extractedData['total'] ?? _total;

        final data = extractedData['data'] as List<dynamic>;

        List<Exam> loadedExams = [];

        for (var exam in data) {
          if (exam['_id'] != null &&
              exam['language'] != null &&
              exam['endDate'] != null &&
              exam['startDate'] != null &&
              exam['nameAr'] != null &&
              exam['nameEn'] != null) {
            var startDate = exam['startDate'];
            var endDate = exam['endDate'];
            var startTime = DateTime.parse(startDate).toLocal();
            var endTime = DateTime.parse(endDate).toLocal();
            var currentTime = DateTime.now().toLocal();

            final userExam = exam['userExam'] != null
                ? UserExam(
                    id: exam['userExam']['_id'],
                    userId: exam['userExam']['user'],
                    userName: '',
                    userImage: '',
                    mark: double.parse(
                        (exam['userExam']['mark'] ?? 0).toString()),
                    createdAt: exam['userExam']['createdAt'],
                    answers: exam['userExam']['answers'],
                    examId: exam['_id'],
                    examNameAr: exam['nameAr'],
                    examNameEn: exam['nameEn'],
                  )
                : null;

            loadedExams.add(Exam(
                id: exam['_id'],
                nameAr: exam['nameAr'],
                nameEn: exam['nameEn'],
                language: exam['language'],
                startDate: startDate,
                endDate: endDate,
                courseId: exam['course']['_id'],
                courseNameAr: exam['course']['nameAr'],
                courseNameEn: exam['course']['nameEn'],
                userExam: userExam,
                status: currentTime.isBefore(startTime)
                    ? 0
                    : currentTime.isAfter(endTime)
                        ? 2
                        : 1));
          }
        }

        if (loadedExams.isNotEmpty) {
          _exams.addAll(loadedExams);
        } else {
          pages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      pages.remove(pageNum);

      rethrow;
    }
  }

  Future<ExamFullData> getExamFullData(String id) async {
    try {
      final response = await apiClient.getData('${AppConstants.exam}/$id');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        final exam = extractedData['data'];

        if (exam['_id'] != null &&
            exam['language'] != null &&
            exam['endDate'] != null &&
            exam['startDate'] != null &&
            exam['nameAr'] != null &&
            exam['nameEn'] != null) {
          List<Question> questions = [];
          final questionsList = exam['questions'] as List<dynamic>;

          for (var question in questionsList) {
            if (question['_id'] != null && question['text'] != null) {
              List<Choice> choices = [];
              final choicesList = question['choices'] as List<dynamic>;
              for (var choice in choicesList) {
                if (choice['_id'] != null && choice['text'] != null) {
                  choices.add(Choice(
                    text: choice['text'],
                    id: choice['_id'],
                    isTrueAnswer: choice['isTrueAnswer'],
                  ));
                }
              }

              questions.add(Question(
                text: question['text'],
                id: question['_id'],
                choices: choices,
              ));
            }
          }
          var startDate = exam['startDate'];
          var endDate = exam['endDate'];

          var startTime = DateTime.parse(startDate).toLocal();
          var endTime = DateTime.parse(endDate).toLocal();
          var currentTime = DateTime.now().toLocal();

          return ExamFullData(
            id: exam['_id'],
            nameAr: exam['nameAr'],
            nameEn: exam['nameEn'],
            language: exam['language'],
            startDate: startDate,
            endDate: endDate,
            courseId: exam['course']['_id'],
            courseNameAr: exam['course']['nameAr'],
            courseNameEn: exam['course']['nameEn'],
            status: currentTime.isBefore(startTime)
                ? 0
                : currentTime.isAfter(endTime)
                    ? 2
                    : 1,
            questions: questions,
          );
        } else {
          throw HttpException('error');
        }
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<double> attendExam(
      String examId, List<Map<String, dynamic>> answers) async {
    try {
      final response = await apiClient.postData(
          AppConstants.attendExam,
          json.encode(
            {
              'examId': examId,
              'answers': answers,
            },
          ));

      final responseData = response.body;

      if (response.statusCode == 201) {
        var data = responseData['userExam'];
        var mark = double.parse((data['mark'] ?? 0).toString());

        var pos = exams.indexWhere(
          (element) => element.id == examId,
        );
        if (pos != -1) {
          exams[pos].userExam = UserExam(
            id: data['_id'],
            examId: data['exam'],
            examNameAr: exams[pos].nameAr,
            examNameEn: exams[pos].nameEn,
            userId: data['user'],
            userName: '',
            userImage: '',
            mark: mark,
            createdAt: data['createdAt'],
            answers: data['answers'],
          );
        }

        pos = allExams.indexWhere(
          (element) => element.id == examId,
        );
        if (pos != -1) {
          allExams[pos].userExam = UserExam(
            id: data['_id'],
            examId: data['exam'],
            examNameAr: allExams[pos].nameAr,
            examNameEn: allExams[pos].nameEn,
            userId: data['user'],
            userName: '',
            userImage: '',
            mark: mark,
            createdAt: data['createdAt'],
            answers: data['answers'],
          );
        }

        pos = searched.indexWhere(
          (element) => element.id == examId,
        );
        if (pos != -1) {
          searched[pos].userExam = UserExam(
            id: data['_id'],
            examId: data['exam'],
            examNameAr: searched[pos].nameAr,
            examNameEn: searched[pos].nameEn,
            userId: data['user'],
            userName: '',
            userImage: '',
            mark: mark,
            createdAt: data['createdAt'],
            answers: data['answers'],
          );
        }
        update();
        return mark;
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetUserExams(int pageNum, {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      userExamsPages = [];
      _userExams = [];
    }

    if (userExamsPages.contains(pageNum)) {
      return;
    }

    userExamsPages.add(pageNum);

    final offest = userExams.length;

    try {
      final response = await apiClient.getData(
          '${AppConstants.userExamsGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _total = extractedData['total'] ?? _total;

        final data = extractedData['data'] as List<dynamic>;

        List<UserExam> loadedExams = [];

        for (var userExam in data) {
          if (userExam['_id'] != null &&
              userExam['exam'] != null &&
              userExam['answers'] != null &&
              userExam['createdAt'] != null) {
            loadedExams.add(UserExam(
              id: userExam['_id'],
              examId: userExam['exam']['_id'],
              examNameAr: userExam['exam']['nameAr'],
              examNameEn: userExam['exam']['nameEn'],
              userId: userExam['user']['_id'],
              userName: userExam['user']['name'],
              userImage: userExam['user']['profileImage'] ?? '',
              mark: double.parse((userExam['mark'] ?? 0).toString()),
              createdAt: userExam['createdAt'],
              answers: userExam['answers'],
            ));
          }
        }

        if (loadedExams.isNotEmpty) {
          _userExams.addAll(loadedExams);
        } else {
          userExamsPages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      userExamsPages.remove(pageNum);
      rethrow;
    }
  }

  Future<void> addExam({
    required String nameAr,
    required String nameEn,
    required String courseId,
    required String language,
    required String startDate,
    required String endDate,
    required List<QuestionItem> questions,
  }) async {
    try {
      List<Map<String, dynamic>> questionsBody = [];

      for (var question in questions) {
        List<Map<String, dynamic>> choicesBody = [];

        for (int i = 0; i < question.options.length; i++) {
          final choice = question.options[i];
          choicesBody.add({
            "text": choice.text,
            "isTrueAnswer": (i == question.trueAnswer),
          });
        }

        questionsBody.add({
          'text': question.title.text,
          'choices': choicesBody,
        });
      }

      final response = await apiClient.postData(
          AppConstants.exam,
          json.encode({
            'nameAr': nameAr,
            'nameEn': nameEn,
            'language': language,
            'courseId': courseId,
            'startDate': startDate,
            'endDate': endDate,
            'questions': questionsBody,
          }));

      if (response.statusCode == 201) {
      } else if (response.statusCode == 402) {
        throw HttpException('Not_enough_funds');
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetAllUserExams(int pageNum, String examId,
      {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh ||
        (allUsersExam.isNotEmpty && allUsersExam.first.examId != examId)) {
      allUsersExamPages = [];
      _allUsersExam = [];
    }

    if (allUsersExamPages.contains(pageNum)) {
      return;
    }

    allUsersExamPages.add(pageNum);

    final offest = _allUsersExam.length;
    final exam1 = '&${AppConstants.examId}=$examId';

    try {
      final response = await apiClient.getData(
          '${AppConstants.allUsersExamGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest$exam1');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _allUsersExamTotal = extractedData['total'] ?? _allUsersExamTotal;

        final data = extractedData['data'] as List<dynamic>;

        List<UserExam> loadedExams = [];

        for (var userExam in data) {
          if (userExam['_id'] != null &&
              userExam['exam'] != null &&
              userExam['answers'] != null &&
              userExam['createdAt'] != null) {
            loadedExams.add(UserExam(
              id: userExam['_id'],
              examId: userExam['exam']['_id'],
              examNameAr: userExam['exam']['nameAr'],
              examNameEn: userExam['exam']['nameEn'],
              userId: userExam['user']['_id'],
              userName: userExam['user']['name'],
              userImage: userExam['user']['profileImage'] ?? '',
              mark: double.parse((userExam['mark'] ?? 0).toString()),
              createdAt: userExam['createdAt'],
              answers: userExam['answers'],
            ));
          }
        }

        if (loadedExams.isNotEmpty) {
          _allUsersExam.addAll(loadedExams);
        } else {
          allUsersExamPages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      allUsersExamPages.remove(pageNum);

      rethrow;
    }
  }

  Future<void> fetchAndSetAllUserExamsEvaluation(
    /* int pageNum, */ String courseId,
    //{bool? isRefresh}
  ) async {
    /* if (isRefresh != null && isRefresh) {
      allUsersExamEvaluationPages = [];
      _allUsersExamEvaluation = [];
    }

    if (allUsersExamEvaluationPages.contains(pageNum)) {
      return;
    }

    allUsersExamEvaluationPages.add(pageNum);
 
    final offest = _allUsersExamEvaluation.length;
 */
    final course = '${AppConstants.courseId}=$courseId';

    try {
      final response = await apiClient
          .getData('${AppConstants.allUsersExamEvaluationGet}?$course');
      //'${AppConstants.allUsersExamEvaluationGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest$exam1');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        //  _allUsersExamEvaluationTotal = extractedData['total'] ?? _allUsersExamEvaluationTotal;

        final data = extractedData['data'] as List<dynamic>;

        List<UserEvaluation> loadedExams = [];

        var examsCount = extractedData['examsCount'];

        for (var userExam in data) {
          if (userExam['user']['_id'] != null &&
              userExam['user']['name'] != null &&
              userExam['markSum'] != null) {
            final markSum = double.parse(userExam['markSum'].toString());
            loadedExams.add(UserEvaluation(
              examsCount: examsCount,
              markSum: markSum,
              examCount: examsCount,
              evaluation: examsCount != 0 ? markSum / examsCount : 0,
              userId: userExam['user']['_id'],
              userName: userExam['user']['name'],
              userImage: userExam['user']['profileImage'] ?? '',
            ));
          }
        }

        if (loadedExams.isNotEmpty) {
          _allUsersExamEvaluation = (loadedExams);
        } else {
          // allUsersExamEvaluationPages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      //allUsersExamEvaluationPages.remove(pageNum);

      rethrow;
    }
  }

  Future<void> deleteExam(String id) async {
    try {
      final response = await apiClient.deleteData(
        '${AppConstants.exam}/$id',
      );

      if (response.statusCode == 204) {
        final itemIndex = exams.indexWhere((item) => item.id == id);
        if (itemIndex != -1) exams.removeAt(itemIndex);
        final itemIndex2 = userExams.indexWhere((item) => item.id == id);
        if (itemIndex2 != -1) userExams.removeAt(itemIndex2);

        final itemIndex3 = searched.indexWhere((item) => item.id == id);
        if (itemIndex3 != -1) searched.removeAt(itemIndex3);
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }
}
