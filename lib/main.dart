import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:get/get.dart';
import 'package:the_academy/utils/firebase_message_handler.dart';
import 'package:the_academy/view/screens/add_course_screen.dart';
import 'package:the_academy/view/screens/add_exam_screen.dart';
import 'package:the_academy/view/screens/all_users_evaluation_screen.dart';
import 'package:the_academy/view/screens/all_users_exam_screen.dart';
import 'package:the_academy/view/screens/coach_courses_list_screen.dart';
import 'package:the_academy/view/screens/categories_screen.dart';
import 'package:the_academy/view/screens/profile_screen.dart';
import 'package:the_academy/view/screens/show_privacy_plocity.dart';
import 'package:the_academy/view/screens/transactions_screen.dart';
import 'controller/models_controller/course_controller.dart';
import 'controller/screens_controllers/main_screen_controller.dart';
import 'controller/screens_controllers/my_exams_screen_controller.dart';
import 'locale/locale_controller.dart';
import 'model/http_exception.dart';
import 'services/init_services.dart';
import 'services/user_controller.dart';
import 'view/screens/forget_password_screen.dart';
import 'view/screens/login_screen.dart';
import 'view/screens/main_screen.dart';
import 'view/screens/courses_list_screen.dart';
import 'view/screens/my_exams_screen.dart';
import 'view/screens/one_chat_screen.dart';
import 'view/screens/one_course_of_mine_screen.dart';
import 'view/screens/one_course_screen.dart';
import 'view/screens/sign_up_screen.dart';
import 'view/screens/splash_screen.dart';
import 'view/screens/subjects_screen.dart';
import 'view/screens/subscribe_screen.dart';
import 'view/screens/welcome_screen.dart';

import 'binding/main_screen_binding.dart';
import 'controller/models_controller/category_controller.dart';
import 'controller/models_controller/generals_controller.dart';
import 'controller/models_controller/permission_controller.dart';
import 'controller/models_controller/subject_controller.dart';
import 'controller/screens_controllers/one_exam_screen_controller.dart';
import 'controller/screens_controllers/forget_password_controller.dart';
import 'locale/locale_string.dart';
import 'model/themes.dart';
import 'services/socket_service.dart';
import 'view/screens/one_exam_screen.dart';

Injector injector = Injector();
String? currentConversation;
String? currentCousrse;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await initServices();

  runApp(const MyApp());
}

