import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart'; // إضافة مكتبة intl للتنسيق

import '../../../../controller/items_seller/add_controller.dart';
import '../../../../core/constant/color.dart';
import '../../../../core/functions/validinput.dart';

class NumberInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,###", "ar");

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // إزالة الفواصل من النص الجديد
    String cleanText = newValue.text.replaceAll(',', '');

    // التحقق من أن النص يحتوي على أرقام فقط
    if (!RegExp(r'^\d+$').hasMatch(cleanText)) {
      return oldValue;
    }

    // تنسيق الرقم بإضافة الفواصل
    int number = int.parse(cleanText);
    String formattedText = _formatter.format(number);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

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
  int? _selectedDeliveryDuration; // تغيير النوع إلى int
  int? _selectedDiscount = 0; // قيمة افتراضية للخصم
  double? _finalPrice;

  // منسق الأرقام لإضافة الفواصل
  final _numberFormat = NumberFormat("#,###", "ar");

  // قائمة خيارات سعر التوصيل من 1000 إلى 50000
  final List<int> _deliveryPrices = List<int>.generate(50, (i) => (i + 1) * 1000);

  // تعديل قائمة مدة التوصيل لترجع أرقام
  final Map<String, int> _deliveryDurations = {
    '24 ساعة': 1,
    'يومين': 2,
    'ثلاث أيام': 3,
    'أربع أيام': 4,
    'خمس أيام': 5,
    'ستة أيام': 6,
    'أسبوع': 7,
  };

  // تعديل قائمة الخصم لتصل إلى 95% فقط
  final List<int> _discountOptions = List<int>.generate(20, (i) => i * 5);

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
      final lastDuration = _storage.read<int>(keyDeliveryDuration);
      if (lastDuration != null) {
        _selectedDeliveryDuration = lastDuration;
        controller.deliveryDuration.text = lastDuration.toString();
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
        double calculatedPrice = price - (price * discount / 100);
        // تقريب السعر إلى أقرب مضاعف لـ 500
        _finalPrice = (calculatedPrice / 500).round() * 500.0;
      });

      print('تم حساب السعر النهائي: $_finalPrice من السعر الأصلي: $price والخصم: $discount%');
    } catch (e) {
      print('خطأ في حساب السعر النهائي: $e');
    }
  }

  // حفظ خيارات التوصيل في التخزين المحلي
  void _saveDeliveryOptions(int? price, int? duration, int? discount) {
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
          validator: (v) => validInput(v ?? '', 1, 10, 'number'),
          onChanged: (value) {
            _updateFinalPrice();
          },
          useFormatter: true,
        ),
        SizedBox(height: 16.h),

        _buildNumberInput(
          controller: controller.count,
          label: 'الكمية المتاحة',
          hintText: 'عدد القطع المتوفرة',
          icon: Icons.inventory_2,
          validator: (v) => validInput(v?.replaceAll(',', '') ?? '', 1, 5, 'number'),
          showIncrementButtons: true,
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
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                value: _selectedDeliveryDuration,
                decoration: _buildDropdownDecoration('مدة التوصيل'),
                icon: Icon(
                  Icons.arrow_drop_down_circle_outlined,
                  color: AppColor.primaryColor,
                ),
                items: _deliveryDurations.entries
                    .map((entry) => DropdownMenuItem(
                  value: entry.value,
                  child: Text(entry.key, style: TextStyle(fontSize: 14.sp)),
                ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDeliveryDuration = val;
                    controller.deliveryDuration.text = val.toString();
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
    bool showIncrementButtons = false,
    bool useFormatter = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: validator,
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
      inputFormatters: useFormatter ? [NumberInputFormatter()] : null,
      onChanged: (value) {
        // استدعاء الدالة المخصصة إذا تم تمريرها
        if (onChanged != null) {
          onChanged(value);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixText: !showIncrementButtons ? suffix : null,
        suffixIcon: showIncrementButtons ? _buildIncrementButtons(controller, onChanged) : null,
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

  Widget _buildIncrementButtons(TextEditingController controller, Function(String)? onChanged) {
    return Container(
      width: 80.w,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر النقصان
          InkWell(
            onTap: () => _decrementValue(controller, onChanged),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.remove,
                size: 18.sp,
                color: AppColor.primaryColor,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // زر الزيادة
          InkWell(
            onTap: () => _incrementValue(controller, onChanged),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColor.primaryColor),
              ),
              child: Icon(
                Icons.add,
                size: 18.sp,
                color: AppColor.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _incrementValue(TextEditingController controller, Function(String)? onChanged) {
    final currentValue = controller.text;
    int value = 0;

    if (currentValue.isNotEmpty) {
      try {
        value = int.parse(currentValue);
      } catch (e) {
        value = 0;
      }
    }

    value++;
    controller.text = value.toString();

    if (onChanged != null) {
      onChanged(value.toString());
    }
  }

  void _decrementValue(TextEditingController controller, Function(String)? onChanged) {
    final currentValue = controller.text;
    int value = 0;

    if (currentValue.isNotEmpty) {
      try {
        value = int.parse(currentValue);
      } catch (e) {
        value = 0;
      }
    }

    if (value > 0) {
      value--;
      controller.text = value.toString();

      if (onChanged != null) {
        onChanged(value.toString());
      }
    }
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
          controller.nextStep();
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
