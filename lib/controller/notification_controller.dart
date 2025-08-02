import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/core/services/services.dart';
import 'package:ecommercecourse/data/datasource/remote/orders/notification_data.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class NotificationController extends GetxController {
  NotificationData notificationData = NotificationData(Get.find());

  List data = [];
  late StatusRequest statusRequest;
  MyServices myServices = Get.find();

  getData() async {
    statusRequest = StatusRequest.loading;
    var response = await notificationData
        .getData(myServices.sharedPreferences.getString("id")!);

    print("=============================== Controller $response ");
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        data.clear();
        data.addAll(response['data']);
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  // دالة لتحديد جميع الإشعارات كمقروءة عند دخول صفحة الإشعارات
  markAllAsRead() async {
    String userId = myServices.sharedPreferences.getString("id")!;
    await notificationData.markAsRead(userId);

    // تحديث عدد الإشعارات في HomeController
    if (Get.isRegistered<HomeControllerImp>()) {
      Get.find<HomeControllerImp>().updateUnreadNotificationCount(0);
    }
  }

  // دالة لتحديد إشعار واحد كمقروء
  markSingleAsRead(String notificationId) async {
    String userId = myServices.sharedPreferences.getString("id")!;
    await notificationData.markAsRead(userId, notificationId: notificationId);

    // تحديث البيانات المحلية
    for (var notification in data) {
      if (notification['notification_id'].toString() == notificationId) {
        notification['notification_read'] = 1;
        break;
      }
    }

    // تحديث عدد الإشعارات في HomeController
    if (Get.isRegistered<HomeControllerImp>()) {
      Get.find<HomeControllerImp>().getUnreadNotificationCount();
    }

    update();
  }

  // دالة للتحقق من حالة قراءة الإشعار
  bool isNotificationRead(Map notification) {
    return notification['notification_read'] == 1;
  }

  // دالة لحساب عدد الإشعارات غير المقروءة محلياً
  int getUnreadCount() {
    return data.where((notification) => notification['notification_read'] == 0).length;
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    // تحديد جميع الإشعارات كمقروءة بعد تحميل البيانات
    markAllAsRead();
  }
}