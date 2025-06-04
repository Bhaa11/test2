import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/linkapi.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class CustomItemsCartList extends StatelessWidget {
  final String name;
  final String price;
  final String count;
  final String imagename;
  final void Function()? onAdd;
  final void Function()? onRemove;
  final VoidCallback? onTap;

  const CustomItemsCartList({
    Key? key,
    required this.name,
    required this.price,
    required this.count,
    required this.imagename,
    required this.onAdd,
    required this.onRemove,
    this.onTap,
  }) : super(key: key);

  // دالة لاستخراج الصورة الأولى من JSON
  String getFirstImage(String? itemsImage) {
    if (itemsImage == null || itemsImage.isEmpty) {
      return '';
    }

    try {
      // محاولة تحليل JSON
      Map<String, dynamic> imageData = json.decode(itemsImage);

      // التحقق من وجود مصفوفة الصور
      if (imageData.containsKey('images') && imageData['images'] is List) {
        List images = imageData['images'];
        if (images.isNotEmpty) {
          return images[0].toString();
        }
      }

      // إذا لم توجد صور، إرجاع فارغ
      return '';
    } catch (e) {
      // في حالة فشل تحليل JSON، قد تكون الصورة بالتنسيق القديم
      return itemsImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: screenWidth * 0.02,
          ),
          child: Row(
            children: [
              _buildProductImage(context),
              SizedBox(width: screenWidth * 0.03),
              _buildProductDetails(context),
              const Spacer(),
              _buildQuantityControls(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.18;

    // استخراج الصورة الأولى
    String firstImage = getFirstImage(imagename);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: firstImage.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: "${AppLink.imagestItems}/$firstImage",
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.image_not_supported_outlined),
          ),
        )
            : Container(
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported_outlined),
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: screenWidth * 0.015),
          Text(
            price,
            style: TextStyle(
              color: AppColor.primaryColor,
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            onRemove,
            Icons.remove,
            screenWidth,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenWidth * 0.01,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: BoxConstraints(minWidth: screenWidth * 0.07),
            alignment: Alignment.center,
            child: Text(
              count,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildControlButton(
            onAdd,
            Icons.add,
            screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      void Function()? onPressed,
      IconData icon,
      double screenWidth,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.015),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.primaryColor.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: AppColor.primaryColor,
            size: screenWidth * 0.05,
          ),
        ),
      ),
    );
  }
}
