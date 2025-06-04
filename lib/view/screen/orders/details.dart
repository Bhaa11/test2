// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:ecommercecourse/controller/orders/details_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrdersDetails extends StatelessWidget {
  const OrdersDetails({super.key});

  @override
  Widget build(BuildContext context) {
    OrdersDetailsController controller = Get.put(OrdersDetailsController());
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب', style: TextStyle(fontFamily: 'Cairo')),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: GetBuilder<OrdersDetailsController>(
          builder: ((controller) => HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: ListView( // تم تغيير widget إلى child هنا
              physics: BouncingScrollPhysics(),
              children: [
                _buildOrderSummary(controller),
                if (controller.ordersModel.ordersType == "0")
                  _buildShippingSection(controller),
              ],
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(OrdersDetailsController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المنتجات',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryColor,
                    fontFamily: 'Cairo')),
            Divider(height: 30, thickness: 1),
            Table(
              columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1.5)},
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                  ),
                  children: [
                    _buildHeaderCell('المنتج'),
                    _buildHeaderCell('الكمية'),
                    _buildHeaderCell('السعر'),
                  ],
                ),
                ...List.generate(
                  controller.data.length,
                      (index) => TableRow(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                    ),
                    children: [
                      _buildDataCell(controller.data[index].itemsName ?? ''),
                      _buildDataCell(controller.data[index].countitems ?? ''),
                      _buildDataCell('${controller.data[index].itemsprice} \$'),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('الإجمالي: ${controller.ordersModel.ordersTotalprice} \$',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontFamily: 'Cairo')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingSection(OrdersDetailsController controller) {
    return Column(
      children: [
        SizedBox(height: 15),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Icon(Icons.location_on, color: AppColor.primaryColor),
            title: Text('عنوان التوصيل',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo')),
            subtitle: Text(
                '${controller.ordersModel.addressCity} - ${controller.ordersModel.addressStreet}',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
        ),
        SizedBox(height: 15),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          child: Container(
            height: 280,
            padding: EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                mapType: MapType.normal,
                markers: controller.markers.toSet(),
                initialCameraPosition: controller.cameraPosition!,
                onMapCreated: (GoogleMapController controllermap) {
                  controller.completercontroller!.complete(controllermap);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontFamily: 'Cairo')),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.grey[800],
              fontFamily: 'Cairo')),
    );
  }
}