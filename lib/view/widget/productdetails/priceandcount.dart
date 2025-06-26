import 'package:flutter/material.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PriceAndCountItems extends StatelessWidget {
  final void Function()? onAdd;
  final void Function()? onRemove;
  final String price;
  final String? originalPrice;
  final String count;
  final String? availableQuantity;

  const PriceAndCountItems({
    Key? key,
    required this.onAdd,
    required this.onRemove,
    required this.price,
    this.originalPrice,
    required this.count,
    this.availableQuantity,
  }) : super(key: key);

// دالة لتنسيق الأرقام وإضافة الفاصلة
  String formatPrice(String value) {
    try {
      final number = int.parse(value);
// استخدام تنسيق الأرقام بنمط en_US لإظهار الفواصل
      final formatter = NumberFormat.decimalPattern('en_US');
      return formatter.format(number);
    } catch (e) {
      return value; // إذا فشل التحويل للعدد (غير رقم)، نُعيد القيمة كما هي
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceSection(),
          const SizedBox(height: 20),
          _buildQuantityControl(),
          const SizedBox(height: 16),
          _buildAvailableQuantity(),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
// القسم الأيسر: السعر بعد الخصم
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "السعر".tr,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${formatPrice(price)} " + "د.ع".tr,
              style: TextStyle(
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ],
        ),
// القسم الأيمن (اختياري): السعر قبل الخصم مع شطبه
        if (originalPrice != null && originalPrice!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Text(
                "قبل الخصم".tr,
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${formatPrice(originalPrice!)} " + "د.ع".tr,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildQuantityControl() {
// التحقق من الكمية المتوفرة
    int currentCount = int.parse(count);
    int maxQuantity = availableQuantity != null ? (int.tryParse(availableQuantity!) ?? 0) : 999;
    bool canAdd = currentCount < maxQuantity;

    return Row(
      children: [
         Text(
          "الكمية".tr,
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlButton(
                onPressed: onRemove,
                icon: Icons.remove,
                isEnabled: int.parse(count) > 1, // تم تغيير الشرط من > 0 إلى > 1
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Text(
                  count,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              _buildControlButton(
                onPressed: onAdd,
                icon: Icons.add,
                isEnabled: canAdd,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableQuantity() {
    if (availableQuantity == null) return const SizedBox.shrink();

    int quantity = int.tryParse(availableQuantity!) ?? 0;

    Color quantityColor;
    String quantityText;

    if (quantity > 10) {
      quantityColor = const Color(0xFF059669);
      quantityText = "متوفر".tr + " ($quantity " + "قطعة".tr + ")";
    } else if (quantity > 0) {
      quantityColor = const Color(0xFFD97706);
      quantityText = "كمية محدودة".tr + " ($quantity " + "قطعة".tr + ")";
    } else {
      quantityColor = const Color(0xFFDC2626);
      quantityText = "غير متوفر".tr;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: quantityColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                quantityText,
                style: TextStyle(
                  color: quantityColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required void Function()? onPressed,
    required IconData icon,
    required bool isEnabled,
  }) {
    return SizedBox(
      width: 44,
      height: 44,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColor.primaryColor : const Color(0xFFE5E7EB),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
          size: 20,
        ),
      ),
    );
  }
}
