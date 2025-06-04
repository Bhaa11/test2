import 'package:ecommercecourse/controller/checkout_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/view/widget/checkout/cardshippingaddress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Checkout extends StatelessWidget {
  const Checkout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // إنشاء Controller والتأكد من تعيين القيم الافتراضية
    CheckoutController controller = Get.put(CheckoutController());
    controller.paymentMethod = "0"; // الدفع نقداً عند الاستلام
    controller.deliveryType = "0";  // التوصيل

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: MaterialButton(
            color: AppColor.secondColor,
            textColor: Colors.white,
            onPressed: () {
              // تأكيد الطلب مباشرة عند الضغط على الزر
              controller.checkout();
            },
            child: const Text("تأكيد الطلب",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )),
      body: GetBuilder<CheckoutController>(
          builder: (controller) => HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "عنوان التوصيل",
                    style: TextStyle(
                        color: AppColor.secondColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  controller.dataaddress.isEmpty
                      ? InkWell(
                    onTap: () {
                      Get.toNamed(AppRoute.addressadd);
                    },
                    child: Center(
                      child: Text(
                        "الرجاء إضافة عنوان التوصيل \nاضغط هنا",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  )
                      : Column(
                    children: List.generate(
                      controller.dataaddress.length,
                          (index) => InkWell(
                        onTap: () {
                          controller.chooseShippingAddress(
                              controller.dataaddress[index]
                                  .addressId!);
                        },
                        child: CardShppingAddressCheckout(
                          title: controller.dataaddress[index]
                              .addressName!,
                          body:
                          "${controller.dataaddress[index].addressCity} ${controller.dataaddress[index].addressStreet}",
                          isactive: controller.addressid ==
                              controller.dataaddress[index].addressId,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}