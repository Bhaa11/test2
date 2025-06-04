import 'package:ecommercecourse/controller/settings_controller.dart';
import 'package:ecommercecourse/controller/profile_controller.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/linkapi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class CustomMenuBottomSheet extends StatelessWidget {
  const CustomMenuBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _buildAccountSection(),
                _buildStoreSection(),
                _buildSupportSection(),
                _buildLogoutSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      children: [
        _listHeader("الحساب"),
        _menuListItem(
          icon: Icons.person_outline,
          title: "الملف الشخصي",
          onTap: () {
            Get.back();
            _showEditProfileDialog();
          },
        ),
        _menuListItem(
          icon: Icons.location_on_outlined,
          title: "العناوين",
          onTap: () {
            Get.back();
            Get.toNamed(AppRoute.addressview);
          },
        ),
        _listDivider(),
      ],
    );
  }

  Widget _buildStoreSection() {
    return Column(
      children: [
        _listHeader("المتجر"),
        _menuListItem(
          icon: Icons.favorite_outline,
          title: "المفضلة",
          onTap: () {
            Get.back();
            Get.toNamed(AppRoute.myfavroite);
          },
        ),
        _listDivider(),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      children: [
        _listHeader("الدعم"),
        _menuListItem(
          icon: Icons.headset_mic_outlined,
          title: "مركز الدعم",
          onTap: () {
            Get.back();
            launchUrl(Uri.parse('tel:07707150740'));
          },
        ),
        _menuListItem(
          icon: Icons.info_outline,
          title: "حول التطبيق",
          onTap: () {
            Get.back();
            _showAboutDialog();
          },
        ),
        _listDivider(),
      ],
    );
  }

  Widget _buildLogoutSection() {
    return Column(
      children: [
        _menuListItem(
          icon: Icons.logout_rounded,
          title: "تسجيل الخروج",
          onTap: () {
            Get.back();
            _showLogoutConfirmDialog();
          },
        ),
      ],
    );
  }

  Widget _listHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: AppColor.secondColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _listDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Divider(
        color: Colors.grey.shade200,
        thickness: 1.5,
      ),
    );
  }

  Widget _menuListItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    // تحديد لون خاص لزر تسجيل الخروج
    bool isLogout = title == "تسجيل الخروج";

    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 5),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isLogout
              ? Colors.red.withOpacity(0.1)
              : AppColor.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isLogout ? Colors.red : AppColor.primaryColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: trailing ??
          Icon(
              Icons.arrow_forward_ios,
              size: 15,
              color: isLogout ? Colors.red : Colors.grey),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog() {
    // حذف أي controller موجود مسبقاً لتجنب التضارب
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>();
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: EditProfileDialog(),
      ),
    );
  }

  void _showLogoutConfirmDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: LogoutConfirmDialog(),
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: AboutAppDialog(),
      ),
    );
  }
}

// Dialog تأكيد تسجيل الخروج
class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find<SettingsController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // أيقونة التحذير
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout_rounded,
              color: Colors.red,
              size: 40,
            ),
          ),
          SizedBox(height: 20),

          // العنوان
          Text(
            'تأكيد تسجيل الخروج',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.secondColor,
            ),
          ),
          SizedBox(height: 15),

          // النص التوضيحي
          Text(
            'هل أنت متأكد من أنك تريد تسجيل الخروج من حسابك؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          SizedBox(height: 30),

          // أزرار التأكيد
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey.shade700,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // إغلاق الـ dialog
                    settingsController.logout(); // تسجيل الخروج
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Dialog تعديل الملف الشخصي
class EditProfileDialog extends StatelessWidget {
  const EditProfileDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(), // إنشاء controller جديد
      builder: (controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(),
              if (controller.statusRequest == StatusRequest.loading)
                Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  ),
                )
              else ...[
                _buildAvatarSection(controller),
                SizedBox(height: 20),
                _buildTextFields(controller),
                SizedBox(height: 30),
                _buildActionButtons(controller),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: EdgeInsets.only(bottom: 15),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: AppColor.primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'تعديل الملف الشخصي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.secondColor,
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () {
              // حذف الـ controller عند الإغلاق
              if (Get.isRegistered<ProfileController>()) {
                Get.delete<ProfileController>();
              }
              Get.back();
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.grey.shade700,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(ProfileController controller) {
    return GestureDetector(
      onTap: () => controller.showImagePickerOptions(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.primaryColor, width: 3),
            ),
            child: ClipOval(
              child: controller.selectedImage != null
                  ? Image.file(
                controller.selectedImage!,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              )
                  : controller.currentImageUrl != null &&
                  controller.currentImageUrl!.isNotEmpty
                  ? Image.network(
                "${AppLink.getUserProfile}/${controller.currentImageUrl}",
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.secondColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFields(ProfileController controller) {
    return Column(
      children: [
        _buildTextField(
          controller: controller.nameController,
          labelText: 'الاسم الكامل',
          prefixIcon: Icons.person,
        ),
        SizedBox(height: 15),
        _buildTextField(
          controller: controller.descriptionController,
          labelText: 'وصف المتجر',
          prefixIcon: Icons.store,
          maxLines: 3,
          isDescription: true,
        ),
        SizedBox(height: 15),
        _buildTextField(
          controller: controller.phoneController,
          labelText: 'رقم الهاتف',
          prefixIcon: Icons.phone,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    int maxLines = 1,
    bool isDescription = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: 20, vertical: isDescription ? 10 : 5),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: AppColor.primaryColor),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: EdgeInsets.only(top: isDescription ? 0 : 0),
            child: Icon(prefixIcon, color: AppColor.primaryColor),
          ),
          alignLabelWithHint: isDescription,
          hintText: isDescription ? 'اكتب وصفاً مختصراً عن متجرك...' : null,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
        ),
        textAlignVertical: isDescription
            ? TextAlignVertical.top
            : TextAlignVertical.center,
      ),
    );
  }

  Widget _buildActionButtons(ProfileController controller) {
    return controller.statusRequest == StatusRequest.loading
        ? Center(
      child: CircularProgressIndicator(
        color: AppColor.primaryColor,
      ),
    )
        : Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // حذف الـ controller عند الإلغاء
              if (Get.isRegistered<ProfileController>()) {
                Get.delete<ProfileController>();
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade700,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: Text('إلغاء'),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => controller.updateProfile(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: Text(
              'حفظ التغييرات',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Dialog حول التطبيق
class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // أيقونة التطبيق
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              color: AppColor.primaryColor,
              size: 40,
            ),
          ),
          SizedBox(height: 20),

          // اسم التطبيق
          Text(
            'متجر إلكتروني',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColor.secondColor,
            ),
          ),
          SizedBox(height: 10),

          // رقم الإصدار
          Text(
            'الإصدار 1.0.0',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 20),

          // وصف التطبيق
          Text(
            'تطبيق متجر إلكتروني شامل يوفر تجربة تسوق مميزة مع واجهة سهلة الاستخدام وخدمات متنوعة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          SizedBox(height: 30),

          // معلومات إضافية
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _buildInfoRow('المطور', 'فريق التطوير'),
                SizedBox(height: 10),
                _buildInfoRow('البريد الإلكتروني', 'support@example.com'),
                SizedBox(height: 10),
                _buildInfoRow('الهاتف', '07707150740'),
              ],
            ),
          ),
          SizedBox(height: 30),

          // زر الإغلاق
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Text(
                'إغلاق',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColor.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
