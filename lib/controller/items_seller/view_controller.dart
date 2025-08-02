import 'package:flutter/cupertino.dart';
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
  ScrollController scrollController = ScrollController();
  int lastItemId = 0;
  bool hasMore = true;
  bool isLoadingMore = false;

  @override
  void onInit() {
    super.onInit();
    getData();

    // إضافة مستمع لحدث التمرير
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  getData() async {
    data.clear();
    statusRequest = StatusRequest.loading;
    lastItemId = 0;
    hasMore = true;
    isLoadingMore = false;
    update();

    await _fetchItems();
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    update();

    await _fetchItems();

    isLoadingMore = false;
    update();
  }

  Future<void> _fetchItems() async {
    String sellerId = myServices.sharedPreferences.getString("id")!;
    var response = await itemsDataSeller.get(sellerId, lastItemId: lastItemId);

    print("Fetching items: lastItemId=$lastItemId");
    print("Response: $response");

    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List datalist = response['data'];
        print("Fetched ${datalist.length} items");
        data.addAll(datalist.map((e) => ItemsModel.fromJson(e)));

        // تحديث المؤشر للتحميل التالي
        lastItemId = response['next_cursor'] ?? 0;
        hasMore = response['has_more'] ?? false;

        print("Updated lastItemId: $lastItemId, hasMore: $hasMore");
      } else {
        hasMore = false;
        if (lastItemId == 0) statusRequest = StatusRequest.failure;
        print("Fetch items failed: ${response['message']}");
      }
    } else {
      print("StatusRequest is not success: $statusRequest");
    }
    update();
  }

  deleteItems(String id, String imagename) async {
    Get.defaultDialog(
        title: "تحذير",
        middleText: "هل انت متآكد من عملية الحذف",
        onCancel: () {},
        onConfirm: () async {
          var response = await itemsDataSeller.delete({
            'id': id,
            'imagename': imagename
          });

          print("Delete response: $response");

          if (response['status'] == "success") {
            data.removeWhere((element) => element.itemsId == id);
            update();
            Get.back();
            Get.snackbar("نجح", "تم حذف المنتج بنجاح");
          } else {
            Get.back();
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