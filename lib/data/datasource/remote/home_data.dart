import 'package:ecommercecourse/core/class/crud.dart';
import 'package:ecommercecourse/linkapi.dart';

class HomeData {
  Crud crud;
  HomeData(this.crud);

  // دالة لتحميل البيانات الأولية
  getData(String usersid) async {
    var response = await crud.postData(AppLink.homepage, {
      "users_id": usersid,
    });
    return response.fold((l) => l, (r) => r);
  }

  // دالة لتحميل المزيد من المنتجات
  getMoreItems(String usersid, String cursor, {int limit = 20}) async {
    var response = await crud.postData(AppLink.homepage, {
      "users_id": usersid,
      "cursor": cursor,
      "limit": limit.toString(),
    });
    return response.fold((l) => l, (r) => r);
  }

  // دالة البحث الأساسية (الطلب الأول) مع الفلاتر
  searchData(String search, {
    int limit = 20,
    String sortOption = 'الأحدث أولاً',
    bool showDiscountOnly = false,
    bool showFreeDeliveryOnly = false,
    double priceMin = 0,
    double priceMax = 2000,
    String localSearch = '',
  }) async {
    var response = await crud.postData(AppLink.searchitems, {
      "search": search,
      "limit": limit.toString(),
      "sort_option": sortOption,
      "show_discount_only": showDiscountOnly ? "1" : "0",
      "show_free_delivery_only": showFreeDeliveryOnly ? "1" : "0",
      "price_min": priceMin.toString(),
      "price_max": priceMax.toString(),
      "local_search": localSearch,
    });
    return response.fold((l) => l, (r) => r);
  }

  // دالة البحث مع pagination والفلاتر
  searchDataWithPagination(String search, String cursor, {
    int limit = 20,
    String sortOption = 'الأحدث أولاً',
    bool showDiscountOnly = false,
    bool showFreeDeliveryOnly = false,
    double priceMin = 0,
    double priceMax = 2000,
    String localSearch = '',
  }) async {
    var response = await crud.postData(AppLink.searchitems, {
      "search": search,
      "cursor": cursor,
      "limit": limit.toString(),
      "sort_option": sortOption,
      "show_discount_only": showDiscountOnly ? "1" : "0",
      "show_free_delivery_only": showFreeDeliveryOnly ? "1" : "0",
      "price_min": priceMin.toString(),
      "price_max": priceMax.toString(),
      "local_search": localSearch,
    });
    return response.fold((l) => l, (r) => r);
  }
}
