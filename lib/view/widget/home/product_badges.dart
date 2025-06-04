import 'package:flutter/material.dart';

class ProductBadges {
  // شارة الخصم
  static Widget buildDiscountBadge(double discount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
            "${discount.toInt()}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // شارة التوصيل المجاني
  static Widget buildFreeDeliveryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_shipping,
            color: Colors.white,
            size: 8,
          ),
          SizedBox(width: 2),
          Text(
            "مجاني",
            style: TextStyle(
              color: Colors.white,
              fontSize: 7,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // شارة مخصصة (يمكن استخدامها لأي نوع من الشارات)
  static Widget buildCustomBadge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    double? fontSize,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor,
              size: 10,
            ),
            const SizedBox(width: 2),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize ?? 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // شارة "جديد"
  static Widget buildNewBadge() {
    return buildCustomBadge(
      text: "جديد",
      backgroundColor: const Color(0xFF4CAF50),
      textColor: Colors.white,
      icon: Icons.fiber_new,
    );
  }

  // شارة "الأكثر مبيعاً"
  static Widget buildBestSellerBadge() {
    return buildCustomBadge(
      text: "الأكثر مبيعاً",
      backgroundColor: const Color(0xFFFF9800),
      textColor: Colors.white,
      icon: Icons.star,
      fontSize: 8,
    );
  }

  // شارة "نفدت الكمية"
  static Widget buildOutOfStockBadge() {
    return buildCustomBadge(
      text: "نفدت الكمية",
      backgroundColor: const Color(0xFF757575),
      textColor: Colors.white,
      icon: Icons.block,
      fontSize: 8,
    );
  }

  // مجموعة الشارات (للاستخدام في الكارت)
  static Widget buildBadgesColumn({
    bool hasDiscount = false,
    double discount = 0,
    bool hasFreeDelivery = false,
    bool isNew = false,
    bool isBestSeller = false,
    bool isOutOfStock = false,
  }) {
    List<Widget> badges = [];

    if (isOutOfStock) {
      badges.add(buildOutOfStockBadge());
    } else {
      if (hasDiscount && discount > 0) {
        badges.add(buildDiscountBadge(discount));
      }

      if (hasFreeDelivery) {
        badges.add(buildFreeDeliveryBadge());
      }

      if (isNew) {
        badges.add(buildNewBadge());
      }

      if (isBestSeller) {
        badges.add(buildBestSellerBadge());
      }
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      children: badges.map((badge) {
        int index = badges.indexOf(badge);
        return Column(
          children: [
            if (index > 0) const SizedBox(height: 4),
            badge,
          ],
        );
      }).toList(),
    );
  }
}
