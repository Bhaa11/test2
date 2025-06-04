// view/screen/seller_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/class/crud.dart';
import 'package:ecommercecourse/linkapi.dart';

// Model للبائع
class SellerDetailsModel {
  String? sellerId;
  String? sellerName;
  String? sellerEmail;
  String? sellerPhone;
  String? sellerImage;
  String? sellerDescription;
  String? sellerAddress;
  String? sellerCity;
  String? sellerCreatedAt;
  String? sellerStatus;
  String? sellerVerified;
  String? averageRating;
  String? totalRatings;
  String? joinDate;

  SellerDetailsModel({
    this.sellerId,
    this.sellerName,
    this.sellerEmail,
    this.sellerPhone,
    this.sellerImage,
    this.sellerDescription,
    this.sellerAddress,
    this.sellerCity,
    this.sellerCreatedAt,
    this.sellerStatus,
    this.sellerVerified,
    this.averageRating,
    this.totalRatings,
    this.joinDate,
  });

  SellerDetailsModel.fromJson(Map<String, dynamic> json) {
    sellerId = json['seller_id']?.toString();
    sellerName = json['seller_name'];
    sellerEmail = json['seller_email'];
    sellerPhone = json['seller_phone'];
    sellerImage = json['seller_image'];
    sellerDescription = json['seller_description'];
    sellerAddress = json['seller_address'];
    sellerCity = json['seller_city'];
    sellerCreatedAt = json['seller_created_at'];
    sellerStatus = json['seller_status']?.toString();
    sellerVerified = json['seller_verified']?.toString();
    averageRating = json['average_rating']?.toString() ?? "0.0";
    totalRatings = json['total_ratings']?.toString() ?? "0";
    joinDate = json['join_date'];
  }

  SellerDetailsModel.fromProductData(Map<String, dynamic> productData) {
    sellerId = productData['items_id_seller']?.toString();
    sellerName = productData['seller_name'];
    sellerImage = productData['seller_image'];
    averageRating = productData['average_rating']?.toString() ?? "0.0";
    totalRatings = productData['total_ratings']?.toString() ?? "0";
    sellerVerified = "1";
    sellerStatus = "1";
    sellerDescription = "متجر ${sellerName ?? 'غير محدد'}";
  }
}

// Model للمنتجات
class SellerProductModel {
  String? itemsId;
  String? itemsName;
  String? itemsNameAr;
  String? itemsDesc;
  String? itemsDescAr;
  String? itemsImage;
  String? itemsCount;
  String? itemsActive;
  String? itemsPrice;
  String? itemsDiscount;
  String? itemsDate;
  String? itemsCat;
  String? categoriesId;
  String? categoriesName;
  String? categoriesNameAr;
  String? itemsPriceDiscount;
  String? favorite;
  String? itemsRating;

  SellerProductModel({
    this.itemsId,
    this.itemsName,
    this.itemsNameAr,
    this.itemsDesc,
    this.itemsDescAr,
    this.itemsImage,
    this.itemsCount,
    this.itemsActive,
    this.itemsPrice,
    this.itemsDiscount,
    this.itemsDate,
    this.itemsCat,
    this.categoriesId,
    this.categoriesName,
    this.categoriesNameAr,
    this.itemsPriceDiscount,
    this.favorite,
    this.itemsRating,
  });

  SellerProductModel.fromJson(Map<String, dynamic> json) {
    itemsId = json['items_id']?.toString();
    itemsName = json['items_name'];
    itemsNameAr = json['items_name_ar'];
    itemsDesc = json['items_desc'];
    itemsDescAr = json['items_desc_ar'];
    itemsImage = json['items_image'];
    itemsCount = json['items_count']?.toString();
    itemsActive = json['items_active']?.toString();
    itemsPrice = json['items_price']?.toString();
    itemsDiscount = json['items_discount']?.toString();
    itemsDate = json['items_date'];
    itemsCat = json['items_cat']?.toString();
    categoriesId = json['categories_id']?.toString();
    categoriesName = json['categories_name'];
    categoriesNameAr = json['categories_name_ar'];
    itemsPriceDiscount = json['itemspricediscount']?.toString();
    favorite = json['favorite']?.toString();
    itemsRating = json['items_rating']?.toString() ?? "0.0";
  }
}

// Data Source
class SellerDetailsData {
  Crud crud;
  SellerDetailsData(this.crud);

  getSellerDetails(String sellerId) async {
    var response = await crud.postData(AppLink.homepage, {
      "seller_id": sellerId,
      "type": "seller_details"
    });
    return response.fold((l) => l, (r) => r);
  }

  getSellerProducts(String sellerId) async {
    var response = await crud.postData(AppLink.itemsview, {
      "seller_id": sellerId
    });
    return response.fold((l) => l, (r) => r);
  }
}

// Controller
class SellerDetailsController extends GetxController {
  SellerDetailsData sellerDetailsData = SellerDetailsData(Get.find());
  SellerDetailsModel? sellerDetails;
  List<SellerProductModel> sellerProducts = [];
  late StatusRequest statusRequest;
  String sellerId = "";
  bool hasSellerData = false;

  @override
  void onInit() {
    sellerId = Get.arguments['seller_id'] ?? "";
    if (sellerId.isNotEmpty) {
      getSellerProducts();
    }
    super.onInit();
  }

  getSellerDetails() async {
    var response = await sellerDetailsData.getSellerDetails(sellerId);
    print("=== استجابة تفاصيل البائع ===");
    print(response);

    if (response['status'] == "success") {
      sellerDetails = SellerDetailsModel.fromJson(response['data']);
      hasSellerData = true;
    } else {
      print("فشل في جلب تفاصيل البائع: ${response['message']}");
    }
    update();
  }

