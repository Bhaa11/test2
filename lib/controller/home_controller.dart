import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/core/services/services.dart';
import 'package:ecommercecourse/data/datasource/remote/home_data.dart';
import 'package:ecommercecourse/data/model/itemsmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../data/datasource/remote/orders/notification_data.dart';


abstract class HomeController extends SearchMixController {
  initialData();
  getdata();
  refreshData();
  loadMore();
  goToItems(List categories, int selectedCat, String categoryid);
}

class HomeControllerImp extends HomeController {
  MyServices myServices = Get.find();
  String? username;
  String? id;
  String? lang;
  String titleHomeCard = "";
  String bodyHomeCard = "";
  String deliveryTime = "";

  @override
  HomeData homedata = HomeData(Get.find());
  List categories = [];
  List items = [];
  List settingsdata = [];
  bool isRefreshing = false;

  // إضافة متغيرات للـ pagination
  String? nextCursor;
  bool hasMore = true;
  bool isLoadingMore = false;
  StatusRequest loadMoreStatus = StatusRequest.none;

  // تغيير نوع البيانات لتتوافق مع CarSelectionDialog
  Map<String, Map<String, List<String>>> carData = {};
  bool carDataLoaded = false;
  String? carDataError;

  // متغيرات الإشعارات الجديدة
  int unreadNotificationCount = 0;
  NotificationData notificationData = NotificationData(Get.find());

  @override
  initialData() {
    lang = myServices.sharedPreferences.getString("lang");
    username = myServices.sharedPreferences.getString("username");
    id = myServices.sharedPreferences.getString("id");
  }

  @override
  void onInit() {
    search = TextEditingController();
    getdata();
    initialData();
    getUnreadNotificationCount(); // جلب عدد الإشعارات غير المقروءة
    super.onInit();
  }

  @override
  Future<void> getdata() async {
    statusRequest = StatusRequest.loading;
    update();
    String usersId = myServices.sharedPreferences.getString("id")!;
    var response = await homedata.getData(usersId);
    print("=============================== Controller");
    print(response);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        _updateData(response);
        // جلب عدد الإشعارات غير المقروءة بعد تحميل البيانات
        getUnreadNotificationCount();
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  @override
  Future<void> refreshData() async {
    isRefreshing = true;
    statusRequest = StatusRequest.loading;
    update();
    try {
      String usersId = myServices.sharedPreferences.getString("id")!;
      var response = await homedata.getData(usersId);
      statusRequest = handlingData(response);
      if (statusRequest == StatusRequest.success) {
        if (response['status'] == "success") {
          _clearData();
          _updateData(response);
          // جلب عدد الإشعارات غير المقروءة بعد التحديث
          getUnreadNotificationCount();
        } else {
          statusRequest = StatusRequest.failure;
        }
      }
    } catch (e) {
      statusRequest = StatusRequest.serverfailure;
    } finally {
      isRefreshing = false;
      update();
    }
  }

  // دالة جديدة لتحميل المزيد من المنتجات
  @override
  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore || nextCursor == null) return;

    isLoadingMore = true;
    loadMoreStatus = StatusRequest.loading;
    update();

