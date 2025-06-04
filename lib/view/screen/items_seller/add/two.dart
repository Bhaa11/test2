import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart'; // إضافة مكتبة intl للتنسيق

import '../../../../controller/items_seller/add_controller.dart';
import '../../../../core/constant/color.dart';
import '../../../../core/functions/validinput.dart';

class ItemsAddStepTwo extends StatefulWidget {
  const ItemsAddStepTwo({super.key});

  @override
  _ItemsAddStepTwoState createState() => _ItemsAddStepTwoState();
}

class _ItemsAddStepTwoState extends State<ItemsAddStepTwo> {
  final controller = Get.find<ItemsAddController>();
  // استخدام GetStorage لتخزين الخيارات المحددة
  final _storage = GetStorage();

  // متغيرات تخزين الخيارات المحددة
  int? _selectedDeliveryPrice;
  String? _selectedDeliveryDuration;
  int? _selectedDiscount = 0; // قيمة افتراضية للخصم
  double? _finalPrice;

  // منسق الأرقام لإضافة الفواصل
  final _numberFormat = NumberFormat("#,###", "ar");

  // قائمة خيارات سعر التوصيل من 1000 إلى 50000
  final List<int> _deliveryPrices = List<int>.generate(50, (i) => (i + 1) * 1000);

  // قائمة خيارات مدة التوصيل
  final List<String> _deliveryDurations = [
    '24 ساعة',
    'يومين',
    'ثلاث أيام',
    'أربع أيام',
    'خمس أيام',
    'ستة أيام',
    'أسبوع'
  ];

  // قائمة خيارات نسبة الخصم من 0% إلى 100% بقفزات 5%
  final List<int> _discountOptions = List<int>.generate(21, (i) => i * 5);

  // مفاتيح التخزين في GetStorage
  static const String keyDeliveryPrice = 'lastDeliveryPrice';
  static const String keyDeliveryDuration = 'lastDeliveryDuration';
  static const String keyDiscount = 'lastDiscount';

  @override
  void initState() {
    super.initState();

    // استرجاع البيانات المخزنة مسبقاً
    _loadSavedPreferences();

    // إضافة مستمعين لتحديث سعر المنتج النهائي عند تغيير السعر أو نسبة الخصم
    controller.price.addListener(_updateFinalPrice);
    controller.discount.addListener(_updateFinalPrice);
  }

  void _loadSavedPreferences() {
    try {
      // استرجاع سعر التوصيل المخزن
      final lastPrice = _storage.read<int>(keyDeliveryPrice);
      if (lastPrice != null) {
        _selectedDeliveryPrice = lastPrice;
        controller.deliveryPrice.text = lastPrice.toString();
        print('استرجاع سعر التوصيل: $lastPrice');
      }

      // استرجاع مدة التوصيل المخزنة
      final lastDuration = _storage.read<String>(keyDeliveryDuration);
      if (lastDuration != null) {
        _selectedDeliveryDuration = lastDuration;
        controller.deliveryDuration.text = lastDuration;
        print('استرجاع مدة التوصيل: $lastDuration');
      }

      // استرجاع نسبة الخصم المخزنة
      final lastDiscount = _storage.read<int>(keyDiscount);
      if (lastDiscount != null) {
        _selectedDiscount = lastDiscount;
        controller.discount.text = lastDiscount.toString();
        print('استرجاع نسبة الخصم: $lastDiscount%');
      }

      // تحديث سعر المنتج النهائي بعد استرجاع البيانات
      _updateFinalPrice();
    } catch (e) {
      print('خطأ أثناء استرجاع البيانات المخزنة: $e');
    }
  }

  // تحديث سعر المنتج النهائي بناءً على السعر ونسبة الخصم
  void _updateFinalPrice() {
    if (!mounted) return;

    try {
      // استخراج السعر بعد إزالة الفواصل من النص
      String priceText = controller.price.text.replaceAll(',', '');
      final price = double.tryParse(priceText) ?? 0;
      final discount = double.tryParse(controller.discount.text) ?? 0;

      setState(() {
        _finalPrice = price - (price * discount / 100);
      });

      print('تم حساب السعر النهائي: $_finalPrice من السعر الأصلي: $price والخصم: $discount%');
    } catch (e) {
      print('خطأ في حساب السعر النهائي: $e');
    }
  }

