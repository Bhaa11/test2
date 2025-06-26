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
                    'معلومات المنتج'.tr,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.grey2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'أدخل البيانات الأساسية للمنتج'.tr,
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
        _buildInputLabel('اسم المنتج'.tr, Icons.edit_rounded),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.name,
          validator: (v) => validInput(v ?? '', 3, 100, 'text'),
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 16.sp, color: AppColor.grey2),
          decoration: _getInputDecoration(
            hintText: 'أدخل اسم المنتج'.tr,
          ),
        ),
      ],
    );
  }

  Widget _buildProductDescriptionField(ItemsAddController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('وصف المنتج'.tr, Icons.description_rounded),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.desc,
          validator: (v) => validInput(v ?? '', 5, 300, 'text'),
          maxLines: 3,
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 16.sp, color: AppColor.grey2),
          decoration: _getInputDecoration(
            hintText: 'أضف وصفاً تفصيلياً للمنتج'.tr,
          ),
        ),
      ],
    );
  }

  Widget _buildProductStatusSelector(ItemsAddController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('حالة المنتج'.tr, Icons.category_rounded),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatusOption(
                controller,
                title: 'جديد'.tr,
                value: 0,
                color: Colors.green.shade600,
                iconData: Icons.new_releases_rounded,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildStatusOption(
                controller,
                title: 'حاوية'.tr,
                value: 1,
                color: Colors.blue.shade600,
                iconData: Icons.inventory_rounded,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildStatusOption(
                controller,
                title: 'مستعمل'.tr,
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
            'يرجى اختيار حالة المنتج'.tr,
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
            _buildInputLabel('ملفات المنتج'.tr, Icons.perm_media_rounded),
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

        // عرض حالة الضغط
        if (controller.isCompressing) ...[
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: controller.compressionProgressPercent,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.compressionProgress,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (controller.compressionTotalFiles > 0) ...[
                            SizedBox(height: 4.h),
                            Text(
                              '${controller.compressionCurrentFile}/${controller.compressionTotalFiles} ' + 'ملفات'.tr,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                LinearProgressIndicator(
                  value: controller.compressionProgressPercent,
                  backgroundColor: Colors.blue.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],

        // منطقة رفع الملفات
        GestureDetector(
          onTap: (controller.selectedFiles.length < 10 && !controller.isCompressing)
              ? controller.showOptionFiles
              : null,
          child: Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: (controller.selectedFiles.length < 10 && !controller.isCompressing)
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
                    controller.isCompressing
                        ? Icons.hourglass_empty
                        : Icons.file_upload_outlined,
                    size: 36.r,
                    color: controller.showFilesError
                        ? Colors.red.shade400
                        : AppColor.primaryColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.isCompressing
                      ? 'جاري ضغط الملفات...'.tr
                      : 'إضافة ملفات للمنتج'.tr,
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
                  controller.isCompressing
                      ? 'يرجى الانتظار حتى انتهاء عملية الضغط'.tr
                      : 'اضغط هنا لاختيار صور وفيديوهات'.tr,
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
                    (controller.selectedFiles.length < 10 && !controller.isCompressing ? 1 : 0),
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
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey.shade400,
                                  size: 32.r,
                                ),
                              );
                            },
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVideo ? Icons.videocam : Icons.photo,
                                color: Colors.white,
                                size: 10.r,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                isVideo ? 'فيديو'.tr : 'صورة'.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // مؤشر أن الملف مضغوط
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: EdgeInsets.all(2.r),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
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
                'يجب اختيار ملف واحد على الأقل للمنتج'.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ] else if (controller.selectedFiles.isNotEmpty && !controller.isCompressing) ...[
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
                'تم رفع'.tr +  ' ${controller.selectedFiles.length} ' + 'ملف بنجاح'.tr,
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
                  'حذف الكل'.tr,
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
        if (controller.selectedFiles.isNotEmpty && !controller.isCompressing) ...[
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
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'الصور:'.tr + ' ${controller.selectedFiles.where((f) => controller.isImageFile(f)).length} | '+ 'الفيديوهات:'.tr + ' ${controller.selectedFiles.where((f) => controller.isVideoFile(f)).length}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // تحذير عند الوصول للحد الأقصى
        if (controller.selectedFiles.length >= 10) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.orange.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade600,
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'وصلت للحد الأقصى من الملفات (10 ملفات)'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.orange.shade700,
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
        onPressed: controller.isCompressing ? null : controller.nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: controller.isCompressing
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'جاري ضغط الملفات...'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'المتابعة للخطوة التالية'.tr,
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
