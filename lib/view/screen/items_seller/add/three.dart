import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../controller/items_seller/add_controller.dart';
import '../../../../controller/home_controller.dart';
import '../../../../core/constant/color.dart';

class ItemsAddStepThree extends StatefulWidget {
  const ItemsAddStepThree({Key? key}) : super(key: key);

  @override
  State<ItemsAddStepThree> createState() => _ItemsAddStepThreeState();
}

class _ItemsAddStepThreeState extends State<ItemsAddStepThree> {
  late final List<String> manufacturers;
  late final Map<String, List<String>> modelsByManufacturer;
  late final List<String> years;

  String? selectedManufacturer;
  String? selectedModel;
  final Set<String> selectedYears = {};

  bool showPublishButton = false;
  bool isAllSelected = false;
  bool showManufacturerError = false;
  bool showModelError = false;

  final controller = Get.find<ItemsAddController>();
  final homeController = Get.find<HomeControllerImp>();

  @override
  void initState() {
    super.initState();
    _initializeCarData();
    // تحديث حالة الزر بناءً على وجود سيارات مضافة مسبقاً
    showPublishButton = controller.carVariants.isNotEmpty;
  }

  void _initializeCarData() {
    // التحقق من تحميل بيانات السيارات
    if (!homeController.carDataLoaded) {
      // في حالة عدم تحميل البيانات، استخدم بيانات افتراضية
      manufacturers = ['الكل'];
      modelsByManufacturer = {'الكل': ['الكل']};
      years = ['الكل'] + List.generate(8, (i) => (2024 - i).toString());
      return;
    }

    // Initialize manufacturers with "الكل" first
    manufacturers = ['الكل'] + homeController.carData.keys.toList();

    // Initialize models map with "الكل" for each manufacturer
    modelsByManufacturer = {
      'الكل': ['الكل'],
    };

    // Add models for each manufacturer
    homeController.carData.forEach((manufacturer, models) {
      modelsByManufacturer[manufacturer] = ['الكل'] + models.keys.toList();
    });

    // Initialize years with "الكل" first
    years = ['الكل'] + List.generate(8, (i) => (2024 - i).toString());
  }

  List<String> _getYearsForModel() {
    if (selectedManufacturer != null &&
        selectedModel != null &&
        selectedManufacturer != 'الكل' &&
        selectedModel != 'الكل' &&
        homeController.carDataLoaded) {

      final manufacturerData = homeController.carData[selectedManufacturer];
      if (manufacturerData != null && manufacturerData.containsKey(selectedModel)) {
        return ['الكل'] + manufacturerData[selectedModel]!;
      }
    }
    return ['الكل'] + List.generate(8, (i) => (2024 - i).toString());
  }

  bool get _isModelDisabled => selectedManufacturer == 'الكل';
  bool get _isAllMode => selectedManufacturer == 'الكل' && selectedModel == 'الكل';

  bool _hasAllVariant(String manu, String model) {
    return controller.carVariants.any((v) => v == '$manu-$model-الكل');
  }

