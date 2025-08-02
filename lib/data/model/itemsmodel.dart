import 'dart:convert';

class ItemsModel {
  String? itemsId;
  String? itemsName;
  String? itemsNameAr;
  String? itemsDesc;
  String? itemsDescAr;
  String? itemsImage;
  String? itemsCount;
  String? itemsActive;
  String? itemsPrice;
  String? itemsDiscount;
  String? itemsDate;
  String? itemsCat;
  String? categoriesId;
  String? categoriesName;
  String? categoriesNamaAr; // الاسم الأصلي محفوظ للتوافق
  String? categoriesNameAr; // الاسم الجديد المطلوب
  String? categoriesImage;
  String? categoriesDatetime;
  String? favorite;
  String? itemsPriceDiscount; // السعر النهائي بعد الخصم من قاعدة البيانات
  String? itemspricediscount; // إضافة للتوافق مع CartModel
  String? itemsIdSeller;
  String? itemsPricedelivery;
  String? itemsCarVariants;
  String? itemsProductStatus;
  String? categoriesDatatime;
  String? sellerName;
  String? sellerImage;
  String? totalRatings;
  String? averageRating;
  // إضافة الحقول الجديدة من الباك إند المحسن
  double? finalRelevanceScore;
  double? exactMatchScore;
  double? qualityScore;

  ItemsModel({
    this.itemsId,
    this.itemsName,
    this.itemsNameAr,
    this.itemsDesc,
    this.itemsDescAr,
    this.itemsImage,
    this.itemsCount,
    this.itemsActive,
    this.itemsPrice,
    this.itemsDiscount,
    this.itemsDate,
    this.itemsCat,
    this.itemsPriceDiscount,
    this.categoriesId,
    this.categoriesName,
    this.categoriesNamaAr,
    this.categoriesNameAr,
    this.categoriesImage,
    this.categoriesDatetime,
    this.favorite,
    this.itemsIdSeller,
    this.itemsPricedelivery,
    this.itemsCarVariants,
    this.itemsProductStatus,
    this.categoriesDatatime,
    this.sellerName,
    this.sellerImage,
    this.totalRatings,
    this.averageRating,
    this.itemspricediscount,
    this.finalRelevanceScore,
    this.exactMatchScore,
    this.qualityScore,
  });

  ItemsModel.fromJson(Map<String, dynamic> json) {
    itemsId = json['items_id']?.toString();
    itemsName = json['items_name'];
    itemsNameAr = json['items_name_ar'];
    itemsDesc = json['items_desc']?.toString();
    itemsDescAr = json['items_desc_ar']?.toString();
    itemsImage = json['items_image'];
    itemsCount = json['items_count']?.toString();
    itemsActive = json['items_active']?.toString();
    itemsPrice = json['items_price']?.toString();
    itemsDiscount = json['items_discount']?.toString();
    itemsDate = json['items_date'];
    itemsCat = json['items_cat']?.toString();

    // استخدام السعر المحسوب من قاعدة البيانات - تصحيح التعيين
    String? priceDiscountValue = json['itemspricediscount']?.toString();
    itemsPriceDiscount = priceDiscountValue;
    itemspricediscount = priceDiscountValue; // نفس القيمة للتوافق

    categoriesId = json['categories_id']?.toString();
    categoriesName = json['categories_name'];
    categoriesNamaAr = json['categories_nama_ar']; // الاسم الأصلي
    categoriesNameAr = json['categories_name_ar'] ?? json['categories_nama_ar']; // الاسم الجديد مع fallback
    categoriesImage = json['categories_image'];
    categoriesDatetime = json['categories_datetime'];
    favorite = json['favorite']?.toString();
    itemsIdSeller = json['items_id_seller']?.toString();
    itemsPricedelivery = json['items_pricedelivery']?.toString();
    itemsCarVariants = json['items_car_variants'];
    itemsProductStatus = json['items_product_status']?.toString();
    categoriesDatatime = json['categories_datatime'];
    sellerName = json['seller_name'];
    sellerImage = json['seller_image'];
    totalRatings = json['total_ratings']?.toString();
    averageRating = json['average_rating']?.toString();

    // إضافة الحقول الجديدة من الباك إند المحسن
    finalRelevanceScore = json['final_relevance_score']?.toDouble();
    exactMatchScore = json['exact_match_score']?.toDouble();
    qualityScore = json['quality_score']?.toDouble();

    print("=== بيانات المنتج من قاعدة البيانات ===");
    print("items_id: $itemsId");
    print("items_name: $itemsName");
    print("items_price (السعر الأصلي): $itemsPrice");
    print("items_discount (نسبة الخصم): $itemsDiscount");
    print("itemspricediscount (السعر النهائي): $itemsPriceDiscount");
    print("final_relevance_score: $finalRelevanceScore");
  }

