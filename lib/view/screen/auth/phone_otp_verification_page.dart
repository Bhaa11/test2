import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:pinput/pinput.dart';
import '../../../core/constant/color.dart';
import '../../../core/services/services.dart';
import '../../../linkapi.dart';
import '../../../main.dart';
import 'completeregistrationpage.dart';

// تأكد من استيراد الـ AuthController الخاص بك
// import 'path/to/your/auth_controller.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phone;
  final String actionType;
  final bool userExists;
  final bool isComplete;
  final bool hasGuestAccount;

  const OTPVerificationPage({
    Key? key,
    required this.phone,
    required this.actionType,
    required this.userExists,
    required this.isComplete,
    required this.hasGuestAccount,
  }) : super(key: key);

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  bool isLoading = false;
  bool canResend = false;
  bool isResending = false;
  int countdown = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    canResend = false;
    countdown = 60;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        if (countdown > 0) {
          setState(() {
            countdown--;
          });
        } else {
          setState(() {
            canResend = true;
          });
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50.w,
      height: 56.h,
      textStyle: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: AppColor.primaryColor,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColor.primaryColor, width: 2),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColor.primaryColor.withOpacity(0.7), width: 2),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 24.w, color: AppColor.primaryColor),
                onPressed: () => Get.back(),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(height: 32.h),
            Text(
              'أدخل رمز التحقق',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D29),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'تم إرسال رمز التحقق إلى',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              widget.phone,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 48.h),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Pinput(
                controller: pinController,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                length: 6,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onCompleted: (pin) {
                  verifyOTP();
                },
              ),
            ),
            SizedBox(height: 40.h),
            Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primaryColor,
                    AppColor.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                  height: 24.h,
                  width: 24.h,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  'التحقق',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: TextButton(
                onPressed: (canResend && !isResending) ? resendOTP : null,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: isResending
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 16.h,
                      width: 16.h,
                      child: CircularProgressIndicator(
                        color: AppColor.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'جاري الإرسال...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ],
                )
                    : Text(
                  canResend
                      ? 'إعادة إرسال الرمز'
                      : 'إعادة الإرسال خلال ${countdown}s',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: (canResend && !isResending)
                        ? AppColor.primaryColor
                        : Colors.grey[500],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> verifyOTP() async {
    String otp = pinController.text;
    if (otp.length != 6) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال رمز التحقق كاملاً',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      MyServices myServices = Get.find(); // تم تعريف المتغير هنا
      String deviceId = myServices.sharedPreferences.getString('device_id') ?? '';

      final response = await http.post(
        Uri.parse(AppLink.verifyOtp),
        body: {
          'phone': widget.phone,
          'code': otp,
          'device_id': deviceId,
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          String actionType = data['data']['action_type'];
          var userData = data['data']['user'];

          if (actionType == 'login') {
            try {
              final authController = Get.find<AuthController>();
              await authController.logout(); // تأكد من تسجيل الخروج الكامل أولاً
              await Future.delayed(const Duration(milliseconds: 500)); // انتظر قليلاً

              // ==========================================================
              // ✔️ التعديل المطلوب: تخزين بيانات المستخدم (يشمل الدور الآن)
              // ==========================================================
              await myServices.sharedPreferences.setString('id', userData['users_id'].toString());
              await myServices.sharedPreferences.setString('username', userData['users_name']);
              await myServices.sharedPreferences.setString('email', userData['users_email'] ?? '');
              await myServices.sharedPreferences.setString('phone', userData['users_phone']);
              await myServices.sharedPreferences.setString('role', userData['users_role'] ?? 'customer'); // حفظ الدور
              await myServices.sharedPreferences.setString('user_type', 'registered'); // التأكيد على النوع مسجل
              await myServices.sharedPreferences.setBool('is_logged_in', true); // التأكيد على حالة تسجيل الدخول
              await myServices.sharedPreferences.setString('step', "2");

              // تسجيل الدخول باستخدام AuthController
              await authController.login(userData);

              Get.offAllNamed('/main');
              Get.snackbar(
                'مرحباً بك',
                'تم تسجيل الدخول بنجاح',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            } catch (e) {
              print('Error during login action: $e');
              Get.snackbar(
                'خطأ في الدخول',
                'فشل إتمام عملية الدخول. حاول مرة أخرى.',
                backgroundColor: Colors.orange[800],
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } else {
            // توجيه إلى صفحة إكمال التسجيل أو ترقية الحساب
            Get.off(() => CompleteRegistrationPage(
              phone: widget.phone,
              actionType: actionType,
              userData: userData ?? {},
            ));
          }
        } else {
          Get.snackbar(
            'خطأ',
            data['message'] ?? 'رمز التحقق غير صحيح',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          pinController.clear();
          focusNode.requestFocus();
        }
      } else {
        Get.snackbar(
          'خطأ في الشبكة',
          'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في التحقق، حاول مرة أخرى',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> resendOTP() async {
    setState(() {
      isResending = true;
    });

    try {
      final myServices = Get.find<MyServices>();
      String deviceId = myServices.sharedPreferences.getString('device_id') ?? '';

      final response = await http.post(
        Uri.parse(AppLink.sendOtp),
        body: {
          'phone': widget.phone,
          'device_id': deviceId,
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          Get.snackbar(
            'تم الإرسال',
            'تم إعادة إرسال رمز التحقق بنجاح',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          startCountdown();
          pinController.clear();
          focusNode.requestFocus();
        } else {
          Get.snackbar(
            'خطأ',
            data['message'] ?? 'فشل في إعادة إرسال الرمز',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print('Error resending OTP: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في إعادة الإرسال',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if(mounted){
        setState(() {
          isResending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
