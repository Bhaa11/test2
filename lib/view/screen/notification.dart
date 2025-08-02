import 'package:ecommercecourse/controller/notification_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationController());

    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(AppRoute.homepage);
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
              Get.offAllNamed(AppRoute.homepage);
            },
          ),
          actions: [
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
                  // عنوان القسم مع عدد الإشعارات
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        // عرض عدد الإشعارات غير المقروءة
                        if (controller.getUnreadCount() > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              "${controller.getUnreadCount()} جديد",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),

                  if (controller.data.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: controller.data.length,
                        itemBuilder: (context, index) {
                          final item = controller.data[index];
                          final bool isUnread = !controller.isNotificationRead(item);

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
                              // يمكن إضافة وظيفة الحذف هنا
                            },
                            child: Card(
                              elevation: isUnread ? 2 : 0,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: isUnread
                                        ? AppColor.primaryColor.withOpacity(0.3)
                                        : Colors.grey.shade200,
                                    width: isUnread ? 1.5 : 1
                                ),
                              ),
                              // تمييز الإشعارات غير المقروءة بلون خلفية مختلف
                              color: isUnread
                                  ? AppColor.thirdColor.withOpacity(0.05)
                                  : Colors.white,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  // تحديد الإشعار كمقروء عند النقر عليه
                                  if (isUnread) {
                                    controller.markSingleAsRead(item['notification_id'].toString());
                                  }
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
                                                  ? AppColor.primaryColor.withOpacity(0.1)
                                                  : const Color(0xFFEEEEEE),
                                              shape: BoxShape.circle,
                                              border: isUnread
                                                  ? Border.all(
                                                  color: AppColor.primaryColor.withOpacity(0.3),
                                                  width: 1.5
                                              )
                                                  : null,
                                            ),
                                            child: Icon(
                                              Icons.notifications_outlined,
                                              color: isUnread
                                                  ? AppColor.primaryColor
                                                  : AppColor.grey,
                                              size: 24,
                                            ),
                                          ),
                                          if (isUnread)
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 2
                                                  ),
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
                                                      color: isUnread
                                                          ? AppColor.black
                                                          : AppColor.grey2,
                                                    ),
                                                  ),
                                                ),
                                                // مؤشر "جديد" للإشعارات غير المقروءة
                                                if (isUnread)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Text(
                                                      'جديد',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  Jiffy.parse(
                                                    item['notification_datetime'],
                                                    pattern: "yyyy-MM-dd",
                                                  ).fromNow(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isUnread
                                                        ? AppColor.grey
                                                        : AppColor.grey.withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              item['notification_body'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                height: 1.4,
                                                color: isUnread
                                                    ? AppColor.grey
                                                    : AppColor.grey.withOpacity(0.8),
                                                fontWeight: isUnread
                                                    ? FontWeight.w500
                                                    : FontWeight.w400,
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
                            SizedBox(
                              height: 180,
                              width: 180,
                              child: Lottie.asset(
                                'assets/animations/empty-notifications.json',
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