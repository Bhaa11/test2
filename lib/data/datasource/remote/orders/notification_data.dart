import 'package:ecommercecourse/core/class/crud.dart';
import 'package:ecommercecourse/linkapi.dart';

class NotificationData {
  Crud crud;
  NotificationData(this.crud);

  // جلب جميع الإشعارات مع حالة القراءة
  getData(String id) async {
    var response = await crud.postData(AppLink.notification, {"id": id});
    return response.fold((l) => l, (r) => r);
  }

  // جلب عدد الإشعارات غير المقروءة
  getUnreadCount(String id) async {
    var response = await crud.postData(AppLink.notificationCount, {"id": id});
    return response.fold((l) => l, (r) => r);
  }

  // تحديد الإشعارات كمقروءة
  markAsRead(String id, {String? notificationId}) async {
    Map<String, String> data = {"id": id};
    if (notificationId != null) {
      data["notification_id"] = notificationId;
    }
    var response = await crud.postData(AppLink.notificationMarkRead, data);
    return response.fold((l) => l, (r) => r);
  }
}