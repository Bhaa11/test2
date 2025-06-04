import 'package:get/get.dart';
import '../../../../core/class/statusrequest.dart';
import '../../../../core/functions/handingdatacontroller.dart';
import '../../../../core/services/services.dart';
import '../../data/datasource/remote/items_data_seller.dart';
import '../../data/model/itemsmodel.dart';
import '../../core/constant/routes.dart';

class ItemsControllerSeller extends GetxController {
  ItemsDataSeller itemsDataSeller = ItemsDataSeller(Get.find());
  MyServices myServices = Get.find();

  List<ItemsModel> data = [];
  late StatusRequest statusRequest;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  getData() async {
    data.clear();
    statusRequest = StatusRequest.loading;
    update();

    String sellerId = myServices.sharedPreferences.getString("id")!;

    var response = await itemsDataSeller.get(sellerId);
    print("=============================== Controller $response");
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List datalist = response['data'];
        data.addAll(datalist.map((e) => ItemsModel.fromJson(e)));
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  deleteItems(String id, String imagename) async {
    // إظهار dialog للتأكيد
    Get.defaultDialog(
        title: "تحذير",
        middleText: "هل انت متآكد من عملية الحذف",
        onCancel: () {},
        onConfirm: () async {
          // إرسال طلب الحذف إلى السيرفر
          var response = await itemsDataSeller.delete({
            'id': id,
            'imagename': imagename
          });

          print("Delete response: $response");

          if (response['status'] == "success") {
            // حذف العنصر من القائمة المحلية
            data.removeWhere((element) => element.itemsId == id);
            update();
            Get.back(); // إغلاق dialog
            Get.snackbar("نجح", "تم حذف المنتج بنجاح");
          } else {
            Get.back(); // إغلاق dialog
            Get.snackbar("خطأ", "فشل في حذف المنتج");
          }
        }
    );
  }

  goToPageEdit(ItemsModel itemsModel) {
    Get.toNamed(AppRoute.itemsedit, arguments: {'itemsModel': itemsModel});
  }

  myback() {
    Get.offAllNamed(AppRoute.homepage);
    return Future.value(false);
  }
}
