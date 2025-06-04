
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/orders_seller/archive_controller.dart';
import '../../../core/class/handlingdataview.dart';
import '../../widget/orders_seller/orderslistcardarchive.dart';

class OrdersArchiveViewSeller extends StatelessWidget {
  const OrdersArchiveViewSeller({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(OrdersArchiveSellerController());
    return Container(
      padding:const  EdgeInsets.all(10),
      child: GetBuilder<OrdersArchiveSellerController>(
          builder: ((controller) => HandlingDataView(statusRequest: controller.statusRequest, widget: ListView.builder(
            itemCount: controller.data.length,
            itemBuilder: ((context, index) =>
                CardOrdersListArchive(listdata: controller.data[index])),
          )))),
    );
  }
}
