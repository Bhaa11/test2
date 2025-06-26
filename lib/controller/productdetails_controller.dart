// lib/controller/productdetails_controller.dart
import 'dart:convert';
import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/core/services/services.dart';
import 'package:ecommercecourse/data/datasource/remote/cart_data.dart';
import 'package:ecommercecourse/data/datasource/remote/items_data.dart';
import 'package:ecommercecourse/data/model/itemsmodel.dart';
import 'package:ecommercecourse/view/screen/image_gallery_view.dart';
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

  // متغيرات لحالات التحميل المختلفة
  bool isLoadingCart = true;
  bool isLoadingRelatedProducts = true;

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
      if (itemsModel.itemsImage != null && itemsModel.itemsImage!.isNotEmpty) {
        return [itemsModel.itemsImage!];
      }
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

  String getFirstVideo() {
    List<String> videos = getVideosList();
    if (videos.isNotEmpty) {
      return videos.first;
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

  /// Get media at specific index
  Map<String, dynamic>? getMediaAt(int index) {
    List<Map<String, dynamic>> allMedia = getAllMediaList();
    if (index >= 0 && index < allMedia.length) {
      return allMedia[index];
    }
    return null;
  }

  /// Check if current media is video
  bool isCurrentMediaVideo() {
    Map<String, dynamic>? currentMedia = getMediaAt(currentMediaIndex);
    return currentMedia?['type'] == 'video';
  }

  /// Check if current media is image
  bool isCurrentMediaImage() {
    Map<String, dynamic>? currentMedia = getMediaAt(currentMediaIndex);
    return currentMedia?['type'] == 'image';
  }

  /// Get video count
  int getVideoCount() {
    return getVideosList().length;
  }

  /// Get image count
  int getImageCount() {
    return getImagesList().length;
  }

  /// Get media info string
  String getMediaInfoString() {
    int imageCount = getImageCount();
    int videoCount = getVideoCount();

    List<String> parts = [];
    if (imageCount > 0) parts.add("$imageCount صورة");
    if (videoCount > 0) parts.add("$videoCount فيديو");

    return parts.join(" • ");
  }

  /// Check if product has multiple images
  bool hasMultipleImages() {
    return getImagesList().length > 1;
  }

  /// Check if product has videos
  bool hasVideos() {
    return getVideosList().isNotEmpty;
  }

  /// Check if product has images
  bool hasImages() {
    return getImagesList().isNotEmpty;
  }

  /// Check if product has multiple media
  bool hasMultipleMedia() {
    return getTotalMediaCount() > 1;
  }

  /// Get current media type
  String getCurrentMediaType() {
    List<Map<String, dynamic>> allMedia = getAllMediaList();
    if (currentMediaIndex < allMedia.length) {
      return allMedia[currentMediaIndex]['type'];
    }
    return 'image';
  }

  /// Get current media URL
  String getCurrentMediaUrl() {
    List<Map<String, dynamic>> allMedia = getAllMediaList();
    if (currentMediaIndex < allMedia.length) {
      return allMedia[currentMediaIndex]['url'];
    }
    return '';
  }

  /// Get current media object
  Map<String, dynamic>? getCurrentMedia() {
    List<Map<String, dynamic>> allMedia = getAllMediaList();
    if (currentMediaIndex < allMedia.length) {
      return allMedia[currentMediaIndex];
    }
    return null;
  }

  /// Open image gallery
  void openImageGallery(int initialIndex) {
    List<String> images = getImagesList();
    if (images.isNotEmpty) {
      Get.to(
            () => ImageGalleryView(
          images: images,
          initialIndex: initialIndex,
          productName: itemsModel.itemsName ?? "صور المنتج",
        ),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  /// Open single image
  void openSingleImage(String imageUrl) {
    Get.to(
          () => ImageGalleryView(
        images: [imageUrl],
        initialIndex: 0,
        productName: itemsModel.itemsName ?? "صورة المنتج",
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// تحديث فهرس الوسائط الحالي
  void updateCurrentMediaIndex(int index) {
    if (index >= 0 && index < getTotalMediaCount()) {
      currentMediaIndex = index;
      update();
    }
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

  /// الانتقال إلى فهرس معين
  void goToMediaIndex(int index) {
    if (index >= 0 && index < getTotalMediaCount() && pageController != null) {
      pageController!.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// دالة التشخيص لمعلومات التاجر
  void debugMerchantData() {
    print("=== Product Media Debug Info ===");
    print("Product Name: '${itemsModel.itemsName}'");
    print("Seller Name: '${itemsModel.sellerName}'");
    print("Seller Image: '${itemsModel.sellerImage}'");
    print("Average Rating: '${itemsModel.averageRating}'");
    print("Total Ratings: '${itemsModel.totalRatings}'");
    print("Items ID Seller: '${itemsModel.itemsIdSeller}'");
    print("Raw Images Data: '${itemsModel.itemsImage}'");
    print("Parsed Images: ${getImagesList()}");
    print("Parsed Videos: ${getVideosList()}");
    print("Total Media: ${getTotalMediaCount()}");
    print("Images Count: ${getImageCount()}");
    print("Videos Count: ${getVideoCount()}");
    print("Media Info: ${getMediaInfoString()}");
    print("Has Multiple Images: ${hasMultipleImages()}");
    print("Has Videos: ${hasVideos()}");
    print("Has Multiple Media: ${hasMultipleMedia()}");
    print("Current Media Index: $currentMediaIndex");
    print("Current Media Type: ${getCurrentMediaType()}");
    print("Current Media URL: ${getCurrentMediaUrl()}");
    print("================================");
  }

  /// Initialize data when controller starts
  void initialData() async {
    try {
      // البيانات الأساسية متوفرة مباشرة - لا نحتاج لشاشة تحميل
      if (Get.arguments != null && Get.arguments['itemsmodel'] != null) {
        itemsModel = Get.arguments['itemsmodel'];
      } else {
        statusRequest = StatusRequest.failure;
        update();
        return;
      }

      // استدعاء دالة التشخيص
      debugMerchantData();

      // تعيين حالة النجاح مباشرة للبيانات الأساسية
      statusRequest = StatusRequest.success;
      update();

      // تحميل البيانات الإضافية في الخلفية
      await _loadAdditionalData();
    } catch (e) {
      print("Error in initialData: $e");
      statusRequest = StatusRequest.failure;
      update();
    }
  }

  /// Load additional data in background
  Future<void> _loadAdditionalData() async {
    // تحميل بيانات السلة
    await _loadCartData();

    // تحميل المنتجات ذات الصلة
    await _loadRelatedProductsData();
  }

  /// Load cart data in background
  Future<void> _loadCartData() async {
    try {
      isLoadingCart = true;
      update();

      initialCount = await getCountItems(itemsModel.itemsId!);
      localCount = initialCount == 0 ? 1 : initialCount;

      isLoadingCart = false;
      update();
    } catch (e) {
      print("Error loading cart data: $e");
      isLoadingCart = false;
      localCount = 1; // قيمة افتراضية
      update();
    }
  }

  /// Load related products data in background
  Future<void> _loadRelatedProductsData() async {
    try {
      isLoadingRelatedProducts = true;
      update();

      await getRelatedProducts();

      isLoadingRelatedProducts = false;
      update();
    } catch (e) {
      print("Error loading related products: $e");
      isLoadingRelatedProducts = false;
      update();
    }
  }

  /// Get count of items in cart for this product
  Future<int> getCountItems(String itemsid) async {
    try {
      var response = await cartData.getCountCart(
          myServices.sharedPreferences.getString("id")!,
          itemsid
      );
      print("=============================== Controller $response ");
      StatusRequest cartStatus = handlingData(response);
      if (StatusRequest.success == cartStatus) {
        if (response['status'] == "success") {
          int count = int.parse(response['data'].toString());
          return count;
        }
      }
    } catch (e) {
      print("Error getting count items: $e");
    }
    return 0;
  }

  /// Get related products from the same category
  Future<void> getRelatedProducts() async {
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

          // إزالة المنتج الحالي من قائمة المنتجات ذات الصلة
          relatedProducts.removeWhere((product) =>
          product.itemsId == itemsModel.itemsId);

          // تحديد العدد إلى 6 منتجات كحد أقصى
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
  void incrementLocal() {
    localCount++;
    update();
  }

  /// Decrease the local count without contacting the server.
  void decrementLocal() {
    if (localCount > 1) {
      localCount--;
      update();
    }
  }

  /// Reset count to 1
  void resetCount() {
    localCount = 1;
    update();
  }

  /// Set specific count
  void setCount(int count) {
    if (count > 0) {
      localCount = count;
      update();
    }
  }

  /// Update the server cart when the "Add to Cart" button is pressed.
  Future<void> updateCart() async {
    try {
      statusRequest = StatusRequest.loading;
      update();

      int diff = initialCount == 0 ? localCount : localCount - initialCount;
      var response;

      if (diff > 0) {
        // إضافة عناصر للسلة
        for (int i = 0; i < diff; i++) {
          response = await cartData.addCart(
              myServices.sharedPreferences.getString("id")!,
              itemsModel.itemsId!
          );
          StatusRequest addStatus = handlingData(response);
          if (addStatus != StatusRequest.success || response['status'] != "success") {
            statusRequest = StatusRequest.failure;
            showErrorMessage("فشل في إضافة المنتج للسلة");
            update();
            return;
          }
        }
        showSuccessMessage("تم إضافة المنتج للسلة بنجاح");
      } else if (diff < 0) {
        // إزالة عناصر من السلة
        for (int i = 0; i < (-diff); i++) {
          response = await cartData.deleteCart(
              myServices.sharedPreferences.getString("id")!,
              itemsModel.itemsId!
          );
          StatusRequest deleteStatus = handlingData(response);
          if (deleteStatus != StatusRequest.success || response['status'] != "success") {
            statusRequest = StatusRequest.failure;
            showErrorMessage("فشل في إزالة المنتج من السلة");
            update();
            return;
          }
        }
        showSuccessMessage("تم تحديث كمية المنتج في السلة");
      } else {
        // لا يوجد تغيير
        showInfoMessage("لم يتم تغيير كمية المنتج");
      }

      statusRequest = StatusRequest.success;
      initialCount = localCount;

    } catch (e) {
      statusRequest = StatusRequest.failure;
      showErrorMessage("حدث خطأ: $e");
      print("Error updating cart: $e");
    }

    update();
  }

  /// Add product to cart (for related products)
  Future<void> addToCart(ItemsModel product) async {
    try {
      var response = await cartData.addCart(
          myServices.sharedPreferences.getString("id")!,
          product.itemsId!
      );

      StatusRequest addStatus = handlingData(response);

      if (StatusRequest.success == addStatus) {
        if (response['status'] == "success") {
          showSuccessMessage("تم إضافة ${product.itemsName} للسلة");
        } else {
          showErrorMessage("فشل في إضافة المنتج للسلة");
        }
      } else {
        showErrorMessage("فشل في الاتصال بالخادم");
      }
    } catch (e) {
      showErrorMessage("حدث خطأ: $e");
      print("Error adding to cart: $e");
    }
  }

  /// Toggle favorite status for related products
  void toggleFavoriteForProduct(ItemsModel product) {
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

      // تحديث حالة المنتج في القائمة المحلية
      int index = relatedProducts.indexWhere((p) => p.itemsId == product.itemsId);
      if (index != -1) {
        relatedProducts[index].favorite = !currentStatus ? "1" : "0";
        update();
      }

    } catch (e) {
      print("Error toggling favorite: $e");
      showErrorMessage("حدث خطأ في إضافة/إزالة المفضلة");
    }
  }

  /// Calculate discount percentage
  int calculateDiscountPercentage(ItemsModel product) {
    try {
      if (product.itemsPrice == null || product.itemsPriceDiscount == null) {
        return 0;
      }

      double original = double.tryParse(product.itemsPrice.toString()) ?? 0;
      double discounted = double.tryParse(product.itemsPriceDiscount.toString()) ?? 0;

      if (original <= 0 || discounted >= original) return 0;

      double percentage = ((original - discounted) / original) * 100;
      return percentage.round();
    } catch (e) {
      print("Error calculating discount: $e");
      return 0;
    }
  }

  /// Navigate to product details
  void goToProductDetails(ItemsModel product) {
    Get.toNamed("/productdetails", arguments: {"itemsmodel": product});
  }

  /// Show success message
  void showSuccessMessage(String message) {
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
  void showErrorMessage(String message) {
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
  void showInfoMessage(String message) {
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
    try {
      return double.tryParse(itemsModel.averageRating ?? "0") ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  int getMerchantReviewCount() {
    try {
      return int.tryParse(itemsModel.totalRatings ?? "0") ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if product has discount
  bool hasDiscount() {
    try {
      if (itemsModel.itemsPriceDiscount == null || itemsModel.itemsPrice == null) {
        return false;
      }
      double original = double.tryParse(itemsModel.itemsPrice.toString()) ?? 0;
      double discounted = double.tryParse(itemsModel.itemsPriceDiscount.toString()) ?? 0;
      return discounted > 0 && discounted < original;
    } catch (e) {
      return false;
    }
  }

  /// Get formatted price
  String getFormattedPrice() {
    try {
      if (hasDiscount()) {
        return itemsModel.itemsPriceDiscount.toString();
      }
      return itemsModel.itemsPrice?.toString() ?? "0";
    } catch (e) {
      return "0";
    }
  }

  /// Get formatted original price
  String getFormattedOriginalPrice() {
    return itemsModel.itemsPrice?.toString() ?? "0";
  }

  /// Get discount percentage for current product
  int getCurrentProductDiscountPercentage() {
    return calculateDiscountPercentage(itemsModel);
  }

  /// Reset media to first item
  void resetMediaToFirst() {
    currentMediaIndex = 0;
    if (pageController != null) {
      pageController!.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    update();
  }

  /// Get media statistics
  Map<String, int> getMediaStatistics() {
    return {
      'totalMedia': getTotalMediaCount(),
      'images': getImageCount(),
      'videos': getVideoCount(),
      'currentIndex': currentMediaIndex,
    };
  }

  /// Check if media is loaded
  bool isMediaLoaded() {
    return getTotalMediaCount() > 0;
  }

  /// Get media type at specific index
  String getMediaTypeAt(int index) {
    Map<String, dynamic>? media = getMediaAt(index);
    return media?['type'] ?? 'unknown';
  }

  /// Get media URL at specific index
  String getMediaUrlAt(int index) {
    Map<String, dynamic>? media = getMediaAt(index);
    return media?['url'] ?? '';
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
    initialData(); // سيتم تحميل البيانات الأساسية فوراً
    super.onInit();
  }

  @override
  void onClose() {
    relatedProducts.clear();
    pageController?.dispose();
    super.onClose();
  }
}
