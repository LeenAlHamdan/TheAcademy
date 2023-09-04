import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLocaleController extends GetxController {
  late SharedPreferences _sharedPrefs;
  late Locale initLang;
  late ThemeMode initMode;
  bool showPrivacyPlocity = false;
  bool futureExecuted = false;
  RxBool userSigned = false.obs;

  MyLocaleController() {
    _sharedPrefs = Get.find();
    if (!_sharedPrefs.containsKey('#agreedPrivacyPlocity')) {
      showPrivacyPlocity = true;
    }
    initLang = _sharedPrefs.getString('lang') == null
        ? Get.deviceLocale == const Locale('ar')
            ? const Locale('ar')
            : const Locale('en')
        : Locale(_sharedPrefs.getString('lang')!);
    var theme = _sharedPrefs.getString('theme');
    initMode = theme != null
        ? theme == 'dark'
            ? ThemeMode.dark
            : ThemeMode.light
        : ThemeMode.system;
  }

  setPrivacyPlocity(bool showPrivacyPlocity) {
    _sharedPrefs.setString('#agreedPrivacyPlocity', 'done');
    showPrivacyPlocity = false;
  }

  Future<void> updateLanguage(String codelang) async {
    Locale locale = Locale(codelang);
    _sharedPrefs.setString('lang', codelang);
    await Get.updateLocale(locale);
  }
}
