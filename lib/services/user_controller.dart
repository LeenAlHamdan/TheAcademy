import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_academy/data/api/api_client.dart';
import 'package:the_academy/main.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/model/permission.dart';
import 'package:the_academy/model/user.dart';
import 'package:the_academy/utils/app_contanants.dart';

class UserController extends GetxController {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;

  UserController({required this.sharedPreferences, required this.apiClient});
  String _token = '';
  String _userId = '';
  User _currentUser = User(
    id: '',
    email: '',
    password: '',
    name: '',
    balance: 0,
    profileImageUrl: '',
    role: 1, // userRole,
    permissions: [],
  );

  static int userRole = 1;
  static int coachRole = 2;
  static int adminRole = 3;
  static int managerRole = 4;

  String get userId => _userId;

  User get currentUser => _currentUser;

  String get token => _token;

  bool get isAdmin => _currentUser.role == adminRole;

  bool get isCoach => _currentUser.role == coachRole;

  bool get isUser => _currentUser.role == userRole;

  bool get isManager => _currentUser.role == managerRole;

  bool get userIsSigned => _token != '';

  bool get userCanEditCourse =>
      _currentUser.permissions
          .firstWhereOrNull((permission) => permission.id == 'EDIT_COURSE') !=
      null;

  bool get userCanRBAC =>
      _currentUser.permissions
          .firstWhereOrNull((permission) => permission.id == 'RBAC') !=
      null;
  bool get userCanAcceptCourses =>
      _currentUser.permissions
          .firstWhereOrNull((permission) => permission.id == 'ACCEPT_COURSE') !=
      null;

  bool get userCanEditExams =>
      _currentUser.permissions
          .firstWhereOrNull((permission) => permission.id == 'EDIT_EXAM') !=
      null;

  bool get userCanControlData =>
      _currentUser.permissions
          .firstWhereOrNull((permission) => permission.id == 'CONTROL_DATA') !=
      null;
  bool get userCanRemoveCourseUsers =>
      _currentUser.permissions
          .firstWhereOrNull((permission) => permission.id == 'EDIT_COURSE') !=
      null;
  //   _currentUser.permissions
  //       .firstWhereOrNull((permission) => permission.id == 'CONTROL_DATA') !=
  //   null;

  bool get userCanPayments =>
      _currentUser.permissions
          .firstWhereOrNull((permission) => permission.id == 'PAYMENTS') !=
      null;

  bool get userCanAttendExams =>
      _currentUser.permissions
          .firstWhereOrNull((permission) => permission.id == 'ATTEND_EXAM') !=
      null;

  void signOut() {
    _currentUser = User(
      id: '',
      email: '',
      password: '',
      name: '',
      balance: 0,
      profileImageUrl: '',
      role: userRole,
      permissions: [],
    );
    update();

    _token = '';
    _userId = '';

    sharedPreferences.remove('userData');
    sharedPreferences.remove(
      AppConstants.TOKEN,
    );

    MyApp.closeSocketConnection();
  }

