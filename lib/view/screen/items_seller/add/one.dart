import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../controller/items_seller/add_controller.dart';
import '../../../../core/constant/color.dart';
import '../../../../core/functions/validinput.dart';

class ItemsAddStepOne extends StatelessWidget {
  const ItemsAddStepOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GetBuilder<ItemsAddController>(
        builder: (controller) => SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              children: [
                _buildFormCard(controller),
                SizedBox(height: 24.h),
                _buildNavigationButton(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(ItemsAddController controller) {
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
        padding: EdgeInsets.all(24.r),
        child: Form(
          key: controller.stepOneFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(),
              SizedBox(height: 24.h),
              _buildProductNameField(controller),
              SizedBox(height: 20.h),
              _buildProductDescriptionField(controller),
              SizedBox(height: 20.h),
              _buildProductStatusSelector(controller),
              SizedBox(height: 28.h),
              _buildFilesUploader(controller),
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
                Icons.inventory_2_rounded,
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
                    'معلومات المنتج',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.grey2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'أدخل البيانات الأساسية للمنتج والملفات التوضيحية',
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

  Widget _buildProductNameField(ItemsAddController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('اسم المنتج', Icons.edit_rounded),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.name,
          validator: (v) => validInput(v ?? '', 3, 100, 'text'),
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 16.sp, color: AppColor.grey2),
          decoration: _getInputDecoration(
            hintText: 'أدخل اسم المنتج',
          ),
        ),
      ],
    );
  }

  Widget _buildProductDescriptionField(ItemsAddController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('وصف المنتج', Icons.description_rounded),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.desc,
          validator: (v) => validInput(v ?? '', 5, 300, 'text'),
          maxLines: 3,
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 16.sp, color: AppColor.grey2),
          decoration: _getInputDecoration(
            hintText: 'أضف وصفاً تفصيلياً للمنتج',
          ),
        ),
      ],
    );
  }

  Widget _buildProductStatusSelector(ItemsAddController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('حالة المنتج', Icons.category_rounded),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatusOption(
                controller,
                title: 'جديد',
                value: 0,
                color: Colors.green.shade600,
                iconData: Icons.new_releases_rounded,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildStatusOption(
                controller,
                title: 'حاوية',
                value: 1,
                color: Colors.blue.shade600,
                iconData: Icons.inventory_rounded,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildStatusOption(
                controller,
                title: 'مستعمل',
                value: 2,
                color: Colors.amber.shade700,
                iconData: Icons.history_rounded,
              ),
            ),
          ],
        ),
        if (controller.showStatusError) ...[
          SizedBox(height: 8.h),
          Text(
            'يرجى اختيار حالة المنتج',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusOption(
      ItemsAddController controller,
      {required String title,
        required int value,
        required Color color,
        required IconData iconData}
      ) {
    final bool isSelected = controller.productStatus == value;

    return GestureDetector(
      onTap: () => controller.setProductStatus(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: isSelected ? color : Colors.grey.shade400,
              size: 24.r,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: AppColor.primaryColor),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.grey2,
          ),
        ),
      ],
    );
  }

  Widget _buildFilesUploader(ItemsAddController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildInputLabel('ملفات المنتج', Icons.perm_media_rounded),
            Spacer(),
            Text(
              '${controller.selectedFiles.length}/10',
              style: TextStyle(
                fontSize: 14.sp,
                color: controller.selectedFiles.length >= 10
                    ? Colors.red.shade600
                    : AppColor.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // منطقة رفع الملفات
        GestureDetector(
          onTap: controller.selectedFiles.length < 10 ? controller.showOptionFiles : null,
          child: Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: controller.selectedFiles.length < 10
                  ? Colors.grey.shade50
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: controller.showFilesError
                    ? Colors.red.shade400
                    : controller.selectedFiles.isNotEmpty
                    ? AppColor.primaryColor
                    : Colors.grey.shade300,
                width: controller.selectedFiles.isNotEmpty || controller.showFilesError ? 2 : 1,
              ),
            ),
            child: controller.selectedFiles.isEmpty
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: controller.showFilesError
                        ? Colors.red.shade50
                        : AppColor.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.file_upload_outlined,
                    size: 36.r,
                    color: controller.showFilesError
                        ? Colors.red.shade400
                        : AppColor.primaryColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'إضافة ملفات للمنتج',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: controller.showFilesError
                        ? Colors.red.shade400
                        : AppColor.grey2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'اضغط هنا لاختيار صور وفيديوهات\n(حتى 10 ملفات)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade400,
                    height: 1.4,
                  ),
                ),
              ],
            )
                : Padding(
              padding: EdgeInsets.all(8.r),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 1,
                ),
                itemCount: controller.selectedFiles.length +
                    (controller.selectedFiles.length < 10 ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.selectedFiles.length) {
                    // زر إضافة ملف جديد
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColor.primaryColor.withOpacity(0.3),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        color: AppColor.primaryColor,
                        size: 32.r,
                      ),
                    );
                  }

                  // عرض الملف
                  File file = controller.selectedFiles[index];
                  bool isVideo = controller.isVideoFile(file);

                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: isVideo
                              ? Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black87,
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 32.r,
                            ),
                          )
                              : Image.file(
                            file,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // زر الحذف
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeFile(index),
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16.r,
                            ),
                          ),
                        ),
                      ),
                      // مؤشر نوع الملف
                      if (isVideo)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'فيديو',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        // رسائل الخطأ والنجاح
        if (controller.showFilesError) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 18.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'يجب اختيار ملف واحد على الأقل للمنتج',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ] else if (controller.selectedFiles.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 18.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'تم رفع ${controller.selectedFiles.length} ملف بنجاح',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.green,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  controller.clearFiles();
                },
                icon: Icon(
                  Icons.delete_outline,
                  size: 18.r,
                  color: Colors.red.shade700,
                ),
                label: Text(
                  'حذف الكل',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14.sp,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                ),
              ),
            ],
          ),
        ],

        // معلومات إضافية
        if (controller.selectedFiles.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.blue.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'الصور: ${controller.selectedFiles.where((f) => controller.isImageFile(f)).length} | الفيديوهات: ${controller.selectedFiles.where((f) => controller.isVideoFile(f)).length}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationButton(ItemsAddController controller) {
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
        onPressed: controller.nextStep,
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

  InputDecoration _getInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 16.h,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.red.shade300, width: 2),
      ),
    );
  }
}
