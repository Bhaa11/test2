import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/core/services/services.dart';
import 'package:ecommercecourse/data/datasource/remote/cart_data.dart';
import 'package:ecommercecourse/data/datasource/remote/checkout_date.dart';
import 'package:ecommercecourse/data/datasource/remote/address_data.dart';
import 'package:ecommercecourse/data/model/cartmodel.dart';
import 'package:ecommercecourse/data/model/addressmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../data/model/itemsmodel.dart';

class CartController extends GetxController {
  CartData cartData = CartData(Get.find());
  MyServices myServices = Get.find();

// متغيرات السلة
  List<CartModel> data = [];
  double priceorders = 0.0;
  int totalcountitems = 0;
  int pricedelivery = 0;

// متغيرات العنوان
  List<AddressModel> addresses = [];
  String selectedAddressId = "";

// حالة الطلب
  late StatusRequest statusRequest;

// دالة لاستخراج الصورة الأولى من JSON
  String getFirstImage(String? itemsImage) {
    if (itemsImage == null || itemsImage.isEmpty) {
      return '';
    }

    try {
// محاولة تحليل JSON
      Map<String, dynamic> imageData = json.decode(itemsImage);

// التحقق من وجود مصفوفة الصور
      if (imageData.containsKey('images') && imageData['images'] is List) {
        List images = imageData['images'];
        if (images.isNotEmpty) {
          return images[0].toString();
        }
      }

// إذا لم توجد صور، إرجاع فارغ
      return '';
    } catch (e) {
// في حالة فشل تحليل JSON، قد تكون الصورة بالتنسيق القديم
      return itemsImage;
    }
  }

// دالة عرض السلة
  view() async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await cartData.viewCart(
        myServices.sharedPreferences.getString("id")!);
    print("CartController view response: $response");
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        if (response['datacart']['status'] == 'success') {
          List dataresponse = response['datacart']['data'];
          Map dataresponsecountprice = response['countprice'];
          data.clear();
          data.addAll(dataresponse.map((e) => CartModel.fromJson(e)));
          totalcountitems =
              int.parse(dataresponsecountprice['totalcount'].toString());
          priceorders =
              double.parse(dataresponsecountprice['totalprice'].toString());
// إصلاح استخراج رسوم التوصيل: استخراج القيمة من أول عنصر في قائمة البيانات إن وجد
          if (dataresponse.isNotEmpty &&
              dataresponse[0]['items_pricedelivery'] != null) {
            pricedelivery =
                int.parse(dataresponse[0]['items_pricedelivery'].toString());
          } else {
            pricedelivery = 0;
          }
          print(
              "Total Order Price: $priceorders, Delivery Price: $pricedelivery");
        }
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

// دالة لإضافة عنصر إلى السلة
  add(String itemsid) async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await cartData.addCart(
        myServices.sharedPreferences.getString("id")!, itemsid);
    print("CartController add response: $response");
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        Get.snackbar(
          "✓ تمت الإضافة",
          "تم اضافة المنتج الى السلة",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          borderRadius: 8,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
          isDismissible: true,
        );
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

// دالة لحذف عنصر من السلة
  delete(String itemsid) async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await cartData.deleteCart(
        myServices.sharedPreferences.getString("id")!, itemsid);
    print("CartController delete response: $response");
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        Get.snackbar(
          "✓ تمت الإزالة",
          "تم ازالة المنتج من السلة",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
          borderRadius: 8,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
          isDismissible: true,
        );
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

// حساب الإجمالي (المجموع الفرعي + رسوم التوصيل)
  double getTotalPrice() {
    return (priceorders + pricedelivery);
  }

// دالة استرجاع عناوين الشحن للمستخدم
  getShippingAddresses() async {
    AddressData addressData = AddressData(Get.find());
    statusRequest = StatusRequest.loading;
    update();
    var response =
    await addressData.getData(myServices.sharedPreferences.getString("id")!);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List listdata = response['data'];
        addresses =
            listdata.map((e) => AddressModel.fromJson(e)).toList();
        if (addresses.isNotEmpty) {
          selectedAddressId = addresses[0].addressId.toString();
        }
      }
    }
    update();
  }

// دالة تأكيد الطلب مباشرة من صفحة السلة
  confirmOrder() async {
    if (selectedAddressId.isEmpty) {
      return Get.snackbar(
        "⚠ خطأ",
        "الرجاء اختيار عنوان التوصيل",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 8,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
        isDismissible: true,
      );
    }
// إعداد بيانات الطلب بناءً على المتطلبات في الباك اند
    Map orderData = {
      "usersid": myServices.sharedPreferences.getString("id"),
      "addressid": selectedAddressId,
      "orderstype": "0", // 0 => توصيل (Delivery) ، 1 => استلام من المتجر (Pickup)
      "pricedelivery": pricedelivery.toString(), // رسوم التوصيل
      "ordersprice": priceorders.toString(),
      "couponid": "0",
      "coupondiscount": "0",
      "paymentmethod": "0" // 0 => الدفع عند الاستلام
    };

    var checkoutData = CheckoutData(Get.find());
    statusRequest = StatusRequest.loading;
    update();

    var response = await checkoutData.checkout(orderData);
    print("Checkout Response: $response");
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
// إعادة تعيين بيانات السلة بعد تأكيد الطلب
        resetVarCart();
        Get.offAllNamed(AppRoute.homepage);
        Get.snackbar(
          "✓ تم التأكيد",
          "تم تأكيد الطلب بنجاح",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          borderRadius: 8,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 3),
          isDismissible: true,
        );
      } else {
        statusRequest = StatusRequest.none;
        Get.snackbar(
          "⚠ خطأ",
          "حدث خطأ، حاول مرة أخرى",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          borderRadius: 8,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
          isDismissible: true,
        );
      }
    }
    update();
  }

// إعادة تحميل بيانات السلة
  refreshPage() {
    resetVarCart();
    view();
  }

// إعادة تعيين بيانات السلة
  resetVarCart() {
    totalcountitems = 0;
    pricedelivery = 0;
    priceorders = 0.0;
    data.clear();
  }

  @override
  void onInit() {
    super.onInit();
    getShippingAddresses();
    view();
  }

// الانتقال إلى صفحة تفاصيل المنتج
  goToPageProductDetails(CartModel cartModel) {
// تحويل CartModel إلى ItemsModel قبل التمرير
    ItemsModel itemsModel = cartModel.toItemsModel();
// تمرير معلومة أن المستخدم جاء من السلة
    Get.toNamed("productdetails", arguments: {
      "itemsmodel": itemsModel,
      "fromCart": true
    });
  }
}