  getSellerProducts() async {
    statusRequest = StatusRequest.loading;
    update();

    var response = await sellerDetailsData.getSellerProducts(sellerId);
    print("=== استجابة منتجات البائع ===");
    print(response);

    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List responseData = response['data'];
        sellerProducts.addAll(responseData.map((e) => SellerProductModel.fromJson(e)));

        if (sellerProducts.isNotEmpty && sellerDetails == null) {
          sellerDetails = SellerDetailsModel.fromProductData(responseData[0]);
          hasSellerData = true;
        }
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  void goToProductDetails(SellerProductModel product) {
    Get.toNamed("/productdetails", arguments: {
      "itemsmodel": product
    });
  }

  refreshData() {
    sellerProducts.clear();
    sellerDetails = null;
    hasSellerData = false;
    getSellerProducts();
  }
}

// الصفحة الرئيسية
class SellerDetailsView extends StatelessWidget {
  const SellerDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(SellerDetailsController());
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: GetBuilder<SellerDetailsController>(
        builder: (controller) => HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: controller.hasSellerData
              ? _buildContent(controller)
              : _buildNoDataView(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColor.black),
        onPressed: () => Get.back(),
      ),
      title: Text(
        "تفاصيل المتجر",
        style: TextStyle(
          color: AppColor.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildContent(SellerDetailsController controller) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSellerCard(controller),
          const SizedBox(height: 16),
          _buildProductsSection(controller),
        ],
      ),
    );
  }

  Widget _buildSellerCard(SellerDetailsController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // معلومات المتجر الأساسية
          Row(
            children: [
              // صورة المتجر
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildSellerImage(controller.sellerDetails?.sellerImage),
                ),
              ),

              const SizedBox(width: 16),

              // اسم المتجر ووصفه
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المتجر مع التحقق
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.sellerDetails?.sellerName ?? "متجر مجهول",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColor.black,
                            ),
                          ),
                        ),
                        if (controller.sellerDetails?.sellerVerified == "1") ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 6),

                    // وصف المتجر
                    Text(
                      controller.sellerDetails?.sellerDescription ?? "لا يوجد وصف",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // التقييم
          _buildRatingSection(controller),

          const SizedBox(height: 12),

          // معلومات إضافية
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.inventory_2_outlined,
                  "${controller.sellerProducts.length} منتج",
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  Icons.store_outlined,
                  "ID: ${controller.sellerDetails?.sellerId ?? 'غير محدد'}",
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(SellerDetailsController controller) {
    double rating = double.tryParse(controller.sellerDetails?.averageRating ?? "0") ?? 0;
    int totalRatings = int.tryParse(controller.sellerDetails?.totalRatings ?? "0") ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // النجوم
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating.floor()
                    ? Icons.star
                    : index < rating
                    ? Icons.star_half
                    : Icons.star_border,
                color: Colors.amber[600],
                size: 20,
              );
            }),
          ),

          const SizedBox(width: 12),

          // التقييم الرقمي
          Text(
            "${rating.toStringAsFixed(1)}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.amber[700],
            ),
          ),

          const SizedBox(width: 8),

          // عدد التقييمات
          Text(
            "($totalRatings تقييم)",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(SellerDetailsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              Text(
                "المنتجات",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // المنتجات
          controller.sellerProducts.isEmpty
              ? _buildEmptyProducts()
              : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: controller.sellerProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(controller.sellerProducts[index], controller);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyProducts() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            "لا توجد منتجات",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(SellerProductModel product, SellerDetailsController controller) {
    return GestureDetector(
      onTap: () => controller.goToProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildProductImage(product.itemsImage),
                ),
              ),
            ),

            // تفاصيل المنتج
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المنتج
                    Text(
                      product.itemsName ?? "",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColor.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // التقييم
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          product.itemsRating ?? "0.0",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // السعر
                    Row(
                      children: [
                        if (product.itemsDiscount != "0" && product.itemsDiscount != null)
                          Text(
                            "${product.itemsPrice} د.ع",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (product.itemsDiscount != "0" && product.itemsDiscount != null)
                          const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${product.itemsPriceDiscount ?? product.itemsPrice} د.ع",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store_outlined,
                size: 40,
                color: Colors.grey[400],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "لا توجد بيانات",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "لا يمكن العثور على معلومات هذا المتجر",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Get.find<SellerDetailsController>().refreshData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text("إعادة المحاولة"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerImage(String? sellerImage) {
    if (sellerImage != null && sellerImage.trim().isNotEmpty) {
      String imageUrl = "${AppLink.imagestUsers}/$sellerImage";

      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[100],
            child: Icon(
              Icons.store,
              size: 30,
              color: Colors.grey[400],
            ),
          );
        },
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        color: Colors.grey[100],
        child: Icon(
          Icons.store,
          size: 30,
          color: Colors.grey[400],
        ),
      );
    }
  }

  Widget _buildProductImage(String? itemsImage) {
    if (itemsImage != null && itemsImage.trim().isNotEmpty) {
      String imageUrl = "${AppLink.imagestItems}/$itemsImage";

      return Image.network(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[100],
            child: Icon(
              Icons.image_outlined,
              size: 30,
              color: Colors.grey[400],
            ),
          );
        },
      );
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[100],
        child: Icon(
          Icons.image_outlined,
          size: 30,
          color: Colors.grey[400],
        ),
      );
    }
  }
}
