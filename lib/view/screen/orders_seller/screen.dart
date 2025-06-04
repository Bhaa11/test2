
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/orders_seller/screen_controller.dart';
import '../../widget/home/custombottomappbarhome.dart';



class OrderScreen extends StatelessWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(OrderScreenControllerImp());
    return GetBuilder<OrderScreenControllerImp>(
        builder: (controller) => Scaffold(
          appBar: AppBar(title: Text("Orders")),
          // floatingActionButton: FloatingActionButton(
          //     onPressed: () {},
          //     child: const Icon(Icons.shopping_basket_outlined)),
          bottomNavigationBar: const CustomBottomAppBarHome(),
          body: controller.listPage.elementAt(controller.currentpage),
        ));
  }
}
