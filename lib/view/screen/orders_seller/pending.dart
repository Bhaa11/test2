
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/orders_seller/pending_controller.dart';
import '../../../core/class/handlingdataview.dart';
import '../../widget/orders_seller/orderslistcard.dart';

class OrdersPendingSeller extends StatelessWidget {
  const OrdersPendingSeller({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(OrdersPendingSellerController());
    return Scaffold(
        body: Container(
          padding:const  EdgeInsets.all(10),
          child: GetBuilder<OrdersPendingSellerController>(
              builder: ((controller) => HandlingDataView(statusRequest: controller.statusRequest, widget: ListView.builder(
                itemCount: controller.data.length,
                itemBuilder: ((context, index) =>
                    CardOrdersList(listdata: controller.data[index])),
              )))),
        ));
  }
}
