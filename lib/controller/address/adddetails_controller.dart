import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/core/services/services.dart';
import 'package:ecommercecourse/data/datasource/remote/address_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AddAddressDetailsController extends GetxController {
  StatusRequest statusRequest = StatusRequest.none;
  final AddressData addressData = AddressData(Get.find());
  final MyServices myServices = Get.find();

  late TextEditingController name;
  late TextEditingController city;
  late TextEditingController street;

  // Set default values for latitude and longitude to "0"
  String lat = '0';
  String long = '0';

  @override
  void onInit() {
    city = TextEditingController();
    street = TextEditingController();
    name = TextEditingController();
    initializeControllers();
    // Directly assign the default location values
    lat = '0';
    long = '0';
    debugPrint('Latitude: $lat, Longitude: $long');
    super.onInit();
  }

  void initializeControllers() {
    name = TextEditingController();
    city = TextEditingController();
    street = TextEditingController();
  }

  Future<void> addAddress() async {
    try {
      if (!validateForm()) return;

      statusRequest = StatusRequest.loading;
      update();

      final response = await addressData.addData(
        myServices.sharedPreferences.getString("id")!,
        name.text.trim(),
        city.text.trim(),
        street.text.trim(),
        lat,
        long,
      );

      debugPrint("=============================== Controller $response");

      handleResponse(response);
    } catch (e) {
      handleError(e);
    } finally {
      update();
    }
  }

  bool validateForm() {
    if (name.text.isEmpty || city.text.isEmpty || street.text.isEmpty) {
      Get.snackbar("خطأ", "جميع الحقول مطلوبة");
      return false;
    }
    if (lat.isEmpty || long.isEmpty) {
      Get.snackbar("خطأ", "بيانات الموقع غير صالحة");
      return false;
    }
    return true;
  }

  void handleResponse(response) {
    statusRequest = handlingData(response);

    if (statusRequest != StatusRequest.success) return;

    if (response['status'] == "success") {
      if (Get.arguments?['fromCart'] == true) {
        Get.offAllNamed(AppRoute.cart);
      } else {
        Get.offAllNamed(AppRoute.addressview);
      }
      Get.snackbar("نجاح", "تمت إضافة العنوان بنجاح");
    } else {
      statusRequest = StatusRequest.failure;
      Get.snackbar("فشل", "حدث خطأ أثناء الإضافة");
    }
  }

  void handleError(dynamic error) {
    statusRequest = StatusRequest.serverfailure;
    debugPrint("Error adding address: $error");
    Get.snackbar("خطأ", "حدث خطأ في الاتصال بالسيرفر");
  }

  @override
  void onClose() {
    name.dispose();
    city.dispose();
    street.dispose();
    super.onClose();
  }
}