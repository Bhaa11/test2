import 'package:ecommercecourse/controller/cart_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/view/widget/cart/custom_bottom_navgationbar_cart.dart';
import 'package:ecommercecourse/view/widget/cart/customitemscartlist.dart';
import 'package:ecommercecourse/view/widget/cart/topcardCart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Cart extends StatelessWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
// حذف الكنترولر السابق وإنشاء جديد لضمان إعادة تحميل البيانات
    Get.delete<CartController>();
    CartController cartController = Get.put(CartController());

// الحصول على معلومة الصفحة المصدر
    String fromPage = Get.arguments?["fromPage"] ?? "other";

    return WillPopScope(
      onWillPop: () async {
// التحكم في سلوك زر الرجوع
        if (fromPage == "homepage") {
// إذا جاء من الصفحة الرئيسية، حذف جميع الصفحات والعودة للصفحة الرئيسية
          Get.offAllNamed(AppRoute.homepage);
          return false; // منع السلوك الافتراضي
        } else {
// إذا جاء من مكان آخر، السلوك الطبيعي (العودة للصفحة السابقة)
          return true; // السماح بالسلوك الافتراضي
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(context, fromPage),
        bottomNavigationBar: GetBuilder<CartController>(
          builder: (controller) => BottomNavgationBarCart(
            shipping: "${controller.pricedelivery}",
            price: "${controller.priceorders}",
            totalprice: "${controller.getTotalPrice()}",
          ),
        ),
        body: GetBuilder<CartController>(
          builder: (controller) => HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: controller.data.isEmpty
                ? _buildEmptyCart(context)
                : _buildCartContent(controller),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String fromPage) {
    return AppBar(
      title: Text(
        "سلة التسوق".tr,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColor.primaryColor,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.grey[50],
      iconTheme: IconThemeData(color: AppColor.primaryColor),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
// نفس منطق WillPopScope
          if (fromPage == "homepage") {
// حذف جميع الصفحات والعودة للصفحة الرئيسية
            Get.offAllNamed(AppRoute.homepage);
          } else {
            Get.back();
          }
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "سلة التسوق فارغة".tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "ابدأ بإضافة منتجات للسلة".tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoute.homepage),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "تصفح المنتجات".tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(CartController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: TopCardCart(
            message: "لديك".tr + " ${controller.totalcountitems} " + "عنصر في السلة".tr,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            physics: const BouncingScrollPhysics(),
            itemCount: controller.data.length,
            itemBuilder: (context, index) {
              return _buildCartItem(controller, index, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(
      CartController controller, int index, BuildContext context) {
    final item = controller.data[index];

// استخدام السعر بعد الخصم إذا كان متوفراً، وإلا استخدام السعر الأصلي
    String displayPrice = item.itemspricediscount ?? item.itemsprice ?? "0";

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: CustomItemsCartList(
        onAdd: () async {
          await controller.add(item.itemsId!);
          controller.refreshPage();
        },
        onRemove: () async {
          await controller.delete(item.itemsId!);
          controller.refreshPage();
        },
        imagename: item.itemsImage!,
        name: item.itemsName!,
        price: "$displayPrice \$",
        count: "${item.countitems}",
        onTap: () {
          controller.goToPageProductDetails(item);
        },
      ),
    );
  }
}
