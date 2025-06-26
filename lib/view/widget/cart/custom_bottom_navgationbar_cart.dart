// ignore_for_file: prefer_const_constructors

import 'package:ecommercecourse/controller/cart_controller.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavgationBarCart extends GetView<CartController> {
  final String price;
  final String shipping;
  final String totalprice;

  const BottomNavgationBarCart({
    Key? key,
    required this.price,
    required this.shipping,
    required this.totalprice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, -3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
// مؤشر سحب
          Container(
            margin: EdgeInsets.only(top: 8, bottom: 4),
            height: 4,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAddressAndPayment(context),
                SizedBox(height: 16),
                _buildPriceSummary(),
                SizedBox(height: 20),
                _buildCheckoutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressAndPayment(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: GetBuilder<CartController>(
              builder: (controller) => _buildInfoCard(
                icon: Icons.location_on,
                title: "العنوان".tr,
                description: controller.selectedAddressId.isNotEmpty && controller.addresses.isNotEmpty
                    ? "${controller.addresses.firstWhere((address) => address.addressId.toString() == controller.selectedAddressId).addressCity} ${controller.addresses.firstWhere((address) => address.addressId.toString() == controller.selectedAddressId).addressStreet}"
                    : "لم يتم اختيار عنوان".tr,
                onTap: () => _showAddressBottomSheet(context),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: _buildInfoCard(
              icon: Icons.payments_outlined,
              title: "الدفع".tr,
              description: "عند الاستلام".tr,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    String? description,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColor.thirdColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColor.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: AppColor.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColor.grey2,
                  ),
                ),
                if (onTap != null) ...[
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColor.grey2,
                  ),
                ],
              ],
            ),
            if (description != null) ...[
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow("سعر المنتجات".tr, price),
          SizedBox(height: 10),
          _buildPriceRow("رسوم التوصيل".tr, shipping),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey[300]),
          ),
          _buildPriceRow("المبلغ الإجمالي".tr, totalprice, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 14,
            color: isTotal ? AppColor.grey2 : Colors.grey[700],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        Text(
          "$value " + "د.ع".tr,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? AppColor.primaryColor : Colors.black,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return GetBuilder<CartController>(
      builder: (controller) => ElevatedButton(
        onPressed: () {
          if (controller.addresses.isEmpty) {
            Get.toNamed(AppRoute.addressadd, arguments: {'fromCart': true});
          } else {
            controller.confirmOrder();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "تأكيد الطلب".tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.shopping_cart_checkout,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

// عرض قائمة العناوين في صفحة منبثقة
  void _showAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GetBuilder<CartController>(
          builder: (controller) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
// مؤشر سحب
                  Container(
                    margin: EdgeInsets.only(top: 12, bottom: 8),
                    height: 4,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

// رأس الصفحة
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "اختيار العنوان".tr,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.grey2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(),

// قائمة العناوين
                  controller.addresses.isEmpty
                      ? Expanded(child: _buildEmptyAddressIndicator())
                      : Expanded(child: _buildAddressList(controller)),

// زر إضافة عنوان
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed(
                          AppRoute.addressadddetails,
                          arguments: {'fromCart': true},
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(Icons.add_location_alt_outlined),
                        label: Text(
                          "إضافة عنوان".tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyAddressIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 70,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            "لا توجد عناوين محفوظة".tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.grey2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "قم بإضافة عنوان لإتمام الطلب".tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(
              AppRoute.addressadd,
              arguments: {'fromCart': true},
            ),
            icon: Icon(Icons.add_location_alt),
            label: Text("إضافة عنوان".tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(CartController controller) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: controller.addresses.length,
      itemBuilder: (context, index) {
        final address = controller.addresses[index];
        final isSelected = controller.selectedAddressId == address.addressId.toString();

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColor.primaryColor : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () {
              controller.selectedAddressId = address.addressId.toString();
              controller.update();
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.primaryColor
                          : AppColor.thirdColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: isSelected ? Colors.white : AppColor.primaryColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.addressName!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColor.grey2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${address.addressStreet}, ${address.addressCity}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppColor.primaryColor,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
