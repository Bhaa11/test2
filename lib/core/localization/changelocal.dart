import 'package:ecommercecourse/core/constant/apptheme.dart';
import 'package:ecommercecourse/core/functions/fcmconfig.dart';
import 'package:ecommercecourse/core/services/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleController extends GetxController {
  Locale? language;
  MyServices myServices = Get.find();
  ThemeData appTheme = themeEnglish;

  changeLang(String langcode) {
    Locale locale = Locale(langcode);
    myServices.sharedPreferences.setString("lang", langcode);

    // ✅ إضافة دعم الكردية في التيمة
    if (langcode == "ar") {
      appTheme = themeArabic;
    } else if (langcode == "ku") {
      appTheme = themeArabic; // الكردية تستخدم نفس تيمة العربية (RTL)
    } else {
      appTheme = themeEnglish;
    }

    Get.changeTheme(appTheme);
    Get.updateLocale(locale);

    // ✅ تحديد اتجاه النص صراحة
    if (langcode == "ar" || langcode == "ku") {
      Get.forceAppUpdate(); // لإعادة بناء التطبيق مع الاتجاه الجديد
    }

    update();
  }

  @override
  void onInit() {
    requestPermissionNotification();
    fcmconfig();

    String? sharedPrefLang = myServices.sharedPreferences.getString("lang");
    if (sharedPrefLang == "ar") {
      language = const Locale("ar");
      appTheme = themeArabic;
    } else if (sharedPrefLang == "en") {
      language = const Locale("en");
      appTheme = themeEnglish;
    } else if (sharedPrefLang == "ku") { // ✅ إضافة دعم الكردية
      language = const Locale("ku");
      appTheme = themeArabic;
    } else {
      String deviceLang = Get.deviceLocale?.languageCode ?? 'ar';
      if (deviceLang == 'ar') {
        language = const Locale("ar");
        appTheme = themeArabic;
      } else if (deviceLang == 'ku') {
        language = const Locale("ku");
        appTheme = themeArabic;
      } else {
        language = Locale(deviceLang);
        appTheme = themeEnglish;
      }
    }
    super.onInit();
  }
}
