import 'package:ecommercecourse/core/class/crud.dart';
import 'package:ecommercecourse/linkapi.dart';

class OfferData {
  Crud crud;
  OfferData(this.crud);

  // تعديل الدالة لتستقبل معرف المستخدم وتقوم بإرساله للباك اند
  getData(String users_id) async {
    var response = await crud.postData(AppLink.offers, {"users_id": users_id});
    return response.fold((l) => l, (r) => r);
  }
}