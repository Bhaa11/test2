import 'package:get/get.dart';
import 'package:ecommercecourse/core/class/crud.dart';
import '../controller/favorite_controller.dart';
import '../controller/items_seller/view_controller.dart';
import '../data/datasource/remote/items_data_seller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // سجلّ خدمة الـ CRUD أولًا
    Get.put<Crud>(Crud());

    // سجلّ الـ DataSource الخاص بالبائع مع تمرير الـ Crud instance
    Get.lazyPut<ItemsDataSeller>(
          () => ItemsDataSeller(Get.find<Crud>()),
    );

    // سجلّ الكنترولرز
    Get.lazyPut<FavoriteController>(() => FavoriteController());
    Get.lazyPut<ItemsControllerSeller>(() => ItemsControllerSeller());
  }
}