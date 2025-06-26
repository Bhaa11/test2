import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColor.primaryColor,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  await initialServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeController = Get.put(LocaleController());

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SpeerIQ',

          builder: (context, child) {
            // ✅ إضافة دعم اتجاه النص للكردية والعربية
            final locale = Get.locale ?? localeController.language;
            final isRTL = locale?.languageCode == 'ar' || locale?.languageCode == 'ku';

            return Directionality(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  statusBarColor: AppColor.primaryColor,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
                child: child!,
              ),
            );
          },

          // إعدادات الترجمة
          translations: MyTranslation(),
          locale: localeController.language,
          fallbackLocale: const Locale('ar'),
          theme: localeController.appTheme,

          initialBinding: InitialBindings(),
          getPages: routes,
        );
      },
    );
  }
}
