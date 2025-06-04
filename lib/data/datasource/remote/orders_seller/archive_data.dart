import 'package:ecommercecourse/core/class/crud.dart';
import 'package:ecommercecourse/linkapi.dart';

class OrdersArchiveSellerData {
  Crud crud;
  OrdersArchiveSellerData(this.crud);

  getData(String sellerId) async {
    var response = await crud.postData(
        AppLink.viewarchiveOrders,
        {"seller_id": sellerId}
    );
    return response.fold((l) => l, (r) => r);
  }
}