    try {
      String usersId = myServices.sharedPreferences.getString("id")!;
      var response = await homedata.getMoreItems(usersId, nextCursor!);
      loadMoreStatus = handlingData(response);

      if (loadMoreStatus == StatusRequest.success) {
        if (response['status'] == "success") {
          List newItems = response['items'];
          items.addAll(newItems); // إضافة المنتجات في النهاية وليس البداية
          // تحديث nextCursor - التأكد من أنه string
          nextCursor = response['next_cursor']?.toString();
          hasMore = response['has_more'] ?? false;
        } else {
          loadMoreStatus = StatusRequest.failure;
        }
      }
    } catch (e) {
      print("Error loading more items: $e");
      loadMoreStatus = StatusRequest.serverfailure;
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  void _clearData() {
    categories.clear();
    items.clear();
    settingsdata.clear();
    carData.clear();
    carDataLoaded = false;
    carDataError = null;
    nextCursor = null;
    hasMore = true;
    isLoadingMore = false;
    loadMoreStatus = StatusRequest.none;
  }

  void _updateData(Map response) {
    try {
      // تحديث البيانات الأساسية (فقط في الطلب الأول)
      if (response.containsKey('categories')) {
        categories.addAll(response['categories']['data']);
      }

      if (response.containsKey('settings')) {
        settingsdata.addAll(response['settings']['data']);
        if (settingsdata.isNotEmpty) {
          titleHomeCard = settingsdata[0]['settings_titleome'] ?? "";
          bodyHomeCard = settingsdata[0]['settings_bodyhome'] ?? "";
          deliveryTime = settingsdata[0]['settings_deliverytime'] ?? "";
          myServices.sharedPreferences.setString("deliverytime", deliveryTime);
          // تحميل بيانات السيارات من قاعدة البيانات
          _loadCarData();
        }
      }

      // تحديث المنتجات - إضافة في النهاية
      if (response.containsKey('items')) {
        items.addAll(response['items']); // إضافة المنتجات في النهاية
      }

      // تحديث معلومات الـ pagination - التأكد من أن nextCursor هو string
      nextCursor = response['next_cursor']?.toString();
      hasMore = response['has_more'] ?? false;

      print("NextCursor: $nextCursor, HasMore: $hasMore, Items count: ${items.length}");
    } catch (e) {
      print("Error updating data: $e");
      statusRequest = StatusRequest.failure;
    }
  }

  // دالة لتحويل البيانات إلى النوع المطلوب
  Map<String, Map<String, List<String>>> _convertCarData(Map<String, dynamic> rawData) {
    Map<String, Map<String, List<String>>> convertedData = {};
    rawData.forEach((brand, models) {
      if (models is Map) {
        Map<String, List<String>> convertedModels = {};
        (models as Map<String, dynamic>).forEach((model, years) {
          if (years is List) {
            convertedModels[model] = years.map((year) => year.toString()).toList();
          }
        });
        convertedData[brand] = convertedModels;
      }
    });
    return convertedData;
  }

  // دالة لتحميل بيانات السيارات من الإعدادات
  void _loadCarData() {
    try {
      var carsSettings = settingsdata.firstWhere(
            (setting) => setting.containsKey('settings_name_cars'),
        orElse: () => null,
      );

      if (carsSettings != null && carsSettings['settings_name_cars'] != null) {
        String carDataString = carsSettings['settings_name_cars'];
        if (carDataString.isNotEmpty) {
          Map<String, dynamic> rawCarData = Map<String, dynamic>.from(json.decode(carDataString));
          carData = _convertCarData(rawCarData);
          carDataLoaded = true;
          carDataError = null;
          print('Car data loaded successfully from database');
        } else {
          carDataLoaded = false;
          carDataError = 'بيانات السيارات فارغة في قاعدة البيانات';
          print('Car data is empty in database');
        }
      } else {
        carDataLoaded = false;
        carDataError = 'لم يتم العثور على بيانات السيارات في قاعدة البيانات';
        print('Car data not found in database');
      }
    } catch (e) {
      print('Error loading car data: $e');
      carDataLoaded = false;
      carDataError = 'خطأ في تحميل بيانات السيارات: ${e.toString()}';
    }
  }

  @override
  goToItems(categories, selectedCat, categoryid) {
    Get.toNamed(AppRoute.items, arguments: {
      "categories": categories,
      "selectedcat": selectedCat,
      "catid": categoryid
    });
  }

  goToPageProductDetails(itemsModel) {
    Get.toNamed("productdetails", arguments: {"itemsmodel": itemsModel});
  }

  // إضافة دالة getFirstImage فقط
  String getFirstImage(String? itemsImage) {
    if (itemsImage == null || itemsImage.isEmpty) {
      return '';
    }
    try {
      // محاولة تحليل JSON أولاً
      if (itemsImage.startsWith('{') || itemsImage.startsWith('[')) {
        dynamic imageData = json.decode(itemsImage);
        if (imageData is Map<String, dynamic>) {
          // التحقق من وجود مصفوفة الصور
          if (imageData.containsKey('images') && imageData['images'] is List) {
            List images = imageData['images'];
            if (images.isNotEmpty) {
              return images[0].toString().trim();
            }
          }
        } else if (imageData is List) {
          // إذا كانت البيانات عبارة عن مصفوفة مباشرة
          if (imageData.isNotEmpty) {
            return imageData[0].toString().trim();
          }
        }
      } else {
        // التعامل مع الصور المفصولة بفاصلة
        List<String> imagesList = itemsImage.split(',');
        if (imagesList.isNotEmpty) {
          return imagesList[0].trim();
        }
      }
      return '';
    } catch (e) {
      print('Error parsing image data: $e');
      // في حالة فشل تحليل JSON، إرجاع النص كما هو
      if (itemsImage.contains(',')) {
        return itemsImage.split(',')[0].trim();
      }
      return itemsImage.trim();
    }
  }

  // دالة جلب عدد الإشعارات غير المقروءة
  Future<void> getUnreadNotificationCount() async {
    try {
      String userId = myServices.sharedPreferences.getString("id")!;
      var response = await notificationData.getUnreadCount(userId);

      if (response['status'] == "success") {
        unreadNotificationCount = response['unread_count'] ?? 0;
        update();
      }
    } catch (e) {
      print("Error getting unread notification count: $e");
    }
  }

  // دالة تحديث عدد الإشعارات غير المقروءة (يستخدمها NotificationController)
  void updateUnreadNotificationCount(int count) {
    unreadNotificationCount = count;
    update();
  }

  // دالة لتقليل عدد الإشعارات غير المقروءة بواحد
  void decrementUnreadNotificationCount() {
    if (unreadNotificationCount > 0) {
      unreadNotificationCount--;
      update();
    }
  }
}

class SearchMixController extends GetxController {
  List<ItemsModel> listdata = [];
  late StatusRequest statusRequest;
  HomeData homedata = HomeData(Get.find());
  TextEditingController? search;
  bool isSearch = false;

