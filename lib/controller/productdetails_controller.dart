import 'dart:convert';
import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/core/services/services.dart';
import 'package:ecommercecourse/data/datasource/remote/cart_data.dart';
import 'package:ecommercecourse/data/datasource/remote/items_data.dart';
import 'package:ecommercecourse/data/model/itemsmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'favorite_controller.dart';

/// Abstract controller for product details.
abstract class ProductDetailsController extends GetxController {
  var isFavorite = false.obs;

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }
}

/// Controller implementation for product details.
class ProductDetailsControllerImp extends ProductDetailsController {
  late ItemsModel itemsModel;
  CartData cartData = CartData(Get.find());
  ItemsData itemsData = ItemsData(Get.find());
  late StatusRequest statusRequest;
  MyServices myServices = Get.find();

  int initialCount = 0;
  int localCount = 1;

  // قائمة المنتجات ذات الصلة
  List<ItemsModel> relatedProducts = [];

  // متغيرات للتحكم في عرض الوسائط المتعددة
  PageController? pageController;
  int currentMediaIndex = 0;

  /// دوال للحصول على الصور والفيديوهات من JSON
  List<String> getImagesList() {
    if (itemsModel.itemsImage == null || itemsModel.itemsImage == "empty") {
      return [];
    }

    try {
      Map<String, dynamic> filesData = jsonDecode(itemsModel.itemsImage!);
      if (filesData['images'] != null) {
        return List<String>.from(filesData['images']);
      }
    } catch (e) {
      // إذا كان النص ليس JSON (النظام القديم)
      return [itemsModel.itemsImage!];
    }
    return [];
  }

