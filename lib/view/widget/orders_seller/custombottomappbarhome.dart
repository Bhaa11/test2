import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/orders_seller/screen_controller.dart';
import '../home/custombuttonappbarseller.dart';

class CustomBottomAppBarHome extends StatelessWidget {
  const CustomBottomAppBarHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderScreenControllerImp>(
        builder: (controller) => BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                    controller.listPage.length + 1, ((index) {
                  int i = index > 2 ? index - 1 : index;
                  return index == 2
                      ? const SizedBox(width: 40)
                      : CustomButtonAppBar(
                      textbutton: controller.titlebottomappbar[i],
                      icondata: Icons.home,
                      onPressed: () {
                        controller.changePage(i);
                      },
                      active: controller.currentpage == i ? true : false);
                }))
              ],
            )));
  }
}