import 'package:ecommercecourse/controller/offers_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../controller/favorite_controller.dart';
import '../../core/constant/routes.dart';
import '../widget/customappbar.dart';
import '../widget/items/items_search/customlistitemssearch.dart';
import '../widget/offers/customitemsoffers.dart';
import 'home.dart';

class OffersView extends StatelessWidget {
  const OffersView({super.key});

  @override
  Widget build(BuildContext context) {
    OffersController controller = Get.put(OffersController());
    FavoriteController controllerFav = Get.put(FavoriteController());
    return GetBuilder<OffersController>(
        builder: (controller) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView(children: [

            CustomAppBar(
              mycontroller: controller.search!,
              titleappbar: "Find Product",
              // onPressedIcon: () {},
              onPressedSearch: () {
                controller.onSearchItems();
              },
              onChanged: (val) {
                controller.checkSearch(val);
              },
              onPressedIconFavorite: () {
                Get.toNamed(AppRoute.myfavroite);
              },
            ),
            SizedBox(height: 20),
            !controller.isSearch? HandlingDataView(
                statusRequest: controller.statusRequest,
                widget: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                    itemCount: controller.data.length,
                    itemBuilder: (context, index) =>
                        CustomListItemsOffer(
                            itemsModel: controller.data[index])))
                : ListItemsSearch(listdatamodel: controller.listdata , animation: true)
          ],),
        ));
  }
}
