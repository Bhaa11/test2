import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/color.dart';
import '../../core/constant/routes.dart';
import 'home/carselectiondialog.dart';
import '../../controller/home_controller.dart';


/// شريط التطبيق المخصص مع تصميم عصري واستجابة عالية
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleappbar;
  final void Function()? onPressedIconFavorite;
  final void Function()? onPressedSearch;
  final void Function(String)? onChanged;
  final TextEditingController mycontroller;
  final IconData iconData;
  final Map<String, Map<String, List<String>>>? carData; // تحديث نوع البيانات

  const CustomAppBar({
    Key? key,
    required this.titleappbar,
    this.onPressedSearch,
    required this.onPressedIconFavorite,
    this.onChanged,
    required this.mycontroller,
    this.iconData = Icons.favorite_border_outlined,
    this.carData,
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
// الحصول على الكونترولر للتحقق من حالة البيانات
                              final controller = Get.find<HomeControllerImp>();

// التحقق من حالة تحميل البيانات
                              if (!controller.carDataLoaded) {
// إظهار مؤشر التحميل
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 8,
                                      backgroundColor: Colors.white,
                                      child: Container(
                                        padding: const EdgeInsets.all(30),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              AppColor.primaryColor.withOpacity(0.05),
                                            ],
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
// أيقونة السيارة مع تأثير دوراني
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  width: 80,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppColor.primaryColor.withOpacity(0.1),
                                                  ),
                                                ),
                                                Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppColor.primaryColor.withOpacity(0.2),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.directions_car_rounded,
                                                  size: 35,
                                                  color: AppColor.primaryColor,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 25),
// مؤشر التحميل المخصص
                                            SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                                                backgroundColor: AppColor.primaryColor.withOpacity(0.2),
                                              ),
                                            ),
                                            const SizedBox(height: 25),
// النص الرئيسي
                                            Text(
                                              'جاري تحميل بيانات السيارات',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.black,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
// النص الفرعي
                                            Text(
                                              'يرجى الانتظار قليلاً...',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColor.grey,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

// انتظار حتى يتم تحميل البيانات أو انتهاء المهلة الزمنية
                                int waitTime = 0;
                                while (!controller.carDataLoaded && waitTime < 10) {
                                  await Future.delayed(Duration(seconds: 1));
                                  waitTime++;
                                }

// إغلاق حوار التحميل
                                Navigator.of(context).pop();

// التحقق من نتيجة التحميل - استخدام controller.carData بدلاً من carData
                                if (!controller.carDataLoaded || controller.carData.isEmpty) {
// إظهار رسالة خطأ
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'عذراً، بيانات السيارات غير متوفرة حالياً\nيرجى المحاولة لاحقاً أو التواصل مع الدعم الفني',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      duration: const Duration(seconds: 4),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.red.shade600,
                                      margin: const EdgeInsets.all(10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      action: SnackBarAction(
                                        label: 'حسناً',
                                        textColor: Colors.white,
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        },
                                      ),
                                    ),
                                  );
                                  return;
                                }
                              }

// التحقق من أن البيانات متاحة وصحيحة - استخدام controller.carData
                              if (controller.carData.isEmpty) {
// إظهار رسالة خطأ للبيانات الفارغة أو الخاطئة
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'عذراً، بيانات السيارات غير متوفرة حالياً\nيرجى المحاولة لاحقاً أو التواصل مع الدعم الفني',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 4),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.red.shade600,
                                    margin: const EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    action: SnackBarAction(
                                      label: 'حسناً',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      },
                                    ),
                                  ),
                                );
                                return;
                              }

// إذا كانت البيانات متاحة، فتح حوار اختيار السيارة - استخدام controller.carData
                              final result = await CarSelectionDialog.show(
                                context: context,
                                carData: controller.carData,
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
              badgeCount: 3, // يمكن إضافة عدد الإشعارات الجديدة ديناميكياً
            ),

            const SizedBox(width: 12),

// زر السلة المحسّن
            _buildActionButton(
              icon: Icons.shopping_cart_outlined,
              onPressed: () {
                Get.toNamed(AppRoute.cart);
              },
              badgeCount: 2, // يمكنك تغييره ديناميكياً حسب عدد العناصر في السلة
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
