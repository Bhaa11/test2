import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/core/services/services.dart';
import 'package:ecommercecourse/data/datasource/remote/address_data.dart';
import 'package:ecommercecourse/data/datasource/remote/checkout_date.dart';
import 'package:ecommercecourse/data/model/addressmodel.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  AddressData addressData = Get.put(AddressData(Get.find()));
  CheckoutData checkoutData = Get.put(CheckoutData(Get.find()));

  MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.none;

  String? paymentMethod;
  String? deliveryType;
  String addressid = "0";

  // حذف خيارات الكوبون حيث لم يعد مطلوباً
  String couponid = "0";
  String coupondiscount = "0";
  late String priceorders;

  List<AddressModel> dataaddress = [];

  chooseShippingAddress(String val) {
    addressid = val;
    update();
  }

  getShippingAddress() async {
    statusRequest = StatusRequest.loading;

    var response = await addressData
        .getData(myServices.sharedPreferences.getString("id")!);

    print("=============================== Controller $response ");

    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List listdata = response['data'];
        dataaddress =
            listdata.map((e) => AddressModel.fromJson(e)).toList();
        if (dataaddress.isNotEmpty) {
          addressid = dataaddress[0].addressId.toString();
        }
      } else {
        statusRequest = StatusRequest.success;
      }
    }
    update();
  }

  checkout() async {
    if (dataaddress.isEmpty) {
      return Get.snackbar("خطأ", "الرجاء اختيار عنوان التوصيل");
    }

    statusRequest = StatusRequest.loading;
    update();

    Map data = {
      "usersid": myServices.sharedPreferences.getString("id"),
      "addressid": addressid.toString(),
      "orderstype": deliveryType.toString(),
      "pricedelivery": "10",
      "ordersprice": priceorders,
      "couponid": couponid,
      "coupondiscount": coupondiscount.toString(),
      "paymentmethod": paymentMethod.toString()
    };

    var response = await checkoutData.checkout(data);

    print("=============================== Controller $response ");

    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        Get.offAllNamed(AppRoute.homepage);
        Get.snackbar("Success", "تم تأكيد الطلب بنجاح");
      } else {
        statusRequest = StatusRequest.none;
        Get.snackbar("Error", "حاول مرة أخرى");
      }
    }
    update();
  }

  @override
  void onInit() {
    // تعيين القيم الافتراضية
    paymentMethod = "0"; // الدفع نقداً عند الاستلام
    deliveryType = "0";  // التوصيل
    couponid = "0";
    coupondiscount = "0";
    priceorders = "0"; // سيتم تعيين قيمة إجمالي الطلب من CartController
    getShippingAddress();
    super.onInit();
  }
}