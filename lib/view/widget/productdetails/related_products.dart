import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommercecourse/controller/productdetails_controller.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/linkapi.dart';
import 'package:ecommercecourse/view/screen/image_gallery_view.dart';
import 'package:ecommercecourse/view/widget/home/product_badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../data/model/itemsmodel.dart';

class RelatedProducts extends GetView<ProductDetailsControllerImp> {
  const RelatedProducts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailsControllerImp>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 16),
            _buildContent(controller),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "منتجات مقترحة".tr + " : ",
            style: TextStyle(
              color: AppColor.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildContent(ProductDetailsControllerImp controller) {
// إظهار تحميل للمنتجات ذات الصلة فقط
    if (controller.isLoadingRelatedProducts) {
      return _buildLoadingState();
    }

// إذا لم توجد منتجات ذات صلة
    if (controller.relatedProducts.isEmpty) {
      return _buildEmptyState();
    }

// عرض المنتجات ذات الصلة
    return _buildProductsList(controller);
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            "جاري تحميل المنتجات المقترحة...".tr,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            "لا توجد منتجات مقترحة في الوقت الحالي".tr,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "تحقق مرة أخرى لاحقاً".tr,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductDetailsControllerImp controller) {
    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: (controller.relatedProducts.length / 2).ceil(),
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
                          controller.relatedProducts[firstIndex],
                          controller,
                          firstIndex,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (secondIndex < controller.relatedProducts.length)
                        Expanded(
                          child: _buildProductCard(
                            controller.relatedProducts[secondIndex],
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

  Widget _buildProductCard(ItemsModel itemsModel, ProductDetailsControllerImp controller, int index) {
    double discount = double.tryParse(itemsModel.itemsDiscount ?? "0") ?? 0;
    double originalPrice = double.tryParse(itemsModel.itemsPrice ?? "0") ?? 0;
    double deliveryPrice = 0;
    bool hasDiscount = discount > 0;
    bool hasFreeDelivery = deliveryPrice == 0;

// استخراج الصورة الأولى
    String firstImage = _getFirstImage(itemsModel.itemsImage);

    return VisibilityDetector(
      key: Key('related-product-${itemsModel.itemsId}-$index'),
      onVisibilityChanged: (visibilityInfo) {
// يمكن إضافة منطق إضافي هنا عند الحاجة
      },
      child: GestureDetector(
        onTap: () => controller.goToProductDetails(itemsModel),
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
                            itemsModel.itemsName ?? "",
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
                              int itemCount = int.tryParse(itemsModel.itemsCount ?? '0') ?? 0;
                              bool isOutOfStock = itemCount == 0;

                              return Text(
                                isOutOfStock ? "نفذ المخزون".tr : "متوفر: ".tr + "${itemsModel.itemsCount}" + " قطعة".tr,
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
                                  "${itemsModel.itemsPriceDiscount} " + "د.ع".tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                Text(
                                  "${itemsModel.itemsPrice} " + "د.ع".tr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  "${itemsModel.itemsPrice} " + "د.ع".tr,
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

// دالة استخراج الصورة الأولى
  String _getFirstImage(String? itemsImage) {
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
