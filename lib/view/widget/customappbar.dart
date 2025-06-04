import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/routes.dart';
import 'home/carselectiondialog.dart';

/// ألوان المشروع
class AppColor {
  static const Color grey = Color(0xFF757575);
  static const Color grey2 = Color(0xFF424242);
  static const Color black = Color(0xff000000);
  static const Color backgroundcolor = Color(0xFFFFF8E1);
  static const Color primaryColor = Color(0xFFFFC107);
  static const Color secondColor = Color(0xFFFFA000);
  static const Color fourthColor = Color(0xFF0D47A1);
  static const Color thirdColor = Color(0xFFFFECB3);
  static const Color lightGrey = Color(0xFFF5F5F5);
}

/// شريط التطبيق المخصص مع تصميم عصري واستجابة عالية
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleappbar;
  final void Function()? onPressedIconFavorite;
  final void Function()? onPressedSearch;
  final void Function(String)? onChanged;
  final TextEditingController mycontroller;
  final IconData iconData;

  const CustomAppBar({
    Key? key,
    required this.titleappbar,
    this.onPressedSearch,
    required this.onPressedIconFavorite,
    this.onChanged,
    required this.mycontroller,
    this.iconData = Icons.favorite_border_outlined,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // حقل البحث المحسّن
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // اختياري: يمكن تفعيل التركيز على حقل البحث عند النقر
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: TextFormField(
                      controller: mycontroller,
                      onChanged: onChanged,
                      onFieldSubmitted: (value) {
                        if (onPressedSearch != null) {
                          onPressedSearch!();
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: InputBorder.none,
                        hintText: titleappbar,
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: AppColor.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 12),
                          child: IconButton(
                            icon: const Icon(Icons.search_rounded, color: AppColor.primaryColor, size: 26),
                            onPressed: () async {
                              // بيانات السيارات
                              final carData = {
                                'فورد': {
                                  'موستنك': ['2018', '2019', '2020', '2021', '2022', '2023', '2024', '2025'],
                                  'إكسبلورر': ['2019', '2020', '2021', '2022', '2023'],
                                  'إف-150': ['2018', '2019', '2020', '2021', '2022'],
                                },
                                'كيا': {
                                  'سبورتاج': ['2020', '2021', '2022', '2023'],
                                  'سيلتوس': ['2021', '2022', '2023'],
                                  'سورينتو': ['2019', '2020', '2021', '2022'],
                                },
                                'تويوتا': {
                                  'كامري': ['2018', '2019', '2020', '2021', '2022'],
                                  'راف4': ['2019', '2020', '2021', '2022', '2023'],
                                  'كورولا': ['2018', '2019', '2020', '2021', '2022'],
                                },
                                'هوندا': {
                                  'أكورد': ['2018', '2019', '2020', '2021', '2022'],
                                  'سيفيك': ['2019', '2020', '2021', '2022'],
                                  'سي-آر-في': ['2018', '2019', '2020', '2021'],
                                },
                                'نيسان': {
                                  'التيما': ['2018', '2019', '2020', '2021'],
                                  'باثفايندر': ['2019', '2020', '2021', '2022'],
                                  'إكس-تريل': ['2018', '2019', '2020', '2021'],
                                },
                                'شيفروليه': {
                                  'كامارو': ['2018', '2019', '2020', '2021', '2022'],
                                  'سيلفرادو': ['2019', '2020', '2021', '2022'],
                                  'ماليبو': ['2018', '2019', '2020', '2021'],
                                },
                              };

                              final result = await CarSelectionDialog.show(
                                context: context,
                                carData: carData,
                              );

                              if (result != null) {
                                // تنسيق البحث بالصيغة المطلوبة: الشركة-الموديل-سنة الصنع
                                final searchQuery = "${result['company']}-${result['model']}-${result['year']}";

                                // تعيين نص البحث في حقل البحث
                                mycontroller.text = searchQuery;

                                // تشغيل دالة onChanged لتحديث واجهة المستخدم
                                if (onChanged != null) {
                                  onChanged!(searchQuery);
                                }

                                // تنفيذ البحث باستخدام المعلومات المختارة
                                if (onPressedSearch != null) {
                                  onPressedSearch!();
                                }

                                // إظهار رسالة نجاح موجزة
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'جاري البحث عن قطع غيار ${result['company']} ${result['model']} ${result['year']}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColor.secondColor,
                                    margin: const EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        suffixIcon: mycontroller.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColor.grey, size: 20),
                          onPressed: () {
                            mycontroller.clear();
                            if (onChanged != null) {
                              onChanged!('');
                            }
                          },
                        )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // زر الإشعارات المحسّن
            _buildActionButton(
              icon: Icons.notifications_outlined,
              onPressed: () {
                Get.toNamed(AppRoute.notificationview);
              },
              badgeCount: 3,  // يمكن إضافة عدد الإشعارات الجديدة ديناميكياً
            ),

            const SizedBox(width: 12),

            // زر السلة المحسّن
            _buildActionButton(
              icon: Icons.shopping_cart_outlined,
              onPressed: () {
                Get.toNamed(AppRoute.cart);
              },
              badgeCount: 2,  // يمكنك تغييره ديناميكياً حسب عدد العناصر في السلة
            ),

          ],
        ),
      ),
    );
  }

  // Widget منفصل للأزرار لتحسين قابلية إعادة الاستخدام
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    int? badgeCount,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPressed,
              child: Center(
                child: Icon(
                  icon,
                  size: 26,
                  color: AppColor.secondColor,
                ),
              ),
            ),
          ),
        ),

        // عرض شارة العدد إذا كانت موجودة (مثل عدد الإشعارات الجديدة)
        if (badgeCount != null && badgeCount > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
