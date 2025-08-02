import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommercecourse/controller/home_controller.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/data/model/itemsmodel.dart';
import 'package:ecommercecourse/linkapi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constant/routes.dart';

class ListItemsHome extends StatelessWidget {
  final List<dynamic> items;
  final bool onRefresh;

  const ListItemsHome({
    super.key,
    required this.items,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          itemCount: items.length,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75, // تعديل النسبة لمساحة أفضل
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final item = ItemsModel.fromJson(items[index]);
            return ItemCard(
              item: item,
              onTap: () => _navigateToProductDetails(item, context),
            );
          },
        );
      },
    );
  }

  void _navigateToProductDetails(ItemsModel item, BuildContext context) {
    final controller = Get.find<HomeControllerImp>();
    controller.goToPageProductDetails(item);
    }
}

class ItemCard extends StatelessWidget {
  final ItemsModel item;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = (screenSize.width - 32) / 2;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج - مساحة ثابتة
            _buildProductImage(cardWidth),

            // تفاصيل المنتج - مساحة مرنة
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // اسم المنتج - في الأعلى
                    _buildProductName(screenSize),

                    // مساحة فارغة مرنة
                    const SizedBox(height: 4),

                    // الأسعار - في الأسفل
                    _buildProductPrice(screenSize),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(double cardWidth) {
    return SizedBox(
      height: cardWidth * 0.75, // ارتفاع ثابت ومناسب للصورة
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: "${AppLink.imagestItems}/${item.itemsImage}",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.white),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColor.thirdColor,
                child: Icon(
                  Icons.image_not_supported,
                  size: cardWidth * 0.2,
                  color: Colors.grey,
                ),
              ),
            ),
            // شارة الخصم
            if (item.itemsDiscount != null && item.itemsDiscount != '0')
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${item.itemsDiscount}%',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildProductName(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // اسم المنتج بالعربية
        Text(
          item.itemsNameAr ?? "منتج بدون اسم",
          style: TextStyle(
            fontSize: screenSize.width * 0.032,
            fontWeight: FontWeight.w600,
            color: AppColor.secondColor,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.rtl,
        ),
        // اسم المنتج بالإنجليزية (إذا كان متوفر)
        if (item.itemsName != null && item.itemsName!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              item.itemsName!,
              style: TextStyle(
                fontSize: screenSize.width * 0.025,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildProductPrice(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // السعر الحالي
        Text(
          '${item.itemsPriceDiscount ?? item.itemsPrice} د.ع',
          style: TextStyle(
            fontSize: screenSize.width * 0.035,
            color: AppColor.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        // السعر الأصلي (إذا كان هناك خصم)
        if (item.itemsDiscount != null &&
            item.itemsDiscount != '0' &&
            item.itemsPrice != item.itemsPriceDiscount)
          Text(
            '${item.itemsPrice} د.ع',
            style: TextStyle(
              fontSize: screenSize.width * 0.025,
              color: Colors.grey[500],
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.grey[500],
            ),
          ),
      ],
    );
  }
}