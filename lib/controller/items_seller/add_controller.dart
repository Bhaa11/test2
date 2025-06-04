import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/statusrequest.dart';
import '../../core/constant/routes.dart';
import '../../core/functions/handingdatacontroller.dart';
import '../../core/functions/uploadfile.dart';
import '../../core/services/services.dart';
import '../../data/datasource/remote/items_data_seller.dart';
import 'package:ecommercecourse/controller/items_seller/view_controller.dart';

class ItemsAddController extends GetxController {
  final ItemsDataSeller itemsDataSeller = ItemsDataSeller(Get.find());
  final MyServices myServices = Get.find();

  // Step Management
  final PageController pageController = PageController();
  int currentStep = 0;
  final GlobalKey<FormState> stepOneFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> stepTwoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> stepThreeFormKey = GlobalKey<FormState>();

  // Controllers للحقول
  late TextEditingController name;
  late TextEditingController namear;
  late TextEditingController desc;
  late TextEditingController descar;
  late TextEditingController price;
  late TextEditingController count;
  late TextEditingController discount;

  // Controllers للخطوة الثالثة
  late TextEditingController carModel;
  late TextEditingController carYear;
  late TextEditingController carColor;
  late TextEditingController deliveryPrice;
  late TextEditingController deliveryDuration;

  // State
  StatusRequest statusRequest = StatusRequest.none;

  // تغيير من File واحد إلى قائمة من الملفات
  List<File> selectedFiles = [];

  List<String> carVariants = [];

  // إضافة حالة المنتج
  int? productStatus;
  bool showStatusError = false;

  // إضافة متغير للتحقق من خطأ الملفات
  bool showFilesError = false;

  @override
  void onInit() {
    super.onInit();
    _initControllers();
  }

  void _initControllers() {
    // خطوة 1 & 2
    name = TextEditingController();
    namear = TextEditingController();
    desc = TextEditingController();
    descar = TextEditingController();
    price = TextEditingController();
    count = TextEditingController();
    discount = TextEditingController();

    // خطوة 3
    carModel = TextEditingController();
    carYear = TextEditingController();
    carColor = TextEditingController();
    deliveryPrice = TextEditingController();
    deliveryDuration = TextEditingController();
  }

  @override
  void onClose() {
    // تصفية جميع الـ controllers لتفادي التسريبات
    name.dispose();
    namear.dispose();
    desc.dispose();
    descar.dispose();
    price.dispose();
    count.dispose();
    discount.dispose();
    carModel.dispose();
    carYear.dispose();
    carColor.dispose();
    deliveryPrice.dispose();
    deliveryDuration.dispose();
    super.onClose();
  }

  // وظيفة لتعيين حالة المنتج
  void setProductStatus(int status) {
    productStatus = status;
    showStatusError = false;
    update();
  }

  /// تضيف سيارات الى القائمة مع إدارة حالات "الكل"
  void addCarVariant(List<String> variants) {
    for (var variant in variants) {
      final parts = variant.split('-');
      if (parts.length != 3) continue;

      final manufacturerModel = '${parts[0]}-${parts[1]}';
      final year = parts[2];

      if (year == 'الكل') {
        carVariants.removeWhere((el) => el.startsWith(manufacturerModel + '-'));
        if (!carVariants.contains(variant)) {
          carVariants.add(variant);
        }
      } else {
        bool hasAll = carVariants.any((el) =>
        el.startsWith(manufacturerModel + '-') && el.endsWith('الكل'));
        if (!hasAll && !carVariants.contains(variant)) {
          carVariants.add(variant);
        }
      }
    }
    update();
  }

  void removeCarVariant(String variant) {
    carVariants.remove(variant);
    update();
  }

  // وظيفة لمسح الملفات
  void clearFiles() {
    selectedFiles.clear();
    update();
  }

