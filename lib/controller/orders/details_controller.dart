import 'dart:async';
import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/data/datasource/remote/orders/details_data.dart';
import 'package:ecommercecourse/data/model/cartmodel.dart';
import 'package:ecommercecourse/data/model/ordersmodel.dart';
import 'package:get/get.dart';


class OrdersDetailsController extends GetxController {
  OrdersDetailsData ordersDetailsData = OrdersDetailsData(Get.find());

  List<CartModel> data = [];

  late StatusRequest statusRequest;

  late OrdersModel ordersModel;


  intialData() {
    // التحقق من أن نوع الطلب هو "0" وأن الإحداثيات غير null أو فارغة
    if (ordersModel.ordersType == "0" &&
        ordersModel.addressLat != null &&
        ordersModel.addressLong != null &&
        ordersModel.addressLat!.isNotEmpty &&
        ordersModel.addressLong!.isNotEmpty) {
      try {
        double parsedLat = double.parse(ordersModel.addressLat!);
        double parsedLong = double.parse(ordersModel.addressLong!);

        ;
      } catch (e) {
        // في حال فشل عملية التحويل يتم تسجيل الخطأ وتعيين قيمة افتراضية
        print("Error parsing latitude or longitude: $e");

      }
    }
  }

  @override
  void onInit() {
    ordersModel = Get.arguments['ordersmodel'];
    intialData();
    getData();
    super.onInit();
  }

  getData() async {
    statusRequest = StatusRequest.loading;

    var response = await ordersDetailsData.getData(ordersModel.ordersId!);

    print("=============================== Controller $response ");

    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List listdata = response['data'];
        data.addAll(listdata.map((e) => CartModel.fromJson(e)));
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }
}