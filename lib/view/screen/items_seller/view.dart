import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/items_seller/view_controller.dart';
import '../../../core/class/handlingdataview.dart';
import '../../../core/constant/routes.dart';
import '../../../linkapi.dart';

class ItemsView extends StatelessWidget {
  const ItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ItemsControllerSeller());
    return Scaffold(
      appBar: AppBar(
        title: Text('Items'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoute.itemsadd);
        },
        child: Icon(Icons.add),
      ),
      body: GetBuilder<ItemsControllerSeller>(
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
                  // الحصول على الصورة الأولى للعرض
                  String firstImage = controller.data[index].getFirstImage();

                  return InkWell(
                    onTap: () {
                      controller.goToPageEdit(controller.data[index]);
                    },
                    child: Card(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              child: firstImage.isNotEmpty
                                  ? CachedNetworkImage(
                                height: 80,
                                imageUrl: "${AppLink.imagestItems}/$firstImage",
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              )
                                  : Container(
                                height: 80,
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: ListTile(
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      controller.deleteItems(
                                        controller.data[index].itemsId!,
                                        controller.data[index].itemsImage!,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              subtitle: Text(controller.data[index].categoriesName!),
                              title: Text(controller.data[index].itemsName!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
