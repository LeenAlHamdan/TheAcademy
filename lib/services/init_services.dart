import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_academy/controller/models_controller/category_controller.dart';
import 'package:the_academy/controller/models_controller/course_controller.dart';
import 'package:the_academy/controller/screens_controllers/main_screen_controller.dart';
import 'package:the_academy/data/api/api_client.dart';
import 'package:the_academy/locale/locale_controller.dart';
import 'package:the_academy/services/socket_service.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/utils/app_contanants.dart';

import '../controller/models_controller/chat_controller.dart';
import '../controller/models_controller/exam_controller.dart';
import '../controller/models_controller/generals_controller.dart';
import '../controller/models_controller/permission_controller.dart';
import '../firebase_options.dart';
import '../main.dart';
import '../utils/app_initializer.dart';
import '../utils/dependecy_injection.dart';
import '../utils/firebase_message_handler.dart';

class InitialServices extends GetxService {
  late SharedPreferences _sharedPrefs;

  Future<InitialServices> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();

    Get.lazyPut(() => _sharedPrefs);
    Get.lazyPut(() => ApiClient(
        appBaseUrl: AppConstants.host, sharedPreferences: Get.find()));

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin()
          ..initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
          );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    Get.lazyPut(() => messaging, fenix: true);

    FirebaseMessaging.onMessage.listen((event) => firebaseMessagingHandler(
        event, flutterLocalNotificationsPlugin, _sharedPrefs));

    FirebaseMessaging.onMessageOpenedApp.listen((event) =>
        firebaseMessagingHandler(
            event, flutterLocalNotificationsPlugin, _sharedPrefs));

    Get.lazyPut(() => MyLocaleController());
    final userController = Get.put(UserController(
      sharedPreferences: Get.find(),
      apiClient: Get.find(),
    ));
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<CourseController>(() => CourseController());

    Get.lazyPut<MainScreenController>(() => MainScreenController());

    Get.lazyPut<ExamController>(() => ExamController(), fenix: true);
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);

    Get.lazyPut<PermissionController>(
      () => PermissionController(),
    );
    Get.lazyPut<GeneralsController>(
      () => GeneralsController(),
    );
    await userController.tryAutoLogin();

    DependencyInjection().initialise(injector);
    await AppInitializer().initialise(injector);
    final SocketService socketService = injector.get<SocketService>();

    socketService.createSocketConnection();

    return this;
  }

  get sharedPrefs => _sharedPrefs;
}
