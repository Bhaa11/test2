import 'package:ecommercecourse/controller/home_controller.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/imgaeasset.dart';

class CustomCardHome extends GetView<HomeControllerImp> {
  final String title;
  final String body;

  const CustomCardHome({
    Key? key,
    required this.title,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isRTL = controller.lang == "ar";
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.97,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.secondColor,
            AppColor.primaryColor.withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.secondColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background tire pattern
          Positioned(
            bottom: -15,
            right: isRTL ? null : -20,
            left: isRTL ? -20 : null,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                AppImageAsset.iconhomeImage, // Use a tire pattern image
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),



          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          color: AppColor.white,
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(1, 1),
                            )
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Body text
                Text(
                  body,
                  style: TextStyle(
                    color: AppColor.white.withOpacity(0.9),
                    fontSize: screenWidth * 0.037,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 25),

                // Shop Now Button
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}