import 'package:flutter/material.dart';
import 'package:ecommercecourse/core/constant/color.dart';

class TopCardCart extends StatelessWidget {
  final String message;

  const TopCardCart({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(
        top: screenWidth * 0.03,
        bottom: screenWidth * 0.05,
        left: screenWidth * 0.04,
        right: screenWidth * 0.04,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            color: AppColor.primaryColor,
            size: screenWidth * 0.07,
          ),
          SizedBox(width: screenWidth * 0.03),
          Text(
            message,
            style: TextStyle(
              color: AppColor.primaryColor,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
