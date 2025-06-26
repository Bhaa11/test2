import 'package:ecommercecourse/data/model/itemsmodel.dart';

class OrdersModel {
  String? ordersId;
  String? ordersUsersid;
  String? ordersAddress;
  String? ordersType;
  String? ordersPricedelivery;
  String? ordersPrice;
  String? ordersTotalprice;
  String? ordersCoupon;
  String? ordersRating;
  String? ordersNoterating;
  String? ordersPaymentmethod;
  String? ordersStatus;
  String? ordersDatetime;
  String? addressId;
  String? addressUsersid;
  String? addressName;
  String? addressCity;
  String? addressStreet;
  String? addressLat;
  String? addressLong;
  String? itemsIdSeller;
  String? sellerRatingScore;
  String? sellerRatingComment;
  String? usersPhone; // رقم هاتف المستخدم
  String? itemsCount; // إضافة items_count على مستوى الطلب
  List<OrderItemData>? items;

  OrdersModel({
    this.ordersId,
    this.ordersUsersid,
    this.ordersAddress,
    this.ordersType,
    this.ordersPricedelivery,
    this.ordersPrice,
    this.ordersTotalprice,
    this.ordersCoupon,
    this.ordersRating,
    this.ordersNoterating,
    this.ordersPaymentmethod,
    this.ordersStatus,
    this.ordersDatetime,
    this.addressId,
    this.addressUsersid,
    this.addressName,
    this.addressCity,
    this.addressStreet,
    this.addressLat,
    this.addressLong,
    this.itemsIdSeller,
    this.sellerRatingScore,
    this.sellerRatingComment,
    this.usersPhone,
    this.itemsCount, // إضافة في الكونستركتر
    this.items,
  });

