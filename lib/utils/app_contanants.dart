class AppConstants {
  static const TOKEN = 'token';

  //api's
  static const host = 'https://theacademyapi.scrollwebapps.com';
  //'http://theacademy.eba-8ajw3bgp.us-east-2.elasticbeanstalk.com';

  static const imagesHost =
      'https://the-academy-assets-public.s3.us-east-2.amazonaws.com';
  //static const environment = 'dev';

  static const name = 'search';
  static const limit = 'limit';
  static const offset = 'offset';

  //Authentication
  static const logIn = 'auth/public/login';
  static const signUp = 'auth/public/sign-up';
  static const restPasswordWithCode = 'auth/public/reset-password';
  static const requestPasswordCode = 'auth/public/request-password-reset-code';
  static const changePassword = 'auth/change-password';
  static const registerAsCoach = 'user/register-as-coach';

  //user
  static const user = 'user';
  static const role = 'role';
  static const code = 'code';

  static const profileImage = 'profile-image';
  static const profileData = 'my-profile';

  static const userId = 'userId';
  static const transactionGet = 'user/my-transaction';

  //Permission
  static const permissionGet = 'user/public/permission';
  static const getPermissionByRole = 'public/permission-by-role';
  //general
  static const generalGet = 'user/public/setting';

//category
  static const categoryGet = 'course/public/category';
  static const categoryId = 'categoryId';

  //subject
  static const subjectGet = 'course/public/subject';
  static const subjectId = 'subjectId';

  //course
  static const course = 'course';
  static const coursesGet = 'course/public';
  static const coachCoursesGet = 'course/my-owned';
  static const getMyEvaluation = 'course/my-evaluation';
  static const courseId = 'courseId';
  static const askToJoinCourse = 'course/ask-to-join';
  static const leaveTheCourse = 'course/remove-from-course';
  static const addUserToCourse = 'course/add-to-course';
  static const setCourseActive = 'course/set-active';
  static const myCourses = 'myCourses';
  static const myPendingCourses = 'myPendingCourses';
  static const active = 'active';
  static const isPrivate = 'isPrivate';
  static const unAccepted = 'unAccepted';
  static const myAllCoursesGet = 'course/my-all';

  //exam
  static const exam = 'course/exam';
  static const allUsersExamEvaluationGet = 'course/evaluation';
  static const allUsersExamGet = 'course/all-user-exam';
  static const userExamsGet = 'course/user-exam';
  static const attendExam = 'course/attend-exam';
  static const examId = 'examId';

  //chat
  static const messagesGet = 'chat/message';
  static const conversationId = 'conversationId';
  static const userPrivateChats = 'chat/conversation';
  static const conversation = 'chat/conversation';
  static const getOneConversation = 'chat/one-conversation';
  static const creatAFile = 'chat/file';
  static const answerPoll = 'chat/poll';
}
