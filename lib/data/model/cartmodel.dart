import 'itemsmodel.dart';

class CartModel {
  String? itemsprice;
  String? countitems;
  String? cartId;
  String? cartUsersid;
  String? cartItemsid;
  String? itemsId;
  String? itemsName;
  String? itemsNameAr;
  String? itemsDesc;
  String? itemsDescAr;
  String? itemsImage;
  String? itemsCount;
  String? itemsActive;
  String? itemsPrice;
  String? itemsPricedelivery;
  String? itemsDiscount;
  String? itemsDate;
  String? itemsCat;
  String? itemsIdSeller;

// Categories fields
  String? categoriesId;
  String? categoriesName;
  String? categoriesNameAr;
  String? categoriesImage;
  String? categoriesDatetime;

// Calculated fields
  String? itemspricediscount;

// Seller information
  String? sellerName;
  String? sellerImage;

// Seller ratings
  String? totalRatings;
  String? averageRating;

  CartModel({
    this.itemsprice,
    this.countitems,
    this.cartId,
    this.cartUsersid,
    this.cartItemsid,
    this.itemsId,
    this.itemsName,
    this.itemsNameAr,
    this.itemsDesc,
    this.itemsDescAr,
    this.itemsImage,
    this.itemsCount,
    this.itemsActive,
    this.itemsPrice,
    this.itemsPricedelivery,
    this.itemsDiscount,
    this.itemsDate,
    this.itemsCat,
    this.itemsIdSeller,
    this.categoriesId,
    this.categoriesName,
    this.categoriesNameAr,
    this.categoriesImage,
    this.categoriesDatetime,
    this.itemspricediscount,
    this.sellerName,
    this.sellerImage,
    this.totalRatings,
    this.averageRating,
  });

  CartModel.fromJson(Map<String, dynamic> json) {
    itemsprice = json['itemsprice'].toString();
    countitems = json['countitems'].toString();
    cartId = json['cart_id'].toString();
    cartUsersid = json['cart_usersid'].toString();
    cartItemsid = json['cart_itemsid'].toString();
    itemsId = json['items_id'].toString();
    itemsName = json['items_name'];
    itemsNameAr = json['items_name_ar'];
    itemsDesc = json['items_desc'];
    itemsDescAr = json['items_desc_ar'];
    itemsImage = json['items_image'];
    itemsCount = json['items_count'].toString();
    itemsActive = json['items_active'].toString();
    itemsPrice = json['items_price'].toString();
    itemsPricedelivery = json['items_pricedelivery'].toString();
    itemsDiscount = json['items_discount'].toString();
    itemsDate = json['items_date'];
    itemsCat = json['items_cat'].toString();
    itemsIdSeller = json['items_id_seller']?.toString();

// Categories fields
    categoriesId = json['categories_id']?.toString();
    categoriesName = json['categories_name'];
    categoriesNameAr = json['categories_name_ar'];
    categoriesImage = json['categories_image'];
    categoriesDatetime = json['categories_datetime'];

// Calculated fields
    itemspricediscount = json['itemspricediscount']?.toString();

// Seller information
    sellerName = json['seller_name'];
    sellerImage = json['seller_image'];

// Seller ratings
    totalRatings = json['total_ratings']?.toString();
    averageRating = json['average_rating']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itemsprice'] = this.itemsprice;
    data['countitems'] = this.countitems;
    data['cart_id'] = this.cartId;
    data['cart_usersid'] = this.cartUsersid;
    data['cart_itemsid'] = this.cartItemsid;
    data['items_id'] = this.itemsId;
    data['items_name'] = this.itemsName;
    data['items_name_ar'] = this.itemsNameAr;
    data['items_desc'] = this.itemsDesc;
    data['items_desc_ar'] = this.itemsDescAr;
    data['items_image'] = this.itemsImage;
    data['items_count'] = this.itemsCount;
    data['items_active'] = this.itemsActive;
    data['items_price'] = this.itemsPrice;
    data['items_pricedelivery'] = this.itemsPricedelivery;
    data['items_discount'] = this.itemsDiscount;
    data['items_date'] = this.itemsDate;
    data['items_cat'] = this.itemsCat;
    data['items_id_seller'] = this.itemsIdSeller;

// Categories fields
    data['categories_id'] = this.categoriesId;
    data['categories_name'] = this.categoriesName;
    data['categories_name_ar'] = this.categoriesNameAr;
    data['categories_image'] = this.categoriesImage;
    data['categories_datetime'] = this.categoriesDatetime;

// Calculated fields
    data['itemspricediscount'] = this.itemspricediscount;

// Seller information
    data['seller_name'] = this.sellerName;
    data['seller_image'] = this.sellerImage;

// Seller ratings
    data['total_ratings'] = this.totalRatings;
    data['average_rating'] = this.averageRating;

    return data;
  }

// دالة لتحويل CartModel إلى ItemsModel
  ItemsModel toItemsModel() {
    return ItemsModel(
      itemsId: this.itemsId,
      itemsName: this.itemsName,
      itemsNameAr: this.itemsNameAr,
      itemsDesc: this.itemsDesc,
      itemsDescAr: this.itemsDescAr,
      itemsImage: this.itemsImage,
      itemsCount: this.itemsCount,
      itemsActive: this.itemsActive,
      itemsPrice: this.itemsPrice,
      itemsPriceDiscount: this.itemspricediscount ?? this.itemsprice, // استخدام السعر المحسوب
      itemsPricedelivery: this.itemsPricedelivery,
      itemsDiscount: this.itemsDiscount,
      itemsDate: this.itemsDate,
      itemsCat: this.itemsCat,
      itemsIdSeller: this.itemsIdSeller,
      categoriesId: this.categoriesId,
      categoriesName: this.categoriesName,
      categoriesNameAr: this.categoriesNameAr,
      categoriesImage: this.categoriesImage,
      categoriesDatetime: this.categoriesDatetime,
      itemspricediscount: this.itemspricediscount ?? this.itemsprice, // نفس القيمة للتوافق
      sellerName: this.sellerName,
      sellerImage: this.sellerImage,
      totalRatings: this.totalRatings,
      averageRating: this.averageRating,
    );
  }
}
