import 'dart:io';

import 'package:ecommercecourse/controller/homescreen_controller.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/view/widget/home/custombottomappbarhome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(HomeScreenControllerImp());
    return GetBuilder<HomeScreenControllerImp>(
      builder: (controller) => Scaffold(
        bottomNavigationBar: const CustomBottomAppBarHome(),
        body: WillPopScope(
          child: controller.listPage.elementAt(controller.currentpage),
          onWillPop: () async {
            // إذا كان المستخدم ليس في الصفحة الرئيسية، اعده إلى الصفحة الرئيسية
            if (controller.currentpage != 0) {
              controller.changePage(0);
              return false;
            }
            // إذا كان في الصفحة الرئيسية
            else {
              // التحقق من موضع السكرول
              if (!controller.isAtTop()) {
                // إذا لم يكن في الأعلى، اذهب إلى الأعلى وحدث البيانات واعرض رسالة الخروج
                controller.scrollToTop();
                controller.refreshHomeData();
                controller.showExitSnackbar();
                controller.canExit = true;
                return false;
              } else {
                // إذا كان في الأعلى، تحقق من إمكانية الخروج
                if (controller.canExit) {
                  // الخروج من التطبيق
                  SystemNavigator.pop();
                  return true;
                } else {
                  // إظهار رسالة الخروج وتحديث البيانات وتمكين الخروج للمرة القادمة
                  controller.showExitSnackbar();
                  controller.canExit = true;
                  return false;
                }
              }
            }
          },
        ),
      ),
    );
  }
}
