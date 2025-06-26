import 'package:flutter/material.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:get/get.dart';

class ProductBadges {
  // ===================== عرض التلميح المخصص الحديث =====================
  static void _showModernTooltip(
      BuildContext context,
      String title,
      String description,
      Color primaryColor,
      IconData icon
      ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.15,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              // التأكد من أن قيمة الشفافية صالحة
              final clampedValue = value.clamp(0.0, 1.0);

              return Transform.scale(
                scale: 0.8 + (0.2 * clampedValue),
                child: Opacity(
                  opacity: clampedValue,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.95),
                          primaryColor.withOpacity(0.85),
                          primaryColor.withOpacity(0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          spreadRadius: 0,
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // خلفية متدرجة إضافية
                          Positioned(
                            top: -50,
                            right: -50,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -30,
                            left: -30,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                          // المحتوى الرئيسي
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // الهيدر
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        icon,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          if (overlayEntry.mounted) {
                                            overlayEntry.remove();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // الوصف
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    description,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // مؤشر الإغلاق التلقائي
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "سيتم الإغلاق تلقائياً خلال 5 ثوانٍ".tr,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // إزالة التلميح تلقائياً بعد 5 ثوانٍ
    Future.delayed(const Duration(seconds: 5), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  // ===================== شارة مخصصة (قالب عام) مع التلميح المحدث =====================
  static Widget buildCustomBadge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    double? fontSize,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    required String tooltipTitle,
    required String tooltipDescription,
    required IconData tooltipIcon,
  }) {
    Widget badgeContent = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return Builder(
      builder: (context) {
        return InkWell(
          borderRadius: borderRadius ?? BorderRadius.circular(10),
          onTap: () {
            _showModernTooltip(
                context,
                tooltipTitle,
                tooltipDescription,
                backgroundColor,
                tooltipIcon
            );
          },
          child: badgeContent,
        );
      },
    );
  }

  // ===================== شارة الخصم مع التلميح المحدث =====================
  static Widget buildDiscountBadge(double discount) {
    if (discount <= 0) return const SizedBox.shrink();

    Widget badgeContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            "${discount.toInt()}% خصم",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return Builder(
      builder: (context) {
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            _showModernTooltip(
              context,
              "خصم حصري".tr + " ${discount.toInt()}%",
              "احصل على خصم فوري بنسبة".tr + " ${discount.toInt()}% " "على هذا المنتج! عرض محدود لفترة قصيرة، لا تفوت الفرصة واطلب الآن.",
              const Color(0xFFFF6B6B),
              Icons.local_fire_department,
            );
          },
          child: badgeContent,
        );
      },
    );
  }

  // ===================== شارة التوصيل المجاني مع التلميح المحدث =====================
  static Widget buildFreeDeliveryBadge() {
    Widget badgeContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child:  Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_shipping, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            "توصيل مجاني".tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return Builder(
      builder: (context) {
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            _showModernTooltip(
              context,
              "توصيل مجاني".tr,
              "نوصل لك هذا المنتج مجاناً إلى باب منزلك! لا توجد رسوم إضافية للشحن، وسيصلك المنتج في أسرع وقت ممكن.".tr,
              const Color(0xFF4ECDC4),
              Icons.local_shipping,
            );
          },
          child: badgeContent,
        );
      },
    );
  }

  // ===================== شارة "جديد" مع التلميح المحدث =====================
  static Widget buildNewBadge() {
    return buildCustomBadge(
      text: "جديد".tr,
      backgroundColor: const Color(0xFF4CAF50),
      textColor: Colors.white,
      icon: Icons.fiber_new,
      fontSize: 12,
      tooltipTitle: "منتج جديد ✨".tr,
      tooltipDescription: "هذا المنتج جديد تماماً ولم يتم استخدامه من قبل.".tr,
      tooltipIcon: Icons.fiber_new,
    );
  }

  // ===================== شارة "الأكثر مبيعاً" مع التلميح المحدث =====================
  static Widget buildBestSellerBadge() {
    return buildCustomBadge(
      text: "الأكثر مبيعاً".tr,
      backgroundColor: const Color(0xFFFF9800),
      textColor: Colors.white,
      icon: Icons.star,
      fontSize: 12,
      tooltipTitle: "الأكثر مبيعاً ⭐".tr,
      tooltipDescription: "هذا المنتج من أكثر المنتجات مبيعاً في المتجر! اختيار العملاء المفضل بسبب جودته العالية وسعره المناسب.".tr,
      tooltipIcon: Icons.star,
    );
  }

