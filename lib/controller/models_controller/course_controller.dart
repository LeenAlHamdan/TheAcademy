import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_academy/data/api/api_client.dart';
import 'package:the_academy/model/course.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/model/user.dart';
import 'package:the_academy/utils/app_contanants.dart';

class CourseController extends GetxController {
  List<Course> _courses = [];

  List<int> pages = [];
  int _total = 0;

  final int _limit = 10;

  int get total => _total;

  final ApiClient apiClient = Get.find();

  List<Course> _myCourses = [];
  List<String> _myCoursesIds = [];

  List<int> myCoursesPages = [];
  int _myCoursesTotal = 0;

  int get myCoursesTotal => _myCoursesTotal;

  List<Course> _coachCourses = [];

  List<int> coachCoursesPages = [];
  int _coachCoursesTotal = 0;

  int get coachCoursesTotal => _coachCoursesTotal;
  List<Course> get coachCourses => _coachCourses;

  List<Course> _subjectCourses = [];

  List<int> subjectPages = [];
  int _subjectTotal = 0;

  List<Course> _publicCourses = [];

  List<int> publicPages = [];
  int _publicTotal = 0;

  List<Course> _searched = [];
  List<int> pagesSearched = [];
  int _totalSearched = 0;

  List<Course> get searched => [..._searched];

  int get subjectTotal => _subjectTotal;
  int get totalSearched => _totalSearched;
  List<Course> get subjectCourses => _subjectCourses;

  int get publicTotal => _publicTotal;
  List<Course> get publicCourses => _publicCourses;

  List<Course> get courses {
    return _courses;
  }

  List<Course> get myCourses {
    return _myCourses;
  }

  List<String> get myCoursesIds => _myCoursesIds;

  List<Course> get myActiveCourses {
    return _myCourses.where((element) => element.active).toList();
  }

