import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // استيراد مكتبة Services للتحكم في واجهة النظام
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import 'core/services/services.dart';
import 'core/localization/translation.dart';
import 'core/localization/changelocal.dart';
import 'core/constant/color.dart';
import 'routes.dart';
import 'bindings/intialbindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تعيين لون شريط الحالة (شريط البطارية والبيانات والساعة)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColor.primaryColor, // لون خلفية شريط الحالة
    statusBarIconBrightness: Brightness.dark, // لون الأيقونات داكن (لأن الخلفية فاتحة)
    statusBarBrightness: Brightness.light, // للأجهزة iOS
  ));

  await initialServices();
  // await Jiffy.setLocale('ar'); // لو حاب تفعّل التعريب في Jiffy
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // سجل الـ LocaleController
    final localeController = Get.put(LocaleController());

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ecommerce Course',

          // تكوين شريط الحالة العلوي باستخدام AnnotatedRegion
          builder: (context, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: AppColor.primaryColor,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
              child: child!,
            );
          },

          // ترجمة وتعريب
          translations: MyTranslation(),
          locale: localeController.language,
          theme: localeController.appTheme,

          // ربط الـ DI
          initialBinding: InitialBindings(),

          // تعريف المسارات
          getPages: routes,
        );
      },
    );
  }
}
