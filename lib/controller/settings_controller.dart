import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/core/services/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:zego_zim/zego_zim.dart';
import '../main.dart';

class SettingsController extends GetxController {
  MyServices myServices = Get.find();

  logout() async {
    try {
      String userid = myServices.sharedPreferences.getString("id")!;
      // إلغاء الاشتراك من المواضيع
      FirebaseMessaging.instance.unsubscribeFromTopic("users");
      FirebaseMessaging.instance.unsubscribeFromTopic("users${userid}");
      // تسجيل خروج من ZIM
      await ZIM.getInstance()?.logout();

      // مسح بيانات المستخدم المسجل
      await myServices.sharedPreferences.remove('is_logged_in');
      await myServices.sharedPreferences.remove('user_type');
      await myServices.sharedPreferences.remove('id');
      await myServices.sharedPreferences.remove('username');
      await myServices.sharedPreferences.remove('email');
      await myServices.sharedPreferences.remove('phone');
      await myServices.sharedPreferences.remove('role');

      // مسح بيانات الزائر بشكل كامل لضمان إنشاء حساب زائر جديد
      await myServices.sharedPreferences.remove('guest_user');
      await myServices.sharedPreferences.remove('device_id');
      await myServices.sharedPreferences.remove('guest_account_created');

      await myServices.sharedPreferences.setString('step', "1");

      // تحديث حالة AuthController
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        authController.setAuthenticated(false);
        authController.setCurrentUser(null);
      }

      // إعادة تهيئة حساب الزائر (سيتم إنشاء حساب جديد إذا لم يكن موجودًا)
      final guestController = Get.put(GuestController());
      await guestController.initializeGuestAccount();

      final guestData = guestController.currentUser;
      if (guestData != null && guestData['users_id'] != null) {
        try {
          ZIMUserInfo userInfo = ZIMUserInfo();
          userInfo.userID = guestData['users_id'].toString();
          userInfo.userName = guestData['users_name'] ?? 'زائر';
          ZIMLoginConfig loginConfig = ZIMLoginConfig();
          loginConfig.userName = guestData['users_name'] ?? 'زائر';
          loginConfig.token = "";
          await ZIM.getInstance()?.login(guestData['users_id'].toString(), loginConfig);
          print('تم تسجيل دخول الزائر في ZIM: ${guestData['users_id']}');
        } catch (e) {
          print('خطأ في تسجيل دخول الزائر في ZIM: $e');
        }
      }

      Get.offAllNamed(AppRoute.homepage);
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
      Get.offAllNamed(AppRoute.homepage);
    }
  }
}
