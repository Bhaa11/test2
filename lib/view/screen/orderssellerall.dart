import 'package:ecommercecourse/view/screen/orders_seller/archive.dart';
import 'package:ecommercecourse/view/screen/orders_seller/pending.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/view/screen/orders_seller/accepted.dart';


class OrdersSellerScreen extends StatefulWidget {
  const OrdersSellerScreen({super.key});

  @override
  State<OrdersSellerScreen> createState() => _OrdersSellerScreenState();
}

class _OrdersSellerScreenState extends State<OrdersSellerScreen> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text('طلبات المتجر'.tr,
            style: TextStyle(
              fontSize: _responsiveFont(screenWidth, 20, textScaleFactor),
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            )),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.12),
          child: _buildSegmentedControl(screenWidth, textScaleFactor),
        ),
      ),
      body: IndexedStack(
        index: _selectedSegment,
        children: const [
          OrdersPendingSeller(), // Pending Orders
          OrdersAccepted(), // Accepted Orders
          OrdersArchiveViewSeller(), // Archived/Completed Orders
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(double screenWidth, double textScaleFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 12,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.backgroundcolor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildSegmentButton(0, 'طلبات\nقيد الانتظار', Icons.pending_actions, Colors.orange, screenWidth, textScaleFactor),
              _buildSegmentButton(1, 'طلبات\nمقبولة', Icons.check_circle_outline, Colors.blue, screenWidth, textScaleFactor),
              _buildSegmentButton(2, 'طلبات\nمكتملة', Icons.inventory_2_outlined, Colors.green, screenWidth, textScaleFactor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton(int index, String text, IconData icon, Color color, double screenWidth, double textScaleFactor) {
    final isSelected = _selectedSegment == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _selectedSegment = index);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: color.withOpacity(0.3), width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: screenWidth * 0.06),
              const SizedBox(height: 4),
              Text(
                text.tr,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: _responsiveFont(screenWidth, 12, textScaleFactor),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? color : AppColor.grey,
                  fontFamily: 'Cairo',
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _responsiveFont(double screenWidth, double baseSize, double textScaleFactor) {
    final scalingFactor = (screenWidth / 360).clamp(0.7, 0.9);
    return (baseSize * scalingFactor) / textScaleFactor;
  }
}
