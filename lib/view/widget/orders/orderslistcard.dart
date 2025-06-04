import 'package:ecommercecourse/controller/orders/pending_controller.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/data/model/ordersmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'dart:convert';

import '../../../linkapi.dart';

class CardOrdersList extends GetView<OrdersPendingController> {
  final OrdersModel listdata;
  final bool isAnimated;

  const CardOrdersList({
    Key? key,
    required this.listdata,
    this.isAnimated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedOpacity(
      opacity: isAnimated ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.015,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(context),
                  SizedBox(height: screenHeight * 0.02),
                  _buildStatusIndicator(context),
                  SizedBox(height: screenHeight * 0.025),
                  _buildCustomerInfo(context),
                  if (listdata.items != null && listdata.items!.isNotEmpty) ...[
                    SizedBox(height: screenHeight * 0.025),
                    _buildProductsSection(context),
                  ],
                  SizedBox(height: screenHeight * 0.025),
                  _buildOrderSummary(context),
                  if (listdata.ordersStatus == "0") ...[
                    SizedBox(height: screenHeight * 0.02),
                    _buildCancelButton(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "طلب #${listdata.ordersId}",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                size: screenWidth * 0.04,
                color: Colors.grey[600],
              ),
              SizedBox(width: 6),
              Text(
                _formatDate(listdata.ordersDatetime!),
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final status = listdata.ordersStatus!;
    final statusData = _getStatusData(status);
    final progressValue = status == '0' ? 0.3 : status == '1' ? 0.7 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusData.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    statusData.icon,
                    size: screenWidth * 0.045,
                    color: statusData.color,
                  ),
                  SizedBox(width: 8),
                  Text(
                    statusData.text,
                    style: TextStyle(
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w700,
                      color: statusData.color,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.grey[200],
                  color: statusData.color,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          statusData.description,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  size: screenWidth * 0.05,
                  color: AppColor.primaryColor,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "معلومات العميل",
                      style: TextStyle(
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.015),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: screenWidth * 0.04,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            [
                              listdata.addressName ?? "غير محدد",
                              if (listdata.addressCity != null && listdata.addressStreet!.isNotEmpty)
                                listdata.addressCity!,
                              if (listdata.addressStreet != null && listdata.addressCity!.isNotEmpty)
                                listdata.addressStreet!,
                            ].join(" - "),
                            style: TextStyle(
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_android_outlined,
                          size: screenWidth * 0.04,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            listdata.usersPhone ?? "غير محدد",
                            style: TextStyle(
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final displayItems = listdata.items!.length > 3 ? listdata.items!.sublist(0, 3) : listdata.items!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "المنتجات (${listdata.items!.length})",
              style: TextStyle(
                fontSize: screenWidth * 0.042,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            if (listdata.items!.length > 3)
              InkWell(
                onTap: () => _showAllProducts(context),
                child: Text(
                  "عرض الكل",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: screenWidth * 0.025),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: screenWidth * 0.03,
            mainAxisSpacing: screenWidth * 0.03,
            childAspectRatio: 0.8,
          ),
          itemCount: displayItems.length + (listdata.items!.length > 3 ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == displayItems.length) {
              return _buildMoreItemsButton(context);
            }
            return _buildProductItem(context, displayItems[index]);
          },
        ),
      ],
    );
  }

  Widget _buildProductItem(BuildContext context, OrderItemData item) {
    final screenWidth = MediaQuery.of(context).size.width;
    String imageUrl = _getImageUrl(item);
    int itemCount = int.tryParse(item.itemsCount?.toString() ?? '1') ?? 1;

    return GestureDetector(
      onTap: () {
        if (item.itemDetails != null) {
          Get.toNamed(
            AppRoute.productdetails,
            arguments: {"itemsmodel": item.itemDetails},
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Container(
                      color: Colors.grey[100],
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.grey[400],
                              size: screenWidth * 0.06,
                            ),
                          );
                        },
                      )
                          : Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.grey[400],
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    item.itemsName ?? "منتج",
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (itemCount > 1)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "×$itemCount",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.028,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreItemsButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final extraItems = listdata.items!.length - 3;

    return GestureDetector(
      onTap: () => _showAllProducts(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: screenWidth * 0.05,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "+$extraItems أخرى",
              style: TextStyle(
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.w700,
                color: AppColor.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllProducts(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: screenHeight * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "المنتجات (${listdata.items!.length})",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: screenWidth * 0.06),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                itemCount: listdata.items!.length,
                separatorBuilder: (context, index) => SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final item = listdata.items![index];
                  return GestureDetector(  // <-- Added GestureDetector here to fix the tap issue
                    onTap: () {
                      if (item.itemDetails != null) {
                        Get.toNamed(
                          AppRoute.productdetails,
                          arguments: {"itemsmodel": item.itemDetails},
                        );
                      }
                    },
                    child: _buildProductListItem(context, item),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListItem(BuildContext context, OrderItemData item) {
    final screenWidth = MediaQuery.of(context).size.width;
    String imageUrl = _getImageUrl(item);
    int itemCount = int.tryParse(item.itemsCount?.toString() ?? '1') ?? 1;
    double price = double.tryParse(item.itemsPriceDiscount ?? '0') ?? 0;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.18,
            height: screenWidth * 0.18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.grey[400],
                    ),
                  );
                },
              )
                  : Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemsName ?? "منتج غير محدد",
                  style: TextStyle(
                    fontSize: screenWidth * 0.042,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  "الكمية: $itemCount",
                  style: TextStyle(
                    fontSize: screenWidth * 0.036,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Text(
            "${price.toStringAsFixed(2)} د.ع",
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.w800,
              color: AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double subtotal = double.parse(listdata.ordersPrice!);
    double deliveryFee = double.parse(listdata.ordersPricedelivery!);
    double total = subtotal + deliveryFee;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _buildSummaryRow(context, "سعر المنتجات", "${subtotal.toStringAsFixed(2)} د.ع"),
          SizedBox(height: 8),
          _buildSummaryRow(context, "رسوم التوصيل", "${deliveryFee.toStringAsFixed(2)} د.ع"),
          SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "المبلغ الإجمالي",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Text(
                "${total.toStringAsFixed(2)} د.ع",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w800,
                  color: AppColor.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.036,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.036,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showCancelConfirmation(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.withOpacity(0.2), width: 1.5),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          "إلغاء الطلب",
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.06),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "إلغاء الطلب",
                style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 15),
              Text(
                "هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "تراجع",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        controller.deleteOrder(listdata.ordersId!);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "نعم، ألغِ الطلب",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  StatusData _getStatusData(String status) {
    switch (status) {
      case '0':
        return StatusData(
          text: "قيد المراجعة",
          description: "طلبك قيد المراجعة من قبل البائع",
          color: Colors.orange,
          icon: Icons.access_time_rounded,
        );
      case '1':
        return StatusData(
          text: "جاري التوصيل",
          description: "طلبك في الطريق إليك الآن",
          color: Colors.blue,
          icon: Icons.local_shipping_rounded,
        );
      case '2':
        return StatusData(
          text: "مكتمل",
          description: "تم توصيل طلبك بنجاح",
          color: Colors.green,
          icon: Icons.check_circle_rounded,
        );
      case '3':
        return StatusData(
          text: "ملغي",
          description: "تم إلغاء هذا الطلب",
          color: Colors.red,
          icon: Icons.cancel_rounded,
        );
      default:
        return StatusData(
          text: "غير محدد",
          description: "حالة الطلب غير معروفة",
          color: Colors.grey,
          icon: Icons.help_rounded,
        );
    }
  }

  String _getImageUrl(OrderItemData item) {
    try {
      String? imageData = item.itemsImage;
      String? cartId = item.cartId;
      String? cartUsersid = item.cartUsersid;

      // الحالة 1: البيانات مقسمة
      if (imageData != null && imageData.contains('{"images"') &&
          cartId != null && cartId.contains('"],"videos"') &&
          cartUsersid != null && cartUsersid.contains(']}')) {

        String fullJson = '{"images":';
        String imagesArray = cartId.split(',"videos"')[0];
        if (imagesArray.startsWith('[')) {
          fullJson += imagesArray + ',"videos":';
        }

        if (cartUsersid.startsWith('[') && cartUsersid.endsWith(']}')) {
          fullJson += cartUsersid;
        }

        try {
          Map<String, dynamic> filesData = jsonDecode(fullJson);
          if (filesData['images'] != null && filesData['images'] is List) {
            List<String> images = List<String>.from(filesData['images']);
            if (images.isNotEmpty) {
              return "${AppLink.imagestItems}/${images.first}";
            }
          }
        } catch (e) {
          print("JSON parsing error: $e");
        }
      }

      // الحالة 2: JSON صحيح وكامل
      else if (imageData != null && imageData.startsWith('{') && imageData.endsWith('}')) {
        try {
          Map<String, dynamic> filesData = jsonDecode(imageData);
          if (filesData['images'] != null && filesData['images'] is List) {
            List<String> images = List<String>.from(filesData['images']);
            if (images.isNotEmpty) {
              return "${AppLink.imagestItems}/${images.first}";
            }
          }
        } catch (e) {
          print("JSON parsing error: $e");
        }
      }

      // الحالة 3: الصيغة القديمة
      else if (imageData != null &&
          !imageData.contains('{') &&
          !imageData.contains('[') &&
          imageData.isNotEmpty &&
          imageData != "empty") {
        return "${AppLink.imagestItems}/$imageData";
      }

      // الحالة 4: استخدام صورة المنتج من itemDetails
      else if (item.itemDetails != null &&
          item.itemDetails!.itemsImage != null &&
          item.itemDetails!.itemsImage!.isNotEmpty) {
        String itemImage = item.itemDetails!.itemsImage!;

        if (itemImage.startsWith('{')) {
          try {
            Map<String, dynamic> filesData = jsonDecode(itemImage);
            if (filesData['images'] != null && filesData['images'] is List) {
              List<String> images = List<String>.from(filesData['images']);
              if (images.isNotEmpty) {
                return "${AppLink.imagestItems}/${images.first}";
              }
            }
          } catch (e) {
            print("JSON parsing error: $e");
          }
        } else {
          return "${AppLink.imagestItems}/$itemImage";
        }
      }

    } catch (e) {
      print("General image error: $e");
    }

    return "";
  }

  String _formatDate(String dateString) {
    try {
      final jiffy = Jiffy.parse(dateString, pattern: "yyyy-MM-dd HH:mm:ss");
      return jiffy.format(pattern: "dd MMM yyyy, h:mm a");
    } catch (e) {
      return dateString;
    }
  }
}

class StatusData {
  final String text;
  final String description;
  final Color color;
  final IconData icon;

  StatusData({
    required this.text,
    required this.description,
    required this.color,
    required this.icon,
  });
}
