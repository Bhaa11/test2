import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommercecourse/controller/productdetails_controller.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/linkapi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/model/itemsmodel.dart';

class RelatedProducts extends GetView<ProductDetailsControllerImp> {
  const RelatedProducts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailsControllerImp>(
      builder: (controller) {
        if (controller.relatedProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 16),
            _buildProductsGrid(controller),
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
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "منتجات مقترحة",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildProductsGrid(ProductDetailsControllerImp controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: controller.relatedProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(controller.relatedProducts[index], controller);
      },
    );
  }

  Widget _buildProductCard(ItemsModel product, ProductDetailsControllerImp controller) {
    return GestureDetector(
      onTap: () => controller.goToProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
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
            _buildProductImage(product, controller),
            _buildProductInfo(product, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(ItemsModel product, ProductDetailsControllerImp controller) {
    return Expanded(
      flex: 3,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: "${AppLink.imagestItems}/${product.itemsImage}",
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: const Color(0xFFF1F5F9),
                  highlightColor: const Color(0xFFF8FAFC),
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFFF8FAFC),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildProductBadges(product, controller),
          _buildFavoriteButton(product, controller),
        ],
      ),
    );
  }

  Widget _buildProductBadges(ItemsModel product, ProductDetailsControllerImp controller) {
    int discountPercentage = controller.calculateDiscountPercentage(product);

    return Positioned(
      top: 8,
      left: 8,
      child: Column(
        children: [
          // شارة الحالة (جديد)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "جديد",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // شارة الخصم إذا وجد
          if (discountPercentage > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "$discountPercentage% خصم",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(ItemsModel product, ProductDetailsControllerImp controller) {
    bool isFavorite = product.favorite == "1";

    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.toggleFavoriteForProduct(product),
            borderRadius: BorderRadius.circular(8),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF6B7280),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(ItemsModel product, ProductDetailsControllerImp controller) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.itemsName ?? "",
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            _buildPriceSection(product, controller),
            const Spacer(),
            _buildAddToCartButton(product, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(ItemsModel product, ProductDetailsControllerImp controller) {
    bool hasDiscount = product.itemsPrice != product.itemsPriceDiscount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${product.itemsPriceDiscount} د.ع",
          style: TextStyle(
            color: AppColor.primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                "${product.itemsPrice} د.ع",
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFDF7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "وفر ${controller.calculateDiscountPercentage(product)}%",
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAddToCartButton(ItemsModel product, ProductDetailsControllerImp controller) {
    return Container(
      width: double.infinity,
      height: 32,
      decoration: BoxDecoration(
        color: AppColor.secondColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.addToCart(product),
          borderRadius: BorderRadius.circular(6),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_shopping_cart,
                  color: Colors.white,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  "أضف للسلة",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
