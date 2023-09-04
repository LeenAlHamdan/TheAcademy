import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/main.dart';
import 'package:the_academy/services/user_controller.dart';

import '../controller/screens_controllers/chat_screen_controller.dart';
import '../controller/screens_controllers/one_course_controller.dart';
import '../controller/screens_controllers/one_course_of_mine_screen_controller.dart';
import '../model/message.dart';
import 'handle_pending_messages.dart';

Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  firebaseMessagingHandler(message, FlutterLocalNotificationsPlugin(),
      await SharedPreferences.getInstance());
}

handleLoad(Map<String, dynamic> load) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (load.containsKey('course')) {
      if (load['active'] && load['accepted']) {
        final oneCourseOfMineScreenController =
            Get.put(OneCourseOfMineScreenController());
        (oneCourseOfMineScreenController).updateCourseId(
          load['course'],
          load['title'],
          load['image'],
          initTab: load['initTab'],
        );

        Get.toNamed(
          '/one-course-of-mine-screen', /*  arguments: {
          'id': load['course'],
          'tilte': load['title'],
          'image': load['image'],
          'initTab': load['initTab'],
        } */
        );
      } else {
        final oneCourseScreenController = Get.put(OneCourseScreenController());
        (oneCourseScreenController).updateCourseId(load['course']);

        Get.toNamed(
          '/one-course-screen', /* arguments: {'id': load['course']} */
        );
      }
      if (load['event'] == 'courseActivation') {
        final CourseController courseController = Get.find();
        courseController.updateCourse(load['course'], load['active']);
      }
    } else if (load.containsKey('conversationId')) {
      final oneChatScreenController = Get.put(ChatScreenController());
      (oneChatScreenController).updateUserId(
        load['userId'],
        load['title'],
        load['image'],
        conversationId: load['conversationId'],
      );

      Get.toNamed(
        '/chat-screen', /* arguments: {
        "conversationId": load['conversationId'],
        'userId': load['userId'],
        'title': load['title'],
        'image': load['image'],
      } */
      );
    }
  });
}

void onDidReceiveBackgroundNotificationResponse(String? payload) async {
  if (payload != null && payload.isNotEmpty) {
    final load = jsonDecode(payload) as Map<String, dynamic>;
    handleLoad(load);
  }
}

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (payload != null && payload.isNotEmpty) {
    //print(payload);
    final load = jsonDecode(payload) as Map<String, dynamic>;
    handleLoad(load);
  }
  //if (message.data != null && message.data.isNotEmpty) handleMessageData(message.data,flutterLocalNotificationsPlugin,sharedPrefs)
}

handleNewMessageNotification(
    Map<String, dynamic> data,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    SharedPreferences sharedPrefs) {
  {
    String? payload;
    String title;
    String body;

    final msg = jsonDecode(data['result']) as Map<String, dynamic>;
    final message = msg['message'] as Map<String, dynamic>;
    if ((message['conversation']?['_id'] != null &&
            message['conversation']?['_id'] == currentConversation) ||
        (message['course']?['_id'] != null &&
            message['course']?['_id'] == currentCousrse)) return;
    final initLang = sharedPrefs.getString('lang') == null
        ? Get.deviceLocale == const Locale('ar')
            ? const Locale('ar')
            : const Locale('en')
        : Locale(sharedPrefs.getString('lang')!);

    final userId = sharedPrefs.getString('userData') != null
        ? json.decode(sharedPrefs.getString('userData')!)['userId']
        : null;
    if (message['sender']['_id'] == userId) return;
    if ((message['type'] != MyMessageType.text.name &&
            message['type'] != MyMessageType.image.name &&
            message['type'] != MyMessageType.voice.name) &&
        (message['type'] == MyMessageType.file.name &&
            message['course'] != null)) {
      title = initLang == const Locale('ar')
          ? 'تم إضافة عنصر جديد'
          : 'New Feed Added';
      final type = message['type'] == 'file'
          ? initLang == const Locale('ar')
              ? 'ملف'
              : 'file'
          : message['type'] == 'location'
              ? initLang == const Locale('ar')
                  ? 'موقع'
                  : 'location'
              : message['type'] == 'slides'
                  ? initLang == const Locale('ar')
                      ? 'مجموعة صور'
                      : 'slides'
                  : initLang == const Locale('ar')
                      ? 'تصويت'
                      : 'poll ';

      String from = message['sender']['name'];
      body = '$from ${'added_a'.tr} $type';
      if (message['course']?['_id'] != null)
        payload = jsonEncode({
          'course': message['course']?['_id'],
          'active': message['course']?['active'] ?? true,
          'accepted': message['course']?['accepted'] ?? true,
          'title': Get.locale == const Locale('ar')
              ? (message['course']?['nameAr'])
              : (message['course']?['nameEn']),
          'image': (message['course']?['image']) ?? '',
        });
    } else {
      //print(' matching');

      if (message['contents']?.first['config']?['tempId'] != null) {
        handelPendnigMessages(
            message['contents']?.first['config']?['tempId'], Get.find());
      }

      title = initLang == const Locale('ar') ? 'رسالة جديدة' : 'New Message';
      final courseName = Get.locale == const Locale('ar')
          ? (message['course']?['nameAr'])
          : (message['course']?['nameEn']);
      String from = courseName ?? message['sender']['name'];
      String msg = message['contents'].first['data'];
      body = '$from: $msg';

      var courseId = message['course']?['_id'];
      payload = (courseId != null)
          ? jsonEncode({
              'course': courseId,
              'active': message['course']?['active'] ?? true,
              'accepted': message['course']?['accepted'] ?? true,
              'title': Get.locale == const Locale('ar')
                  ? (message['course']?['nameAr'])
                  : (message['course']?['nameEn']),
              'image': (message['course']?['image']) ?? '',
              'initTab': OneCourseOfMineScreenController.chatTabIndex
            })
          : jsonEncode({
              'conversationId': message['conversation']?['_id'],
              'userId': message['sender']['_id'],
              'title': message['sender']['name'],
              'image': message['sender']['profileImage'],
            });
    }

    var android = AndroidNotificationDetails('channel ID', 'channel NAME',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'logo',
        ticker: 'ticker');
    var ios = const DarwinNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: ios);

    flutterLocalNotificationsPlugin.show(
      title.hashCode,
      title,
      body,
      platform,
      payload: payload,
    );
  }
}