  // حفظ خيارات التوصيل في التخزين المحلي
  void _saveDeliveryOptions(int? price, String? duration, int? discount) {
    if (price != null) {
      _storage.write(keyDeliveryPrice, price);
      print('تم حفظ سعر التوصيل: $price');
    }

    if (duration != null) {
      _storage.write(keyDeliveryDuration, duration);
      print('تم حفظ مدة التوصيل: $duration');
    }

    if (discount != null) {
      _storage.write(keyDiscount, discount);
      print('تم حفظ نسبة الخصم: $discount%');
    }
  }

  // تنسيق الرقم بإضافة الفواصل
  String _formatNumber(num value) {
    return _numberFormat.format(value);
  }

  @override
  void dispose() {
    // إزالة المستمعين عند إغلاق الصفحة
    controller.price.removeListener(_updateFinalPrice);
    controller.discount.removeListener(_updateFinalPrice);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: _buildPricingCard(),
      ),
    );
  }

  Widget _buildPricingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Form(
          key: controller.stepTwoFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                icon: Icons.payments_rounded,
                title: 'التفاصيل المالية',
                subtitle: 'أدخل معلومات السعر والمخزون والتوصيل',
              ),
              SizedBox(height: 32.h),

              // قسم تسعير المنتج
              _buildPricingSection(),
              SizedBox(height: 32.h),

              // قسم معلومات التوصيل
              _buildDeliverySection(),
              SizedBox(height: 32.h),

              // قسم الخصم
              _buildDiscountSection(),
              SizedBox(height: 40.h),

              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionHeader(
          icon: Icons.monetization_on_outlined,
          title: 'معلومات المنتج',
        ),
        SizedBox(height: 16.h),

        _buildNumberInput(
          controller: controller.price,
          label: 'سعر المنتج',
          hintText: 'السعر بالدينار العراقي',
          suffix: 'د.ع',
          icon: Icons.monetization_on,
          validator: (v) => validInput(v?.replaceAll(',', '') ?? '', 1, 10, 'number'),
          onChanged: (value) {
            _updateFinalPrice();
          },
        ),
        SizedBox(height: 16.h),

        _buildNumberInput(
          controller: controller.count,
          label: 'الكمية المتاحة',
          hintText: 'عدد القطع المتوفرة',
          icon: Icons.inventory_2,
          validator: (v) => validInput(v?.replaceAll(',', '') ?? '', 1, 5, 'number'),
        ),
      ],
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionHeader(
          icon: Icons.local_shipping_outlined,
          title: 'معلومات التوصيل',
        ),
        SizedBox(height: 16.h),

        Row(
          children: [
            // اختيار سعر التوصيل
            Expanded(
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                value: _selectedDeliveryPrice,
                decoration: _buildDropdownDecoration('سعر التوصيل'),
                icon: Icon(
                  Icons.arrow_drop_down_circle_outlined,
                  color: AppColor.primaryColor,
                ),
                items: _deliveryPrices
                    .map((val) => DropdownMenuItem(
                  value: val,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                      children: [
                        TextSpan(
                          text: _formatNumber(val),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: ' د.ع'),
                      ],
                    ),
                  ),
                ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDeliveryPrice = val;
                    controller.deliveryPrice.text = val.toString();
                    // حفظ القيمة المحددة في التخزين
                    _saveDeliveryOptions(val, null, null);
                  });
                },
                validator: (v) => v == null ? 'يرجى تحديد سعر التوصيل' : null,
              ),
            ),
            SizedBox(width: 16.w),
            // اختيار مدة التوصيل
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedDeliveryDuration,
                decoration: _buildDropdownDecoration('مدة التوصيل'),
                icon: Icon(
                  Icons.arrow_drop_down_circle_outlined,
                  color: AppColor.primaryColor,
                ),
                items: _deliveryDurations
                    .map((dur) => DropdownMenuItem(
                  value: dur,
                  child: Text(dur, style: TextStyle(fontSize: 14.sp)),
                ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDeliveryDuration = val;
                    controller.deliveryDuration.text = val!;
                    // حفظ القيمة المحددة في التخزين
                    _saveDeliveryOptions(null, val, null);
                  });
                },
                validator: (v) => v == null ? 'يرجى تحديد مدة التوصيل' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiscountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionHeader(
          icon: Icons.discount_outlined,
          title: 'الخصم',
        ),
        SizedBox(height: 16.h),

        // اختيار نسبة الخصم
        DropdownButtonFormField<int>(
          isExpanded: true,
          value: _selectedDiscount,
          decoration: _buildDropdownDecoration('نسبة الخصم'),
          icon: Icon(
            Icons.arrow_drop_down_circle_outlined,
            color: AppColor.primaryColor,
          ),
          items: _discountOptions
              .map((val) => DropdownMenuItem(
            value: val,
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14.sp, color: Colors.black),
                children: [
                  TextSpan(
                    text: val.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: '%'),
                ],
              ),
            ),
          ))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedDiscount = val;
              controller.discount.text = val.toString();
              // حفظ نسبة الخصم في التخزين
              _saveDeliveryOptions(null, null, val);
              _updateFinalPrice();
            });
          },
        ),

        // عرض السعر النهائي بعد الخصم
        if (_finalPrice != null && _finalPrice! > 0) ...[
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.price_change_outlined,
                  color: AppColor.primaryColor,
                  size: 24.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'السعر النهائي بعد الخصم',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.grey2,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: AppColor.primaryColor,
                          ),
                          children: [
                            TextSpan(
                              text: _formatNumber(_finalPrice!.toInt()),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' د.ع'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      filled: true,
      fillColor: Colors.grey.shade50,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.red.shade300, width: 2),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: AppColor.primaryColor,
                size: 22.r,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.grey2,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(right: 48.w),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.grey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.r,
          color: AppColor.primaryColor,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.grey2,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    String? hintText,
    String? suffix,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: validator,
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
      onChanged: (value) {
        // محاولة تنسيق النص مع إضافة فواصل للأرقام
        if (value.isNotEmpty) {
          try {
            // إزالة كل الفواصل من النص لتحويله إلى رقم
            final cleanValue = value.replaceAll(',', '');
            final number = int.parse(cleanValue);
            final formatted = _formatNumber(number);

            // تجنب حلقة لا نهائية في التحديث
            if (formatted != value) {
              final currentPos = controller.selection.baseOffset;
              // حساب الفرق في الطول قبل وبعد التنسيق
              final lengthDiff = formatted.length - value.length;
              // تحديث TextEditingValue
              controller.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(
                  offset: currentPos + lengthDiff > 0 ? currentPos + lengthDiff : formatted.length,
                ),
              );
            }
          } catch (e) {
            // تجاهل الخطأ في حالة كانت القيمة غير صالحة للتحويل
            print('خطأ في تنسيق الرقم: $e');
          }
        }

        // استدعاء الدالة المخصصة إذا تم تمريرها
        if (onChanged != null) {
          onChanged(value);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixText: suffix,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIcon: Icon(icon, color: AppColor.primaryColor),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.9),
            AppColor.primaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // قبل المتابعة، تأكد من إزالة الفواصل من قيمة السعر المرسلة للخادم
          String originalPrice = controller.price.text;
          controller.price.text = originalPrice.replaceAll(',', '');
          controller.nextStep();
          // استعادة النص المنسق للعرض بعد إرسال الطلب
          Future.delayed(Duration.zero, () {
            controller.price.text = originalPrice;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'المتابعة للخطوة التالية',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_rounded, size: 20.r),
          ],
        ),
      ),
    );
  }
}
