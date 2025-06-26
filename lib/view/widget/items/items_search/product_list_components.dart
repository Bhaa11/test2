import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../../../core/constant/color.dart';
import '../../../../data/model/itemsmodel.dart';
import '../../../../linkapi.dart';
import '../../home/product_badges.dart';
import 'list_items_components.dart';

class ProductListComponents {
  static Widget buildSearchAndFilterBar(
      BuildContext context, {
        required TextEditingController searchController,
        required bool showDiscountOnly,
        required bool showFreeDeliveryOnly,
        required int viewType,
        required VoidCallback onSearchClear,
        required Function(int) onViewTypeChanged,
        required Function(bool) onDiscountFilterChanged,
        required Function(bool) onFreeDeliveryFilterChanged,
        required VoidCallback onSortPressed,
      }) {
    return ProductSearchFilter.buildSearchAndFilterBar(
      context,
      searchController: searchController,
      showDiscountOnly: showDiscountOnly,
      showFreeDeliveryOnly: showFreeDeliveryOnly,
      viewType: viewType,
      onSearchClear: onSearchClear,
      onViewTypeChanged: onViewTypeChanged,
      onDiscountFilterChanged: onDiscountFilterChanged,
      onFreeDeliveryFilterChanged: onFreeDeliveryFilterChanged,
      onSortPressed: onSortPressed,
    );
  }

  static Widget buildFilterStatus(
      BuildContext context, {
        required int filteredCount,
        required int totalCount,
        required VoidCallback onReset,
      }) {
    return ProductSearchFilter.buildFilterStatus(
      context,
      filteredCount: filteredCount,
      totalCount: totalCount,
      onReset: onReset,
    );
  }