  // إضافة متغيرات pagination للبحث
  String? searchNextCursor;
  bool searchHasMore = true;
  bool isSearchLoadingMore = false;
  StatusRequest searchLoadMoreStatus = StatusRequest.none;
  String? currentSearchQuery;

  // متغيرات الفلاتر
  String currentSortOption = 'الأحدث أولاً';
  bool currentShowDiscountOnly = false;
  bool currentShowFreeDeliveryOnly = false;
  double currentPriceMin = 0;
  double currentPriceMax = 2000;
  String currentLocalSearch = '';

  @override
  void onInit() {
    statusRequest = StatusRequest.none;
    super.onInit();
  }

  // البحث الأولي مع الفلاتر
  searchData() async {
    statusRequest = StatusRequest.loading;
    // إعادة تعيين متغيرات pagination
    searchNextCursor = null;
    searchHasMore = true;
    isSearchLoadingMore = false;
    currentSearchQuery = search!.text;
    update();

    var response = await homedata.searchData(
      search!.text,
      sortOption: currentSortOption,
      showDiscountOnly: currentShowDiscountOnly,
      showFreeDeliveryOnly: currentShowFreeDeliveryOnly,
      priceMin: currentPriceMin,
      priceMax: currentPriceMax,
      localSearch: currentLocalSearch,
    );

    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        listdata.clear();
        List responsedata = response['data'];
        listdata.addAll(responsedata.map((e) => ItemsModel.fromJson(e)));

        // تحديث معلومات pagination
        searchNextCursor = response['next_cursor']?.toString();
        searchHasMore = response['has_more'] ?? false;

        print("Search - NextCursor: $searchNextCursor, HasMore: $searchHasMore, Results: ${listdata.length}");
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  // تحميل المزيد من نتائج البحث مع الفلاتر
  Future<void> loadMoreSearchResults() async {
    if (isSearchLoadingMore || !searchHasMore || searchNextCursor == null || currentSearchQuery == null) {
      return;
    }

    isSearchLoadingMore = true;
    searchLoadMoreStatus = StatusRequest.loading;
    update();

    try {
      var response = await homedata.searchDataWithPagination(
        currentSearchQuery!,
        searchNextCursor!,
        sortOption: currentSortOption,
        showDiscountOnly: currentShowDiscountOnly,
        showFreeDeliveryOnly: currentShowFreeDeliveryOnly,
        priceMin: currentPriceMin,
        priceMax: currentPriceMax,
        localSearch: currentLocalSearch,
      );

      searchLoadMoreStatus = handlingData(response);

      if (searchLoadMoreStatus == StatusRequest.success) {
        if (response['status'] == "success") {
          List responsedata = response['data'];
          List<ItemsModel> newItems = responsedata.map((e) => ItemsModel.fromJson(e)).toList();
          listdata.addAll(newItems);

          // تحديث معلومات pagination
          searchNextCursor = response['next_cursor']?.toString();
          searchHasMore = response['has_more'] ?? false;

          print("Load More Search - NextCursor: $searchNextCursor, HasMore: $searchHasMore, New Items: ${newItems.length}");
        } else {
          searchLoadMoreStatus = StatusRequest.failure;
        }
      }
    } catch (e) {
      print("Error loading more search results: $e");
      searchLoadMoreStatus = StatusRequest.serverfailure;
    } finally {
      isSearchLoadingMore = false;
      update();
    }
  }

  // تحديث الفلاتر وإعادة البحث
  void updateFilters({
    String? sortOption,
    bool? showDiscountOnly,
    bool? showFreeDeliveryOnly,
    double? priceMin,
    double? priceMax,
    String? localSearch,
  }) {
    if (sortOption != null) currentSortOption = sortOption;
    if (showDiscountOnly != null) currentShowDiscountOnly = showDiscountOnly;
    if (showFreeDeliveryOnly != null) currentShowFreeDeliveryOnly = showFreeDeliveryOnly;
    if (priceMin != null) currentPriceMin = priceMin;
    if (priceMax != null) currentPriceMax = priceMax;
    if (localSearch != null) currentLocalSearch = localSearch;

    // إعادة البحث مع الفلاتر الجديدة
    if (isSearch && search!.text.isNotEmpty) {
      searchData();
    }
  }

  // إعادة تعيين الفلاتر
  void resetFilters() {
    currentSortOption = 'الأحدث أولاً';
    currentShowDiscountOnly = false;
    currentShowFreeDeliveryOnly = false;
    currentPriceMin = 0;
    currentPriceMax = 2000;
    currentLocalSearch = ''; // إعادة تعيين البحث المحلي

    // إعادة البحث مع الفلاتر المعاد تعيينها
    if (isSearch && search!.text.isNotEmpty) {
      searchData();
    }
  }

  // دالة جديدة لإعادة تعيين البحث المحلي فقط
  void resetLocalSearch() {
    currentLocalSearch = '';
    if (isSearch && search!.text.isNotEmpty) {
      searchData();
    }
  }

  checkSearch(val) {
    if (val == "") {
      statusRequest = StatusRequest.success;
      isSearch = false;
      listdata.clear();
      // إعادة تعيين متغيرات البحث
      searchNextCursor = null;
      searchHasMore = true;
      isSearchLoadingMore = false;
      currentSearchQuery = null;
      // إعادة تعيين جميع الفلاتر عند مسح البحث الرئيسي
      currentSortOption = 'الأحدث أولاً';
      currentShowDiscountOnly = false;
      currentShowFreeDeliveryOnly = false;
      currentPriceMin = 0;
      currentPriceMax = 2000;
      currentLocalSearch = '';
    }
    update();
  }

  onSearchItems() {
    // التحقق من الصفحة الحالية
    String currentRoute = Get.currentRoute;

    if (currentRoute == AppRoute.search) {
      // إذا كنا في صفحة البحث، تنفيذ البحث العادي
      isSearch = true;
      searchData();
      update();
    } else {
      // إذا كنا في الصفحة الرئيسية، الذهاب لصفحة البحث
      Get.toNamed(AppRoute.search, arguments: {'searchQuery': search!.text});
    }
  }
}
