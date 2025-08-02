import 'package:ecommercecourse/controller/home_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/view/widget/items/items_search/customlistitemssearch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late HomeControllerImp controller;
  late ScrollController _scrollController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // الحصول على نص البحث المرسل من الصفحة الرئيسية
    final searchQuery = Get.arguments?['searchQuery'] ?? '';
    _searchController = TextEditingController(text: searchQuery);

    // إذا كان هناك نص بحث، تنفيذ البحث مباشرة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller = Get.find<HomeControllerImp>();
      if (searchQuery.isNotEmpty) {
        controller.search!.text = searchQuery;
        controller.isSearch = true;
        controller.searchData();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreSearchResults();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller = Get.find<HomeControllerImp>();
    return WillPopScope(
      onWillPop: () async {
        // التحقق من وجود نص في حقل البحث المحلي
        if (controller.currentLocalSearch.isNotEmpty) {
          // إعادة تعيين البحث المحلي
          controller.resetLocalSearch();
          return false; // منع الرجوع الفوري
        } else {
          // مسح البحث الرئيسي والعودة للصفحة الرئيسية
          controller.search!.clear();
          controller.checkSearch("");
          return true; // السماح بالرجوع
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: AppColor.backgroundcolor,
          appBar: _buildSearchAppBar(),
          body: GetBuilder<HomeControllerImp>(
            builder: (controller) => _buildSearchContent(controller),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: AppColor.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          // التحقق من وجود نص في حقل البحث المحلي
          if (controller.currentLocalSearch.isNotEmpty) {
            // إعادة تعيين البحث المحلي
            controller.resetLocalSearch();
          } else {
            // مسح البحث الرئيسي والعودة للصفحة الرئيسية
            controller.search!.clear();
            controller.checkSearch("");
            Get.back();
          }
        },
      ),
      title: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: _searchController.text.isEmpty,
          decoration: InputDecoration(
            hintText: "ابحث عن منتج".tr,
            prefixIcon: const Icon(Icons.search, color: AppColor.primaryColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: AppColor.grey),
              onPressed: () {
                _searchController.clear();
                controller.search!.clear();
                controller.checkSearch("");
                setState(() {});
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (val) {
            controller.search!.text = val;
            controller.checkSearch(val);
            setState(() {});
          },
          onSubmitted: (val) {
            if (val.isNotEmpty) {
              controller.isSearch = true;
              controller.searchData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchContent(HomeControllerImp controller) {
    if (!controller.isSearch) {
      // إذا لم يكن هناك بحث، عرض واجهة فارغة
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 15),
            Text(
              "ابحث عن منتجاتك المفضلة".tr,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return HandlingDataView(
      statusRequest: controller.statusRequest,
      widget: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ListItemsSearch(
            listdatamodel: controller.listdata,
            animation: false,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestionItem(String suggestion) {
    return InkWell(
      onTap: () {
        _searchController.text = suggestion;
        controller.search!.text = suggestion;
        controller.isSearch = true;
        controller.searchData();
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Text(
              suggestion,
              style: TextStyle(
                fontSize: 15,
                color: AppColor.black,
              ),
            ),
            const Spacer(),
            Icon(Icons.north_west, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}