  Future<void> updateCourse(
    String courseId,
    bool active,
  ) async {
    try {
      // bool? active;
      var _coursesItem =
          _courses.firstWhereOrNull((element) => element.id == courseId);
      // active = _coursesItem?.active;
      var _myCoursesItem =
          _myCourses.firstWhereOrNull((element) => element.id == courseId);
      // active = active ?? _myCoursesItem?.active;

      var _publicCoursesItem =
          _publicCourses.firstWhereOrNull((element) => element.id == courseId);
      //   active = active ?? _publicCoursesItem?.active;

      var _subjectCoursesItem =
          _subjectCourses.firstWhereOrNull((element) => element.id == courseId);
      //    active = active ?? _subjectCoursesItem?.active;

      var _coachCoursesItem =
          _coachCourses.firstWhereOrNull((element) => element.id == courseId);
      var _searchedItem =
          _searched.firstWhereOrNull((element) => element.id == courseId);
      // active = active ?? _coachCoursesItem?.active;

      //if (active == null) return;

      _coursesItem?.active = active;
      _myCoursesItem?.active = active;
      _publicCoursesItem?.active = active;
      _subjectCoursesItem?.active = active;
      _coachCoursesItem?.active = active;
      _searchedItem?.active = active;
      update();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateCourseUsers(
    String courseId,
    String userId,
    bool add,
  ) async {
    try {
      // bool? active;
      var _coursesItem =
          _courses.firstWhereOrNull((element) => element.id == courseId);
      // active = _coursesItem?.active;
      var _myCoursesItem =
          _myCourses.firstWhereOrNull((element) => element.id == courseId);
      // active = active ?? _myCoursesItem?.active;

      var _publicCoursesItem =
          _publicCourses.firstWhereOrNull((element) => element.id == courseId);
      //   active = active ?? _publicCoursesItem?.active;

      var _subjectCoursesItem =
          _subjectCourses.firstWhereOrNull((element) => element.id == courseId);
      //    active = active ?? _subjectCoursesItem?.active;

      var _coachCoursesItem =
          _coachCourses.firstWhereOrNull((element) => element.id == courseId);
      var _searchedItem =
          _searched.firstWhereOrNull((element) => element.id == courseId);
      // active = active ?? _coachCoursesItem?.active;

      //if (active == null) return;
      if (add) {
        _coursesItem?.users.add(userId);
        _myCoursesItem?.users.add(userId);
        _publicCoursesItem?.users.add(userId);
        _subjectCoursesItem?.users.add(userId);
        _coachCoursesItem?.users.add(userId);
        _searchedItem?.users.add(userId);
      } else {
        _coursesItem?.users.remove(
          userId,
        );
        _myCoursesItem?.users.remove(
          userId,
        );
        _publicCoursesItem?.users.remove(
          userId,
        );
        _subjectCoursesItem?.users.remove(
          userId,
        );
        _coachCoursesItem?.users.remove(
          userId,
        );
        _searchedItem?.users.remove(
          userId,
        );
      }
      update();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> toggleActiveCourse(
    String courseId,
    bool active,
  ) async {
    try {
      final response = await apiClient.patchData(
          '${AppConstants.setCourseActive}',
          json.encode(
            {
              'active': active,
              'courseId': courseId,
            },
          ));

      if (response.statusCode == 200) {
        _courses.firstWhereOrNull((element) => element.id == courseId)?.active =
            active;
        _myCourses
            .firstWhereOrNull((element) => element.id == courseId)
            ?.active = active;
        _publicCourses
            .firstWhereOrNull((element) => element.id == courseId)
            ?.active = active;
        _subjectCourses
            .firstWhereOrNull((element) => element.id == courseId)
            ?.active = active;

        _coachCourses
            .firstWhereOrNull((element) => element.id == courseId)
            ?.active = active;
        _searched
            .firstWhereOrNull((element) => element.id == courseId)
            ?.active = active;
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<CourseFullData> getCourseFullData(String id, String userId) async {
    try {
      final response =
          await apiClient.getData('${AppConstants.coursesGet}/$id');

      //print(response.statusCode);
      //print(response.body);
      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        final course = extractedData['data'];

        if (course['_id'] != null &&
            course['image'] != null &&
            course['nameAr'] != null &&
            course['nameEn'] != null) {
          List<CourseUser> users = [];
          final usersList = course['users'] as List<dynamic>;
          //print(usersList);

          for (var user in usersList) {
            if (user['_id'] != null &&
                user['name'] != null &&
                user['email'] != null) {
              users.add(CourseUser(
                email: user['email'],
                name: user['name'],
                id: user['_id'],
                isOnline: user['isOnline'],
                profileImageUrl: user['profileImage'] ?? '',
              ));
            }
          }
          //print(users.length);

          List<CourseUser> pendingUsers = [];
          final pendingUsersList = course['pendingUsers'] as List<dynamic>;
          for (var user in pendingUsersList) {
            if (user['_id'] != null &&
                user['name'] != null &&
                user['email'] != null) {
              pendingUsers.add(CourseUser(
                email: user['email'],
                name: user['name'],
                id: user['_id'],
                profileImageUrl: user['profileImage'] ?? '',
                isOnline: user['isOnline'],
              ));
            }
          }

          final isTheCoach = userId == course['owner']['_id'];
          final userEvaluation =
              isTheCoach ? null : await getUserEvaluation(id);

          return CourseFullData(
            id: course['_id'],
            nameAr: course['nameAr'],
            nameEn: course['nameEn'],
            descriptionAr: course['descriptionAr'],
            descriptionEn: course['descriptionEn'],
            image: course['image'],
            coachId: course['owner']['_id'],
            coachName: course['owner']['name'],
            isPrivate: course['isPrivate'],
            subjectId: course['subject']?['_id'] ?? '',
            subjectNameAr: course['subject']?['nameAr'] ?? "",
            subjectNameEn: course['subject']?['nameEn'] ?? '',
            active: course['active'],
            accepted: course['accepted'],
            coachImage: course['owner']['profileImage'] ?? '',
            users: users,
            pendingUsers: pendingUsers,
            userEvaluation: userEvaluation,
          );
        } else {
          //print(' else1');

          throw HttpException('error');
        }
      } else {
        //print(' else12');

        throw HttpException('error');
      }
    } catch (error) {
      //print(error);

      rethrow;
    }
  }

  Future<UserEvaluation?> getUserEvaluation(String courseId) async {
    try {
      final response = await apiClient.getData(
          '${AppConstants.getMyEvaluation}?${AppConstants.courseId}=$courseId');
      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        final data = extractedData['data'];
        var examsCount = extractedData['examsCount'];
        if (examsCount == 0 || data['markSum'] == null) return null;

        final markSum = double.parse(data['markSum'].toString());
        final examCount = data['examCount'];
        return UserEvaluation(
          examsCount: examsCount,
          markSum: markSum,
          examCount: examCount,
          evaluation: examCount != 0 ? markSum / examCount : 0,
          userId: data['user']['_id'],
          userName: data['user']['name'],
          userImage: data['user']['profileImage'] ?? '',
        );
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      debugPrint(error.toString());

      rethrow;
    }
  }

  Future<void> fetchAndSetCourses(int pageNum,
      {String? subjectId, bool isRefresh = false}) async {
    if (isRefresh) {
      if (subjectId != null) {
        subjectPages = [];
        _subjectCourses = [];
      } else {
        pages = [];
        _courses = [];
      }
      update();
    }
    if (subjectId != null) {
      if (subjectPages.contains(pageNum)) {
        return;
      }
    } else if (pages.contains(pageNum)) {
      return;
    }

    if (subjectId != null) {
      subjectPages.add(pageNum);
    } else
      pages.add(pageNum);
    final offest = subjectId != null ? subjectCourses.length : courses.length;
    final subject =
        subjectId != null ? '&${AppConstants.subjectId}=$subjectId' : '';

    try {
      final response = await apiClient.getData(
          '${AppConstants.coursesGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest$subject');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }

        final extractedData = Map<String, dynamic>.from(response.body);
        if (subjectId != null)
          _subjectTotal = extractedData['total'] ?? _subjectTotal;
        else
          _total = extractedData['total'] ?? _total;
        final data = extractedData['data'] as List<dynamic>;

        List<Course> loadedCourses = [];

        for (var course in data) {
          if (course['_id'] != null &&
              course['image'] != null &&
              course['nameAr'] != null &&
              course['nameEn'] != null) {
            List<String> users = [];
            final usersList = course['users'] as List<dynamic>;

            for (var user in usersList) {
              users.add(user);
            }

            List<String> pendingUsers = [];
            final pendingUsersList = course['pendingUsers'] as List<dynamic>;

            for (var user in pendingUsersList) {
              pendingUsers.add(user);
            }
            loadedCourses.add(Course(
              id: course['_id'],
              nameAr: course['nameAr'],
              nameEn: course['nameEn'],
              descriptionAr: course['descriptionAr'],
              descriptionEn: course['descriptionEn'],
              image: course['image'],
              coachId: course['owner']['_id'],
              coachName: course['owner']['name'],
              isPrivate: course['isPrivate'],
              subjectId: course['subject']?['_id'] ?? '',
              subjectNameAr: course['subject']?['nameAr'] ?? "",
              subjectNameEn: course['subject']?['nameEn'] ?? '',
              active: course['active'],
              accepted: course['accepted'],
              users: users,
              pendingUsers: pendingUsers,
            ));
          }
        }

        if (loadedCourses.isNotEmpty) {
          if (subjectId != null)
            _subjectCourses.addAll(loadedCourses);
          else
            _courses.addAll(loadedCourses);
        } else {
          if (subjectId != null)
            _subjectCourses.remove(pageNum);
          else
            pages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      _subjectCourses.remove(pageNum);

      rethrow;
    }
  }

  Future<void> fetchAndSetPublicCourses(int pageNum,
      {bool isRefresh = false}) async {
    if (isRefresh) {
      publicPages = [];
      _publicCourses = [];
      update();
    }
    if (publicPages.contains(pageNum)) {
      return;
    }

    publicPages.add(pageNum);
    final offest = publicCourses.length;
    final public = '&isPrivate=false';

    try {
      final response = await apiClient.getData(
          '${AppConstants.coursesGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest$public');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _publicTotal = extractedData['total'] ?? _publicTotal;

        final data = extractedData['data'] as List<dynamic>;

        List<Course> loadedCourses = [];

        for (var course in data) {
          if (course['_id'] != null &&
              course['image'] != null &&
              course['nameAr'] != null &&
              course['nameEn'] != null) {
            List<String> users = [];
            final usersList = course['users'] as List<dynamic>;
            for (var user in usersList) {
              users.add(user);
            }
            List<String> pendingUsers = [];
            final pendingUsersList = course['pendingUsers'] as List<dynamic>;

            for (var user in pendingUsersList) {
              pendingUsers.add(user);
            }
            loadedCourses.add(Course(
              id: course['_id'],
              nameAr: course['nameAr'],
              nameEn: course['nameEn'],
              descriptionAr: course['descriptionAr'],
              descriptionEn: course['descriptionEn'],
              image: course['image'],
              coachId: course['owner']['_id'],
              coachName: course['owner']['name'],
              isPrivate: course['isPrivate'],
              subjectId: course['subject']?['_id'] ?? '',
              subjectNameAr: course['subject']?['nameAr'] ?? "",
              subjectNameEn: course['subject']?['nameEn'] ?? '',
              active: course['active'],
              accepted: course['accepted'],
              users: users,
              pendingUsers: pendingUsers,
            ));
          }
        }

        if (loadedCourses.isNotEmpty) {
          _publicCourses.addAll(loadedCourses);
        } else {
          publicPages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      publicPages.remove(pageNum);

      rethrow;
    }
  }

  Future<void> fetchAndSetMyCoursesId({bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      _myCoursesIds = [];
    }

    try {
      final response =
          await apiClient.getData('${AppConstants.myAllCoursesGet}');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        final data = extractedData['data'] as List<dynamic>;

        List<String> loadedId = [];

        for (var course in data) {
          if (course['_id'] != null) {
            loadedId.add(
              course['_id'],
            );
          }
        }

        if (loadedId.isNotEmpty) {
          _myCoursesIds.addAll(loadedId);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetMyCourses(int pageNum, String userId,
      {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      myCoursesPages = [];
      _myCourses = [];
    }

    if (myCourses.contains(pageNum)) {
      return;
    }

    myCoursesPages.add(pageNum);

    final offest = myCourses.length;

    try {
      final response = await apiClient.getData(
          '${AppConstants.coursesGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest&${AppConstants.myCourses}=true&${AppConstants.userId}=$userId');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _myCoursesTotal = extractedData['total'] ?? _myCoursesTotal;

        final data = extractedData['data'] as List<dynamic>;

        List<Course> loadedCourses = [];

        for (var course in data) {
          if (course['_id'] != null &&
              course['image'] != null &&
              course['nameAr'] != null &&
              course['nameEn'] != null) {
            List<String> users = [];
            final usersList = course['users'] as List<dynamic>;
            for (var user in usersList) {
              users.add(user);
            }
            List<String> pendingUsers = [];
            final pendingUsersList = course['pendingUsers'] as List<dynamic>;

            for (var user in pendingUsersList) {
              pendingUsers.add(user);
            }
            loadedCourses.add(Course(
              id: course['_id'],
              nameAr: course['nameAr'],
              nameEn: course['nameEn'],
              descriptionAr: course['descriptionAr'],
              descriptionEn: course['descriptionEn'],
              image: course['image'],
              coachId: course['owner']['_id'],
              coachName: course['owner']['name'],
              isPrivate: course['isPrivate'],
              subjectId: course['subject']?['_id'] ?? '',
              subjectNameAr: course['subject']?['nameAr'] ?? "",
              subjectNameEn: course['subject']?['nameEn'] ?? '',
              active: course['active'],
              accepted: course['accepted'],
              users: users,
              pendingUsers: pendingUsers,
            ));
          }
        }

        if (loadedCourses.isNotEmpty) {
          _myCourses.addAll(loadedCourses);
        } else {
          myCoursesPages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      myCoursesPages.remove(pageNum);

      rethrow;
    }
  }

  Future<void> fetchAndSetCoachCourses(int pageNum, {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      coachCoursesPages = [];
      _coachCourses = [];
    }

    if (coachCourses.contains(pageNum)) {
      return;
    }

    coachCoursesPages.add(pageNum);

    final offest = coachCourses.length;

    try {
      final response = await apiClient.getData(
          '${AppConstants.coachCoursesGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _coachCoursesTotal = extractedData['total'] ?? _coachCoursesTotal;

        final data = extractedData['data'] as List<dynamic>;

        List<Course> loadedCourses = [];

        for (var course in data) {
          if (course['_id'] != null &&
              course['image'] != null &&
              course['nameAr'] != null &&
              course['nameEn'] != null) {
            List<String> users = [];
            final usersList = course['users'] as List<dynamic>;
            for (var user in usersList) {
              users.add(user);
            }
            List<String> pendingUsers = [];
            final pendingUsersList = course['pendingUsers'] as List<dynamic>;

            for (var user in pendingUsersList) {
              pendingUsers.add(user);
            }
            loadedCourses.add(Course(
                id: course['_id'],
                nameAr: course['nameAr'],
                nameEn: course['nameEn'],
                descriptionAr: course['descriptionAr'],
                descriptionEn: course['descriptionEn'],
                image: course['image'],
                coachId: course['owner']['_id'],
                coachName: course['owner']['name'],
                isPrivate: course['isPrivate'],
                subjectId: course['subject']?['_id'] ?? '',
                subjectNameAr: course['subject']?['nameAr'] ?? "",
                subjectNameEn: course['subject']?['nameEn'] ?? '',
                active: course['active'],
                accepted: course['accepted'],
                users: users,
                pendingUsers: pendingUsers));
          }
        }

        if (loadedCourses.isNotEmpty) {
          _coachCourses.addAll(loadedCourses);
        } else {
          coachCoursesPages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      coachCoursesPages.remove(pageNum);

      rethrow;
    }
  }

  Future<void> askToJoinToCourse(String id) async {
    try {
      final response =
          await apiClient.patchData('${AppConstants.askToJoinCourse}/$id', {});
      if (response.statusCode != 200) {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> leaveTheCourse(
    String courseId,
    String userId,
  ) async {
    try {
      final response = await apiClient.patchData(
          '${AppConstants.leaveTheCourse}',
          json.encode(
            {
              'userId': userId,
              'courseId': courseId,
            },
          ));

      if (response.statusCode != 200) {
        throw HttpException('error');
      }
      var course = courses.firstWhereOrNull(
        (element) => element.id == courseId,
      );
      if (course != null) {
        var pos = course.users.indexWhere(
          (element) => element == userId,
        );
        if (pos != -1) {
          courses.removeAt(pos);
        }

        pos = course.pendingUsers.indexWhere(
          (element) => element == userId,
        );
        if (pos != -1) {
          courses.removeAt(pos);
        }
      }

      course = publicCourses.firstWhereOrNull(
        (element) => element.id == courseId,
      );
      if (course != null) {
        var pos = course.users.indexWhere(
          (element) => element == userId,
        );
        if (pos != -1) {
          courses.removeAt(pos);
        }

        pos = course.pendingUsers.indexWhere(
          (element) => element == userId,
        );
        if (pos != -1) {
          courses.removeAt(pos);
        }
      }
      course = coachCourses.firstWhereOrNull(
        (element) => element.id == courseId,
      );
      if (course != null) {
        var pos = course.users.indexWhere(
          (element) => element == userId,
        );
        if (pos != -1) {
          courses.removeAt(pos);
        }

        pos = course.pendingUsers.indexWhere(
          (element) => element == userId,
        );
        if (pos != -1) {
          courses.removeAt(pos);
        }
      }
      course = subjectCourses.firstWhereOrNull(
        (element) => element.id == courseId,
      );
      if (course != null) {
        var pos = course.users.indexWhere(
          (element) => element == userId,
        );
        if (pos != -1) {
          courses.removeAt(pos);
        }

        pos = course.pendingUsers.indexWhere(
          (element) => element == userId,
        );
        if (pos != -1) {
          courses.removeAt(pos);
        }
      }
      course = searched.firstWhereOrNull(
        (element) => element.id == courseId,
      );
      if (course != null) {
        var pos = course.users.indexWhere(
          (element) => element == userId,
        );
        if (pos != -1) {
          courses.removeAt(pos);
        }

        pos = course.pendingUsers.indexWhere(
          (element) => element == userId,
        );
        if (pos != -1) {
          courses.removeAt(pos);
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> acceptUserInCourse(
    String courseId,
    String userId,
  ) async {
    try {
      final response = await apiClient.patchData(
          '${AppConstants.addUserToCourse}',
          json.encode(
            {
              'userId': userId,
              'courseId': courseId,
            },
          ));

      if (response.statusCode != 200) {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> search(
    String name,
    int pageNum,
    String userId, {
    int? lim,
    String? subjectId,
    bool? isMyCourses,
    bool? isMyPendingCourses,
    bool? isActive,
    bool? isUnAccepted,
    bool? isPrivate,
    bool isRefresh = false,
    bool isCoach = false,
  }) async {
    if (searched.isEmpty) {
      pagesSearched = [];
    } else if (searched.isNotEmpty || isRefresh) {
      pagesSearched = [];
      _searched = [];
    }

    if (searched.isNotEmpty && pagesSearched.contains(pageNum)) {
      return;
    }

    final search = name != '' ? '&${AppConstants.name}=$name' : '';
    final offest = searched.length;
    final limit = lim ?? _limit;
    final user = '&${AppConstants.userId}=$userId';
    final myCourses = isMyCourses != null && isMyCourses
        ? '&${AppConstants.myCourses}=true'
        : '';
    final myPendingCourses = isMyPendingCourses != null && isMyPendingCourses
        ? '&${AppConstants.myPendingCourses}=true'
        : '';

    final active = isActive != null ? '&${AppConstants.active}=$isActive' : '';
    final private = isPrivate != null && isPrivate
        ? '&${AppConstants.isPrivate}=$isPrivate'
        : '';

    final unAccepted = isUnAccepted != null && isUnAccepted
        ? '&${AppConstants.unAccepted}=$isUnAccepted'
        : '';
    final subject =
        subjectId != null ? '&${AppConstants.subjectId}=$subjectId' : '';

    try {
      var uri = isCoach
          ? '${AppConstants.coachCoursesGet}?${AppConstants.limit}=$limit&${AppConstants.offset}=$offest$search$active$private$unAccepted$subject'
          : '${AppConstants.coursesGet}?${AppConstants.limit}=$limit&${AppConstants.offset}=$offest$search$myCourses$subject$myPendingCourses$active$user';
      final response = await apiClient.getData(uri);

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _totalSearched = extractedData['total'] ?? _totalSearched;

        final data = extractedData['data'] as List<dynamic>;

        List<Course> loadedCourses = [];

        for (var course in data) {
          if (course['_id'] != null &&
              course['image'] != null &&
              course['nameAr'] != null &&
              course['nameEn'] != null) {
            List<String> users = [];
            final usersList = course['users'] as List<dynamic>;
            for (var user in usersList) {
              users.add(user);
            }
            List<String> pendingUsers = [];
            final pendingUsersList = course['pendingUsers'] as List<dynamic>;

            for (var user in pendingUsersList) {
              pendingUsers.add(user);
            }
            loadedCourses.add(Course(
                id: course['_id'],
                nameAr: course['nameAr'],
                nameEn: course['nameEn'],
                descriptionAr: course['descriptionAr'],
                descriptionEn: course['descriptionEn'],
                image: course['image'],
                coachId: course['owner']['_id'],
                coachName: course['owner']['name'],
                isPrivate: course['isPrivate'],
                subjectId: course['subject']?['_id'] ?? '',
                subjectNameAr: course['subject']?['nameAr'] ?? '',
                subjectNameEn: course['subject']?['nameEn'] ?? '',
                active: course['active'],
                accepted: course['accepted'],
                users: users,
                pendingUsers: pendingUsers));
          }
        }

        if (pagesSearched.contains(pageNum)) return;

        _searched.addAll(loadedCourses);
        update();

        if (loadedCourses.isNotEmpty) {
          pagesSearched.add(pageNum);
        }
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      debugPrint(error.toString());
      throw error;
    }
  }

  Future<void> addCourse({
    required String nameAr,
    required String nameEn,
    required String descriptionAr,
    required String descriptionEn,
    required String subjectId,
    required bool isPrivate,
    required File image,
  }) async {
    try {
      final response = await apiClient.multiPartWithFields(
          uri: AppConstants.course,
          file: image,
          type: 'POST',
          fileName: 'image',
          fields: {
            'nameAr': nameAr,
            'nameEn': nameEn,
            'descriptionAr': descriptionAr,
            'descriptionEn': descriptionEn,
            'subjectId': subjectId,
            'isPrivate': isPrivate.toString(),
          });

      if (response.statusCode == 201) {
        // _currentUser.profileImageUrl = user['profileImage'];
      } else if (response.statusCode == 402) {
        throw HttpException('Not_enough_funds');
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateCourseData(
    String courseId, {
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? subjectId,
    bool? isPrivate,
    File? image,
  }) async {
    try {
      final response = await apiClient.multiPartWithFields(
          uri: "${AppConstants.course}/$courseId",
          file: image,
          type: 'PATCH',
          fileName: 'image',
          fields: {
            if (nameAr != null) 'nameAr': nameAr,
            if (nameEn != null) 'nameEn': nameEn,
            if (descriptionAr != null) 'descriptionAr': descriptionAr,
            if (descriptionEn != null) 'descriptionEn': descriptionEn,
            if (subjectId != null) 'subjectId': subjectId,
            if (isPrivate != null) 'isPrivate': isPrivate.toString(),
          });

      if (response.statusCode == 200) {
        var _coursesItem =
            _courses.firstWhereOrNull((element) => element.id == courseId);
        var _myCoursesItem =
            _myCourses.firstWhereOrNull((element) => element.id == courseId);
        var _publicCoursesItem = _publicCourses
            .firstWhereOrNull((element) => element.id == courseId);
        var _subjectCoursesItem = _subjectCourses
            .firstWhereOrNull((element) => element.id == courseId);
        var _coachCoursesItem =
            _coachCourses.firstWhereOrNull((element) => element.id == courseId);
        var _searchedItem =
            _searched.firstWhereOrNull((element) => element.id == courseId);
        if (nameAr != null) {
          _coursesItem?.nameAr = nameAr;
          _myCoursesItem?.nameAr = nameAr;
          _publicCoursesItem?.nameAr = nameAr;
          _subjectCoursesItem?.nameAr = nameAr;
          _coachCoursesItem?.nameAr = nameAr;
          _searchedItem?.nameAr = nameAr;
        }
        if (nameEn != null) {
          _coursesItem?.nameEn = nameEn;
          _myCoursesItem?.nameEn = nameEn;
          _publicCoursesItem?.nameEn = nameEn;
          _subjectCoursesItem?.nameEn = nameEn;
          _coachCoursesItem?.nameEn = nameEn;
          _searchedItem?.nameEn = nameEn;
        }
        if (descriptionAr != null) {
          _coursesItem?.descriptionAr = descriptionAr;
          _myCoursesItem?.descriptionAr = descriptionAr;
          _publicCoursesItem?.descriptionAr = descriptionAr;
          _subjectCoursesItem?.descriptionAr = descriptionAr;
          _coachCoursesItem?.descriptionAr = descriptionAr;
          _searchedItem?.descriptionAr = descriptionAr;
        }

        if (descriptionEn != null) {
          _coursesItem?.descriptionEn = descriptionEn;
          _myCoursesItem?.descriptionEn = descriptionEn;
          _publicCoursesItem?.descriptionEn = descriptionEn;
          _subjectCoursesItem?.descriptionEn = descriptionEn;
          _coachCoursesItem?.descriptionEn = descriptionEn;
          _searchedItem?.descriptionEn = descriptionEn;
        }

        if (isPrivate != null) {
          _coursesItem?.isPrivate = isPrivate;
          _myCoursesItem?.isPrivate = isPrivate;
          _publicCoursesItem?.isPrivate = isPrivate;
          _subjectCoursesItem?.isPrivate = isPrivate;
          _coachCoursesItem?.isPrivate = isPrivate;
          _searchedItem?.isPrivate = isPrivate;
        }
        update();

        // _currentUser.profileImageUrl = user['profileImage'];
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }
}
