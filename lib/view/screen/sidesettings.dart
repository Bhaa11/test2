import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ecommercecourse/controller/settings_controller.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';

import '../../core/constant/imgaeasset.dart';

class SideSettings extends StatelessWidget {
  SideSettings({Key? key}) : super(key: key);
  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: AppColor.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      endDrawer: _buildDrawer(context),
      body: Center(child: Text('المحتوى الرئيسي للتطبيق')),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.primaryColor, AppColor.secondColor],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      AppImageAsset.avatar,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'مرحبا، المستخدم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildListTile(
            icon: Icons.notifications_active_outlined,
            title: "الإشعارات",
            trailing: Switch(
              activeColor: AppColor.primaryColor,
              value: true,
              onChanged: (val) {},
            ),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.shopping_bag_outlined,
            title: "الطلبات الحالية",
            onTap: () => Get.toNamed(AppRoute.orderspending),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.archive_outlined,
            title: "الأرشيف",
            onTap: () => Get.toNamed(AppRoute.ordersarchive),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.location_on_outlined,
            title: "العناوين",
            onTap: () => Get.toNamed(AppRoute.addressview),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.support_agent_outlined,
            title: "الدعم",
            onTap: () => launchUrl(Uri.parse('tel:07707150740')),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: "سياسة الخصوصية",
            onTap: () => launchUrl(Uri.parse('https://yourdomain.com/privacy')),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "تسجيل الخروج",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
              onPressed: () => controller.logout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    Function()? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColor.primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: Colors.grey[50],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],
      indent: 70,
    );
  }
}