  // وظيفة لحذف ملف واحد
  void removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
      update();
    }
  }

  // دالة للتحقق من نوع الملف
  bool isVideoFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv'].contains(extension);
  }

  bool isImageFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['png', 'jpg', 'jpeg', 'gif'].contains(extension);
  }

  // دالة لتنظيم الملفات (صور أولاً ثم فيديوهات)
  Map<String, List<String>> organizeFileNames() {
    List<String> imageNames = [];
    List<String> videoNames = [];

    for (File file in selectedFiles) {
      String fileName = file.path.split('/').last;
      if (isImageFile(file)) {
        imageNames.add(fileName);
      } else if (isVideoFile(file)) {
        videoNames.add(fileName);
      }
    }

    return {
      'images': imageNames,
      'videos': videoNames,
    };
  }

  set additionalProductDetails(List<String> additionalProductDetails) {
    addCarVariant(additionalProductDetails);
  }

  // التنقل بين الخطوات
  void nextStep() {
    if (currentStep == 0) {
      if (productStatus == null) {
        showStatusError = true;
        update();
        return;
      }

      // التحقق من الملفات
      if (selectedFiles.isEmpty) {
        showFilesError = true;
        update();
        return;
      }

      if (stepOneFormKey.currentState!.validate()) {
        showFilesError = false; // إعادة تعيين حالة خطأ الملفات
        currentStep = 1;
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        update();
      }
    } else if (currentStep == 1) {
      if (stepTwoFormKey.currentState!.validate()) {
        currentStep = 2;
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        update();
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      update();
    }
  }

  // اختيار الملفات
  void showOptionFiles() {
    showMultipleFilesBottomMenu(chooseMultipleFiles);
  }

  Future<void> chooseMultipleFiles() async {
    try {
      List<File>? files = await multipleFilesUploadGallery();
      if (files != null && files.isNotEmpty) {
        // التحقق من عدم تجاوز 10 ملفات
        int totalFiles = selectedFiles.length + files.length;
        if (totalFiles > 10) {
          int allowedFiles = 10 - selectedFiles.length;
          if (allowedFiles > 0) {
            selectedFiles.addAll(files.take(allowedFiles));
            Get.snackbar("تنبيه", "تم اختيار $allowedFiles ملف فقط. الحد الأقصى 10 ملفات");
          } else {
            Get.snackbar("تنبيه", "لقد وصلت للحد الأقصى من الملفات (10 ملفات)");
          }
        } else {
          selectedFiles.addAll(files);
        }
        showFilesError = false; // إعادة تعيين خطأ الملفات عند اختيار ملفات
        update();
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ في اختيار الملفات: ${e.toString()}");
    }
  }

  // إرسال البيانات
  Future<void> addData() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!stepThreeFormKey.currentState!.validate()) return;
    if (selectedFiles.isEmpty) {
      Get.snackbar("تنبيه", "الرجاء اختيار ملف واحد على الأقل للمنتج");
      return;
    }
    if (carVariants.isEmpty) {
      Get.snackbar("تنبيه", "يرجى إضافة سيارة واحدة على الأقل");
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    // تنظيم أسماء الملفات
    Map<String, List<String>> organizedFiles = organizeFileNames();
    String filesJson = jsonEncode(organizedFiles);

    final data = {
      "name": name.text,
      "namear": namear.text,
      "desc": desc.text,
      "descar": descar.text,
      "price": price.text,
      "count": count.text,
      "discount": discount.text,
      "catid": "1",
      "datenow": DateTime.now().toString(),
      "items_id_seller": myServices.sharedPreferences.getString("id")!,
      "items_car_variants": carVariants,
      "delivery_price": deliveryPrice.text,
      "delivery_duration": deliveryDuration.text,
      "items_product_status": productStatus.toString(),
      "files_json": filesJson, // إرسال JSON للملفات
    };

    try {
      final response = await itemsDataSeller.addMultiple(data, selectedFiles);
      statusRequest = handlingData(response);
      if (statusRequest == StatusRequest.success && response['status'] == "success") {
        Get.offNamed(AppRoute.itemsview);
        Get.find<ItemsControllerSeller>().getData();
      } else {
        Get.snackbar("خطأ", "فشل في إضافة المنتج: ${response['message']}");
      }
    } catch (e) {
      statusRequest = StatusRequest.serverfailure;
      Get.snackbar("خطأ", "خطأ في الاتصال: ${e.toString()}");
    }

    update();
  }
}
