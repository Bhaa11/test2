import 'package:ecommercecourse/controller/home_controller.dart';
import 'package:ecommercecourse/controller/homescreen_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/data/model/itemsmodel.dart';
import 'package:ecommercecourse/view/widget/customappbar.dart';
import 'package:ecommercecourse/view/widget/home/customcardhome.dart';
import 'package:ecommercecourse/view/widget/home/listcategorieshome.dart';
import 'package:ecommercecourse/view/widget/home/listitemshome.dart';
import 'package:ecommercecourse/view/widget/home/product_badges.dart';
import 'package:ecommercecourse/view/widget/loading/home_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/class/statusrequest.dart';
import '../../core/constant/color.dart';
import '../../linkapi.dart';
import '../widget/items/items_search/customlistitemssearch.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // تمرير ScrollController إلى HomeScreenController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final homeScreenController = Get.find<HomeScreenControllerImp>();
        homeScreenController.setScrollController(_scrollController);
      } catch (e) {
        print('HomeScreenController not found: $e');
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(HomeControllerImp());
    return GetBuilder<HomeControllerImp>(
      builder: (controller) => WillPopScope(
        onWillPop: () async {
          // إذا كان حقل البحث يحتوي على نص، قم بحذفه
          if (controller.search!.text.isNotEmpty) {
            controller.search!.clear();
            controller.checkSearch("");
            return false; // منع الخروج من التطبيق
          }
          return true; // السماح بالخروج الطبيعي
        },
        child: Scaffold(
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
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  cacheExtent: 2000,
                  slivers: [
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        child: Container(
                          color: AppColor.primaryColor,
                          child: CustomAppBar(
                            mycontroller: controller.search!,
                            titleappbar: "ابحث عن منتج".tr,
                            onPressedSearch: () => controller.onSearchItems(),
                            onChanged: (val) => controller.checkSearch(val),
                            onPressedIconFavorite: () => Get.toNamed(AppRoute.myfavroite),
                            carData: controller.carDataLoaded ? controller.carData : null, // تمرير البيانات فقط إذا كانت متاحة
                          ),
                        ),
                        minHeight: 80,
                        maxHeight: 80,
                      ),
                      pinned: true,
                    ),
                    SliverToBoxAdapter(
                      child: _buildMainContent(controller, context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(HomeControllerImp controller, BuildContext context) {
    // إذا كان في حالة البحث
    if (controller.isSearch) {
      return HandlingDataView(
        statusRequest: controller.statusRequest,
        widget: _buildSearchResults(controller),
      );
    }

    // إذا كان في حالة التحميل
    if (controller.statusRequest == StatusRequest.loading) {
      return const HomeLoadingWidget();
    }

    // إذا كان هناك خطأ
    if (controller.statusRequest == StatusRequest.failure ||
        controller.statusRequest == StatusRequest.serverfailure) {
      return _buildErrorWidget(controller);
    }

    // إذا كانت البيانات محملة بنجاح
    if (controller.statusRequest == StatusRequest.success) {
      return _buildHomeContent(controller, context);
    }

    // الحالة الافتراضية
    return const HomeLoadingWidget();
  }

  Widget _buildErrorWidget(HomeControllerImp controller) {
    return Container(
      height: MediaQuery.of(Get.context!).size.height * 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'حدث خطأ في تحميل البيانات',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'تأكد من اتصالك بالإنترنت وحاول مرة أخرى'.tr,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            // إضافة رسالة خطأ بيانات السيارات إذا كانت موجودة
            if (controller.carDataError != null) ...[
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.carDataError!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade700,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => controller.getdata(),
              icon: const Icon(Icons.refresh),
              label: Text('إعادة المحاولة'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(HomeControllerImp controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
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
            padding: const EdgeInsets.only(right: 15, left: 15, top: 0, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "منتجاتنا".tr,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        color: AppColor.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "بحث".tr,
                        style: TextStyle(
                          color: AppColor.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
    if (controller.items.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 15),
              Text(
                'لا توجد منتجات متاحة حالياً'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: (controller.items.length / 2).ceil(),
      cacheExtent: 1500,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        int firstIndex = index * 2;
        int secondIndex = firstIndex + 1;

        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildProductCard(
                        ItemsModel.fromJson(controller.items[firstIndex]),
                        controller,
                        firstIndex,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (secondIndex < controller.items.length)
                      Expanded(
                        child: _buildProductCard(
                          ItemsModel.fromJson(controller.items[secondIndex]),
                          controller,
                          secondIndex,
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(ItemsModel itemsModel, HomeControllerImp controller, int index) {
    double discount = double.tryParse(itemsModel.itemsDiscount ?? "0") ?? 0;
    double originalPrice = double.tryParse(itemsModel.itemsPrice ?? "0") ?? 0;
    double deliveryPrice = 0;
    bool hasDiscount = discount > 0;
    bool hasFreeDelivery = deliveryPrice == 0;

    // استخراج الصورة الأولى
    String firstImage = controller.getFirstImage(itemsModel.itemsImage);

    return VisibilityDetector(
      key: Key('product-${itemsModel.itemsId}-$index'),
      onVisibilityChanged: (visibilityInfo) {
        // يمكن إضافة منطق إضافي هنا عند الحاجة
      },
      child: GestureDetector(
        onTap: () => controller.goToPageProductDetails(itemsModel),
        child: Container(
          height: 280,
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
                            ? CachedNetworkImage(
                          imageUrl: "${AppLink.imagestItems}/$firstImage",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                          memCacheWidth: 400,
                          memCacheHeight: 400,
                          maxWidthDiskCache: 400,
                          maxHeightDiskCache: 400,
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 300),
                        )
                            : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
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
                          // اسم المنتج
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

                          const SizedBox(height: 4),

                          // عدد القطع المتوفرة
                          Builder(
                            builder: (context) {
                              int itemCount = int.tryParse(itemsModel.itemsCount ?? '0') ?? 0;
                              bool isOutOfStock = itemCount == 0;

                              return Text(
                                isOutOfStock ? "نفذ المخزون".tr : "متوفر: ".tr + " ${itemsModel.itemsCount}" + " قطعة".tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isOutOfStock ? Colors.red : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 4),

                          // الأسعار
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasDiscount) ...[
                                Text(
                                  "${itemsModel.itemsPriceDiscount} " + "د.ع".tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                Text(
                                  "${itemsModel.itemsPrice} " + "د.ع".tr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  "${itemsModel.itemsPrice} " + "د.ع".tr,
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
              // الشارات
              Positioned(
                top: 6,
                right: 6,
                child: ProductBadges.buildBadgesColumn(
                  hasDiscount: hasDiscount,
                  discount: discount,
                  hasFreeDelivery: hasFreeDelivery,
                ),
              ),
            ],
          ),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
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
