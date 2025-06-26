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

abstract class HomeController extends SearchMixController {
  initialData();
  getdata();
  refreshData();
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

  HomeData homedata = HomeData(Get.find());

  List categories = [];
  List items = [];
  List settingsdata = [];
  bool isRefreshing = false;

  // تغيير نوع البيانات لتتوافق مع CarSelectionDialog
  Map<String, Map<String, List<String>>> carData = {};
  bool carDataLoaded = false;
  String? carDataError;

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
    super.onInit();
  }

  @override
  Future<void> getdata() async {
    statusRequest = StatusRequest.loading;
    update();
    String users_id = myServices.sharedPreferences.getString("id")!;
    var response = await homedata.getData(users_id);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        _updateData(response);
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
      String users_id = myServices.sharedPreferences.getString("id")!;
      var response = await homedata.getData(users_id);
      statusRequest = handlingData(response);
      if (statusRequest == StatusRequest.success) {
        if (response['status'] == "success") {
          _clearData();
          _updateData(response);
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

  void _clearData() {
    categories.clear();
    items.clear();
    settingsdata.clear();
    carData.clear();
    carDataLoaded = false;
    carDataError = null;
  }

  void _updateData(Map response) {
    categories.addAll(response['categories']['data']);
    items.addAll(response['items']);
    settingsdata.addAll(response['settings']['data']);

    titleHomeCard = settingsdata[0]['settings_titleome'];
    bodyHomeCard = settingsdata[0]['settings_bodyhome'];
    deliveryTime = settingsdata[0]['settings_deliverytime'];
    myServices.sharedPreferences.setString("deliverytime", deliveryTime);

    // تحميل بيانات السيارات من قاعدة البيانات
    _loadCarData();
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
      // البحث عن settings_name_cars في بيانات الإعدادات
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
}

class SearchMixController extends GetxController {
  List<ItemsModel> listdata = [];
  late StatusRequest statusRequest;
  HomeData homedata = HomeData(Get.find());
  TextEditingController? search;
  bool isSearch = false;

  @override
  void onInit() {
    statusRequest = StatusRequest.none;
    super.onInit();
  }

  searchData() async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await homedata.searchData(search!.text);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        listdata.clear();
        List responsedata = response['data'];
        listdata.addAll(responsedata.map((e) => ItemsModel.fromJson(e)));
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  checkSearch(val) {
    if (val == "") {
      statusRequest = StatusRequest.success; // تغيير من none إلى success
      isSearch = false;
      listdata.clear(); // مسح نتائج البحث
    }
    update();
  }

  onSearchItems() {
    isSearch = true;
    searchData();
    update();
  }
}
