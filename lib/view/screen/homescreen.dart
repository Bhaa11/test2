import 'dart:io';

import 'package:ecommercecourse/controller/homescreen_controller.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/view/widget/home/custombottomappbarhome.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(HomeScreenControllerImp());
    return GetBuilder<HomeScreenControllerImp>(
        builder: (controller) => Scaffold(
          bottomNavigationBar: const CustomBottomAppBarHome(),
          body: WillPopScope(child: controller.listPage.elementAt(controller.currentpage),
            onWillPop: () {
              Get.defaultDialog(
                title: "Warning",
                titleStyle: TextStyle(fontWeight: FontWeight.bold),
                middleText: "Do you want to exit the app",
                onCancel: () {},
                cancelTextColor: AppColor.secondColor,
                confirmTextColor: AppColor.secondColor,
                buttonColor: AppColor.thirdColor,
                onConfirm: () {
                  exit(0);
                },);
              return Future.value(false);
            },),
        ));
  }
}
