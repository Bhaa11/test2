import 'package:ecommercecourse/view/screen/home.dart';
import 'package:ecommercecourse/view/screen/myfavorite.dart';
import 'package:ecommercecourse/view/screen/notification.dart';
import 'package:ecommercecourse/view/screen/offfers.dart';
import 'package:ecommercecourse/view/screen/profilepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view/screen/ordersall.dart';
import 'home_controller.dart';

// 1. في ملف homescreen_controller.dart
abstract class HomeScreenController extends GetxController {
  changePage(int currentpage);
  bool isAtTop();
  void scrollToTop();
  void refreshHomeData();
  void showExitSnackbar();
}

class HomeScreenControllerImp extends HomeScreenController {
  int currentpage = 0;
  bool canExit = false;
  ScrollController? homeScrollController;

  List<Widget> listPage = [
    const HomePage(),
    OrdersAll(),
    OffersView(),
    ProfilePage()
  ];

  List<Map<String, dynamic>> bottomappbar = [
    {
      "title": "الرئيسية".tr,
      "icon": Icons.home_outlined,
      "filled_icon": Icons.home_rounded,
    },
    {
      "title": "طلباتي".tr,
      "icon": Icons.receipt_long_outlined,
      "filled_icon": Icons.receipt_long,
    },
    {
      "title": "الرسائل".tr,
      "icon": Icons.chat_bubble_outline,
      "filled_icon": Icons.chat_bubble,
    },

    {
      "title": "حسابي".tr,
      "icon": Icons.person_outline,
      "filled_icon": Icons.person,
    },
  ];

  @override
  changePage(int i) {
    currentpage = i;
    canExit = false; // إعادة تعيين حالة الخروج عند تغيير الصفحة
    update();
  }

  @override
  bool isAtTop() {
    if (homeScrollController == null) return true;
    return homeScrollController!.offset <= 0;
  }

  @override
  void scrollToTop() {
    if (homeScrollController != null) {
      homeScrollController!.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void refreshHomeData() {
    // الحصول على HomeController وتحديث البيانات
    try {
      final homeController = Get.find<HomeControllerImp>();
      homeController.refreshData();
    } catch (e) {
      print('Error refreshing home data: $e');
    }
  }

  @override
  void showExitSnackbar() {
    // تحديث البيانات أولاً
    refreshHomeData();

    // ثم إظهار رسالة الخروج
    Get.rawSnackbar(
      messageText: Text(
        'اضغط مرة أخرى للخروج'.tr,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      backgroundColor: Colors.black87,
      duration: const Duration(seconds: 2),
      borderRadius: 8,
      margin: const EdgeInsets.all(15),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void setScrollController(ScrollController controller) {
    homeScrollController = controller;
  }
}