  static Widget buildGridView({
    required List<ItemsModel> items,
    required bool animation,
    required Function(ItemsModel) onTap,
  }) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.72,
      ),
      cacheExtent: 1000,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        final item = items[index];
        return animation
            ? AnimationConfiguration.staggeredGrid(
          position: index,
          columnCount: 2,
          duration: const Duration(milliseconds: 350),
          child: ScaleAnimation(
            scale: 0.95,
            child: FadeInAnimation(
              child: _buildProductCard(context, item, onTap, index),
            ),
          ),
        )
            : _buildProductCard(context, item, onTap, index);
      },
    );
  }

  static Widget buildListView({
    required List<ItemsModel> items,
    required bool animation,
    required Function(ItemsModel) onTap,
  }) {
    return ListView.separated(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      cacheExtent: 1500,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        final item = items[index];
        return animation
            ? AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 350),
          child: SlideAnimation(
            horizontalOffset: 50,
            child: FadeInAnimation(
              child: _buildListItemCard(context, item, onTap, index),
            ),
          ),
        )
            : _buildListItemCard(context, item, onTap, index);
      },
    );
  }

  static Widget buildNoResultsFound() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "لا توجد نتائج مطابقة",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "جرب تغيير معايير البحث أو الفلاتر",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 15),
            Text(
              "لم نتمكن من العثور على ما تبحث عنه",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "جرب استخدام كلمات بحث مختلفة",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // يمكن إضافة وظيفة للذهاب إلى صفحة التصفح
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("تصفح المنتجات"),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildProductCard(
      BuildContext context, ItemsModel item, Function(ItemsModel) onTap, int index) {
    final theme = Theme.of(context);
    String firstImage = ProductUtils.getFirstImage(item.itemsImage);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onTap(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج
            _buildProductImage(item, context, firstImage, index),

            // معلومات المنتج
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المنتج - صف واحد فقط
                    Text(
                      item.itemsName ?? 'اسم غير متوفر',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // السعر والتوصيل المجاني
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // مساحة ثابتة لسعر الخصم
                        Container(
                          height: 14,
                          child: ProductUtils.hasDiscount(item)
                              ? Text(
                            "${ProductUtils.getOriginalPrice(item)} د.ع",
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          )
                              : Opacity(
                            opacity: 0,
                            child: Text(
                              "0000 د.ع",
                              style: TextStyle(
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // السعر الحالي
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: ProductUtils.getFinalPrice(item),
                                style: TextStyle(
                                  color: AppColor.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              TextSpan(
                                text: " د.ع",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
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

  static Widget _buildListItemCard(
      BuildContext context, ItemsModel item, Function(ItemsModel) onTap, int index) {
    String firstImage = ProductUtils.getFirstImage(item.itemsImage);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => onTap(item),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 130,
                  height: 130,
                  child: firstImage.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: "${AppLink.imagestItems}/$firstImage",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImageShimmer(),
                    errorWidget: (context, url, error) => _buildImageErrorWidget(),
                    memCacheWidth: 300,
                    memCacheHeight: 300,
                    maxWidthDiskCache: 300,
                    maxHeightDiskCache: 300,
                    fadeInDuration: const Duration(milliseconds: 300),
                  )
                      : _buildImageErrorWidget(),
                ),
              ),

              const SizedBox(width: 12),

              // تفاصيل المنتج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المنتج - صف واحد فقط
                    Text(
                      item.itemsName ?? 'اسم غير متوفر',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // الأسعار بشكل عمودي مع مساحة ثابتة
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // مساحة ثابتة للسعر قبل الخصم
                        Container(
                          height: 16,
                          child: ProductUtils.hasDiscount(item)
                              ? Text(
                            "${ProductUtils.getOriginalPrice(item)} د.ع",
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          )
                              : const SizedBox(),
                        ),

                        // مسافة ثابتة بين السعرين
                        const SizedBox(height: 4),

                        // السعر النهائي
                        Text(
                          "${ProductUtils.getFinalPrice(item)} د.ع",
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // الشارات بشكل أفقي أسفل السعر
                    Row(
                      children: [
                        // شارة الخصم
                        if (ProductUtils.hasDiscount(item))
                          ProductBadges.buildDiscountBadge(
                            ProductUtils.getDiscountValue(item).toDouble(),
                          ),

                        // مسافة بين الشارات
                        if (ProductUtils.hasDiscount(item) && ProductUtils.hasFreeDelivery(item))
                          const SizedBox(width: 8),

                        // شارة التوصيل المجاني
                        if (ProductUtils.hasFreeDelivery(item))
                          ProductBadges.buildFreeDeliveryBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildProductImage(ItemsModel item, BuildContext context, String firstImage, int index) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // صورة المنتج
          firstImage.isNotEmpty
              ? CachedNetworkImage(
            imageUrl: "${AppLink.imagestItems}/$firstImage",
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildImageShimmer(),
            errorWidget: (context, url, error) => _buildImageErrorWidget(),
            memCacheWidth: 400,
            memCacheHeight: 400,
            maxWidthDiskCache: 400,
            maxHeightDiskCache: 400,
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 300),
          )
              : _buildImageErrorWidget(),

          // الشارات باستخدام النظام الجديد
          Positioned(
            top: 8,
            right: 8,
            child: ProductBadges.buildBadgesColumn(
              hasDiscount: ProductUtils.hasDiscount(item),
              discount: ProductUtils.getDiscountValue(item).toDouble(),
              hasFreeDelivery: ProductUtils.hasFreeDelivery(item),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildImageShimmer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
          stops: const [0.1, 0.5, 0.9],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
        ),
      ),
    );
  }

  static Widget _buildImageErrorWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 30,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              'لا توجد صورة',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showSortBottomSheet(
      BuildContext context, {
        required String currentSort,
        required Function(String) onSortSelected,
      }) {
    ProductSearchFilter.showSortBottomSheet(
      context,
      currentSort: currentSort,
      onSortSelected: onSortSelected,
    );
  }
}

class ProductUtils {
  static final NumberFormat formatter = NumberFormat('#,##0');

  // دالة محسنة لاستخراج الصورة الأولى
  static String getFirstImage(String? itemsImage) {
    if (itemsImage == null || itemsImage.isEmpty) {
      return '';
    }

    try {
      // محاولة تحليل JSON أولاً
      if (itemsImage.startsWith('{') || itemsImage.startsWith('[')) {
        dynamic imageData = json.decode(itemsImage);

        if (imageData is Map<String, dynamic>) {
          // التحقق من وجود مصفوفة الصور
          if (imageData.containsKey('images') && imageData['images'] is List) {
            List images = imageData['images'];
            if (images.isNotEmpty) {
              return images[0].toString().trim();
            }
          }
        } else if (imageData is List) {
          // إذا كانت البيانات عبارة عن مصفوفة مباشرة
          if (imageData.isNotEmpty) {
            return imageData[0].toString().trim();
          }
        }
      } else {
        // التعامل مع الصور المفصولة بفاصلة
        List<String> imagesList = itemsImage.split(',');
        if (imagesList.isNotEmpty) {
          return imagesList[0].trim();
        }
      }

      return '';
    } catch (e) {
      print('Error parsing image data: $e');
      // في حالة فشل تحليل JSON، إرجاع النص كما هو
      if (itemsImage.contains(',')) {
        return itemsImage.split(',')[0].trim();
      }
      return itemsImage.trim();
    }
  }

  static bool hasDiscount(ItemsModel item) {
    if (item.itemsDiscount == null) return false;

    int discount;
    if (item.itemsDiscount is String) {
      discount = int.tryParse(item.itemsDiscount.toString()) ?? 0;
    } else {
      discount = item.itemsDiscount as int? ?? 0;
    }

    return discount > 0;
  }

  static bool hasFreeDelivery(ItemsModel item) {
    if (item.itemsActive != null && item.itemsActive == "1") {
      return true;
    }

    double price = double.tryParse(getFinalPrice(item).replaceAll(',', '')) ?? 0;
    return price >= 200;
  }

  static int getDiscountValue(ItemsModel item) {
    if (item.itemsDiscount == null) return 0;

    if (item.itemsDiscount is String) {
      return int.tryParse(item.itemsDiscount.toString()) ?? 0;
    } else {
      return item.itemsDiscount as int? ?? 0;
    }
  }

  static String getOriginalPrice(ItemsModel item) {
    if (item.itemsPrice == null) return "0";

    double price;
    if (item.itemsPrice is String) {
      price = double.tryParse(item.itemsPrice.toString()) ?? 0.0;
    } else if (item.itemsPrice is int) {
      price = (item.itemsPrice as int).toDouble();
    } else {
      price = item.itemsPrice as double? ?? 0.0;
    }

    return formatter.format(price);
  }

  static String getFinalPrice(ItemsModel item) {
    double originalPrice = 0.0;

    if (item.itemsPrice != null) {
      if (item.itemsPrice is String) {
        originalPrice = double.tryParse(item.itemsPrice.toString()) ?? 0.0;
      } else if (item.itemsPrice is int) {
        originalPrice = (item.itemsPrice as int).toDouble();
      } else {
        originalPrice = item.itemsPrice as double? ?? 0.0;
      }
    }

    if (hasDiscount(item)) {
      int discountPercentage = getDiscountValue(item);
      double discountAmount = originalPrice * (discountPercentage / 100);
      double finalPrice = originalPrice - discountAmount;
      return formatter.format(finalPrice);
    }

    return formatter.format(originalPrice);
  }

  static double getItemPrice(ItemsModel item) {
    double originalPrice = 0.0;

    if (item.itemsPrice != null) {
      if (item.itemsPrice is String) {
        originalPrice = double.tryParse(item.itemsPrice.toString()) ?? 0.0;
      } else if (item.itemsPrice is int) {
        originalPrice = (item.itemsPrice as int).toDouble();
      } else {
        originalPrice = item.itemsPrice as double? ?? 0.0;
      }
    }

    if (hasDiscount(item)) {
      int discountPercentage = getDiscountValue(item);
      double discountAmount = originalPrice * (discountPercentage / 100);
      return originalPrice - discountAmount;
    }

    return originalPrice;
  }
}
