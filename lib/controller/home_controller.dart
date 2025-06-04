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
    update();

    try {
      String users_id = myServices.sharedPreferences.getString("id")!;
      var response = await homedata.getData(users_id);
      if (handlingData(response) == StatusRequest.success) {
        if (response['status'] == "success") {
          _clearData();
          _updateData(response);
          Get.rawSnackbar(
            messageText: Text(
              'تم التحديث بنجاح'.tr,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          );
        }
      }
    } finally {
      isRefreshing = false;
      update();
    }
  }

  void _clearData() {
    categories.clear();
    items.clear();
    settingsdata.clear();
  }

  void _updateData(Map response) {
    categories.addAll(response['categories']['data']);
    items.addAll(response['items']);
    settingsdata.addAll(response['settings']['data']);

    titleHomeCard = settingsdata[0]['settings_titleome'];
    bodyHomeCard = settingsdata[0]['settings_bodyhome'];
    deliveryTime = settingsdata[0]['settings_deliverytime'];
    myServices.sharedPreferences.setString("deliverytime", deliveryTime);
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

  // دالة لاستخراج الصورة الأولى من JSON
  String getFirstImage(String? itemsImage) {
    if (itemsImage == null || itemsImage.isEmpty) {
      return '';
    }

    try {
      // محاولة تحليل JSON
      Map<String, dynamic> imageData = json.decode(itemsImage);

      // التحقق من وجود مصفوفة الصور
      if (imageData.containsKey('images') && imageData['images'] is List) {
        List images = imageData['images'];
        if (images.isNotEmpty) {
          return images[0].toString();
        }
      }

      // إذا لم توجد صور، إرجاع فارغ
      return '';
    } catch (e) {
      // في حالة فشل تحليل JSON، قد تكون الصورة بالتنسيق القديم
      return itemsImage;
    }
  }
}

class SearchMixController extends GetxController {
  List<ItemsModel> listdata = [];
  late StatusRequest statusRequest;
  HomeData homedata = HomeData(Get.find());
  TextEditingController? search;
  bool isSearch = false;

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
      statusRequest = StatusRequest.none;
      isSearch = false;
    }
    update();
  }

  onSearchItems() {
    isSearch = true;
    searchData();
    update();
  }

  // دالة لاستخراج الصورة الأولى من JSON
  String getFirstImage(String? itemsImage) {
    if (itemsImage == null || itemsImage.isEmpty) {
      return '';
    }

    try {
      // محاولة تحليل JSON
      Map<String, dynamic> imageData = json.decode(itemsImage);

      // التحقق من وجود مصفوفة الصور
      if (imageData.containsKey('images') && imageData['images'] is List) {
        List images = imageData['images'];
        if (images.isNotEmpty) {
          return images[0].toString();
        }
      }

      // إذا لم توجد صور، إرجاع فارغ
      return '';
    } catch (e) {
      // في حالة فشل تحليل JSON، قد تكون الصورة بالتنسيق القديم
      return itemsImage;
    }
  }
}
