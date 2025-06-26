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
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        boxShadow: [
          // يمكن إضافة الظل هنا إذا كان مطلوباً
        ],
      ),
      child: Column(
        children: [
          _buildSearchField(
            context,
            searchController: searchController,
            onClear: onSearchClear,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildSortButton(context, onPressed: onSortPressed),

              const SizedBox(width: 10),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickFilterChip(
                        context,
                        label: "منتجات مخفضة",
                        icon: Icons.discount_outlined,
                        isSelected: showDiscountOnly,
                        onSelected: onDiscountFilterChanged,
                      ),

                      const SizedBox(width: 8),

                      _buildQuickFilterChip(
                        context,
                        label: "توصيل مجاني",
                        icon: Icons.local_shipping_outlined,
                        isSelected: showFreeDeliveryOnly,
                        onSelected: onFreeDeliveryFilterChanged,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

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
      }) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: "ابحث عن منتج...".tr,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: onClear,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      textInputAction: TextInputAction.search,
    );
  }

  static Widget _buildSortButton(BuildContext context, {required VoidCallback onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.sort_rounded,
        size: 16,
        color: Colors.grey[700],
      ),
      label:  Text(
        "ترتيب".tr,
        style: TextStyle(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(color: Colors.grey[300]!),
        backgroundColor: Colors.grey[50],
        minimumSize: const Size(0, 36),
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
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.grey[800],
        ),
      ),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : Colors.grey[700],
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[100],
      selectedColor: Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  static Widget _buildViewOptions(
      BuildContext context, {
        required int viewType,
        required Function(int) onViewTypeChanged,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildViewOptionButton(
            context,
            icon: Icons.view_list_rounded,
            isSelected: viewType == 1,
            onPressed: () => onViewTypeChanged(1),
          ),
          _buildViewOptionButton(
            context,
            icon: Icons.grid_view_rounded,
            isSelected: viewType == 2,
            onPressed: () => onViewTypeChanged(2),
          ),
        ],
      ),
    );
  }

  static Widget _buildViewOptionButton(
      BuildContext context, {
        required IconData icon,
        required bool isSelected,
        required VoidCallback onPressed,
      }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[500],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "النتائج ($filteredCount)",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),

          if (filteredCount != totalCount)
            TextButton.icon(
              onPressed: onReset,
              icon: Icon(Icons.refresh_rounded, size: 16, color: Colors.blue[700]),
              label: Text(
                "إعادة ضبط".tr,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 13,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط العنوان
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ترتيب المنتجات".tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const Divider(),

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
                    Icon(
                      currentSort == option
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: currentSort == option
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      option,
                      style: TextStyle(
                        fontWeight: currentSort == option
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: currentSort == option
                            ? Theme.of(context).primaryColor
                            : Colors.grey[800],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
