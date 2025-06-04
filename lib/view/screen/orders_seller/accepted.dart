
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../controller/orders_seller/acceteped_controller.dart';
import '../../../core/class/handlingdataview.dart';
import '../../widget/orders_seller/orderslistcardaccepted.dart';

class OrdersAccepted extends StatelessWidget {
  const OrdersAccepted({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(OrdersAcceptedController());
    return Scaffold(
        body: Container(
          padding:const  EdgeInsets.all(10),
          child: GetBuilder<OrdersAcceptedController>(
              builder: ((controller) => HandlingDataView(statusRequest: controller.statusRequest, widget: ListView.builder(
                itemCount: controller.data.length,
                itemBuilder: ((context, index) =>
                    CardOrdersListAccepted(listdata: controller.data[index])),
              )))),
        ));
  }
}
