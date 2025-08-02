import 'package:ecommercecourse/view/widget/items/items_search/product_list_components.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../controller/home_controller.dart';
import '../../../../data/model/itemsmodel.dart';
import '../../../../core/class/statusrequest.dart';
import '../../../../core/constant/color.dart';
import 'list_items_components.dart';

class ListItemsSearch extends StatefulWidget {
  final List<ItemsModel> listdatamodel;
  final bool animation;

  const ListItemsSearch({
    super.key,
    required this.listdatamodel,
    required this.animation,
  });

  @override
  State<ListItemsSearch> createState() => _ListItemsSearchState();
}

class _ListItemsSearchState extends State<ListItemsSearch> {
  // خيارات العرض
  int _viewType = 2; // 1: قائمة، 2: شبكة بعمودين

  // متحكم النص للبحث المحلي
  final TextEditingController _searchController = TextEditingController();

  // متحكم التمرير لمراقبة الوصول إلى النهاية
  late ScrollController _scrollController;

  // متغير لحفظ آخر نص بحث
  String _lastSearchText = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // تحديث النص من الكونترولر عند بداية التشغيل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSearchTextFromController();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // مزامنة النص من الكونترولر
  void _syncSearchTextFromController() {
    try {
      final controller = Get.find<HomeControllerImp>();
      if (controller.currentLocalSearch != _lastSearchText) {
        _lastSearchText = controller.currentLocalSearch;
        if (_searchController.text != _lastSearchText) {
          _searchController.text = _lastSearchText;
        }
      }
    } catch (e) {
      print('Error syncing search text: $e');
    }
  }

  // مراقبة التمرير لتحميل المزيد
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreSearchResults();
    }
  }

  // تحميل المزيد من نتائج البحث
  void _loadMoreSearchResults() {
    try {
      final controller = Get.find<HomeControllerImp>();
      controller.loadMoreSearchResults();
    } catch (e) {
      print('Error loading more search results: $e');
    }
  }

  // تطبيق البحث عبر الباك إند - مع الاحتفاظ بالنص
  void _applyBackendSearch(String searchQuery) {
    final controller = Get.find<HomeControllerImp>();
    _lastSearchText = searchQuery;
    controller.updateFilters(localSearch: searchQuery);

    // التأكد من أن النص محفوظ في الحقل
    if (_searchController.text != searchQuery) {
      setState(() {
        _searchController.text = searchQuery;
      });
    }
  }

  void _handleProductTap(ItemsModel item) {
    try {
      Get.find<HomeControllerImp>().goToPageProductDetails(item);
    } catch (e) {
      Get.snackbar(
        'حدث خطأ',
        'تعذر فتح صفحة المنتج',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        borderRadius: 8,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeControllerImp>(
      builder: (controller) {
        // مزامنة النص عند كل إعادة بناء
        _syncSearchTextFromController();

        if (widget.listdatamodel.isEmpty && !controller.isSearchLoadingMore) {
          return ProductListComponents.buildEmptyState(context);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProductListComponents.buildSearchAndFilterBar(
              context,
              searchController: _searchController,
              showDiscountOnly: controller.currentShowDiscountOnly,
              showFreeDeliveryOnly: controller.currentShowFreeDeliveryOnly,
              viewType: _viewType,
              onSearchClear: () {
                setState(() {
                  _searchController.clear();
                  _lastSearchText = '';
                });
                _applyBackendSearch('');
              },
              onViewTypeChanged: (type) => setState(() {
                _viewType = type;
              }),
              onDiscountFilterChanged: (value) {
                controller.updateFilters(showDiscountOnly: value);
              },
              onFreeDeliveryFilterChanged: (value) {
                controller.updateFilters(showFreeDeliveryOnly: value);
              },
              onSortPressed: () => ProductListComponents.showSortBottomSheet(
                context,
                currentSort: controller.currentSortOption,
                onSortSelected: (option) {
                  controller.updateFilters(sortOption: option);
                },
              ),
              onLocalSearch: _applyBackendSearch,
            ),
            if (_hasActiveFilters(controller))
              ProductListComponents.buildFilterStatus(
                context,
                filteredCount: widget.listdatamodel.length,
                totalCount: widget.listdatamodel.length,
                onReset: () {
                  setState(() {
                    _searchController.clear();
                    _lastSearchText = '';
                  });
                  controller.resetFilters();
                },
              ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildProductsViewWithPagination(controller),
            ),
          ],
        );
      },
    );
  }

  bool _hasActiveFilters(HomeControllerImp controller) =>
      _searchController.text.isNotEmpty ||
          controller.currentShowFreeDeliveryOnly ||
          controller.currentShowDiscountOnly ||
          controller.currentPriceMin > 0 ||
          controller.currentPriceMax < 2000 ||
          controller.currentSortOption != 'الأحدث أولاً';

  Widget _buildProductsViewWithPagination(HomeControllerImp controller) {
    if (widget.listdatamodel.isEmpty && !controller.isSearchLoadingMore) {
      return ProductListComponents.buildNoResultsFound();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: _buildProductsView(),
        ),
        _buildSearchLoadMoreIndicator(controller),
      ],
    );
  }

  Widget _buildProductsView() {
    switch (_viewType) {
      case 1:
        return SingleChildScrollView(
          controller: _scrollController,
          child: ProductListComponents.buildListView(
            items: widget.listdatamodel,
            animation: widget.animation,
            onTap: _handleProductTap,
          ),
        );
      case 2:
      default:
        return SingleChildScrollView(
          controller: _scrollController,
          child: ProductListComponents.buildGridView(
            items: widget.listdatamodel,
            animation: widget.animation,
            onTap: _handleProductTap,
          ),
        );
    }
  }

  Widget _buildSearchLoadMoreIndicator(HomeControllerImp controller) {
    if (controller.isSearchLoadingMore) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                strokeWidth: 2,
              ),
              const SizedBox(height: 8),
              Text(
                'جاري تحميل المزيد من النتائج...'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
