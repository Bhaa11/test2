import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/model/itemsmodel.dart';

class ProductSearchFilter {
  static Widget buildSearchAndFilterBar(
      BuildContext context, {
        required TextEditingController searchController,
        required bool showDiscountOnly,
        required bool showFreeDeliveryOnly,
        required int viewType,
        required VoidCallback onSearchClear,
        required Function(int) onViewTypeChanged,
        required Function(bool) onDiscountFilterChanged,
        required Function(bool) onFreeDeliveryFilterChanged,
        required VoidCallback onSortPressed,
        required Function(String) onLocalSearch,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          _buildSearchField(
            context,
            searchController: searchController,
            onClear: onSearchClear,
            onLocalSearch: onLocalSearch,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildSortButton(context, onPressed: onSortPressed),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickFilterChip(
                        context,
                        label: "مخفضة",
                        icon: Icons.local_offer,
                        isSelected: showDiscountOnly,
                        onSelected: onDiscountFilterChanged,
                      ),
                      const SizedBox(width: 6),
                      _buildQuickFilterChip(
                        context,
                        label: "توصيل مجاني",
                        icon: Icons.local_shipping,
                        isSelected: showFreeDeliveryOnly,
                        onSelected: onFreeDeliveryFilterChanged,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildViewOptions(
                context,
                viewType: viewType,
                onViewTypeChanged: onViewTypeChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildSearchField(
      BuildContext context, {
        required TextEditingController searchController,
        required VoidCallback onClear,
        required Function(String) onLocalSearch,
      }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "ابحث في النتائج ...".tr,
          hintStyle: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.blueGrey[600],
            size: 24,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 22,
              color: Colors.redAccent,
            ),
            onPressed: () {
              searchController.clear();
              onLocalSearch('');
              onClear();
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.6),
              width: 1.6,
            ),
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          onLocalSearch(value.trim());
        },
      ),
    );
  }

  static Widget _buildSortButton(BuildContext context, {required VoidCallback onPressed}) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune,
                  size: 16,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 4),
                Text(
                  "ترتيب".tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildQuickFilterChip(
      BuildContext context, {
        required String label,
        required IconData icon,
        required bool isSelected,
        required Function(bool) onSelected,
      }) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200]!,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelected(!isSelected),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildViewOptions(
      BuildContext context, {
        required int viewType,
        required Function(int) onViewTypeChanged,
      }) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // تبديل بين نمط 1 و 2
            int newViewType = viewType == 1 ? 2 : 1;
            onViewTypeChanged(newViewType);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              viewType == 1 ? Icons.view_list : Icons.grid_view,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildViewOptionButton(
      BuildContext context, {
        required IconData icon,
        required bool isSelected,
        required VoidCallback onPressed,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  static Widget buildFilterStatus(
      BuildContext context, {
        required int filteredCount,
        required int totalCount,
        required VoidCallback onReset,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "النتائج ($filteredCount)",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
              fontSize: 13,
            ),
          ),
          if (filteredCount != totalCount)
            InkWell(
              onTap: onReset,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 14,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "إعادة ضبط".tr,
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static void showSortBottomSheet(
      BuildContext context, {
        required String currentSort,
        required Function(String) onSortSelected,
      }) {
    final sortOptions = [
      'السعر: من الأقل للأعلى'.tr,
      'السعر: من الأعلى للأقل'.tr,
      'الخصم: من الأعلى للأقل'.tr,
      'الأحدث أولاً'.tr,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مؤشر التمرير
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ترتيب المنتجات".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // خيارات الترتيب
                ...sortOptions.map((option) => InkWell(
                  onTap: () {
                    onSortSelected(option);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentSort == option
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            border: Border.all(
                              color: currentSort == option
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: currentSort == option
                              ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          option,
                          style: TextStyle(
                            fontWeight: currentSort == option
                                ? FontWeight.w500
                                : FontWeight.normal,
                            color: currentSort == option
                                ? Theme.of(context).primaryColor
                                : Colors.grey[700],
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