Future initServices() async {
  InitialServices initialServices = Get.put(InitialServices());
  await initialServices.init();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MyLocaleController localeController = Get.find();
    final UserController userController = Get.find();
    final CategoryController categoryController = Get.find();
    final CourseController courseController = Get.find();
    final PermissionController permissionController = Get.find();
    final GeneralsController generalsController = Get.find();
    final MainScreenController mainScreenController = Get.find();

    return GetMaterialApp(
      title: 'The Academy',
      theme: Themes.customLightTheme,
      darkTheme: Themes.customDarkTheme,
      themeMode: localeController.initMode,
      translations: LocaleString(),
      locale: localeController.initLang,
      home: FutureBuilder(
          future: getData(userController, categoryController, courseController,
              permissionController, generalsController, localeController),
          builder: (ctx, authResultSnapshot) {
            if (authResultSnapshot.hasError) {
              mainScreenController.hasError = true;
              //print(authResultSnapshot.error);
              mainScreenController.hasSignedOut.value =
                  authResultSnapshot.error.toString() == '401';
              return MainScreen();
            }
            return authResultSnapshot.connectionState == ConnectionState.waiting
                ? SplashScreen()
                /*  : authResultSnapshot.hasError
                    ? MainScreen(
                        hasSignedOut:
                            authResultSnapshot.error.toString() == '401')
                 */
                : GetBuilder<UserController>(
                    builder: (userController) =>
                        userController.currentUser.id.isNotEmpty
                            ? localeController.showPrivacyPlocity
                                ? ShowPrivacyPlocityScreen(
                                    fromMain: true,
                                  )
                                : !userController.isUser
                                    ? MainScreen()
                                    : SubscribeScreen()
                            : WelcomeScreen()
                    /* userController.userIsSigned
                      ? localeController.showPrivacyPlocity
                          ? ShowPrivacyPlocityScreen(
                              fromMain: true,
                            )
                          : !userController.isUser
                              ? MainScreen()
                              : SubscribeScreen()
                      : WelcomeScreen() */
                    ,
                  );

            //                      : MainScreen();
          }),
      getPages: [
        GetPage(
            name: '/splash',
            page: () => const SplashScreen(),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.fade),
        GetPage(
            name: '/welcome',
            page: () => const WelcomeScreen(),
            transitionDuration: Duration(milliseconds: 500),
            transition: Get.locale == const Locale('ar')
                ? Transition.leftToRightWithFade
                : Transition.rightToLeftWithFade),
        GetPage(
            name: '/login',
            page: () => LoginScreen(),
            transitionDuration: Duration(milliseconds: 500),
            transition: Get.locale == const Locale('ar')
                ? Transition.leftToRightWithFade
                : Transition.rightToLeftWithFade),
        GetPage(
            name: '/sign-up',
            page: () => const SignUpScreen(),
            transitionDuration: Duration(milliseconds: 500),
            transition: Get.locale == const Locale('ar')
                ? Transition.leftToRightWithFade
                : Transition.rightToLeftWithFade),
        GetPage(
            name: '/forget-passowrd',
            page: () => const ForgetPasswordScreen(),
            binding: BindingsBuilder.put(() => ForgetPasswordController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Get.locale == const Locale('ar')
                ? Transition.leftToRightWithFade
                : Transition.rightToLeftWithFade),
        GetPage(
            name: '/subscribe',
            page: () => SubscribeScreen(),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/main-screen',
            page: () => MainScreen(),
            binding: MainScreenBindings(),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/subjects-screen',
            page: () => SubjectsScreen(),
            binding: BindingsBuilder.put(() => SubjectController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/one-course-screen',
            page: () => OneCourseScreen(),
            //      binding: BindingsBuilder.put(() => OneCourseScreenController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/courses-list-screen',
            page: () => CoursesListScreen(),
            //binding: BindingsBuilder.put(() => CoursesListScreenController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/coach-courses-list-screen',
            page: () => CoachCoursesListScreen(),
            //binding: BindingsBuilder.put(() => CoursesListScreenController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/one-course-of-mine-screen',
            page: () => OneCourseOfMineScreen(),
            /*  binding:
                BindingsBuilder.put(() => OneCourseOfMineScreenController()),
           */
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/my-exams-screen',
            page: () => MyExamsScreen(),
            binding: BindingsBuilder.put(() => MyExamsScreenController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/exam-screen',
            page: () => OneExamScreen(),
            binding: BindingsBuilder.put(() => OneExamScreenController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        /*  GetPage(
            name: '/my-chats-screen',
            page: () => MyChatsScreen(),
            binding: BindingsBuilder.put(() => MyChatsScreenController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp), */
        GetPage(
            name: '/chat-screen',
            page: () => OneChatScreen(),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/privacy-policy-screen',
            page: () => ShowPrivacyPlocityScreen(),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/transactions-screen',
            page: () => TransactionsScreen(),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/add-course-screen',
            page: () => AddCourseScreen(),
            binding: BindingsBuilder.put(() => SubjectController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/add-exam-screen',
            page: () => AddExamScreen(),
//            binding: BindingsBuilder.put(() => SubjectController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/profile-screen',
            page: () => ProfileScreen(),
//            binding: BindingsBuilder.put(() => SubjectController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/categories-screen',
            page: () => CategoriesScreen(),
//            binding: BindingsBuilder.put(() => SubjectController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/all-users-exam-screen',
            page: () => AllUsersExamScreen(),
//            binding: BindingsBuilder.put(() => SubjectController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/all-users-evaluation-screen',
            page: () => AllUsersEvaluationScreen(),
//            binding: BindingsBuilder.put(() => SubjectController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
        GetPage(
            name: '/my-app',
            page: () => MyApp(),
//            binding: BindingsBuilder.put(() => SubjectController()),
            transitionDuration: Duration(milliseconds: 500),
            transition: Transition.downToUp),
      ],
    );
  }

  Future<bool> getData(
    UserController userController,
    CategoryController categoryController,
    CourseController courseController,
    PermissionController permissionController,
    GeneralsController generalsController,
    MyLocaleController localeController,
  ) async {
    if (localeController.futureExecuted) return false;
    try {
      await userController.tryAutoLoginAndFetsh();
      var userId = userController.userId;

      if (userController.userIsSigned) {
        localeController.userSigned.value = true;
        createSocketConnection();
        await categoryController.fetchAndSetCategories(0, isRefresh: true);
        await courseController.fetchAndSetCourses(0, isRefresh: true);
        await courseController.fetchAndSetPublicCourses(0, isRefresh: true);
        if (userController.userCanEditCourse)
          await courseController.fetchAndSetCoachCourses(0, isRefresh: true);

        await courseController.fetchAndSetMyCourses(0, userId, isRefresh: true);
        final FirebaseMessaging messaging = Get.find();
        await initFirebase(messaging);
      } else {
        await Future.delayed(Duration(seconds: 1));
      }

      //   if (userController.isUser || !userController.userIsSigned) {
      await permissionController.fetchAndSetCoachPermission();
      // }
      await generalsController.fetchAndSetGenerals();
      localeController.futureExecuted = userController.userIsSigned;

      return false;
    } on HttpException catch (error) {
      throw error;
    } catch (error) {
      debugPrint(error.toString());
      throw error;
    }
  }

  static void createSocketConnection() {
    if (!SocketService.isInited) {
      final SocketService socketService = injector.get<SocketService>();
      socketService.createSocketConnection();
    }
  }

  static void closeSocketConnection() {
    if (SocketService.isInited) {
      final SocketService socketService = injector.get<SocketService>();
      SocketService.isInited = false;
      socketService.closeSocket();
    }
  }
}
