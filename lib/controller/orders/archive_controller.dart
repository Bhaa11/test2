import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/core/services/services.dart';
import 'package:ecommercecourse/data/datasource/remote/orders/archive_data.dart';
import 'package:ecommercecourse/data/model/ordersmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersArchiveController extends GetxController {
  OrdersArchiveData ordersArchiveData = OrdersArchiveData(Get.find());

  List<OrdersModel> data = [];

  late StatusRequest statusRequest;

  MyServices myServices = Get.find();

  String printOrderType(String val) {
    if (val == "0") {
      return "توصيل";
    } else {
      return "استلام";
    }
  }

  String printPaymentMethod(String val) {
    if (val == "0") {
      return "الدفع عند الاستلام";
    } else {
      return "بطاقة الدفع";
    }
  }

  String printOrderStatus(String val) {
    if (val == "0") {
      return "في انتظار الموافقة";
    } else if (val == "1") {
      return "قيد التحضير";
    } else if (val == "2") {
      return "جاهز للاستلام";
    } else if (val == "3") {
      return "في الطريق";
    } else {
      return "مكتمل";
    }
  }

  getOrders() async {
    data.clear();
    statusRequest = StatusRequest.loading;
    update();

    var response = await ordersArchiveData
        .getData(myServices.sharedPreferences.getString("id")!);
    print("=============================== Controller $response ");

    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List listdata = response['data'];
        data.addAll(listdata.map((e) => OrdersModel.fromJson(e)));
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  // تقييم الطلب (الكود الموجود)
  submitRating(String ordersid, double rating, String comment) async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await ordersArchiveData
        .rating(ordersid, comment, rating.toString());
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        statusRequest = StatusRequest.success;
        for (int i = 0; i < data.length; i++) {
          if (data[i].ordersId == ordersid) {
            data[i].ordersRating = rating.toString();
            data[i].ordersNoterating = comment;
            break;
          }
        }
        Get.snackbar(
          "نجح",
          "تم إرسال التقييم بنجاح",
          snackPosition: SnackPosition.TOP,
        );
      } else {
        statusRequest = StatusRequest.failure;
        Get.snackbar(
          "خطأ",
          "فشل في إرسال التقييم",
          snackPosition: SnackPosition.TOP,
        );
      }
    }
    update();
  }
// تقييم البائع (محدث)
  submitSellerRating(String ordersid, double rating, String comment) async {
    try {
      // الحصول على معرف المستخدم
      String? userId = myServices.sharedPreferences.getString("id");
      if (userId == null) {
        Get.snackbar(
          "خطأ",
          "لم يتم العثور على معرف المستخدم",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // البحث عن الطلب للحصول على معرف البائع
      OrdersModel? order = data.firstWhereOrNull((element) => element.ordersId == ordersid);
      if (order == null) {
        Get.snackbar(
          "خطأ",
          "لم يتم العثور على الطلب",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // الحصول على معرف البائع من الطلب مباشرة
      String? sellerId = order.itemsIdSeller;

      // التحقق من صحة معرف البائع
      if (sellerId == null || sellerId.isEmpty || sellerId == "0") {
        Get.snackbar(
          "خطأ",
          "معرف البائع غير صحيح أو غير موجود",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      statusRequest = StatusRequest.loading;
      update();

      // إرسال التقييم
      var response = await ordersArchiveData.submitSellerRating(
        sellerId: sellerId,
        userId: userId,
        orderId: ordersid,
        ratingScore: rating.toString(),
        ratingComment: comment,
      );

      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        if (response['status'] == "success") {
          Get.back(); // إغلاق الحوار
          Get.snackbar(
            "نجح",
            "تم إرسال تقييم البائع بنجاح",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // تحديث تقييم البائع في البيانات المحلية
          for (int i = 0; i < data.length; i++) {
            if (data[i].ordersId == ordersid) {
              data[i].sellerRatingScore = rating.toString();
              data[i].sellerRatingComment = comment;
              break;
            }
          }
        } else {
          Get.snackbar(
            "خطأ",
            response['message'] ?? "فشل في إرسال تقييم البائع",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "خطأ",
          "حدث خطأ في الاتصال",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("خطأ في submitSellerRating: $e");
      Get.snackbar(
        "خطأ",
        "حدث خطأ غير متوقع",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    statusRequest = StatusRequest.none;
    update();
  }


  refrehOrder() {
    getOrders();
  }

  @override
  void onInit() {
    getOrders();
    super.onInit();
  }
}
