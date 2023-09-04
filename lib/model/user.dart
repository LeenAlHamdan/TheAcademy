import 'permission.dart';

class User {
  final String id;
  final double balance;
  final String name;
  final String email;
  String? password;
  String profileImageUrl;
  int role;

  List<Permission> permissions;

  User({
    required this.email,
    required this.balance,
    this.password,
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.role,
    required this.permissions,
  });
}

class CourseUser {
  final String id;
  final String name;
  final String email;
  String profileImageUrl;
  bool isOnline;

  CourseUser({
    required this.email,
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.isOnline,
  });
}
