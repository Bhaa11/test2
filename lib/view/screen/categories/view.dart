
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controller/categories/view_controller.dart';
import '../../../core/class/handlingdataview.dart';
import '../../../core/constant/routes.dart';
import '../../../linkapi.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CategoriesController());
    return Scaffold(
        appBar: AppBar(
          title: Text('Categories'),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          Get.toNamed(AppRoute.itemsadd);
        }, child: Icon(Icons.add),),
        body: GetBuilder<CategoriesController>(
          builder: (controller) => HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: WillPopScope(
              onWillPop: () {
                return controller.myback();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ListView.builder(
                    itemCount: controller.data.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          controller.goToPageEdit(controller.data[index]);
                        },
                        child: Card(
                          child: Row(children: [
                            Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  child: SvgPicture.network(
                                      height: 80,
                                      "${AppLink.imagestCategories}/${controller.data[index].categoriesImage}"),
                                )),
                            Expanded(
                                flex: 3,
                                child: ListTile(
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(icon: Icon(Icons.delete) , onPressed: () {
                                        Get.defaultDialog(title: "تحذير" , middleText: "هل انت متآكد من عملية الحذف" , onCancel: () {}, onConfirm: () {
                                          controller.deleteCategory(controller.data[index].categoriesId!, controller.data[index].categoriesImage!);
                                          Get.back();
                                        });
                                      },),
                                    ],
                                  ),
                                  subtitle: Text(
                                      controller.data[index].categoriesDatetime!),
                                  title: Text(
                                      controller.data[index].categoriesName!),)),
                          ],),),
                      );
                    }

                ),),
            ),),)
    );
  }
}
