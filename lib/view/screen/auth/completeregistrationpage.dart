import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constant/color.dart';
import '../../../core/services/services.dart';
import '../../../linkapi.dart';
import '../../../main.dart'; // استيراد للوصول إلى AuthController

class CompleteRegistrationPage extends StatefulWidget {
  final String phone;
  final String actionType;
  final Map<String, dynamic> userData;

  const CompleteRegistrationPage({
    Key? key,
    required this.phone,
    required this.actionType,
    required this.userData,
  }) : super(key: key);

  @override
  _CompleteRegistrationPageState createState() =>
      _CompleteRegistrationPageState();
}

class _CompleteRegistrationPageState extends State<CompleteRegistrationPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController storeDescriptionController =
  TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isSeller = false;

  @override
  void initState() {
    super.initState();

    if (widget.userData['users_role'] == 'seller' ||
        (widget.userData['users_description'] != null &&
            widget.userData['users_description']
                .toString()
                .contains('بائع في التطبيق'))) {
      isSeller = true;
      if (widget.userData['users_description'] != null &&
          !widget.userData['users_description']
              .toString()
              .contains('بائع في التطبيق')) {
        storeDescriptionController.text = widget.userData['users_description'];
      }
    }
  }

  bool isValidName(String name) {
    if (name.trim().isEmpty || name.trim().length < 2) {
      return false;
    }
    for (int i = 0; i < name.length; i++) {
      int code = name.codeUnitAt(i);
      bool isArabic =
          (code >= 0x0600 && code <= 0x06FF) || (code >= 0xFE70 && code <= 0xFEFF);
      bool isEnglish =
          (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
      bool isSpace = code == 32;

      if (!isArabic && !isEnglish && !isSpace) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _getPageTitle(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                Text(
                  _getPageTitle(),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Text(
                  _getPageDescription(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                TextFormField(
                  controller: firstNameController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'الاسم الأول',
                    hintText: 'أدخل اسمك الأول',
                    prefixIcon: Icon(Icons.person, color: AppColor.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide:
                      BorderSide(color: AppColor.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الاسم الأول مطلوب';
                    }
                    if (!isValidName(value)) {
                      return 'الاسم يجب أن يحتوي على أحرف عربية أو إنجليزية فقط وعلى الأقل حرفين';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: lastNameController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'الاسم الأخير',
                    hintText: 'أدخل اسمك الأخير',
                    prefixIcon:
                    Icon(Icons.person_outline, color: AppColor.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide:
                      BorderSide(color: AppColor.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الاسم الأخير مطلوب';
                    }
                    if (!isValidName(value)) {
                      return 'الاسم يجب أن يحتوي على أحرف عربية أو إنجليزية فقط وعلى الأقل حرفين';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.grey[50],
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      'أريد أن أكون بائع في التطبيق',
                      style: TextStyle(fontSize: 16.sp),
                      textAlign: TextAlign.right,
                    ),
                    subtitle: Text(
                      'يمكنك إضافة وبيع منتجاتك',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                      textAlign: TextAlign.right,
                    ),
                    value: isSeller,
                    onChanged: (value) {
                      setState(() {
                        isSeller = value ?? false;
                        if (!isSeller) {
                          storeDescriptionController.clear();
                        }
                      });
                    },
                    activeColor: AppColor.primaryColor,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                if (isSeller) ...[
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: storeDescriptionController,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: 'وصف متجرك',
                      hintText:
                      'اكتب وصفاً مختصراً عن متجرك ونوع المنتجات التي تبيعها',
                      prefixIcon: Icon(Icons.store, color: AppColor.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                        BorderSide(color: AppColor.primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (isSeller && (value == null || value.trim().isEmpty)) {
                        return 'وصف المتجر مطلوب للبائعين';
                      }
                      if (value != null &&
                          value.trim().isNotEmpty &&
                          value.trim().length < 10) {
                        return 'وصف المتجر يجب أن يكون على الأقل 10 أحرف';
                      }
                      return null;
                    },
                  ),
                ],
                SizedBox(height: 30.h),
                ElevatedButton(
                  onPressed: isLoading ? null : completeRegistration,
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
                    _getButtonText(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                if (widget.actionType == 'upgrade_guest_account')
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600]),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'سيتم الاحتفاظ بجميع مشترياتك ومفضلاتك',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.blue[700],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (widget.actionType) {
      case 'upgrade_guest_account':
        return 'ترقية الحساب';
      case 'complete_registration':
        return 'إكمال التسجيل';
      default:
        return 'تسجيل الحساب';
    }
  }

  String _getPageDescription() {
    switch (widget.actionType) {
      case 'upgrade_guest_account':
        return 'أكمل بياناتك لترقية حسابك الزائر';
      case 'complete_registration':
        return 'أكمل بياناتك لإنهاء التسجيل';
      default:
        return 'أدخل بياناتك لإنشاء حسابك';
    }
  }

  String _getButtonText() {
    switch (widget.actionType) {
      case 'upgrade_guest_account':
        return 'ترقية الحساب';
      case 'complete_registration':
        return 'إكمال التسجيل';
      default:
        return 'حفظ البيانات';
    }
  }

  Future<void> completeRegistration() async {
    print('🔵 بدء عملية إكمال التسجيل');

    if (!formKey.currentState!.validate()) {
      print('🔴 فشل في التحقق من صحة النموذج');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final myServices = Get.find<MyServices>();
      String deviceId = myServices.sharedPreferences.getString('device_id') ?? '';

      String defaultEmail =
          widget.phone.substring(widget.phone.length - 10) + "@speeriq.com";

      print('🔵 البيانات المرسلة:');
      print('- الهاتف: ${widget.phone}');
      print('- الاسم الأول: ${firstNameController.text.trim()}');
      print('- الاسم الأخير: ${lastNameController.text.trim()}');
      print('- الإيميل: $defaultEmail');
      print('- النوع: ${isSeller ? 'seller' : 'customer'}');
      print(
          '- وصف المتجر: ${isSeller ? storeDescriptionController.text.trim() : ''}');
      print('- معرف الجهاز: $deviceId');
      print('- نوع العملية: ${widget.actionType}');
      print('- رابط API: ${AppLink.completeRegistration}');

      final response = await http.post(
        Uri.parse(AppLink.completeRegistration),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'phone': widget.phone,
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'email': defaultEmail,
          'role': isSeller ? 'seller' : 'customer',
          'storeDescription':
          isSeller ? storeDescriptionController.text.trim() : '',
          'device_id': deviceId,
          'action_type': widget.actionType,
        },
      ).timeout(Duration(seconds: 30));

      print('🔵 كود الاستجابة: ${response.statusCode}');
      print('🔵 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔵 البيانات المفسرة: $data');

        if (data['status'] == 'success') {
          print('🟢 نجح إكمال التسجيل');

          final authController = Get.find<AuthController>();
          await authController.login(data['data']['user']);
          print('🟢 تم تسجيل الدخول عبر AuthController');

          Get.offAllNamed('/homepage');

          String successMessage =
          widget.actionType == 'upgrade_guest_account'
              ? 'تم ترقية حسابك بنجاح! مرحباً بك ${firstNameController.text}'
              : 'تم إكمال التسجيل بنجاح! مرحباً بك ${firstNameController.text}';

          Get.snackbar(
            'مرحباً بك',
            successMessage,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 4),
          );
        } else {
          print('🔴 فشل إكمال التسجيل: ${data['message']}');
          Get.snackbar(
            'خطأ',
            data['message'] ?? 'فشل في حفظ البيانات',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        print('🔴 خطأ في الشبكة: ${response.statusCode}');
        Get.snackbar(
          'خطأ في الشبكة',
          'تحقق من اتصالك بالإنترنت وحاول مرة أخرى (${response.statusCode})',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('🔴 خطأ في إكمال التسجيل: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في حفظ البيانات، حاول مرة أخرى: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
      print('🔵 انتهت عملية إكمال التسجيل');
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    storeDescriptionController.dispose();
    super.dispose();
  }
}
