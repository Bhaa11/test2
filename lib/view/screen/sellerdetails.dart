// view/screen/seller_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/class/crud.dart';
import 'package:ecommercecourse/linkapi.dart';
import 'package:ecommercecourse/view/widget/home/product_badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
    sellerDescription = productData['seller_description'];
    averageRating = productData['average_rating']?.toString() ?? "0.0";
    totalRatings = productData['total_ratings']?.toString() ?? "0";
    sellerVerified = "1";
    sellerStatus = "1";
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

  // دالة استخراج الصورة الأولى
  String getFirstImage(String? itemsImage) {
    if (itemsImage == null || itemsImage.isEmpty) return '';

    try {
      // محاولة تحليل JSON
      if (itemsImage.startsWith('{') || itemsImage.startsWith('[')) {
        final decoded = itemsImage.replaceAll(RegExp(r'[{}"\[\]]'), '');
        final parts = decoded.split(',');
        for (String part in parts) {
          if (part.contains('images:')) {
            final imagePart = part.split('images:')[1];
            final images = imagePart.split(',');
            if (images.isNotEmpty) {
              return images[0].trim();
            }
          }
        }
      }

      // إذا لم يكن JSON، إرجاع النص كما هو
      return itemsImage;
    } catch (e) {
      // في حالة الخطأ، إرجاع النص الأصلي
      return itemsImage;
    }
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
    // متغير للتحكم في عرض النص
    bool isExpanded = false;

    return StatefulBuilder(
        builder: (context, setState) {
          return Container(

            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(12),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة المتجر
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Text(
                              controller.sellerDetails?.sellerDescription ?? "لا يوجد وصف",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                              maxLines: isExpanded ? null : 4,
                              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                            ),
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
                      child: GestureDetector(
                        onTap: () {
                          // إضافة منطق الانتقال إلى صفحة الدردشة
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(sellerId: controller.sellerDetails?.sellerId)));
                        },
                        child: _buildInfoItem(
                          Icons.chat_bubble_outline,
                          "مراسلة البائع",
                          Colors.blue,
                        ),
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
    );
  }


  Widget _buildRatingSection(SellerDetailsController controller) {
    double rating = double.tryParse(controller.sellerDetails?.averageRating ?? "0") ?? 0;
    int totalRatings = int.tryParse(controller.sellerDetails?.totalRatings ?? "0") ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
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
                size: 18,
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
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
                "منتجات البائع",
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
              : _buildEnhancedItemsList(controller),

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

  Widget _buildEnhancedItemsList(SellerDetailsController controller) {
    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: (controller.sellerProducts.length / 2).ceil(),
        cacheExtent: 1500,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
        itemBuilder: (context, index) {
          int firstIndex = index * 2;
          int secondIndex = firstIndex + 1;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildProductCard(
                          controller.sellerProducts[firstIndex],
                          controller,
                          firstIndex,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (secondIndex < controller.sellerProducts.length)
                        Expanded(
                          child: _buildProductCard(
                            controller.sellerProducts[secondIndex],
                            controller,
                            secondIndex,
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(SellerProductModel product, SellerDetailsController controller, int index) {
    double discount = double.tryParse(product.itemsDiscount ?? "0") ?? 0;
    double originalPrice = double.tryParse(product.itemsPrice ?? "0") ?? 0;
    double deliveryPrice = 0;
    bool hasDiscount = discount > 0;
    bool hasFreeDelivery = deliveryPrice == 0;

    // استخراج الصورة الأولى
    String firstImage = controller.getFirstImage(product.itemsImage);

    return VisibilityDetector(
      key: Key('seller-product-${product.itemsId}-$index'),
      onVisibilityChanged: (visibilityInfo) {
        // يمكن إضافة منطق إضافي هنا عند الحاجة
      },
      child: GestureDetector(
        onTap: () => controller.goToProductDetails(product),
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة المنتج
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: firstImage.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: "${AppLink.imagestItems}/$firstImage",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                          memCacheWidth: 400,
                          memCacheHeight: 400,
                          maxWidthDiskCache: 400,
                          maxHeightDiskCache: 400,
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 300),
                        )
                            : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // تفاصيل المنتج
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // اسم المنتج
                          Text(
                            product.itemsName ?? "",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColor.black,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                          ),

                          const SizedBox(height: 4),

                          // عدد القطع المتوفرة
                          Builder(
                            builder: (context) {
                              int itemCount = int.tryParse(product.itemsCount ?? '0') ?? 0;
                              bool isOutOfStock = itemCount == 0;

                              return Text(
                                isOutOfStock ? "نفذ المخزون".tr : "متوفر: ".tr + "${product.itemsCount}" + " قطعة".tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isOutOfStock ? Colors.red : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 4),

                          // الأسعار
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasDiscount) ...[
                                Text(
                                  "${product.itemsPriceDiscount} " + "د.ع".tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                Text(
                                  "${product.itemsPrice} " + "د.ع".tr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  "${product.itemsPrice} " + "د.ع".tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // الشارات
              Positioned(
                top: 6,
                right: 6,
                child: ProductBadges.buildBadgesColumn(
                  hasDiscount: hasDiscount,
                  discount: discount,
                  hasFreeDelivery: hasFreeDelivery,
                ),
              ),
            ],
          ),
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