  OrdersModel.fromJson(Map<String, dynamic> json) {
    ordersId = json['orders_id'].toString();
    ordersUsersid = json['orders_usersid'].toString();
    ordersAddress = json['orders_address'].toString();
    ordersType = json['orders_type'].toString();
    ordersPricedelivery = json['orders_pricedelivery'].toString();
    ordersPrice = json['orders_price'].toString();
    ordersTotalprice = json['orders_totalprice'].toString();
    ordersCoupon = json['orders_coupon'].toString();
    ordersRating = json['orders_rating'].toString();
    ordersNoterating = json['orders_noterating'];
    ordersPaymentmethod = json['orders_paymentmethod'].toString();
    ordersStatus = json['orders_status'].toString();
    ordersDatetime = json['orders_datetime'].toString();
    addressId = json['address_id']?.toString();
    addressUsersid = json['address_usersid']?.toString();
    addressName = json['address_name'];
    addressCity = json['address_city'];
    addressStreet = json['address_street'];
    addressLat = json['address_lat']?.toString();
    addressLong = json['address_long']?.toString();

    itemsIdSeller = json['items_id_seller']?.toString();
    sellerRatingScore = json['seller_rating_score']?.toString() ?? "0";
    sellerRatingComment = json['seller_rating_comment']?.toString() ?? "";
    usersPhone = json['users_phone']?.toString();
    itemsCount = json['items_count']?.toString() ?? "1"; // إضافة items_count

    print("=== تشخيص تقييم البائع ===");
    print("Order ID: $ordersId");
    print("Seller Rating Score: $sellerRatingScore");
    print("Seller Rating Comment: $sellerRatingComment");
    print("Users Phone: $usersPhone");
    print("Items Count: $itemsCount"); // طباعة للتشخيص

    if (json['items'] != null) {
      items = <OrderItemData>[];
      json['items'].forEach((item) {
        items!.add(OrderItemData.fromJson(item));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['orders_id'] = ordersId;
    data['orders_usersid'] = ordersUsersid;
    data['orders_address'] = ordersAddress;
    data['orders_type'] = ordersType;
    data['orders_pricedelivery'] = ordersPricedelivery;
    data['orders_price'] = ordersPrice;
    data['orders_totalprice'] = ordersTotalprice;
    data['orders_coupon'] = ordersCoupon;
    data['orders_rating'] = ordersRating;
    data['orders_noterating'] = ordersNoterating;
    data['orders_paymentmethod'] = ordersPaymentmethod;
    data['orders_status'] = ordersStatus;
    data['orders_datetime'] = ordersDatetime;
    data['address_id'] = addressId;
    data['address_usersid'] = addressUsersid;
    data['address_name'] = addressName;
    data['address_city'] = addressCity;
    data['address_street'] = addressStreet;
    data['address_lat'] = addressLat;
    data['address_long'] = addressLong;
    data['items_id_seller'] = itemsIdSeller;
    data['seller_rating_score'] = sellerRatingScore;
    data['seller_rating_comment'] = sellerRatingComment;
    data['users_phone'] = usersPhone;
    data['items_count'] = itemsCount; // إضافة في toJson

    if (items != null) {
      data['items'] = items!.map((item) => item.toJson()).toList();
    }

    return data;
  }
}

// كلاس محدث لبيانات المنتج في الطلب
class OrderItemData {
  String? itemsId;
  String? itemsName;
  String? itemsNameAr;
  String? itemsImage;
  String? cartId;
  String? cartUsersid;
  String? cartItemsid;
  String? itemsPrice;
  String? itemsDiscount;
  String? itemsPriceDiscount;
  String? itemsCount; // items_count على مستوى المنتج

// معلومات البائع المباشرة
  String? itemsIdSeller;
  String? sellerName;
  String? sellerImage;
  String? totalRatings;
  String? averageRating;

  ItemsModel? itemDetails;

  OrderItemData({
    this.itemsId,
    this.itemsName,
    this.itemsNameAr,
    this.itemsImage,
    this.cartId,
    this.cartUsersid,
    this.cartItemsid,
    this.itemsPrice,
    this.itemsDiscount,
    this.itemsPriceDiscount,
    this.itemsCount,
    this.itemsIdSeller,
    this.sellerName,
    this.sellerImage,
    this.totalRatings,
    this.averageRating,
    this.itemDetails,
  });

  factory OrderItemData.fromJson(Map<String, dynamic> json) {
    print("=== تحليل بيانات OrderItemData ===");
    print("raw json: $json");
    print("items_count من json: ${json['items_count']}"); // إضافة طباعة التشخيص

    return OrderItemData(
      itemsId: json['items_id']?.toString(),
      itemsName: json['items_name'],
      itemsNameAr: json['items_name_ar'],
      itemsImage: json['items_image'],
      cartId: json['cart_id']?.toString(),
      cartUsersid: json['cart_usersid']?.toString(),
      cartItemsid: json['cart_itemsid']?.toString(),
      itemsPrice: json['items_price']?.toString(),
      itemsDiscount: json['items_discount']?.toString(),
      itemsPriceDiscount: json['itemspricediscount']?.toString(),
      itemsCount: json['items_count']?.toString() ?? "1", // استخراج items_count

// استخراج معلومات البائع المباشرة
      itemsIdSeller: json['items_id_seller']?.toString(),
      sellerName: json['seller_name'],
      sellerImage: json['seller_image'],
      totalRatings: json['total_ratings']?.toString() ?? "0",
      averageRating: json['average_rating']?.toString() ?? "0",

// إنشاء ItemsModel كامل مع جميع البيانات من الـ JSON
      itemDetails: ItemsModel(
        itemsId: json['items_id']?.toString(),
        itemsName: json['items_name'],
        itemsNameAr: json['items_name_ar'],
        itemsImage: json['items_image'],
        itemsPrice: json['items_price']?.toString(),
        itemsDiscount: json['items_discount']?.toString(),
        itemsPriceDiscount: json['itemspricediscount']?.toString(),
        itemsCount: json['items_count']?.toString() ?? "1", // إضافة items_count في itemDetails أيضاً
        itemsDesc: json['items_desc'],
        itemsDescAr: json['items_desc_ar'],
        itemsActive: json['items_active']?.toString(),
        itemsDate: json['items_date'],
        itemsCat: json['items_cat']?.toString(),
        categoriesId: json['categories_id']?.toString(),
        categoriesName: json['categories_name'],
        categoriesNameAr: json['categories_name_ar'],
        categoriesImage: json['categories_image'],
        categoriesDatetime: json['categories_datetime'],
        favorite: json['favorite']?.toString() ?? "0",
        itemsPricedelivery: json['items_pricedelivery']?.toString(),
        itemsCarVariants: json['items_car_variants'],
        itemsProductStatus: json['items_product_status']?.toString(),
        sellerName: json['seller_name'],
        sellerImage: json['seller_image'],
        totalRatings: json['total_ratings']?.toString() ?? "0",
        averageRating: json['average_rating']?.toString() ?? "0",
        itemsIdSeller: json['items_id_seller']?.toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['items_id'] = itemsId;
    data['items_name'] = itemsName;
    data['items_name_ar'] = itemsNameAr;
    data['items_image'] = itemsImage;
    data['cart_id'] = cartId;
    data['cart_usersid'] = cartUsersid;
    data['cart_itemsid'] = cartItemsid;
    data['items_price'] = itemsPrice;
    data['items_discount'] = itemsDiscount;
    data['itemspricediscount'] = itemsPriceDiscount;
    data['items_count'] = itemsCount; // إضافة items_count في toJson
    data['items_id_seller'] = itemsIdSeller;
    data['seller_name'] = sellerName;
    data['seller_image'] = sellerImage;
    data['total_ratings'] = totalRatings;
    data['average_rating'] = averageRating;
    return data;
  }
}
