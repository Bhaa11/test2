import 'package:ecommercecourse/view/widget/items/items_search/product_list_components.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../controller/home_controller.dart';
import '../../../../data/model/itemsmodel.dart';
import 'list_items_components.dart';

class ListItemsSearch extends StatefulWidget {
  final List<ItemsModel> listdatamodel;
  final bool animation;

  const ListItemsSearch({
    Key? key,
    required this.listdatamodel,
    required this.animation,
  }) : super(key: key);

  @override
  State<ListItemsSearch> createState() => _ListItemsSearchState();
}

class _ListItemsSearchState extends State<ListItemsSearch> {
  // خيارات العرض
  int _viewType = 2; // 1: قائمة، 2: شبكة بعمودين

  // خيارات الترتيب
  String _sortOption = 'السعر: من الأقل للأعلى';

  // خيارات الفلترة
  bool _showFreeDeliveryOnly = false;
  bool _showDiscountOnly = false;
  RangeValues _priceRange = const RangeValues(0, 2000);

  // قائمة مؤقتة للبيانات المعروضة
  late List<ItemsModel> _filteredItems;

  // متحكم النص للبحث
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.listdatamodel);
    _searchController.addListener(_searchItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchItems() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = widget.listdatamodel
          .where((item) {
        final price = ProductUtils.getItemPrice(item);
        bool matchesPrice = price >= _priceRange.start && price <= _priceRange.end;
        bool matchesFreeDelivery = _showFreeDeliveryOnly ? ProductUtils.hasFreeDelivery(item) : true;
        bool matchesDiscount = _showDiscountOnly ? ProductUtils.hasDiscount(item) : true;

        bool matchesSearch = true;
        final searchQuery = _searchController.text.trim().toLowerCase();
        if (searchQuery.isNotEmpty) {
          final itemName = (item.itemsName ?? '').toLowerCase();
          final categoryName = (item.categoriesName ?? '').toLowerCase();
          matchesSearch = itemName.contains(searchQuery) || categoryName.contains(searchQuery);
        }

        return matchesPrice && matchesFreeDelivery && matchesDiscount && matchesSearch;
      })
          .toList();

      _sortItems();
    });
  }

  void _sortItems() {
    switch (_sortOption) {
      case 'السعر: من الأقل للأعلى':
        _filteredItems.sort((a, b) => ProductUtils.getItemPrice(a).compareTo(ProductUtils.getItemPrice(b)));
        break;
      case 'السعر: من الأعلى للأقل':
        _filteredItems.sort((a, b) => ProductUtils.getItemPrice(b).compareTo(ProductUtils.getItemPrice(a)));
        break;
      case 'الخصم: من الأعلى للأقل':
        _filteredItems.sort((a, b) => ProductUtils.getDiscountValue(b).compareTo(ProductUtils.getDiscountValue(a)));
        break;
      case 'الأحدث أولاً':
        break;
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
    if (widget.listdatamodel.isEmpty) {
      return ProductListComponents.buildEmptyState(context);
    }

    return Column(
      children: [
        ProductListComponents.buildSearchAndFilterBar(
          context,
          searchController: _searchController,
          showDiscountOnly: _showDiscountOnly,
          showFreeDeliveryOnly: _showFreeDeliveryOnly,
          viewType: _viewType,
          onSearchClear: () {
            _searchController.clear();
            _applyFilters();
          },
          onViewTypeChanged: (type) => setState(() {
            _viewType = type;
          }),
          onDiscountFilterChanged: (value) {
            setState(() {
              _showDiscountOnly = value;
              _applyFilters();
            });
          },
          onFreeDeliveryFilterChanged: (value) {
            setState(() {
              _showFreeDeliveryOnly = value;
              _applyFilters();
            });
          },
          onSortPressed: () => ProductListComponents.showSortBottomSheet(
            context,
            currentSort: _sortOption,
            onSortSelected: (option) {
              setState(() {
                _sortOption = option;
                _applyFilters();
              });
            },
          ),
        ),

        if (_hasActiveFilters)
          ProductListComponents.buildFilterStatus(
            context,
            filteredCount: _filteredItems.length,
            totalCount: widget.listdatamodel.length,
            onReset: _resetFilters,
          ),

        _buildProductsView(),
      ],
    );
  }

  bool get _hasActiveFilters =>
      _searchController.text.isNotEmpty ||
          _showFreeDeliveryOnly ||
          _showDiscountOnly ||
          _priceRange.start > 0 ||
          _priceRange.end < 2000;

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _showFreeDeliveryOnly = false;
      _showDiscountOnly = false;
      _priceRange = const RangeValues(0, 2000);
      _sortOption = 'السعر: من الأقل للأعلى';
      _filteredItems = List.from(widget.listdatamodel);
    });
  }

  Widget _buildProductsView() {
    if (_filteredItems.isEmpty) {
      return ProductListComponents.buildNoResultsFound();
    }

    switch (_viewType) {
      case 1:
        return ProductListComponents.buildListView(
          items: _filteredItems,
          animation: widget.animation,
          onTap: _handleProductTap,
        );
      case 2:
      default:
        return ProductListComponents.buildGridView(
          items: _filteredItems,
          animation: widget.animation,
          onTap: _handleProductTap,
        );
    }
  }
}
