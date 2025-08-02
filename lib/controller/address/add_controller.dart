import 'dart:async';
import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:get/get.dart';

class AddAddressController extends GetxController {
  StatusRequest statusRequest = StatusRequest.loading;

  // إزالة جميع المتغيرات والكلاسات الخاصة بـ Google Map
  // Completer<GoogleMapController>? completercontroller;
  // List<Marker> markers = [];
  // CameraPosition? kGooglePlex;

  // تعيين القيم إلى 0
  double lat = 0;
  double long = 0;

  // تم إزالة دالة addMarkers
  // أصبحت القيم الافتراضية 0 ولا حاجة لتعديلها عند الضغط على الخريطة

  goToPageAddDetailsAddress() {
    // يتم تمرير القيم كـ "0"
    Get.toNamed(AppRoute.addressadddetails,
        arguments: {"lat": lat.toString(), "long": long.toString()});
  }



  getCurrentLocation() async {
    // يمكن استدعاء geolocator للحصول على الموقع الحالي، لكننا نقوم بتعيين القيم إلى 0 لتفادي المشاكل
    // position = await Geolocator.getCurrentPosition();
    lat = 0;
    long = 0;
    statusRequest = StatusRequest.none;
    update();
  }

  @override
  void onInit() {
    getCurrentLocation();
    // تم إزالة تهيئة completercontroller
    super.onInit();
  }
}