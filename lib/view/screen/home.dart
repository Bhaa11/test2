import 'package:ecommercecourse/controller/home_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/data/model/itemsmodel.dart';
import 'package:ecommercecourse/view/widget/customappbar.dart';
import 'package:ecommercecourse/view/widget/home/customcardhome.dart';
import 'package:ecommercecourse/view/widget/home/listcategorieshome.dart';
import 'package:ecommercecourse/view/widget/home/listitemshome.dart';
import 'package:ecommercecourse/view/widget/home/product_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../../linkapi.dart';
import '../widget/items/items_search/customlistitemssearch.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(HomeControllerImp());
    return GetBuilder<HomeControllerImp>(
      builder: (controller) => Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            return true;
          },
          child: SafeArea(
            child: LiquidPullToRefresh(
              onRefresh: () async {
                await controller.refreshData();
                return Future.delayed(Duration.zero);
              },
              color: AppColor.primaryColor,
              backgroundColor: AppColor.backgroundcolor,
              height: 100,
              animSpeedFactor: 1.5,
              showChildOpacityTransition: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                cacheExtent: 1000,
                slivers: [
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      child: Container(
                        color: AppColor.primaryColor,
                        child: CustomAppBar(
                          mycontroller: controller.search!,
                          titleappbar: "ابحث عن منتج",
                          onPressedSearch: () => controller.onSearchItems(),
                          onChanged: (val) => controller.checkSearch(val),
                          onPressedIconFavorite: () => Get.toNamed(AppRoute.myfavroite),
                        ),
                      ),
                      minHeight: 80,
                      maxHeight: 80,
                    ),
                    pinned: true,
                  ),
                  SliverToBoxAdapter(
                    child: HandlingDataView(
                      statusRequest: controller.statusRequest,
                      widget: controller.isSearch
                          ? _buildSearchResults(controller)
                          : _buildHomeContent(controller, context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(HomeControllerImp controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: CustomCardHome(
            title: controller.titleHomeCard,
            body: controller.bodyHomeCard,
          ),
        ),
        _buildProductGrid(controller, context),
      ],
    );
  }

  Widget _buildProductGrid(HomeControllerImp controller, BuildContext context) {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان منتجاتنا
          Padding(
            padding: const EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "منتجاتنا",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // يمكن إضافة وظيفة للذهاب إلى صفحة كل المنتجات
                  },
                  child: const Text(
                    "عرض الكل",
                    style: TextStyle(color: AppColor.primaryColor),
                  ),
                ),
              ],
            ),
          ),

          // عرض المنتجات المحسن
          _buildEnhancedItemsList(controller),

          // مساحة إضافية في نهاية القائمة
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEnhancedItemsList(HomeControllerImp controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75, // نسبة محسنة
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: controller.items.length,
      itemBuilder: (context, index) {
        ItemsModel itemsModel = ItemsModel.fromJson(controller.items[index]);
        return _buildProductCard(itemsModel, controller);
      },
    );
  }

  Widget _buildProductCard(ItemsModel itemsModel, HomeControllerImp controller) {
    double discount = double.tryParse(itemsModel.itemsDiscount ?? "0") ?? 0;
    double originalPrice = double.tryParse(itemsModel.itemsPrice ?? "0") ?? 0;
    double deliveryPrice = 0;
    bool hasDiscount = discount > 0;
    bool hasFreeDelivery = deliveryPrice == 0;

    // استخراج الصورة الأولى
    String firstImage = controller.getFirstImage(itemsModel.itemsImage);

    return GestureDetector(
      onTap: () => controller.goToPageProductDetails(itemsModel),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة المنتج
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: firstImage.isNotEmpty
                          ? Image.network(
                        "${AppLink.imagestItems}/$firstImage",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                          : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                // تفاصيل المنتج
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // اسم المنتج - عرض الاسم الإنجليزي فقط
                        Text(
                          itemsModel.itemsName ?? "",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.black,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                        ),

                        // الأسعار
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasDiscount) ...[
                              Text(
                                "${itemsModel.itemsPriceDiscount} د.ع",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                              Text(
                                "${itemsModel.itemsPrice} د.ع",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ] else ...[
                              Text(
                                "${itemsModel.itemsPrice} د.ع",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // الشارات - استخدام الكلاس المنفصل
            Positioned(
              top: 6,
              right: 6,
              child: ProductBadges.buildBadgesColumn(
                hasDiscount: hasDiscount,
                discount: discount,
                hasFreeDelivery: hasFreeDelivery,
                // يمكنك إضافة المزيد من الخصائص حسب الحاجة
                // isNew: true,
                // isBestSeller: false,
                // isOutOfStock: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(HomeControllerImp controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
          ),
          ListItemsSearch(
            listdatamodel: controller.listdata,
            animation: false,
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _SliverAppBarDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