Future<void> firebaseMessagingHandler(
  RemoteMessage message,
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  SharedPreferences sharedPrefs,
) async {
  RemoteNotification? notification = message.notification;
  String? payload;

  // ignore: unnecessary_null_comparison
  if (message.data != null && message.data.isNotEmpty)
    payload = handleMessageData(
        message.data, flutterLocalNotificationsPlugin, sharedPrefs);
  if (notification != null &&
      notification.title != null &&
      notification.body != null) {
    /* print(
              'Message also contained a notification: ${notification.hashCode} ${notification.title} ${notification.body}')ك */

    //AndroidNotification? android = message.notification?.android;

    var android = AndroidNotificationDetails(
        notification.android?.channelId ?? 'channel ID', 'channel NAME',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'logo',
        ticker: 'ticker');
    var ios = const DarwinNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: ios);

    flutterLocalNotificationsPlugin
        .show(
          notification.hashCode,
          notification.title,
          notification.body,
          platform,
          payload: payload,
        )
        .catchError((error) => debugPrint('error $error'));
  }
}

String? handleMessageData(
    Map<String, dynamic> data,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    SharedPreferences sharedPrefs) {
  String? payload;
  //print('message arrrived ${message.data}');
  var event = data['event'];
  if (event == 'newCourse' ||
      event == 'courseActivation' ||
      event == 'userJoin' ||
      event == 'userRemove' ||
      event == 'userAskToJoin') {
    if (data['course'] != null) {
      final course = jsonDecode(data['course']);
      payload = jsonEncode({
        'event': event,
        'course': course?['_id'],
        'active': event == 'userJoin' ||
                event == 'userRemove' ||
                event == 'userAskToJoin'
            ? false
            : course?['active'] ?? false,
        'accepted': course?['accepted'] ?? false,
        'title': Get.locale == const Locale('ar')
            ? (course?['nameAr'])
            : (course?['nameEn']),
        'image': (course?['image']) ?? '',
      });
    }
  } else if (event == 'newExam') {
    final exam = jsonDecode(data['exam']) as Map<String, dynamic>;
    final course = exam['course'] as Map<String, dynamic>;
    payload = jsonEncode({
      'event': event,
      'course': course['_id'],
      'active': true,
      'accepted': true,
      'title': Get.locale == const Locale('ar')
          ? (course['nameAr'])
          : (course['nameEn']),
      'image': (course['image']) ?? '',
      'initTab': OneCourseOfMineScreenController.examTabIndex
    });
  } else if (event == 'userMessage' || event == 'courseMessage') {
    handleNewMessageNotification(
        data, flutterLocalNotificationsPlugin, sharedPrefs);
  }
  /* print(
               'Message also contained a data: ${message.hashCode} ${message.data} '); */

  return payload;
}

Future<void> subscribeTopics(FirebaseMessaging fcm) async {
  await fcm.subscribeToTopic('all_topic'.tr);
  final UserController userProv = Get.find();
  final CourseController courseController = Get.find();

  if (userProv.userIsSigned) {
    await fcm.subscribeToTopic(userProv.userId);

    await fcm
        .subscribeToTopic('${userProv.userId}-${Get.locale!.languageCode}');
    await courseController.fetchAndSetMyCoursesId(isRefresh: true);
    await subscribeToMultipleTopicsWithLan(
        courseController.myCoursesIds, Get.locale!.languageCode);
  }
}

Future<void> initFirebase(FirebaseMessaging fcm) async {
  await subscribeTopics(fcm);

  NotificationSettings settings = await fcm.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    sound: true,
    provisional: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    //print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    //      print('User granted provisional permission');
  } else {
    //    print('User declined or has not accepted permission');
  }
}

Future<void> unsubscribeFromMultipleTopics(List<String> topics) async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  for (String topic in topics.toList()) {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

Future<void> unsubscribeFromMultipleTopicsWithLan(
    List<String> topics, String lang) async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  for (String topic in topics.toList()) {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    await _firebaseMessaging.unsubscribeFromTopic('$topic-$lang');
  }
}

Future<void> subscribeFromMultipleTopics(List<String> topics) async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  for (String topic in topics.toList()) {
    await _firebaseMessaging.subscribeToTopic(topic);
  }
}

Future<void> subscribeToMultipleTopicsWithLan(List<String> topics, String lang,
    {bool myCourses = false}) async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  for (String topic in topics.toList()) {
    await _firebaseMessaging.subscribeToTopic(topic);
    await _firebaseMessaging.subscribeToTopic('$topic-$lang');
  }
}