  bool get _shouldDisableYears {
    if (_isAllMode) return true;
    if (selectedManufacturer != null && selectedModel != null) {
      final hasAll = _hasAllVariant(selectedManufacturer!, selectedModel!);
      if (hasAll && !isAllSelected) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeControllerImp>(
      builder: (homeCtrl) {
        // إذا لم يتم تحميل بيانات السيارات بعد
        if (!homeCtrl.carDataLoaded && homeCtrl.carDataError == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColor.primaryColor),
                SizedBox(height: 16.h),
                Text(
                  'جاري تحميل بيانات السيارات...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColor.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // إذا حدث خطأ في تحميل البيانات
        if (homeCtrl.carDataError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.r,
                  color: AppColor.errorRed,
                ),
                SizedBox(height: 16.h),
                Text(
                  homeCtrl.carDataError!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColor.errorRed,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    homeCtrl.refreshData();
                  },
                  child: Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCarSelectionForm(),
              SizedBox(height: 24.h),
              _buildCarVariantsList(),
              if (showPublishButton) ...[
                SizedBox(height: 32.h),
                _buildPublishButton(),
              ],
              SizedBox(height: 30.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarSelectionForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(22.w),
        child: Form(
          key: controller.stepThreeFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(),
              SizedBox(height: 24.h),
              _buildManufacturerSelector(),
              SizedBox(height: 20.h),
              _buildModelSelector(),
              SizedBox(height: 28.h),
              _buildYearsSelector(),
              SizedBox(height: 30.h),
              _buildAddCarButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.directions_car_filled,
                color: AppColor.primaryColor,
                size: 28.r,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'توافق القطعة',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.grey2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'حدد السيارات التي تناسبها هذه القطعة',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColor.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Divider(color: AppColor.lightGrey.withOpacity(0.5), thickness: 1),
      ],
    );
  }

  Widget _buildManufacturerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الشركة المصنعة',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.grey2,
          ),
        ),
        SizedBox(height: 10.h),
        DropdownButtonFormField<String>(
          value: selectedManufacturer,
          decoration: _getInputDecoration('اختر الشركة المصنعة', hasError: showManufacturerError),
          items: manufacturers
              .map((it) => DropdownMenuItem(
            value: it,
            child: Text(
              it,
              style: TextStyle(fontSize: 16.sp),
            ),
          ))
              .toList(),
          onChanged: (val) {
            setState(() {
              if (val == 'الكل') {
                controller.carVariants.clear();
                selectedModel = 'الكل';
                selectedYears
                  ..clear()
                  ..add('الكل');
                isAllSelected = true;
              } else {
                selectedModel = null;
                selectedYears.clear();
                isAllSelected = false;
              }
              selectedManufacturer = val;
              showPublishButton = controller.carVariants.isNotEmpty;
              showManufacturerError = false;
            });
          },
          validator: (v) => controller.carVariants.isEmpty && v == null
              ? 'يرجى اختيار الشركة المصنعة'
              : null,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColor.primaryColor),
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        if (showManufacturerError)
          Padding(
            padding: EdgeInsets.only(top: 8.h, right: 16.w),
            child: Text(
              'يجب اختيار الشركة المصنعة أولاً',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الموديل',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.grey2,
          ),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: selectedManufacturer == null
              ? () {
            setState(() {
              showManufacturerError = true;
            });
          }
              : null,
          child: DropdownButtonFormField<String>(
            value: selectedModel,
            decoration: _getInputDecoration(
              'اختر موديل السيارة',
              enabled: !_isModelDisabled,
              hasError: showModelError,
            ),
            items: selectedManufacturer != null
                ? modelsByManufacturer[selectedManufacturer]!
                .map((it) => DropdownMenuItem(
              value: it,
              child: Text(
                it,
                style: TextStyle(fontSize: 16.sp),
              ),
            ))
                .toList()
                : [],
            onChanged: _isModelDisabled
                ? null
                : (val) {
              setState(() {
                if (selectedManufacturer == 'الكل' && val == 'الكل') {
                  controller.carVariants.clear();
                  selectedYears
                    ..clear()
                    ..add('الكل');
                  isAllSelected = true;
                } else {
                  selectedYears.clear();
                  isAllSelected = false;
                }
                selectedModel = val;
                showPublishButton = controller.carVariants.isNotEmpty;
                showModelError = false;
              });
            },
            validator: (v) => controller.carVariants.isEmpty && v == null
                ? 'يرجى اختيار الموديل'
                : null,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColor.primaryColor),
            isExpanded: true,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        if (showModelError)
          Padding(
            padding: EdgeInsets.only(top: 8.h, right: 16.w),
            child: Text(
              'يجب اختيار موديل السيارة أولاً',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildYearsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سنة الصنع',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.grey2,
          ),
        ),
        SizedBox(height: 14.h),
        _buildYearsChips(),
      ],
    );
  }

