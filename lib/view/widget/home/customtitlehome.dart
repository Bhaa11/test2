import 'package:ecommercecourse/core/constant/color.dart';
import 'package:flutter/material.dart';

class CustomTitleHome extends StatelessWidget {
  final String title;
  const CustomTitleHome({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: AppColor.primaryColor, size: 24),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}