
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../view/screen/orders/archive.dart';
import '../../view/screen/orders/pending.dart';
import '../../view/screen/orders_seller/accepted.dart';

abstract class OrderScreenController extends GetxController {
  changePage(int currentpage);
}

class OrderScreenControllerImp extends OrderScreenController {
  int currentpage = 0;

  List<Widget> listPage = [
    const OrdersPending(),
    const OrdersAccepted(),
    const OrdersArchiveView(),
  ];

  List  titlebottomappbar = [
    "Pending" ,
    "Accepted" ,
    "Archive" ,

  ] ;

  @override
  changePage(int i) {
    currentpage = i;
    update();
  }
}