  Widget _buildYearsChips() {
    final availableYears = _getYearsForModel();

    return GestureDetector(
      onTap: () {
        if (selectedManufacturer == null) {
          setState(() {
            showManufacturerError = true;
          });
        } else if (selectedModel == null) {
          setState(() {
            showModelError = true;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Wrap(
          spacing: 10.w,
          runSpacing: 12.h,
          children: availableYears.map((year) {
            final isSelected = selectedYears.contains(year);
            final isDisabled = (year != 'الكل' &&
                controller.carVariants.contains(
                  '${selectedManufacturer ?? ''}-${selectedModel ?? ''}-$year',
                )) ||
                _shouldDisableYears ||
                (_isAllMode && year != 'الكل');

            return ChoiceChip(
              label: Text(
                year,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : isDisabled ? Colors.grey : AppColor.grey2,
                ),
              ),
              selected: isSelected,
              onSelected: (isDisabled || selectedManufacturer == null || selectedModel == null)
                  ? null
                  : (sel) {
                setState(() {
                  if (year == 'الكل') {
                    if (sel) {
                      // عند اختيار "الكل" - إزالة جميع السنوات المحددة واختيار "الكل" فقط
                      selectedYears.clear();
                      selectedYears.add('الكل');
                      isAllSelected = true;
                    } else {
                      // عند إلغاء اختيار "الكل"
                      selectedYears.remove('الكل');
                      isAllSelected = false;
                    }
                  } else {
                    // عند اختيار سنة محددة
                    if (sel) {
                      // إزالة "الكل" إذا كان محدداً وإضافة السنة المحددة
                      selectedYears.remove('الكل');
                      selectedYears.add(year);
                      isAllSelected = false;
                    } else {
                      // إزالة السنة المحددة
                      selectedYears.remove(year);
                    }
                  }
                  showPublishButton = controller.carVariants.isNotEmpty;
                });
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: AppColor.primaryColor,
              avatar: isSelected
                  ? Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 18.r, color: Colors.white),
              )
                  : null,
              disabledColor: Colors.grey.shade200,
              elevation: isSelected ? 2 : 0,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAddCarButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _handleAddCar(),
        icon: Icon(Icons.add_circle_outline, size: 22.r),
        label: Text(
          'إضافة سيارة',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColor.primaryColor,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }

  Widget _buildCarVariantsList() {
    return GetBuilder<ItemsAddController>(
      builder: (ctrl) {
        if (ctrl.carVariants.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 24.r),
                    SizedBox(width: 12.w),
                    Text(
                      'السيارات المتوافقة (${ctrl.carVariants.length})',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.grey2,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: ctrl.carVariants.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _buildVariantCard(ctrl.carVariants[index], ctrl);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVariantCard(String variant, ItemsAddController ctrl) {
    final parts = variant.split('-');
    final manufacturer = parts[0];
    final model = parts[1];
    final year = parts[2];

    return Dismissible(
      key: Key(variant),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        decoration: BoxDecoration(
          color: AppColor.errorLightRed,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.delete_forever, color: AppColor.errorRed, size: 28.r),
      ),
      onDismissed: (_) {
        ctrl.removeCarVariant(variant);
        setState(() {
          showPublishButton = ctrl.carVariants.isNotEmpty;
        });
        Get.snackbar(
          'تم الحذف',
          'تم حذف ${manufacturer} ${model} ${year}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.black87,
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r,
          boxShadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        );
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        leading: CircleAvatar(
          backgroundColor: AppColor.primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.directions_car,
            color: AppColor.primaryColor,
            size: 24.r,
          ),
        ),
        title: Text(
          '$manufacturer $model',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.grey2,
          ),
        ),
        subtitle: Text(
          year,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColor.grey,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: AppColor.errorRed, size: 24.r),
          onPressed: () {
            ctrl.removeCarVariant(variant);
            setState(() => showPublishButton = ctrl.carVariants.isNotEmpty);
          },
          splashRadius: 24.r,
        ),
      ),
    );
  }

  Widget _buildPublishButton() {
    return Container(
      width: double.infinity,
      height: 60.h,
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
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        onPressed: controller.addData,
        icon: Icon(Icons.publish, color: Colors.white, size: 26.r),
        label: Text(
          'نشر المنتج',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handleAddCar() {
    // Form validation
    if (!controller.stepThreeFormKey.currentState!.validate()) return;

    if (selectedManufacturer == null || selectedModel == null) {
      _showErrorMessage('يرجى اختيار الشركة المصنعة والموديل');
      return;
    }

    if (selectedYears.isEmpty) {
      _showErrorMessage('يرجى اختيار سنة واحدة على الأقل أو "الكل"');
      return;
    }

    // Add variants
    final variants = (isAllSelected || _isAllMode)
        ? ['$selectedManufacturer-$selectedModel-الكل']
        : selectedYears.map((year) => '$selectedManufacturer-$selectedModel-$year').toList();

    if (controller.carVariants.contains('الكل-الكل-الكل') &&
        !(variants.length == 1 && variants[0] == 'الكل-الكل-الكل')) {
      controller.removeCarVariant('الكل-الكل-الكل');
    }

    controller.addCarVariant(variants);

    // Update UI
    setState(() {
      selectedYears.clear();
      showPublishButton = controller.carVariants.isNotEmpty;
      isAllSelected = false;
    });

    // Show success message
    Get.snackbar(
      'تمت الإضافة',
      'تم إضافة السيارة بنجاح',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
      duration: const Duration(seconds: 2),
      icon: Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 28.r,
      ),
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColor.errorLightRed,
      colorText: AppColor.errorRed,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
      icon: Icon(
        Icons.error_outline,
        color: AppColor.errorRed,
        size: 28.r,
      ),
    );
  }

  InputDecoration _getInputDecoration(String hint, {bool enabled = true, bool hasError = false}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: hasError ? Colors.red : AppColor.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.red.shade300, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey.shade200),
      ),
    );
  }
}
