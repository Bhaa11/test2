import 'package:ecommercecourse/core/class/crud.dart';
import 'package:ecommercecourse/linkapi.dart';

class OrdersPendingSellerData {
  Crud crud;
  OrdersPendingSellerData(this.crud);

  getData(String sellerId) async {
    var response = await crud.postData(
        AppLink.viewpendingOrders,
        {"seller_id": sellerId}
    );
    return response.fold((l) => l, (r) => r);
  }

  approveOrder(String userid, String orderid) async {
    var response = await crud.postData(
        AppLink.approveOrder,
        {"usersid": userid, "ordersid": orderid}
    );
    return response.fold((l) => l, (r) => r);
  }
}
