import 'dart:io';
import 'package:ecommercecourse/controller/categories/view_controller.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/class/statusrequest.dart';
import '../../../../core/functions/handingdatacontroller.dart';
import 'package:get/get.dart';
import '../../core/constant/routes.dart';
import '../../core/functions/uploadfile.dart';
import '../../data/datasource/remote/categories_data.dart';
import '../../data/model/categoriesmodel.dart';

class CategoriesEditController extends GetxController {

  CategoriesData categoriesData = CategoriesData(Get.find());
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  late TextEditingController name;
  late TextEditingController namear;

  CategoriesModel? categoriesModel;

  StatusRequest? statusRequest = StatusRequest.none;

  File? file;

  chooseImage() async {
    file = await fileUploadGallery(true);
    update();
  }

  editData() async {

    if (formState.currentState!.validate()) {
      statusRequest = StatusRequest.loading;

      update();

      Map data ={
        "name" : name.text,
        "namear" : namear.text,
        "imageold" : categoriesModel!.categoriesImage!,
        "id" : categoriesModel!.categoriesId.toString()
      };

      var response = await categoriesData.edit(data , file);
      print("===============================22 Controller $response ");
      statusRequest = handlingData(response);
      if (StatusRequest.success == statusRequest) {
        if (response['status'] == "success") {
          Get.offNamed(AppRoute.categoriesview);
          CategoriesController c = Get.find();
          c.getData();


        } else {


          statusRequest = StatusRequest.failure ;


        }
        //End
      }
      update();
    }

  }

  @override
  void onInit() {
    categoriesModel = Get.arguments['categoriesModel'];
    name = TextEditingController();
    namear = TextEditingController();
    name.text = categoriesModel!.categoriesName!;
    namear.text = categoriesModel!.categoriesNamaAr!;
    super.onInit();
  }
}
