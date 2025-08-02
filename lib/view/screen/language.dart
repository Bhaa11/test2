import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/core/localization/changelocal.dart';
import 'package:ecommercecourse/view/widget/language/custombuttomlang.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/color.dart';

class Language extends GetView<LocaleController> {
  const Language({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              const Icon(
                Icons.language_rounded,
                size: 80,
                color: AppColor.primaryColor,
              ),
              const SizedBox(height: 24),

              Text(
                "اختر اللغة".tr,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                "اختر اللغة المفضلة لديك".tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 48),

              // Language buttons
              _buildLanguageButton(
                flag: "",
                language: "العربية",
                code: "ar",
                context: context,
              ),

              const SizedBox(height: 16),

              _buildLanguageButton(
                flag: "",
                language: "English",
                code: "en",
                context: context,
              ),

              const SizedBox(height: 16),

              _buildLanguageButton(
                flag: "",
                language: "کوردی",
                code: "ku",
                context: context,
              ),

              const SizedBox(height: 32),


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton({
    required String flag,
    required String language,
    required String code,
    required BuildContext context,
  }) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.changeLang(code);
            Get.toNamed(AppRoute.onBoarding);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(
                  flag,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 16),

                Text(
                  language,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const Spacer(),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
