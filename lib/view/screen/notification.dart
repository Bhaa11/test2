import 'package:ecommercecourse/controller/notification_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart'; // استيراد ملف الطرق
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationController());

    // معالجة زر الرجوع للعودة إلى الصفحة الرئيسية بدلا من الخروج
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(AppRoute.homepage); // العودة للصفحة الرئيسية
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColor.backgroundcolor,
        appBar: AppBar(
          title: const Text(
            'الإشعارات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColor.backgroundcolor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColor.grey2),
            onPressed: () {
              // العودة للصفحة الرئيسية بدلا من الخروج
              Get.offAllNamed(AppRoute.homepage);
            },
          ),
          actions: [
            // زر لتحديث الإشعارات
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColor.secondColor),
              onPressed: () {
                final controller = Get.find<NotificationController>();
                controller.getData();
              },
            ),
          ],
        ),
        body: GetBuilder<NotificationController>(
          builder: (controller) => HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // عنوان القسم مع عدد الإشعارات - تم إزالة زر مسح الكل
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start, // تغيير التوزيع ليكون في البداية بعد إزالة الزر
                      children: [
                        Text(
                          controller.data.isNotEmpty
                              ? "لديك ${controller.data.length} إشعارات"
                              : "لا توجد إشعارات",
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColor.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // خط فاصل بين العنوان وقائمة الإشعارات
                  const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),

                  if (controller.data.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: controller.data.length,
                        itemBuilder: (context, index) {
                          final item = controller.data[index];
                          final bool isUnread = index < 3; // مثال: الثلاثة الأولى غير مقروءة

                          return Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red.shade50,
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 28,
                              ),
                            ),
                            onDismissed: (direction) {
                              // يمكن استدعاء دالة لحذف الإشعار
                              // controller.deleteNotification(item['notification_id']);
                            },
                            child: Card(
                              elevation: 0,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200, width: 1),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  // يمكن إضافة تفاعل عند الضغط على الإشعار
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // مؤشر الإشعار
                                      Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isUnread
                                                  ? AppColor.thirdColor
                                                  : const Color(0xFFEEEEEE),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.notifications_outlined,
                                              color: isUnread
                                                  ? AppColor.secondColor
                                                  : AppColor.grey,
                                              size: 24,
                                            ),
                                          ),
                                          if (isUnread)
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  color: Colors.redAccent,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),

                                      // محتوى الإشعار
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item['notification_title'],
                                                    style: TextStyle(
                                                      fontWeight: isUnread
                                                          ? FontWeight.bold
                                                          : FontWeight.w500,
                                                      fontSize: 16,
                                                      color: AppColor.black,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  Jiffy.parse(
                                                    item['notification_datetime'],
                                                    pattern: "yyyy-MM-dd",
                                                  ).fromNow(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColor.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              item['notification_body'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.4,
                                                color: AppColor.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
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
                    )
                  else
                  // عرض رسم متحرك عندما لا توجد إشعارات
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // استخدام Lottie للرسوم المتحركة
                            // يمكنك استبدالها بصورة Icon إذا لم تكن مستخدمًا Lottie
                            SizedBox(
                              height: 180,
                              width: 180,
                              child: Lottie.asset(
                                'assets/animations/empty-notifications.json',
                                // في حالة عدم وجود ملف Lottie، استخدم الآيكون بدلاً منه
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.notifications_off_outlined,
                                  size: 80,
                                  color: AppColor.grey.withOpacity(0.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'لا توجد إشعارات حالياً',
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColor.grey2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'ستظهر هنا الإشعارات الخاصة بك',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // زر التحديث
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.getData();
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('تحديث'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: AppColor.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
