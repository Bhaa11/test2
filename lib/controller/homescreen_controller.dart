import 'package:ecommercecourse/view/screen/home.dart';
import 'package:ecommercecourse/view/screen/myfavorite.dart';
import 'package:ecommercecourse/view/screen/notification.dart';
import 'package:ecommercecourse/view/screen/offfers.dart';
import 'package:ecommercecourse/view/screen/profilepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view/screen/ordersall.dart';

// 1. في ملف homescreen_controller.dart
abstract class HomeScreenController extends GetxController {
  changePage(int currentpage);
}

class HomeScreenControllerImp extends HomeScreenController {
  int currentpage = 0;

  List<Widget> listPage = [
    const HomePage(),
    OrdersAll(),
    OffersView(),
    ProfilePage()
  ];

  List<Map<String, dynamic>> bottomappbar = [
    {
      "title": "الرئيسية",
      "icon": Icons.home_outlined,
      "filled_icon": Icons.home_rounded,
    },
    {
      "title": "طلباتي",
      "icon": Icons.receipt_long_outlined,
      "filled_icon": Icons.receipt_long,
    },
    {
      "title": "العروض",
      "icon": Icons.local_offer_outlined,
      "filled_icon": Icons.local_offer_rounded,
    },
    {
      "title": "حسابي",
      "icon": Icons.person_outline,
      "filled_icon": Icons.person,
    },
  ];

  @override
  changePage(int i) {
    currentpage = i;
    update();
  }
}