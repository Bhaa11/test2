import 'dart:convert';
import 'dart:io';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:ecommercecourse/controller/items_seller/view_controller.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/class/statusrequest.dart';
import '../../../../core/functions/handingdatacontroller.dart';
import 'package:get/get.dart';
import '../../core/constant/routes.dart';
import '../../core/functions/uploadfile.dart';
import '../../data/datasource/remote/items_data_seller.dart';
import '../../data/model/categoriesmodel.dart';
import '../../data/model/itemsmodel.dart';
import '../items_controller.dart';

class ItemsEditController extends GetxController {

  ItemsDataSeller itemsDataSeller = ItemsDataSeller(Get.find());

  List<SelectedListItem> dropdownnlist = [];

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late TextEditingController name;
  late TextEditingController namear;

  late TextEditingController dropdownname;
  late TextEditingController dropdownid;

  late TextEditingController desc;
  late TextEditingController descar;

  late TextEditingController count;
  late TextEditingController price;
  late TextEditingController discount;

  TextEditingController? catname;
  TextEditingController? catid;

  StatusRequest? statusRequest = StatusRequest.none;

  File? file;
  List<File> selectedFiles = []; // إضافة دعم للملفات المتعددة

  String? active;

  ItemsModel? itemsModel;

  changeStatusAction(val) {
    active = val;
    update();
  }

  chooseImage() async {
    file = await fileUploadGallery(true);
    update();
  }

  // دالة جديدة لاختيار ملفات متعددة
  chooseMultipleFiles() async {
    try {
      List<File>? files = await multipleFilesUploadGallery();
      if (files != null && files.isNotEmpty) {
        selectedFiles.addAll(files);
        update();
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ في اختيار الملفات: ${e.toString()}");
    }
  }

  // دالة لحذف ملف من القائمة
  removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
      update();
    }
  }

  // دالة لمسح جميع الملفات
  clearFiles() {
    selectedFiles.clear();
    update();
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

  editData() async {

    if (formState.currentState!.validate()) {
      statusRequest = StatusRequest.loading;
      update();

      Map data = {
        "id": itemsModel!.itemsId,
        "imageold": itemsModel!.itemsImage,
        "active": active,
        "name": name.text,
        "namear": namear.text,
        "desc": desc.text,
        "descar": descar.text,
        "price": price.text,
        "count": count.text,
        "discount": discount.text,
        "catid": catid!.text,
        "datenow": DateTime.now().toString(),
      };

      // إذا تم اختيار ملفات جديدة، أضف معلومات الملفات
      if (selectedFiles.isNotEmpty) {
        Map<String, List<String>> organizedFiles = organizeFileNames();
        data["files_json"] = jsonEncode(organizedFiles);
      }

      var response;

      // إذا كان هناك ملفات متعددة جديدة
      if (selectedFiles.isNotEmpty) {
        response = await itemsDataSeller.editMultiple(data, selectedFiles);
      }
      // إذا كان هناك ملف واحد فقط (النظام القديم)
      else if (file != null) {
        response = await itemsDataSeller.edit(data, file);
      }
      // إذا لم يتم تغيير أي ملفات
      else {
        response = await itemsDataSeller.edit(data);
      }

      print("===============================22 Controller $response ");
      statusRequest = handlingData(response);
      if (StatusRequest.success == statusRequest) {
        if (response['status'] == "success") {
          Get.offNamed(AppRoute.itemsview);
          ItemsControllerSeller c = Get.find();
          c.getData();
        } else {
          statusRequest = StatusRequest.failure;
        }
      }
      update();
    }
  }

  @override
  void onInit() {
    itemsModel = Get.arguments['itemsModel'];
    name = TextEditingController();
    namear = TextEditingController();
    desc = TextEditingController();
    descar = TextEditingController();
    price = TextEditingController();
    count = TextEditingController();
    discount = TextEditingController();

    catid = TextEditingController();
    catname = TextEditingController();

    dropdownname = TextEditingController();
    dropdownid = TextEditingController();

    name.text = itemsModel!.itemsName!;
    namear.text = itemsModel!.itemsNameAr!;

    active = itemsModel!.itemsActive;

    desc.text = itemsModel!.itemsDesc!;
    descar.text = itemsModel!.itemsDescAr!;

    price.text = itemsModel!.itemsPrice!;
    discount.text = itemsModel!.itemsDiscount!;
    count.text = itemsModel!.itemsCount!;

    catid!.text = itemsModel!.categoriesId!;
    catname!.text = itemsModel!.categoriesName!;

    namear.text = itemsModel!.itemsNameAr!;

    super.onInit();
  }
}
