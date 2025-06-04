import 'package:ecommercecourse/view/screen/items_seller/add/one.dart';
import 'package:ecommercecourse/view/screen/items_seller/add/two.dart';
import 'package:ecommercecourse/view/screen/items_seller/add/three.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../controller/items_seller/add_controller.dart';
import '../../../../core/class/handlingdataview.dart';
import '../../../../core/constant/color.dart';

class ItemsAdd extends StatelessWidget {
  const ItemsAdd({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ItemsAddController());

    return WillPopScope(
      onWillPop: () async {
        // لو مش في الخطوة الأولى، ارجع خطوة وامنع البوب
        if (controller.currentStep > 0) {
          controller.currentStep--;
          controller.pageController.animateToPage(
            controller.currentStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          controller.update(); // تحديث حالة الخطوة في الـ UI
          return false;
        }
        // لو في الخطوة الأولى خلي البوب الإفتراضي ينفّذ (يرجع للصفحة السابقة = البروفايل)
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (controller.currentStep > 0) {
                controller.currentStep--;
                controller.pageController.animateToPage(
                  controller.currentStep,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                controller.update(); // تحديث حالة الخطوة في الـ UI
              } else {
                Get.back(); // ترجع للصفحة السابقة (البروفايل)
              }
            },
          ),
          title: GetBuilder<ItemsAddController>(
            builder: (_) => _buildProgressIndicator(controller),
          ),
          centerTitle: true,
          elevation: 2,
          backgroundColor: AppColor.white,
          toolbarHeight: 70.h,
          shadowColor: AppColor.grey.withOpacity(0.3),
        ),
        body: GetBuilder<ItemsAddController>(
          builder: (_) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.primaryColor.withOpacity(0.05),
                  AppColor.thirdColor.withOpacity(0.02),
                ],
              ),
            ),
            child: HandlingDataView(
              statusRequest: controller.statusRequest,
              widget: Padding(
                padding: EdgeInsets.all(0.w),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: controller.pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          ItemsAddStepOne(),
                          ItemsAddStepTwo(),
                          ItemsAddStepThree(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ItemsAddController controller) {
    return SizedBox(
      height: 40.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Row(
            children: [
              _buildProgressCircle(index, controller.currentStep),
              if (index < 2)
                Container(
                  width: 20.w,
                  height: 2.h,
                  color: AppColor.grey3,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProgressCircle(int index, int currentStep) {
    final bool isActive = currentStep >= index;
    final bool isCompleted = currentStep > index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: isActive ? AppColor.primaryColor : AppColor.lightGrey,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColor.secondColor : AppColor.grey3,
          width: isActive ? 2.w : 1.w,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isCompleted
                ? Icon(
              Icons.check_rounded,
              color: AppColor.white,
              size: 18.sp,
            )
                : Text(
              '${index + 1}',
              style: TextStyle(
                color: isActive ? AppColor.white : AppColor.grey2,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (isActive)
            AnimatedScale(
              scale: 1.1,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.white.withOpacity(0.3),
                    width: 2.w,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
