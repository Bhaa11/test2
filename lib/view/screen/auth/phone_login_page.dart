import 'package:ecommercecourse/view/screen/auth/phone_otp_verification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/constant/color.dart';
import '../../../core/services/services.dart';
import '../../../linkapi.dart';

class PhoneLoginPage extends StatefulWidget {
  @override
  _PhoneLoginPageState createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('تسجيل الدخول'),
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),

              Text(
                'أدخل رقم هاتفك',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 10.h),

              Text(
                'سنرسل لك رمز التحقق عبر الرسائل النصية',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40.h),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: '9647xxxxxxxxx',
                  prefixIcon: Icon(Icons.phone, color: AppColor.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'رقم الهاتف مطلوب';
                  }
                  if (!RegExp(r'^964[0-9]{10}$').hasMatch(value)) {
                    return 'رقم الهاتف غير صحيح (مثال: 9647xxxxxxxxx)';
                  }
                  return null;
                },
              ),

              SizedBox(height: 30.h),

              ElevatedButton(
                onPressed: isLoading ? null : sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
                child: isLoading
                    ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'إرسال رمز التحقق',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600]),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'ستحتفظ بجميع بياناتك ومشترياتك عند تسجيل حسابك',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),

              TextButton(
                onPressed: () => Get.offAllNamed('/homepage'),
                child: Text(
                  'المتابعة كزائر',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendOTP() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final myServices = Get.find<MyServices>();
      String deviceId = myServices.sharedPreferences.getString('device_id') ?? '';

      final response = await http.post(
        Uri.parse(AppLink.sendOtp),
        body: {
          'phone': phoneController.text.trim(),
          'device_id': deviceId,
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          Get.to(() => OTPVerificationPage(
            phone: phoneController.text.trim(),
            actionType: data['data']['action_type'] ?? 'complete_registration',
            userExists: data['data']['user_exists'] ?? false,
            isComplete: data['data']['complete'] ?? false,
            hasGuestAccount: data['data']['has_guest_account'] ?? false,
          ));

          Get.snackbar(
            'تم الإرسال',
            'تم إرسال رمز التحقق بنجاح',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'خطأ',
            data['message'] ?? 'فشل في إرسال رمز التحقق',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
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
      print('Error sending OTP: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في الإرسال، حاول مرة أخرى',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
