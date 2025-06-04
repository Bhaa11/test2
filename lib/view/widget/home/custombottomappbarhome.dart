import 'package:ecommercecourse/controller/homescreen_controller.dart';
import 'package:ecommercecourse/view/widget/home/custombuttonappbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBottomAppBarHome extends StatelessWidget {
  const CustomBottomAppBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottomBarHeight =
    MediaQuery.of(context).size.height * 0.075 > 70
        ? 70
        : MediaQuery.of(context).size.height * 0.075;

    return GetBuilder<HomeScreenControllerImp>(
      builder: (controller) => Container(
        height: bottomBarHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              controller.bottomappbar.length,
                  (index) => Expanded(
                child: CustomButtonAppBar(
                  textbutton: controller.bottomappbar[index]['title'],
                  icon: controller.bottomappbar[index]['icon'],
                  filledIcon: controller.bottomappbar[index]['filled_icon'],
                  onPressed: () => controller.changePage(index),
                  active: controller.currentpage == index,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}