  Future<void> logIn(String email, String password) async {
    try {
      final response = await apiClient.postData(
          AppConstants.logIn,
          json.encode(
            {
              'email': email,
              'password': password,
            },
          ));

      final responseData = response.body;

      if (response.statusCode == 477) {
        throw HttpException('EMAIL_NOT_FOUND');
      } else if (response.statusCode == 401) {
        throw HttpException('INVALID_PASSWORD');
      } else if (response.statusCode! >= 400) {
        throw HttpException('ERROR');
      }

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['token'];
      _userId = responseData['user']['id'];
      var role = responseData['user']['role'];

      final response1 = await apiClient.getData(
          '${AppConstants.user}/${AppConstants.getPermissionByRole}?${AppConstants.role}=$role');

      if (response1.statusCode == 200) {
        if (response1.body == null) {
          throw HttpException('error');
        }
        final response1Body = Map<String, dynamic>.from(response1.body);

        final data = response1Body['data'] as Map<String, dynamic>;
        List<Permission> loadedPermissions = [];
        data.keys.forEach((key) {
          final permission = data[key];

          if (permission['nameAr'] != null && permission['nameEn'] != null) {
            loadedPermissions.add(Permission(
              id: key,
              nameAr: permission['nameAr'],
              nameEn: permission['nameEn'],
            ));
          }
        });
        _currentUser = User(
            email: responseData['user']['email'],
            name: responseData['user']['name'],
            id: _userId,
            password: password,
            profileImageUrl: responseData['user']['profileImage'] ?? '',
            balance: double.parse(responseData['user']['balance'].toString()),
            role: role,
            permissions: loadedPermissions);
        update();
      } else {
        throw HttpException('error');
      }

      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'name': _currentUser.name,
          'role': _currentUser.role,
          'email': _currentUser.email,
          'profileImageUrl': _currentUser.profileImageUrl,
          'balance': _currentUser.balance,
        },
      );
      sharedPreferences.setString('userData', userData);
      sharedPreferences.setString(AppConstants.TOKEN, token);
    } catch (error) {
      throw error;
    }
  }

  Future<void> tryAutoLogin() async {
    if (!sharedPreferences.containsKey('userData')) {
      _token = '';
    }

    var userData = sharedPreferences.getString('userData');
    if (userData == null) return;

    final extractedUserData = json.decode(userData) as Map<String, dynamic>;

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    String email = extractedUserData['email'];
    String name = extractedUserData['name'];
    String profileImageUrl = extractedUserData['profileImageUrl'] ?? '';
    var balance = extractedUserData['balance'] ?? 0;
    var role =
        extractedUserData['role'] != null ? extractedUserData['role'] : 0;

    _currentUser = User(
      email: email,
      name: name,
      profileImageUrl: profileImageUrl,
      id: _userId,
      balance: balance,
      role: role,
      password: '',
      permissions: [],
    );
  }

  Future<bool> tryAutoLoginAndFetsh() async {
    if (!sharedPreferences.containsKey('userData')) {
      _token = '';
      return false;
    }

    final extractedUserData =
        json.decode(sharedPreferences.getString('userData')!)
            as Map<String, dynamic>;

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    String email = extractedUserData['email'];
    String name = extractedUserData['name'];
    String profileImageUrl = extractedUserData['profileImageUrl'] ?? '';
    var balance = extractedUserData['balance'] ?? 0;
    var role =
        extractedUserData['role'] != null ? extractedUserData['role'] : 0;

    _currentUser = User(
      email: email,
      name: name,
      profileImageUrl: profileImageUrl,
      id: _userId,
      balance: balance,
      role: role,
      password: '',
      permissions: [],
    );

    try {
      await fetchProfile();

      return true;
    } on HttpException catch (error) {
      throw error;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchProfile() async {
    String email = _currentUser.email;
    String profileImageUrl = _currentUser.profileImageUrl;
    int role = _currentUser.role;
    String name = _currentUser.name;
    double balance = _currentUser.balance;
    try {
      final response = await apiClient
          .getData('${AppConstants.user}/${AppConstants.profileData}');
      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final responseBody = Map<String, dynamic>.from(response.body);

        final responseData = responseBody['data'];
        email = responseData['email'] ?? email;
        profileImageUrl = responseData['profileImage'] ?? profileImageUrl;
        role = responseData['role'] ?? role;
        name = responseData['name'] ?? name;
        balance = responseData['balance'] != null
            ? double.parse(responseData['balance'].toString())
            : balance;
        final response1 = await apiClient.getData(
            '${AppConstants.user}/${AppConstants.getPermissionByRole}?${AppConstants.role}=$role');
        if (response1.statusCode == 200) {
          if (response1.body == null) {
            throw HttpException('error');
          }
          final response1Body = Map<String, dynamic>.from(response1.body);

          final data = response1Body['data'] as Map<String, dynamic>;
          List<Permission> loadedPermissions = [];
          data.keys.forEach((key) {
            final permission = data[key];

            if (permission['nameAr'] != null && permission['nameEn'] != null) {
              loadedPermissions.add(Permission(
                id: key,
                nameAr: permission['nameAr'],
                nameEn: permission['nameEn'],
              ));
            }
          });

          final userData = json.encode(
            {
              'token': _token,
              'userId': _userId,
              'name': _currentUser.name,
              'role': _currentUser.role,
              'email': _currentUser.email,
              'profileImageUrl': _currentUser.profileImageUrl,
              'balance': _currentUser.balance,
            },
          );
          sharedPreferences.setString('userData', userData);
          sharedPreferences.setString(AppConstants.TOKEN, token);

          _currentUser = User(
            email: email,
            name: name,
            profileImageUrl: profileImageUrl,
            id: _userId,
            balance: balance,
            role: role,
            permissions: loadedPermissions,
          );
          update();
        } else {
          throw HttpException('error');
        }
      } else if (response.statusCode == 401) {
        signOut();
        throw HttpException('401');
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await apiClient.postData(
          AppConstants.signUp,
          json.encode(
            {
              'email': email,
              'password': password,
              'name': name,
            },
          ));

      final responseData = response.body;

      if (response.statusCode == 201) {
        _token = responseData['token'];
        _userId = responseData['user']['id'];
        var role = responseData['user']['role'] ?? userRole;
        final response1 = await apiClient.getData(
            '${AppConstants.user}/${AppConstants.getPermissionByRole}?${AppConstants.role}=$role');
        if (response1.statusCode == 200) {
          if (response1.body == null) {
            throw HttpException('error');
          }
          final response1Body = Map<String, dynamic>.from(response1.body);

          final data = response1Body['data'] as Map<String, dynamic>;
          List<Permission> loadedPermissions = [];
          data.keys.forEach((key) {
            final permission = data[key];

            if (permission['nameAr'] != null && permission['nameEn'] != null) {
              loadedPermissions.add(Permission(
                id: key,
                nameAr: permission['nameAr'],
                nameEn: permission['nameEn'],
              ));
            }
          });

          _currentUser = User(
            email: responseData['user']['email'],
            name: responseData['user']['name'],
            id: _userId,
            password: password,
            balance: 0,
            profileImageUrl: responseData['user']['profileImage'] ?? '',
            role: role,
            permissions: loadedPermissions,
          );
          update();
        } else {
          throw HttpException('error');
        }
        final userData = json.encode(
          {
            'token': _token,
            'userId': _userId,
            'name': _currentUser.name,
            'role': _currentUser.role,
            'email': _currentUser.email,
            'profileImageUrl': _currentUser.profileImageUrl,
            'balance': _currentUser.balance,
          },
        );
        sharedPreferences.setString('userData', userData);
        sharedPreferences.setString(AppConstants.TOKEN, token);
      } else if (response.statusCode == 412) {
        throw HttpException('EMAIL_EXISTS');
      } else if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      } else if (response.statusCode! >= 400) {
        throw HttpException('ERROR');
      } else {
        throw HttpException('ERROR');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> requestPasswordCode(
    String email,
  ) async {
    try {
      final response = await apiClient.postData(
          AppConstants.requestPasswordCode,
          json.encode(
            {
              'email': email,
            },
          ));

      final responseData = response.body;
      if (response.statusCode == 477) {
        throw HttpException('EMAIL_NOT_FOUND');
      } else if (response.statusCode! >= 400) {
        throw HttpException('ERROR');
      }

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> restPasswordWithCode(
      String email, String newPassword, String code) async {
    try {
      final response = await apiClient.postData(
          '${AppConstants.restPasswordWithCode}?${AppConstants.code}=$code',
          json.encode(
            {
              'email': email,
              'newPassword': newPassword,
            },
          ));

      final responseData = response.body;

      if (response.statusCode == 477) {
        throw HttpException('EMAIL_NOT_FOUND');
      } else if (response.statusCode == 400) {
        throw HttpException('INVAILD_CODE');
      } else if (response.statusCode! >= 400) {
        throw HttpException('ERROR');
      }

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await apiClient.postData(
          '${AppConstants.changePassword}',
          json.encode(
            {
              'oldPassword': oldPassword,
              'newPassword': newPassword,
            },
          ));

      final responseData = response.body;

      if (response.statusCode == 401) {
        throw HttpException('INVALID_PASSWORD');
      }

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProfileImage(File file) async {
    try {
      final response = await apiClient.multiPart(
          uri: '${AppConstants.user}/${AppConstants.profileImage}',
          file: file,
          type: 'PATCH',
          fileName: 'profileImage');

      final responseData = response.body;

      if (response.statusCode == 200) {
        final user = response.body as Map<String, dynamic>;

        _currentUser.profileImageUrl = user['profileImage'];

        final userData = json.encode(
          {
            'token': _token,
            'userId': _userId,
            'name': _currentUser.name,
            'role': _currentUser.role,
            'email': _currentUser.email,
            'profileImageUrl': _currentUser.profileImageUrl,
            'balance': _currentUser.balance,
          },
        );
        sharedPreferences.setString('userData', userData);
        update();
      } else {
        throw HttpException('error');
      }

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> registerAsCoach() async {
    try {
      final response =
          await apiClient.patchData(AppConstants.registerAsCoach, {});

      final responseData = response.body;

      if (response.statusCode == 402) {
        throw HttpException('Not_enough_funds');
      } else if (response.statusCode! >= 400) {
        throw HttpException('ERROR');
      }

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      rethrow;
    }
  }
}
