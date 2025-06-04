import 'package:ecommercecourse/controller/orders/pending_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/view/widget/orders/orderslistcard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersPending extends StatelessWidget {
  final String orderType;

  const OrdersPending({Key? key, this.orderType = "0"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(OrdersPendingController());

    return GetBuilder<OrdersPendingController>(
      builder: (controller) => HandlingDataView(
        statusRequest: controller.statusRequest,
        widget: Container(
          padding: const EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: controller.filteredData(orderType).length,
            itemBuilder: (context, index) =>
                CardOrdersList(listdata: controller.filteredData(orderType)[index]),
          ),
        ),
      ),
    );
  }
}
