import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'core/services/services.dart';
import 'core/localization/translation.dart';
import 'core/localization/changelocal.dart';
import 'core/constant/color.dart';
import 'routes.dart';
import 'bindings/intialbindings.dart';
import 'linkapi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialServices();

  const int appID = 156821102;
  const String appSign = "2fde9bdf21fc01dd44783d791afc1820fcb32940b5839c9ab066d335e9e99b9c";
  ZIMAppConfig appConfig = ZIMAppConfig();
  appConfig.appID = appID;
  appConfig.appSign = appSign;
  ZIM.create(appConfig);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColor.primaryColor,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeController = Get.put(LocaleController());
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SpeerIQ',
          translations: MyTranslation(),
          locale: localeController.language,
          fallbackLocale: const Locale('ar'),
          theme: localeController.appTheme,
          initialBinding: InitialBindings(),
          getPages: routes,
          home: SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(Duration(seconds: 2));
    try {
      final myServices = Get.find<MyServices>();
      final prefs = myServices.sharedPreferences;
      final authController = Get.put(AuthController());

      bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      String? userType = prefs.getString('user_type');

      if (isLoggedIn && userType == 'registered') {
        String? userId = prefs.getString('id');
        String? userName = prefs.getString('username');
        if (userId != null && userName != null) {
          Map<String, dynamic> userData = {
            'users_id': userId,
            'users_name': userName,
            'users_email': prefs.getString('email') ?? '',
            'users_phone': prefs.getString('phone') ?? '',
            'users_role': prefs.getString('role') ?? 'customer', // إضافة الدور
          };
          authController.setCurrentUser(userData);
          authController.setAuthenticated(true);
          await _loginToZIM(userId, userName);
          Get.offAllNamed('/homepage');
          return;
        } else {
          // بيانات المستخدم غير مكتملة، اعتبره غير مسجل مؤقتاً
          isLoggedIn = false;
        }
      }

      if (!isLoggedIn) {
        final guestController = Get.put(GuestController());
        await guestController.initializeGuestAccount();
        final guestData = guestController.currentUser;
        if (guestData != null && guestData['users_id'] != null) {
          await _loginToZIM(
            guestData['users_id'].toString(),
            guestData['users_name'] ?? 'زائر',
          );
        }
        Get.offAllNamed('/homepage');
      }
    } catch (e) {
      print('خطأ في تهيئة التطبيق: $e');
      Get.offAllNamed('/homepage');
    }
  }

  Future<void> _loginToZIM(String userId, String userName) async {
    try {
      ZIMUserInfo userInfo = ZIMUserInfo();
      userInfo.userID = userId;
      userInfo.userName = userName;
      ZIMLoginConfig loginConfig = ZIMLoginConfig();
      loginConfig.userName = userName;
      loginConfig.token = "";
      await ZIM.getInstance()?.login(userId, loginConfig);
      print('تم تسجيل دخول المستخدم: $userId');
    } catch (e) {
      print('خطأ في تسجيل دخول ZIM: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.primaryColor,
              AppColor.secondColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.speed_rounded,
                size: 80.w,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              'SpeerIQ',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'مرحباً بك في عالم السرعة والذكاء',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 50.h),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            SizedBox(height: 20.h),
            Text(
              'جاري التحميل...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthController extends GetxController {
  final _isAuthenticated = false.obs;
  final _currentUser = Rxn<Map<String, dynamic>>();

  bool get isAuthenticated => _isAuthenticated.value;
  RxBool get authStateChanges => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser.value;
  bool get isGuest => !_isAuthenticated.value;

  void setAuthenticated(bool value) {
    _isAuthenticated.value = value;
  }

  void setCurrentUser(Map<String, dynamic>? user) {
    _currentUser.value = user;
  }

  Future<void> logout() async {
    try {
      await ZIM.getInstance()?.logout();
      final myServices = Get.find<MyServices>();
      // مسح كافة بيانات المستخدم المسجل والزائر
      await myServices.sharedPreferences.clear();
      _isAuthenticated.value = false;
      _currentUser.value = null;
      Get.offAllNamed('/homepage');
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
    }
  }

  Future<void> login(Map<String, dynamic> userData) async {
    try {
      final myServices = Get.find<MyServices>();
      final prefs = myServices.sharedPreferences;

      await prefs.setString('id', userData['users_id'].toString());
      await prefs.setString('username', userData['users_name'] ?? '');
      await prefs.setString('email', userData['users_email'] ?? '');
      await prefs.setString('phone', userData['users_phone'] ?? '');
      await prefs.setString('role', userData['users_role'] ?? 'customer'); // حفظ الدور
      await prefs.setString('user_type', 'registered');
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('step', "2");

      if (userData['users_id'] != null && userData['users_name'] != null) {
        ZIMUserInfo userInfo = ZIMUserInfo();
        userInfo.userID = userData['users_id'].toString();
        userInfo.userName = userData['users_name'];
        ZIMLoginConfig loginConfig = ZIMLoginConfig();
        loginConfig.userName = userData['users_name'];
        loginConfig.token = "";
        await ZIM.getInstance()?.login(userData['users_id'].toString(), loginConfig);
      }

      _isAuthenticated.value = true;
      _currentUser.value = userData;

      // عند تسجيل الدخول بنجاح، يجب مسح بيانات الزائر القديمة إن وجدت
      if (Get.isRegistered<GuestController>()) {
        final guestController = Get.find<GuestController>();
        await guestController.clearGuestAccountPreferences(); // دالة جديدة لمسح الـ Prefs
      }
    } catch (e) {
      print('خطأ في تسجيل الدخول: $e');
      throw e;
    }
  }
}

class GuestController extends GetxController {
  final _currentUser = Rxn<Map<String, dynamic>>();
  final _isGuest = true.obs;

  Map<String, dynamic>? get currentUser => _currentUser.value;
  bool get isGuest => _isGuest.value;
  String get userId => _currentUser.value?['users_id']?.toString() ?? '';
  String get userName => _currentUser.value?['users_name'] ?? 'زائر';

  Future<void> initializeGuestAccount() async {
    try {
      final myServices = Get.find<MyServices>();
      final prefs = myServices.sharedPreferences;

      // تحقق مما إذا كان المستخدم مسجلاً بالفعل
      bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      if (isLoggedIn) {
        print('يوجد حساب مسجل بالفعل، لن يتم تهيئة حساب زائر.');
        _isGuest.value = false; // تحديث الحالة لتعكس أننا لسنا ضيوفًا
        return;
      }

      // التحقق من وجود حساب زائر مسبقاً
      String? existingGuestData = prefs.getString('guest_user');
      String? existingDeviceId = prefs.getString('device_id');
      bool guestAccountCreatedFlag = prefs.getBool('guest_account_created') ?? false;

      if (existingGuestData != null && existingDeviceId != null && guestAccountCreatedFlag) {
        // استخدام الحساب الزائر الموجود
        Map<String, dynamic> userData = Map<String, dynamic>.from(json.decode(existingGuestData));
        _currentUser.value = userData;
        _isGuest.value = true;
        await _saveGuestDataToPrefs(userData);
        await updateGuestActivity({'last_login': DateTime.now().toIso8601String()});
        print('تم استخدام الحساب الزائر الموجود: ${userData['users_id']}');
        return;
      }

      // إنشاء حساب زائر جديد فقط في حالة عدم وجود حساب مسبقاً
      await _createNewGuestAccount();
    } catch (e) {
      print('خطأ في تهيئة الحساب الزائر: $e');
      // في حالة الخطأ، إنشاء حساب زائر محلي
      await _createLocalGuestAccount();
    }
  }

  Future<void> _saveGuestDataToPrefs(Map<String, dynamic> userData) async {
    try {
      final myServices = Get.find<MyServices>();
      final prefs = myServices.sharedPreferences;

      await prefs.setString('guest_user', json.encode(userData)); // حفظ بيانات الزائر كـ JSON
      await prefs.setString('device_id', userData['users_device_id']); // حفظ معرف الجهاز
      await prefs.setBool('guest_account_created', true); // علامة لبيان أن حساب الزائر قد تم إنشاؤه

      // حفظ البيانات الأساسية للوصول السريع
      await prefs.setString('id', userData['users_id'].toString());
      await prefs.setString('username', userData['users_name'] ?? 'زائر');
      await prefs.setString('email', userData['users_email'] ?? '');
      await prefs.setString('phone', userData['users_phone'] ?? '');

      // التحقق من نوع المستخدم الحالي قبل تغييره
      bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      if (!isLoggedIn) {
        await prefs.setString('user_type', 'guest');
        await prefs.setBool('is_logged_in', false);
        await prefs.setString('step', "1");
      }
      print('تم حفظ بيانات الحساب الزائر: ${userData['users_id']}');
    } catch (e) {
      print('خطأ في حفظ بيانات الحساب الزائر: $e');
    }
  }

  Future<void> _createNewGuestAccount() async {
    try {
      final myServices = Get.find<MyServices>();
      final prefs = myServices.sharedPreferences;
      String deviceId = await _generateDeviceId();
      String deviceInfo = await _getDeviceInfo();

      try {
        final response = await http.post(
          Uri.parse(AppLink.createGuestAccount),
          body: {
            'device_id': deviceId,
            'device_info': deviceInfo,
          },
        ).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            Map<String, dynamic> userData = Map<String, dynamic>.from(data['data']['user']);
            _currentUser.value = userData;
            _isGuest.value = true;
            await _saveGuestDataToPrefs(userData); // حفظ بيانات الزائر في SharedPreferences
            print('تم إنشاء حساب زائر جديد في قاعدة البيانات: ${userData['users_id']}');
            return;
          }
        }
      } catch (e) {
        print('خطأ في الاتصال بالخادم لإنشاء حساب زائر: $e');
      }

      // في حالة فشل الإنشاء على الخادم، إنشاء حساب زائر محلي
      await _createLocalGuestAccount();
    } catch (e) {
      print('خطأ في إنشاء الحساب الزائر (عام): $e');
      await _createLocalGuestAccount();
    }
  }

  Future<void> _createLocalGuestAccount() async {
    try {
      final myServices = Get.find<MyServices>();
      final prefs = myServices.sharedPreferences;
      String deviceId = await _generateDeviceId();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      Map<String, dynamic> localGuestData = {
        'users_id': 'guest_$timestamp',
        'users_name': 'زائر ${deviceId.substring(0, 6)}',
        'users_email': 'guest$timestamp@local.com',
        'users_phone': '',
        'users_type': 'guest',
        'users_device_id': deviceId,
        'users_approve': '1',
        'users_create': DateTime.now().toIso8601String(),
        'is_local': true, // علامة للإشارة إلى أنه حساب محلي فقط
      };

      await _saveGuestDataToPrefs(localGuestData); // حفظ بيانات الزائر في SharedPreferences

      _currentUser.value = localGuestData;
      _isGuest.value = true;

      print('تم إنشاء حساب زائر محلي: ${localGuestData['users_id']}');
    } catch (e) {
      print('خطأ في إنشاء الحساب الزائر المحلي: $e');
    }
  }

  Future<void> updateGuestActivity(Map<String, dynamic> activity) async {
    try {
      final myServices = Get.find<MyServices>();
      final prefs = myServices.sharedPreferences;
      String? deviceId = prefs.getString('device_id');

      // لا نرسل تحديث نشاط إذا كان الحساب زائرًا محليًا فقط
      if (deviceId != null && !(_currentUser.value?['is_local'] ?? false)) {
        try {
          await http.post(
            Uri.parse(AppLink.updateGuestActivity),
            body: {
              'device_id': deviceId,
              'activity_data': json.encode(activity),
            },
          ).timeout(Duration(seconds: 5));
        } catch (e) {
          print('خطأ في تحديث النشاط على الخادم: $e');
        }
      }
    } catch (e) {
      print('خطأ في تحديث نشاط الحساب الزائر: $e');
    }
  }

  // هذه الدالة تمسح فقط متغيرات المتحكم، وليس بيانات SharedPreferences
  Future<void> clearGuestAccount() async {
    _currentUser.value = null;
    _isGuest.value = false;
    print('تم مسح متغيرات الحساب الزائر مؤقتاً');
  }

  // دالة جديدة لمسح بيانات الزائر من SharedPreferences بشكل صريح
  Future<void> clearGuestAccountPreferences() async {
    final myServices = Get.find<MyServices>();
    final prefs = myServices.sharedPreferences;
    await prefs.remove('guest_user');
    await prefs.remove('device_id');
    await prefs.remove('guest_account_created');
    print('تم مسح بيانات الحساب الزائر من SharedPreferences');
  }

  Future<String> _generateDeviceId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId = '';
      if (GetPlatform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (GetPlatform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
      }

      // استخدم معرف الجهاز الأساسي فقط دون إضافة timestamp لتجنب التغيير
      if (deviceId.isEmpty) {
        // في حال فشل الحصول على معرف فريد، نستخدم حلاً احتياطياً ثابتاً نسبياً
        deviceId = 'fallback_device_${(await http.get(Uri.parse('http://worldtimeapi.org/api/ip'))).body.hashCode}';
      }
      return deviceId;
    } catch (e) {
      print('خطأ في توليد معرف الجهاز: $e');
      return 'device_error_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<String> _getDeviceInfo() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> info = {};
      if (GetPlatform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        info = {
          'platform': 'android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
        };
      } else if (GetPlatform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        info = {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'version': iosInfo.systemVersion,
        };
      }
      return json.encode(info);
    } catch (e) {
      return json.encode({
        'platform': GetPlatform.isAndroid ? 'android' : 'ios',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }
}