  // دالة للتحقق من وجود خصم
  bool hasDiscount() {
    if (itemsDiscount == null || itemsPrice == null) {
      return false;
    }
    try {
      double discount = double.parse(itemsDiscount!);
      return discount > 0;
    } catch (e) {
      return false;
    }
  }

  // دالة للحصول على السعر النهائي بعد الخصم
  String getFinalPrice() {
    // إذا كان السعر النهائي موجود من قاعدة البيانات، استخدمه
    if (itemsPriceDiscount != null && itemsPriceDiscount != "0") {
      return itemsPriceDiscount!;
    }

    // وإلا احسب السعر بناءً على السعر الأصلي والخصم
    if (itemsPrice != null && itemsDiscount != null) {
      try {
        double originalPrice = double.parse(itemsPrice!);
        double discountPercent = double.parse(itemsDiscount!);
        if (discountPercent > 0) {
          double finalPrice = originalPrice - (originalPrice * discountPercent / 100);
          return finalPrice.toStringAsFixed(2);
        }
      } catch (e) {
        print("خطأ في حساب السعر النهائي: $e");
      }
    }
    return itemsPrice ?? "0";
  }

  // دالة للحصول على مقدار الوفر
  String getSavingAmount() {
    if (!hasDiscount()) return "0";
    try {
      double originalPrice = double.parse(itemsPrice!);
      double finalPrice = double.parse(getFinalPrice());
      double saving = originalPrice - finalPrice;
      return saving.toStringAsFixed(2);
    } catch (e) {
      return "0";
    }
  }

  // دالة للحصول على قائمة الصور
  List<String> getImagesList() {
    if (itemsImage == null || itemsImage == "empty") return [];
    try {
      Map<String, dynamic> filesData = jsonDecode(itemsImage!);
      if (filesData['images'] != null) {
        return List<String>.from(filesData['images']);
      }
    } catch (e) {
      // إذا كان النص ليس JSON (النظام القديم)
      return [itemsImage!];
    }
    return [];
  }

  // دالة للحصول على قائمة الفيديوهات
  List<String> getVideosList() {
    if (itemsImage == null || itemsImage == "empty") return [];
    try {
      Map<String, dynamic> filesData = jsonDecode(itemsImage!);
      if (filesData['videos'] != null) {
        return List<String>.from(filesData['videos']);
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  // دالة للحصول على الصورة الأولى (للعرض الرئيسي)
  String getFirstImage() {
    List<String> images = getImagesList();
    if (images.isNotEmpty) {
      return images.first;
    }
    return "";
  }

  // دالة للحصول على جميع الملفات
  List<String> getAllFilesList() {
    List<String> allFiles = [];
    allFiles.addAll(getImagesList());
    allFiles.addAll(getVideosList());
    return allFiles;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['items_id'] = itemsId;
    data['items_name'] = itemsName;
    data['items_name_ar'] = itemsNameAr;
    data['items_desc'] = itemsDesc;
    data['items_desc_ar'] = itemsDescAr;
    data['items_image'] = itemsImage;
    data['items_count'] = itemsCount;
    data['items_active'] = itemsActive;
    data['items_price'] = itemsPrice;
    data['items_discount'] = itemsDiscount;
    data['items_date'] = itemsDate;
    data['items_cat'] = itemsCat;
    data['itemspricediscount'] = itemsPriceDiscount;
    data['categories_id'] = categoriesId;
    data['categories_name'] = categoriesName;
    data['categories_nama_ar'] = categoriesNamaAr;
    data['categories_name_ar'] = categoriesNameAr;
    data['categories_image'] = categoriesImage;
    data['categories_datetime'] = categoriesDatetime;
    data['favorite'] = favorite;
    data['items_id_seller'] = itemsIdSeller;
    data['items_pricedelivery'] = itemsPricedelivery;
    data['items_car_variants'] = itemsCarVariants;
    data['items_product_status'] = itemsProductStatus;
    data['categories_datatime'] = categoriesDatatime;
    data['seller_name'] = sellerName;
    data['seller_image'] = sellerImage;
    data['total_ratings'] = totalRatings;
    data['average_rating'] = averageRating;
    data['final_relevance_score'] = finalRelevanceScore;
    data['exact_match_score'] = exactMatchScore;
    data['quality_score'] = qualityScore;
    return data;
  }
}
