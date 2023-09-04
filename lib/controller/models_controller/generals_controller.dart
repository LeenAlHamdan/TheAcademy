import 'dart:ui';

import 'package:get/get.dart';
import 'package:the_academy/data/api/api_client.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/utils/app_contanants.dart';

class GeneralsController extends GetxController {
  Map<String, dynamic> _generals = {};

  Map<String, dynamic> get generals => _generals;

  final ApiClient apiClient = Get.find();

  dynamic getValueByKey(String key) {
    try {
      return generals.entries
          .firstWhere((element) => element.key == key)
          .value['value'];
    } catch (_) {
      return null;
    }
  }

  String get privacyPolicy => Get.locale == const Locale('ar')
      ? getValueByKey('PRIVACY_POLICY_AR') != null
          ? getValueByKey('PRIVACY_POLICY_AR')!.toString()
          : ''
      : getValueByKey('PRIVACY_POLICY_EN') != null
          ? getValueByKey('PRIVACY_POLICY_EN')!.toString()
          : '';

  double get coachSubscriptionFee =>
      getValueByKey('COACH_SUBSCRIPTION_FEE') != null
          ? double.parse(getValueByKey('COACH_SUBSCRIPTION_FEE')!.toString())
          : 0;

  double get privateCourseFee => getValueByKey('PRIVATE_COURSE_FEE') != null
      ? double.parse(getValueByKey('PRIVATE_COURSE_FEE')!.toString())
      : 0;

  Future<void> fetchAndSetGenerals() async {
    try {
      final response1 = await apiClient.getData(AppConstants.generalGet);
      if (response1.statusCode == 200) {
        if (response1.body == null) {
          throw HttpException('error');
        }
        final response1Body = Map<String, dynamic>.from(response1.body);

        final data = response1Body['data'] as Map<String, dynamic>;

        _generals = data;

        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }
}
