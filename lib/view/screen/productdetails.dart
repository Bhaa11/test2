// lib/view/screens/product_details.dart

import 'package:ecommercecourse/controller/productdetails_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/view/screen/sellerdetails.dart';
import 'package:ecommercecourse/view/widget/productdetails/priceandcount.dart';
import 'package:ecommercecourse/view/widget/productdetails/toppageproductdetails.dart';
import 'package:ecommercecourse/view/widget/productdetails/badges.dart';
import 'package:ecommercecourse/view/widget/productdetails/related_products.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../linkapi.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProductDetailsControllerImp controller =
    Get.put(ProductDetailsControllerImp());
    controller.itemsModel = Get.arguments['itemsmodel'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF8F9FA),
      body: GetBuilder<ProductDetailsControllerImp>(
        builder: (controller) => HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    expandedHeight: 300,
                    pinned: true,
                    elevation: 0,
                    centerTitle: true,
                    iconTheme: const IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      background: TopProductPageDetails(controller.itemsModel),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildProductDetailsCard(context, controller),
                  ),
                ],
              ),
              _buildAddToCartButton(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetailsCard(
      BuildContext context, ProductDetailsControllerImp controller) {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildProductHeader(context, controller),
            const SizedBox(height: 16),
            _buildProductBadges(controller),
            const SizedBox(height: 24),
            _buildPriceAndCounter(controller),
            const SizedBox(height: 24),
            _buildProductDescription(controller),
            const SizedBox(height: 24),
            _buildMerchantInfo(controller),
            const SizedBox(height: 32),
            const RelatedProducts(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(
      BuildContext context, ProductDetailsControllerImp controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.itemsModel.itemsName ?? "",
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 26,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "كود المنتج: #${controller.itemsModel.itemsId ?? 'غير محدد'}",
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductBadges(ProductDetailsControllerImp controller) {
    final int condition = 0;
    final bool freeShipping = true;
    final double discountPercentage =
    controller.calculateDiscountPercentage(controller.itemsModel).toDouble();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ProductBadges.conditionBadge(condition: condition),
        ProductBadges.freeShippingBadge(isFreeShipping: freeShipping),
        ProductBadges.discountBadge(discountPercentage: discountPercentage),
      ],
    );
  }

  Widget _buildPriceAndCounter(ProductDetailsControllerImp controller) {
    String? originalPrice;
    if (controller.itemsModel.itemsPrice !=
        controller.itemsModel.itemsPriceDiscount) {
      originalPrice = "${controller.itemsModel.itemsPrice}";
    }

    return PriceAndCountItems(
      onAdd: controller.incrementLocal,
      onRemove: controller.decrementLocal,
      price: "${controller.itemsModel.itemsPriceDiscount}",
      originalPrice: originalPrice,
      count: "${controller.localCount}",
    );
  }

  Widget _buildProductDescription(ProductDetailsControllerImp controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "وصف المنتج",
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            controller.itemsModel.itemsDesc ?? "لا يوجد وصف متاح للمنتج.",
            style: const TextStyle(
              color: Color(0xFF374151),
              height: 1.6,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMerchantInfo(ProductDetailsControllerImp controller) {
    final String merchantName = controller.getMerchantName();
    final String? merchantImage = controller.getMerchantImage();
    final double merchantRating = controller.getMerchantRating();
    final int merchantReviewCount = controller.getMerchantReviewCount();
    const int maxStars = 5;

    int filledStars = merchantRating.floor();

    // طباعة معلومات التشخيص
    print("=== UI Debug ===");
    print("Merchant Name: $merchantName");
    print("Merchant Image: $merchantImage");
    print("Merchant Rating: $merchantRating");
    print("Merchant Review Count: $merchantReviewCount");
    print("===============");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "معلومات التاجر",
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFF3F4F6),
                child: ClipOval(
                  child: _buildMerchantImage(merchantImage),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchantName,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        for (int i = 1; i <= maxStars; i++)
                          Icon(
                            i <= filledStars
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber.shade600,
                            size: 18,
                          ),
                        const SizedBox(width: 6),
                        Text(
                          merchantRating > 0
                              ? "${merchantRating.toStringAsFixed(1)}"
                              : "لا توجد تقييمات",
                          style: const TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "($merchantReviewCount)",
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  // التنقل إلى صفحة تفاصيل البائع
                  Get.to(() => const SellerDetailsView(), arguments: {
                    "seller_id": controller.itemsModel.itemsIdSeller
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.secondColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColor.secondColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

  }

  Widget _buildMerchantImage(String? merchantImage) {
    print("=== Image Debug ===");
    print("Raw merchant image: '$merchantImage'");

    if (merchantImage != null && merchantImage.trim().isNotEmpty) {
      // تجربة عدة احتمالات لرابط الصورة
      List<String> possibleUrls = [
        "${AppLink.imagestUsers}/$merchantImage",
      ];

      String imageUrl = possibleUrls[0]; // استخدم الأول كافتراضي
      print("Trying image URL: $imageUrl");

      return Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print("Image loaded successfully!");
            return child;
          }
          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image: $error");
          print("Stack trace: $stackTrace");

          // جرب الرابط التالي إذا فشل الأول
          if (possibleUrls.length > 1) {
            return Image.network(
              possibleUrls[1],
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error2, stackTrace2) {
                print("Second URL also failed: $error2");
                return Icon(
                  Icons.person,
                  size: 30,
                  color: AppColor.primaryColor,
                );
              },
            );
          }

          return Icon(
            Icons.person,
            size: 30,
            color: AppColor.primaryColor,
          );
        },
      );
    } else {
      print("No merchant image provided or empty string");
      return Icon(
        Icons.person,
        size: 30,
        color: AppColor.primaryColor,
      );
    }
  }

  Widget _buildAddToCartButton(ProductDetailsControllerImp controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () async {
              await controller.updateCart();
              Get.toNamed(AppRoute.cart);
            },
            icon: const Icon(
              Iconsax.shopping_cart,
              size: 28,
              color: Colors.white,
            ),
            label: const Text(
              "إضافة للسلة",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.secondColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              shadowColor: AppColor.secondColor.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}