  List<String> getVideosList() {
    if (itemsModel.itemsImage == null || itemsModel.itemsImage == "empty") {
      return [];
    }

    try {
      Map<String, dynamic> filesData = jsonDecode(itemsModel.itemsImage!);
      if (filesData['videos'] != null) {
        return List<String>.from(filesData['videos']);
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  String getFirstImage() {
    List<String> images = getImagesList();
    if (images.isNotEmpty) {
      return images.first;
    }
    return "";
  }

  List<Map<String, dynamic>> getAllMediaList() {
    List<Map<String, dynamic>> allMedia = [];

    // إضافة الصور
    for (String image in getImagesList()) {
      allMedia.add({'type': 'image', 'url': image});
    }

    // إضافة الفيديوهات
    for (String video in getVideosList()) {
      allMedia.add({'type': 'video', 'url': video});
    }

    return allMedia;
  }

  int getTotalMediaCount() {
    return getImagesList().length + getVideosList().length;
  }

  /// تحديث فهرس الوسائط الحالي
  void updateCurrentMediaIndex(int index) {
    currentMediaIndex = index;
    update();
  }

  /// الانتقال إلى الوسائط التالية
  void nextMedia() {
    int totalMedia = getTotalMediaCount();
    if (totalMedia > 1 && pageController != null) {
      int nextIndex = (currentMediaIndex + 1) % totalMedia;
      pageController!.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// الانتقال إلى الوسائط السابقة
  void previousMedia() {
    int totalMedia = getTotalMediaCount();
    if (totalMedia > 1 && pageController != null) {
      int prevIndex = currentMediaIndex == 0 ? totalMedia - 1 : currentMediaIndex - 1;
      pageController!.animateToPage(
        prevIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// دالة التشخيص لمعلومات التاجر
  void debugMerchantData() {
    print("=== Merchant Debug Info ===");
    print("Seller Name: '${itemsModel.sellerName}'");
    print("Seller Image: '${itemsModel.sellerImage}'");
    print("Average Rating: '${itemsModel.averageRating}'");
    print("Total Ratings: '${itemsModel.totalRatings}'");
    print("Items ID Seller: '${itemsModel.itemsIdSeller}'");
    print("Images: ${getImagesList()}");
    print("Videos: ${getVideosList()}");
    print("Total Media: ${getTotalMediaCount()}");
    print("========================");
  }

  /// Initialize data when controller starts
  initialData() async {
    statusRequest = StatusRequest.loading;
    update();

    itemsModel = Get.arguments['itemsmodel'];

    // إضافة دالة التشخيص
    debugMerchantData();

    // جلب عدد المنتجات في السلة
    initialCount = await getCountItems(itemsModel.itemsId!);
    localCount = initialCount == 0 ? 1 : initialCount;

    // جلب المنتجات ذات الصلة
    await getRelatedProducts();

    statusRequest = StatusRequest.success;
    update();
  }

  /// Get count of items in cart for this product
  getCountItems(String itemsid) async {
    statusRequest = StatusRequest.loading;
    var response = await cartData.getCountCart(
        myServices.sharedPreferences.getString("id")!,
        itemsid
    );
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        int count = int.parse(response['data'].toString());
        return count;
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    return 0;
  }

  /// Get related products from the same category
  getRelatedProducts() async {
    try {
      var response = await itemsData.getData(
          itemsModel.categoriesId.toString(),
          myServices.sharedPreferences.getString("id") ?? "0"
      );

      StatusRequest relatedStatus = handlingData(response);

      if (StatusRequest.success == relatedStatus) {
        if (response['status'] == "success") {
          List dataresponse = response['data'];
          relatedProducts.clear();
          relatedProducts.addAll(dataresponse.map((e) => ItemsModel.fromJson(e)));

          relatedProducts.removeWhere((product) =>
          product.itemsId == itemsModel.itemsId);

          if (relatedProducts.length > 6) {
            relatedProducts = relatedProducts.take(6).toList();
          }
        }
      }
    } catch (e) {
      print("Error getting related products: $e");
    }
  }

  /// Increase the local count without contacting the server.
  incrementLocal() {
    localCount++;
    update();
  }

  /// Decrease the local count without contacting the server.
  decrementLocal() {
    if (localCount > 1) {
      localCount--;
      update();
    }
  }

  /// Update the server cart when the "Add to Cart" button is pressed.
  updateCart() async {
    statusRequest = StatusRequest.loading;
    update();

    int diff = initialCount == 0 ? localCount : localCount - initialCount;
    var response;

    try {
      if (diff > 0) {
        for (int i = 0; i < diff; i++) {
          response = await cartData.addCart(
              myServices.sharedPreferences.getString("id")!,
              itemsModel.itemsId!
          );
          statusRequest = handlingData(response);
          if (response['status'] != "success") {
            statusRequest = StatusRequest.failure;
            Get.snackbar(
              "إشعار",
              "فشل في إضافة المنتج للسلة",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
            );
            update();
            return;
          }
        }
      } else if (diff < 0) {
        for (int i = 0; i < (-diff); i++) {
          response = await cartData.deleteCart(
              myServices.sharedPreferences.getString("id")!,
              itemsModel.itemsId!
          );
          statusRequest = handlingData(response);
          if (response['status'] != "success") {
            statusRequest = StatusRequest.failure;
            Get.snackbar(
              "إشعار",
              "فشل في إزالة المنتج من السلة",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
            );
            update();
            return;
          }
        }
      }

      statusRequest = StatusRequest.success;
      initialCount = localCount;

      Get.snackbar(
        "إشعار",
        "تم تحديث السلة بنجاح",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      statusRequest = StatusRequest.failure;
      Get.snackbar(
        "خطأ",
        "حدث خطأ: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }

    update();
  }

  /// Add product to cart (for related products)
  addToCart(ItemsModel product) async {
    try {
      var response = await cartData.addCart(
          myServices.sharedPreferences.getString("id")!,
          product.itemsId!
      );

      StatusRequest addStatus = handlingData(response);

      if (StatusRequest.success == addStatus) {
        if (response['status'] == "success") {
          Get.snackbar(
            "تمت الإضافة",
            "تم إضافة ${product.itemsName} للسلة",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            duration: const Duration(seconds: 2),
          );
        } else {
          Get.snackbar(
            "خطأ",
            "فشل في إضافة المنتج للسلة",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }

  /// Toggle favorite status for related products
  toggleFavoriteForProduct(ItemsModel product) {
    try {
      FavoriteController favoriteController = Get.find<FavoriteController>();
      String itemId = product.itemsId?.toString() ?? '';

      bool currentStatus = favoriteController.isFavorite[itemId] ??
          (product.favorite == "1");

      favoriteController.setFavorite(itemId, !currentStatus);

      if (!currentStatus) {
        favoriteController.addFavorite(itemId);
      } else {
        favoriteController.removeFavorite(itemId);
      }

      int index = relatedProducts.indexWhere((p) => p.itemsId == product.itemsId);
      if (index != -1) {
        relatedProducts[index].favorite = !currentStatus ? "1" : "0";
        update();
      }

    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }

  /// Calculate discount percentage
  int calculateDiscountPercentage(ItemsModel product) {
    if (product.itemsPrice == null || product.itemsPriceDiscount == null) {
      return 0;
    }

    double original = double.tryParse(product.itemsPrice.toString()) ?? 0;
    double discounted = double.tryParse(product.itemsPriceDiscount.toString()) ?? 0;

    if (original <= 0 || discounted >= original) return 0;

    double percentage = ((original - discounted) / original) * 100;
    return percentage.round();
  }

  /// Navigate to product details
  goToProductDetails(ItemsModel product) {
    Get.toNamed("/productdetails", arguments: {"itemsmodel": product});
  }

  /// Show success message
  showSuccessMessage(String message) {
    Get.snackbar(
      "نجح",
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Show error message
  showErrorMessage(String message) {
    Get.snackbar(
      "خطأ",
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  /// Show info message
  showInfoMessage(String message) {
    Get.snackbar(
      "معلومات",
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  /// دوال للحصول على معلومات التاجر
  String getMerchantName() {
    return itemsModel.sellerName ?? "مجهول";
  }

  String? getMerchantImage() {
    return itemsModel.sellerImage?.isNotEmpty == true ? itemsModel.sellerImage : null;
  }

  double getMerchantRating() {
    return double.tryParse(itemsModel.averageRating ?? "0") ?? 0.0;
  }

  int getMerchantReviewCount() {
    return int.tryParse(itemsModel.totalRatings ?? "0") ?? 0;
  }

  // بيانات تجريبية للألوان والأحجام (يمكن تطويرها لاحقاً)
  List subitems = [
    {"name": "أحمر", "id": 1, "active": '0'},
    {"name": "أصفر", "id": 2, "active": '0'},
    {"name": "أسود", "id": 3, "active": '1'}
  ];

  @override
  void onInit() {
    pageController = PageController();
    initialData();
    super.onInit();
    print("Product favorite status: ${itemsModel.favorite}");
    print("------------------------------==============");
  }

  @override
  void onClose() {
    relatedProducts.clear();
    pageController?.dispose();
    super.onClose();
  }
}
