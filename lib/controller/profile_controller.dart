import 'dart:io';
import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/core/services/services.dart';
import 'package:ecommercecourse/data/datasource/remote/profile_data.dart';
import 'package:ecommercecourse/data/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommercecourse/main.dart';

class ProfileController extends GetxController {
  // Dependencies
  late ProfileData profileData;
  late MyServices myServices;
  final AuthController authController = Get.find<AuthController>();
  late GuestController guestController;

  // Status
  StatusRequest statusRequest = StatusRequest.none;
  StatusRequest updateStatusRequest = StatusRequest.none;

  // Text Controllers
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController phoneController;

  // User Data
  UserModel? currentUser;
  File? selectedImage;
  String? currentImageUrl;

  // Image Picker
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    // Initialize dependencies
    profileData = ProfileData(Get.find());
    myServices = Get.find();
    guestController = Get.put(GuestController());

    // Initialize controllers
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    phoneController = TextEditingController();

    // Load user profile
    getUserProfile();

    // استمع لتغييرات حالة المصادقة
    ever(authController.authStateChanges, (bool isLoggedIn) {
      print("Authentication state changed: $isLoggedIn");
      if (isLoggedIn) {
        print("User logged in, refreshing profile...");
        getUserProfile();
      } else {
        print("User logged out, clearing profile data...");
        _clearProfileData();
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  /// مسح بيانات الملف الشخصي عند تسجيل الخروج
  void _clearProfileData() {
    currentUser = null;
    selectedImage = null;
    currentImageUrl = null;
    nameController.clear();
    descriptionController.clear();
    phoneController.clear();
    statusRequest = StatusRequest.none;
    updateStatusRequest = StatusRequest.none;
    update();
    print("Profile data cleared");
  }

  /// جلب معلومات المستخدم
  Future<void> getUserProfile() async {
    try {
      statusRequest = StatusRequest.loading;
      update();

      // التحقق من حالة المصادقة أولاً
      if (!authController.isAuthenticated) {
        print("User not authenticated, loading guest data");
        _loadGuestData();
        return;
      }

      // الحصول على معرف المستخدم من AuthController بدلاً من SharedPreferences
      String? userId = authController.currentUser?['users_id']?.toString();

      if (userId == null || userId.isEmpty) {
        print("No user ID found in AuthController, checking SharedPreferences");
        userId = myServices.sharedPreferences.getString("id");
      }

      if (userId == null || userId.isEmpty) {
        print("No user ID found, treating as guest");
        _loadGuestData();
        return;
      }

      print("Loading profile for user ID: $userId");

      var response = await profileData.getUserProfile(userId);
      statusRequest = handlingData(response);

      if (statusRequest == StatusRequest.success) {
        if (response['status'] == "success") {
          currentUser = UserModel.fromJson(response['data']);
          _fillFormWithUserData();
          _updateSharedPreferences();
          print("Profile loaded successfully for: ${currentUser?.usersName}");
        } else {
          statusRequest = StatusRequest.failure;
          Get.snackbar("خطأ", response['message'] ?? "فشل في جلب البيانات");
        }
      }
    } catch (e) {
      statusRequest = StatusRequest.serverfailure;
      Get.snackbar("خطأ", "حدث خطأ في الاتصال بالخادم");
      print("Error in getUserProfile: $e");
    }
    update();
  }

  /// تحميل بيانات المستخدم الزائر
  void _loadGuestData() {
    try {
      Map<String, dynamic>? guestData = guestController.currentUser;

      if (guestData != null) {
        // إنشاء UserModel من بيانات الزائر
        currentUser = UserModel(
          usersId: guestData['users_id']?.toString(),
          usersName: guestData['users_name'] ?? 'زائر',
          usersEmail: guestData['users_email'] ?? '',
          usersPhone: guestData['users_phone'] ?? '',
          usersDescription: 'مستخدم زائر',
          usersImage: null,
          usersCreatedate: guestData['users_create'] ?? DateTime.now().toIso8601String(),
        );

        _fillFormWithUserData();
        statusRequest = StatusRequest.success;
        print("Guest data loaded: ${currentUser?.usersName}");
      } else {
        statusRequest = StatusRequest.failure;
        print("No guest data available");
      }
    } catch (e) {
      statusRequest = StatusRequest.failure;
      print("Error loading guest data: $e");
    }
    update();
  }

  /// ملء النموذج ببيانات المستخدم
  void _fillFormWithUserData() {
    if (currentUser != null) {
      nameController.text = currentUser?.usersName ?? "";
      descriptionController.text = currentUser?.usersDescription ?? "";
      phoneController.text = currentUser?.usersPhone ?? "";
      currentImageUrl = currentUser?.usersImage;
    }
  }

  /// تحديث البيانات في SharedPreferences
  void _updateSharedPreferences() {
    if (currentUser != null && authController.isAuthenticated) {
      myServices.sharedPreferences
          .setString("username", currentUser!.usersName ?? "");
      myServices.sharedPreferences
          .setString("phone", currentUser!.usersPhone ?? "");
    }
  }

  /// اختيار صورة من المعرض
  Future<void> chooseImageFromGallery() async {
    // التحقق من أن المستخدم مسجل دخول
    if (!authController.isAuthenticated) {
      Get.snackbar("تنبيه", "يجب تسجيل الدخول لتحديث الصورة");
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        selectedImage = File(image.path);
        update();
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل في اختيار الصورة من المعرض");
      print("Error picking image from gallery: $e");
    }
  }

  /// اختيار صورة من الكاميرا
  Future<void> chooseImageFromCamera() async {
    // التحقق من أن المستخدم مسجل دخول
    if (!authController.isAuthenticated) {
      Get.snackbar("تنبيه", "يجب تسجيل الدخول لتحديث الصورة");
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        selectedImage = File(image.path);
        update();
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل في التقاط الصورة");
      print("Error picking image from camera: $e");
    }
  }

  /// إظهار خيارات اختيار الصورة
  void showImagePickerOptions() {
    // التحقق من أن المستخدم مسجل دخول
    if (!authController.isAuthenticated) {
      Get.snackbar("تنبيه", "يجب تسجيل الدخول لتحديث الصورة");
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر صورة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'الكاميرا',
                  color: Colors.blue,
                  onTap: () {
                    Get.back();
                    chooseImageFromCamera();
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'المعرض',
                  color: Colors.green,
                  onTap: () {
                    Get.back();
                    chooseImageFromGallery();
                  },
                ),
              ],
            ),
            if (selectedImage != null || currentImageUrl != null) ...[
              const SizedBox(height: 20),
              _buildImagePickerOption(
                icon: Icons.delete,
                label: 'حذف الصورة',
                color: Colors.red,
                onTap: () {
                  Get.back();
                  resetSelectedImage();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// بناء خيار اختيار الصورة
  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }

  /// تحديث الملف الشخصي
  Future<void> updateProfile() async {
    // التحقق من أن المستخدم مسجل دخول
    if (!authController.isAuthenticated) {
      Get.snackbar("تنبيه", "يجب تسجيل الدخول لتحديث الملف الشخصي");
      return;
    }

    if (!_validateForm()) return;

    try {
      updateStatusRequest = StatusRequest.loading;
      update();

      String? userId = authController.currentUser?['users_id']?.toString();
      if (userId == null) {
        updateStatusRequest = StatusRequest.failure;
        update();
        Get.snackbar("خطأ", "لم يتم العثور على معرف المستخدم");
        return;
      }

      var response = await profileData.updateUserProfile(
        userid: userId,
        username: nameController.text.trim(),
        userdescription: descriptionController.text.trim(),
        userphone: phoneController.text.trim(),
        imageFile: selectedImage,
        imageold: currentImageUrl,
      );

      updateStatusRequest = handlingData(response);

      if (updateStatusRequest == StatusRequest.success) {
        if (response['status'] == "success") {
          // تحديث البيانات في AuthController
          Map<String, dynamic> updatedUserData = Map<String, dynamic>.from(authController.currentUser ?? {});
          updatedUserData['users_name'] = nameController.text.trim();
          updatedUserData['users_phone'] = phoneController.text.trim();
          authController.setCurrentUser(updatedUserData);

          // تحديث البيانات المحلية
          _updateSharedPreferences();

          // إعادة تعيين الصورة المختارة
          selectedImage = null;

          // إظهار رسالة نجاح
          Get.snackbar(
            "نجح",
            "تم تحديث الملف الشخصي بنجاح",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          // إعادة جلب البيانات المحدثة
          await getUserProfile();

          // إغلاق الـ dialog
          Get.back();

        } else {
          updateStatusRequest = StatusRequest.failure;
          Get.snackbar("خطأ", response['message'] ?? "فشل في تحديث الملف الشخصي");
        }
      } else {
        Get.snackbar("خطأ", "حدث خطأ أثناء التحديث");
      }
    } catch (e) {
      updateStatusRequest = StatusRequest.serverfailure;
      Get.snackbar("خطأ", "حدث خطأ في الاتصال بالخادم");
      print("Error in updateProfile: $e");
    }
    update();
  }

  /// التحقق من صحة النموذج
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar("خطأ", "يرجى إدخال الاسم");
      return false;
    }

    if (nameController.text.trim().length < 2) {
      Get.snackbar("خطأ", "يجب أن يكون الاسم أكثر من حرفين");
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      Get.snackbar("خطأ", "يرجى إدخال رقم الهاتف");
      return false;
    }

    if (phoneController.text.trim().length < 10) {
      Get.snackbar("خطأ", "رقم الهاتف غير صحيح");
      return false;
    }

    return true;
  }

  /// إعادة تعيين الصورة المختارة
  void resetSelectedImage() {
    selectedImage = null;
    update();
  }

  /// تحديث الصورة فقط
  Future<void> updateImageOnly() async {
    // التحقق من أن المستخدم مسجل دخول
    if (!authController.isAuthenticated) {
      Get.snackbar("تنبيه", "يجب تسجيل الدخول لتحديث الصورة");
      return;
    }

    if (selectedImage == null) {
      Get.snackbar("خطأ", "يرجى اختيار صورة أولاً");
      return;
    }

    try {
      updateStatusRequest = StatusRequest.loading;
      update();

      String? userId = authController.currentUser?['users_id']?.toString();
      if (userId == null) {
        updateStatusRequest = StatusRequest.failure;
        update();
        Get.snackbar("خطأ", "لم يتم العثور على معرف المستخدم");
        return;
      }

      var response = await profileData.updateUserImage(
        userid: userId,
        imageFile: selectedImage!,
        imageold: currentImageUrl,
      );

      updateStatusRequest = handlingData(response);

      if (updateStatusRequest == StatusRequest.success) {
        if (response['status'] == "success") {
          selectedImage = null;
          Get.snackbar(
            "نجح",
            "تم تحديث الصورة بنجاح",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          getUserProfile();
        } else {
          Get.snackbar("خطأ", response['message'] ?? "فشل في تحديث الصورة");
        }
      }
    } catch (e) {
      updateStatusRequest = StatusRequest.serverfailure;
      Get.snackbar("خطأ", "حدث خطأ في الاتصال بالخادم");
      print("Error in updateImageOnly: $e");
    }
    update();
  }

  /// إعادة تحميل البيانات
  Future<void> refreshProfile() async {
    await getUserProfile();
  }

  /// التحقق من وجود تغييرات في النموذج
  bool hasChanges() {
    if (currentUser == null) return false;

    return nameController.text.trim() != (currentUser?.usersName ?? "") ||
        descriptionController.text.trim() !=
            (currentUser?.usersDescription ?? "") ||
        phoneController.text.trim() != (currentUser?.usersPhone ?? "") ||
        selectedImage != null;
  }

  /// إعادة تعيين النموذج للقيم الأصلية
  void resetForm() {
    _fillFormWithUserData();
    selectedImage = null;
    update();
  }

  /// التحقق من نوع المستخدم
  bool get isGuestUser => !authController.isAuthenticated;

  /// الحصول على نوع المستخدم كنص
  String get userTypeText => authController.isAuthenticated ? 'مستخدم مسجل' : 'مستخدم زائر';
}
