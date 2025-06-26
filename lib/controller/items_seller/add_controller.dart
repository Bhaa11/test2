import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_compress/video_compress.dart';

// Imports للمشروع
import '../../core/class/statusrequest.dart';
import '../../core/constant/routes.dart';
import '../../core/functions/handingdatacontroller.dart';
import '../../core/functions/uploadfile.dart';
import '../../core/services/services.dart';
import '../../core/services/compression_service.dart';
import '../../data/datasource/remote/items_data_seller.dart';
import 'view_controller.dart';

class ItemsAddController extends GetxController {
  final ItemsDataSeller itemsDataSeller = ItemsDataSeller(Get.find());
  final MyServices myServices = Get.find();
  final CompressionService _compressionService = CompressionService.instance;

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

  // إضافة متغيرات للضغط
  List<File> originalFiles = []; // الملفات الأصلية
  bool isCompressing = false; // حالة الضغط
  String compressionProgress = ""; // نص تقدم الضغط
  int compressionCurrentFile = 0; // الملف الحالي
  int compressionTotalFiles = 0; // إجمالي الملفات

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

    // تنظيف ملفات الضغط المؤقتة
    _compressionService.cleanTempFiles();
    _compressionService.dispose();

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
    originalFiles.clear();
    showFilesError = false;
    update();
  }

  // وظيفة لحذف ملف واحد
  void removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
      if (index < originalFiles.length) {
        originalFiles.removeAt(index);
      }

      // إذا لم تعد هناك ملفات، أظهر رسالة الخطأ
      if (selectedFiles.isEmpty) {
        showFilesError = true;
      }

      update();
    }
  }

  // دالة للتحقق من نوع الملف
  bool isVideoFile(File file) {
    return _compressionService.isVideoFile(file);
  }

  bool isImageFile(File file) {
    return _compressionService.isImageFile(file);
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
      // التحقق من حالة المنتج
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

      // التحقق من صحة النموذج
      if (stepOneFormKey.currentState!.validate()) {
        showFilesError = false;
        showStatusError = false;
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

  // اختيار الملفات - محدث لدعم خيارات الكاميرا المتعددة
  void showOptionFiles() {
    showMultipleFilesBottomMenu(
        chooseImageFromCamera,
        chooseVideoFromCamera,
        chooseMultipleFiles
    );
  }

  // التقاط صورة من الكاميرا
  Future<void> chooseImageFromCamera() async {
    try {
      List<File>? files = await multipleImageUploadCamera();
      if (files != null && files.isNotEmpty) {
        // التحقق من عدم تجاوز 10 ملفات
        if (selectedFiles.length >= 10) {
          Get.snackbar(
            "تنبيه",
            "لقد وصلت للحد الأقصى من الملفات (10 ملفات)",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
          );
          return;
        }

        // حفظ الملفات الأصلية وبدء عملية الضغط
        originalFiles.addAll(files);
        await _compressAndAddFiles(files);
        showFilesError = false;
        update();
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ في التقاط الصورة: ${e.toString()}",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  // تصوير فيديو من الكاميرا
  Future<void> chooseVideoFromCamera() async {
    try {
      List<File>? files = await multipleVideoUploadCamera();
      if (files != null && files.isNotEmpty) {
        // التحقق من عدم تجاوز 10 ملفات
        if (selectedFiles.length >= 10) {
          Get.snackbar(
            "تنبيه",
            "لقد وصلت للحد الأقصى من الملفات (10 ملفات)",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
          );
          return;
        }

        // التحقق من حجم الفيديو
        File videoFile = files.first;
        int fileSizeInBytes = await videoFile.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 100) { // حد أقصى 100 ميجابايت
          Get.snackbar(
            "تنبيه",
            "حجم الفيديو كبير جداً (${fileSizeInMB.toStringAsFixed(1)} MB). الحد الأقصى 100 MB",
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade800,
          );
          return;
        }

        // حفظ الملفات الأصلية وبدء عملية الضغط
        originalFiles.addAll(files);
        await _compressAndAddFiles(files);
        showFilesError = false;
        update();
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ في تصوير الفيديو: ${e.toString()}",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
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
            files = files.take(allowedFiles).toList();
            Get.snackbar(
              "تنبيه",
              "تم اختيار $allowedFiles ملف فقط. الحد الأقصى 10 ملفات",
              backgroundColor: Colors.orange.shade100,
              colorText: Colors.orange.shade800,
            );
          } else {
            Get.snackbar(
              "تنبيه",
              "لقد وصلت للحد الأقصى من الملفات (10 ملفات)",
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade800,
            );
            return;
          }
        }

        // حفظ الملفات الأصلية وبدء عملية الضغط
        originalFiles.addAll(files);
        await _compressAndAddFiles(files);
        showFilesError = false;
        update();
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ في اختيار الملفات: ${e.toString()}",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  // وظيفة ضغط الملفات المختارة
  Future<void> _compressAndAddFiles(List<File> files) async {
    isCompressing = true;
    compressionCurrentFile = 0;
    compressionTotalFiles = files.length;
    compressionProgress = "جاري تحضير الملفات للضغط...";
    update();

    try {
      // حساب الحجم الإجمالي قبل الضغط
      int totalOriginalSize = 0;
      for (File file in files) {
        totalOriginalSize += await file.length();
      }

      final compressedFiles = await _compressionService.compressMultipleFiles(
        files,
        onProgress: (current, total, fileName) {
          compressionCurrentFile = current;
          compressionTotalFiles = total;
          compressionProgress = "ضغط: $fileName ($current/$total)";
          update();
        },
        imageQuality: 75, // جودة الصور (0-100)
        videoQuality: VideoQuality.MediumQuality, // جودة الفيديو
        targetImageSize: (1.5 * 1024 * 1024).round(), // 1.5 MB للصور - تحويل إلى int
      );

      selectedFiles.addAll(compressedFiles);

      // حساب الحجم الإجمالي بعد الضغط
      int totalCompressedSize = 0;
      for (File file in compressedFiles) {
        totalCompressedSize += await file.length();
      }

      // حساب نسبة التوفير
      final compressionRatio = totalOriginalSize > 0
          ? ((totalOriginalSize - totalCompressedSize) / totalOriginalSize * 100).round()
          : 0;

      // عرض النتيجة
      Get.snackbar(
        "تم الضغط بنجاح",
        "تم توفير $compressionRatio% من الحجم الأصلي\nمن ${_compressionService.formatFileSize(totalOriginalSize)} إلى ${_compressionService.formatFileSize(totalCompressedSize)}",
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 4),
      );

    } catch (e) {
      Get.snackbar(
        "خطأ",
        "فشل في ضغط بعض الملفات: ${e.toString()}",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      // في حالة فشل الضغط، استخدم الملفات الأصلية
      selectedFiles.addAll(files);
    } finally {
      isCompressing = false;
      compressionProgress = "";
      compressionCurrentFile = 0;
      compressionTotalFiles = 0;
      update();
    }
  }

  // الحصول على معلومات الملف
  Future<Map<String, dynamic>> getFileInfo(File file) async {
    return await _compressionService.getFileInfo(file);
  }

  // الحصول على حالة التقدم كنسبة مئوية - مُصحح
  double get compressionProgressPercent {
    if (compressionTotalFiles == 0) return 0.0;
    return compressionCurrentFile.toDouble() / compressionTotalFiles.toDouble();
  }

  // الحصول على نسبة التقدم كنص
  String get compressionProgressText {
    if (compressionTotalFiles == 0) return "0%";
    final percent = (compressionProgressPercent * 100).round();
    return "$percent%";
  }

  // التحقق من إمكانية إضافة ملفات جديدة
  bool get canAddMoreFiles {
    return selectedFiles.length < 10 && !isCompressing;
  }

  // الحصول على عدد الملفات المتبقية
  int get remainingFilesCount {
    return 10 - selectedFiles.length;
  }

  // الحصول على إحصائيات الملفات
  Map<String, int> get filesStatistics {
    int imageCount = selectedFiles.where((f) => isImageFile(f)).length;
    int videoCount = selectedFiles.where((f) => isVideoFile(f)).length;

    return {
      'images': imageCount,
      'videos': videoCount,
      'total': selectedFiles.length,
    };
  }

  // إرسال البيانات
  Future<void> addData() async {
    FocusManager.instance.primaryFocus?.unfocus();

    // التحقق من صحة النموذج
    if (!stepThreeFormKey.currentState!.validate()) return;

    // التحقق من وجود ملفات
    if (selectedFiles.isEmpty) {
      Get.snackbar(
        "تنبيه",
        "الرجاء اختيار ملف واحد على الأقل للمنتج",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    // التحقق من وجود سيارات
    if (carVariants.isEmpty) {
      Get.snackbar(
        "تنبيه",
        "يرجى إضافة سيارة واحدة على الأقل",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    try {
      // تنظيم أسماء الملفات
      Map<String, List<String>> organizedFiles = organizeFileNames();
      String filesJson = jsonEncode(organizedFiles);

      final data = {
        "name": name.text.trim(),
        "namear": namear.text.trim(),
        "desc": desc.text.trim(),
        "descar": descar.text.trim(),
        "price": price.text.replaceAll(',', '').trim(), // إزالة الفواصل من السعر
        "count": count.text.replaceAll(',', '').trim(), // إزالة الفواصل من الكمية
        "discount": discount.text.trim(),
        "catid": "1",
        "datenow": DateTime.now().toString(),
        "items_id_seller": myServices.sharedPreferences.getString("id")!,
        "items_car_variants": carVariants,
        "delivery_price": deliveryPrice.text.replaceAll(',', '').trim(), // إزالة الفواصل من سعر التوصيل
        "delivery_duration": deliveryDuration.text.trim(),
        "items_product_status": productStatus.toString(),
        "files_json": filesJson,
      };

      final response = await itemsDataSeller.addMultiple(data, selectedFiles);
      statusRequest = handlingData(response);

      if (statusRequest == StatusRequest.success && response['status'] == "success") {
        // نجح الحفظ
        Get.snackbar(
          "نجح",
          "تم إضافة المنتج بنجاح",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );

        // الانتقال لصفحة المنتجات وتحديث البيانات
        Get.offNamed(AppRoute.itemsview);
        Get.find<ItemsControllerSeller>().getData();

        // تنظيف الملفات المؤقتة بعد الرفع
        _compressionService.cleanTempFiles();

      } else {
        statusRequest = StatusRequest.failure;
        Get.snackbar(
          "خطأ",
          "فشل في إضافة المنتج: ${response['message'] ?? 'خطأ غير معروف'}",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    } catch (e) {
      statusRequest = StatusRequest.serverfailure;
      Get.snackbar(
        "خطأ",
        "خطأ في الاتصال: ${e.toString()}",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }

    update();
  }

  // إعادة تعيين النموذج
  void resetForm() {
    // مسح النصوص
    name.clear();
    namear.clear();
    desc.clear();
    descar.clear();
    price.clear();
    count.clear();
    discount.clear();
    carModel.clear();
    carYear.clear();
    carColor.clear();
    deliveryPrice.clear();
    deliveryDuration.clear();

    // مسح البيانات الأخرى
    selectedFiles.clear();
    originalFiles.clear();
    carVariants.clear();
    productStatus = null;

    // إعادة تعيين الحالات
    showStatusError = false;
    showFilesError = false;
    isCompressing = false;
    compressionProgress = "";
    compressionCurrentFile = 0;
    compressionTotalFiles = 0;
    currentStep = 0;
    statusRequest = StatusRequest.none;

    // العودة للخطوة الأولى
    pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    update();
  }

  // التحقق من صحة البيانات في كل خطوة
  bool validateCurrentStep() {
    switch (currentStep) {
      case 0:
        return stepOneFormKey.currentState?.validate() == true &&
            productStatus != null &&
            selectedFiles.isNotEmpty;
      case 1:
        return stepTwoFormKey.currentState?.validate() == true;
      case 2:
        return stepThreeFormKey.currentState?.validate() == true &&
            carVariants.isNotEmpty;
      default:
        return false;
    }
  }

  // الحصول على عنوان الخطوة الحالية
  String get currentStepTitle {
    switch (currentStep) {
      case 0:
        return "معلومات المنتج الأساسية";
      case 1:
        return "التسعير والكمية";
      case 2:
        return "تفاصيل التوصيل والسيارات";
      default:
        return "خطوة غير معروفة";
    }
  }

  // الحصول على وصف الخطوة الحالية
  String get currentStepDescription {
    switch (currentStep) {
      case 0:
        return "أدخل اسم المنتج ووصفه وحالته مع إضافة الصور والفيديوهات";
      case 1:
        return "حدد سعر المنتج والكمية المتاحة مع الخصم إن وجد";
      case 2:
        return "أضف تفاصيل التوصيل والسيارات المتوافقة مع المنتج";
      default:
        return "";
    }
  }
}
