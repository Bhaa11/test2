import 'package:ecommercecourse/controller/orders/archive_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:flutter/material.dart';

import '../../../core/constant/color.dart';

void ShowDialogRating(BuildContext context, String ordersid) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => RatingDialog(
      initialRating: 1.0,
      title: Text(
        'تقييم البائع',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      message: Text(
        'اضغط على النجوم لتحديد تقييمك وأضف تعليقك',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15),
      ),
      image: const Image(
        image: AssetImage('assets/images/logo.png'),
        height: 100,
        width: 100,
      ),
      submitButtonText: 'إرسال التقييم',
      submitButtonTextStyle: const TextStyle(
        color: AppColor.primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      commentHint: 'اكتب تعليقك هنا (اختياري)',
      onCancelled: () => print('تم إلغاء التقييم'),
      onSubmitted: (response) {
        OrdersArchiveController controller = Get.find();
        // إرسال التقييم مع معرف الطلب
        controller.submitSellerRating(ordersid, response.rating, response.comment);
      },
    ),
  );
}
