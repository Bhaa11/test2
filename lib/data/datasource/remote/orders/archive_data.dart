import 'package:ecommercecourse/core/class/crud.dart';
import 'package:ecommercecourse/linkapi.dart';

class OrdersArchiveData {
  Crud crud;
  OrdersArchiveData(this.crud);

  getData(String userid) async {
    var response = await crud.postData(AppLink.ordersarchive, {
      "id": userid
    });
    return response.fold((l) => l, (r) => r);
  }

  rating(String ordersid, String comment, String rating) async {
    var response = await crud.postData(AppLink.rating, {
      "id": ordersid,
      "rating": rating,
      "comment": comment
    });
    return response.fold((l) => l, (r) => r);
  }

  // إضافة دالة تقييم البائع
  submitSellerRating({
    required String sellerId,
    required String userId,
    required String orderId,
    required String ratingScore,
    required String ratingComment,
  }) async {
    var response = await crud.postData(AppLink.sellerRating, {
      "seller_id": sellerId,
      "user_id": userId,
      "order_id": orderId,
      "rating_score": ratingScore,
      "rating_comment": ratingComment,
    });
    return response.fold((l) => l, (r) => r);
  }
}