  // ===================== شارة "نفدت الكمية" مع التلميح المحدث =====================
  static Widget buildOutOfStockBadge() {
    return buildCustomBadge(
      text: "نفدت الكمية".tr,
      backgroundColor: const Color(0xFF757575),
      textColor: Colors.white,
      icon: Icons.block,
      fontSize: 12,
      tooltipTitle: "نفدت الكمية 😔".tr,
      tooltipDescription: "عذراً، هذا المنتج غير متوفر حالياً. يمكنك إضافته لقائمة الرغبات ليتم إشعارك عند توفره مرة أخرى.".tr,
      tooltipIcon: Icons.block,
    );
  }

  // ===================== شارة حالة المنتج مع التلميح المحدث =====================
  static Widget conditionBadge({required String productStatus}) {
    String text;
    Color bgStart;
    Color bgEnd;
    IconData icon;
    String tooltipTitle;
    String tooltipDescription;

    switch (productStatus) {
      case "0":
        text = "جديد".tr;
        bgStart = const Color(0xFF4CAF50).withOpacity(0.8);
        bgEnd = const Color(0xFF4CAF50);
        icon = Icons.fiber_new;
        tooltipTitle = "منتج جديد".tr;
        tooltipDescription = "هذا المنتج جديد تماماً، لم يتم استخدامه مسبقاً.".tr;
        break;
      case "1":
        text = "حاوية".tr;
        bgStart = const Color(0xFFFFA726).withOpacity(0.8);
        bgEnd = const Color(0xFFFFA726);
        icon = Icons.inventory_2;
        tooltipTitle = "منتج حاوية 📦";
        tooltipDescription = "هذا المنتج مستورد من حاوية ويُعتبر شبه جديد. جودة ممتازة بسعر أقل من المنتج الجديد.".tr;
        break;
      case "2":
        text = "مستعمل".tr;
        bgStart = const Color(0xFF9E9E9E).withOpacity(0.8);
        bgEnd = const Color(0xFF9E9E9E);
        icon = Icons.recycling;
        tooltipTitle = "منتج مستعمل ♻️".tr;
        tooltipDescription = "هذا المنتج مستخدم مسبقاً.".tr;
        break;
      default:
        text = "غير محدد".tr;
        bgStart = const Color(0xFF9E9E9E).withOpacity(0.8);
        bgEnd = const Color(0xFF9E9E9E);
        icon = Icons.help;
        tooltipTitle = "حالة غير محددة ❓";
        tooltipDescription = "حالة هذا المنتج غير محددة. يرجى التواصل مع البائع للحصول على مزيد من التفاصيل.".tr;
    }

    Widget badgeContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgStart, bgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: bgStart.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    return Builder(
      builder: (context) {
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            _showModernTooltip(
              context,
              tooltipTitle,
              tooltipDescription,
              bgEnd,
              icon,
            );
          },
          child: badgeContent,
        );
      },
    );
  }

  // ===================== شارة التوصيل المجاني قصاصة للمشروع =====================
  static Widget freeShippingBadge({required bool isFreeShipping}) {
    if (!isFreeShipping) return const SizedBox.shrink();
    return buildFreeDeliveryBadge();
  }

  // ===================== شارة نسبة الخصم قصاصة للمشروع =====================
  static Widget discountBadge({required double discountPercentage}) {
    return buildDiscountBadge(discountPercentage);
  }

  // ===================== تقييم التاجر مع التلميح المحدث =====================
  static Widget merchantRatingWidget({
    required double rating,
    required int reviewCount,
  }) {
    Widget badgeContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF92400E),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "($reviewCount)",
            style: const TextStyle(
              color: Color(0xFF78716C),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    return Builder(
      builder: (context) {
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            _showModernTooltip(
              context,
              "تقييم البائع ⭐".tr,
              "تقييم البائع".tr + " ${rating.toStringAsFixed(1)} " + "من 5 نجوم بناءً على".tr + " $reviewCount " + "تقييم من العملاء. هذا يعكس جودة الخدمة والمنتجات المقدمة.".tr,
              const Color(0xFFFBBF24),
              Icons.star,
            );
          },
          child: badgeContent,
        );
      },
    );
  }
}
