// view/screen/seller_ratings_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/class/crud.dart';
import 'package:ecommercecourse/linkapi.dart';

// Model للتقييمات
class SellerRatingModel {
  String? ratingId;
  String? ratingSellerId;
  String? ratingUserId;
  String? ratingOrderId;
  String? ratingScore;
  String? ratingComment;
  String? ratingCreatedAt;
  String? ratingUpdatedAt;
  String? usersName;
  String? usersEmail;
  String? ordersDatetime;
  String? ordersTotalprice;
  String? ordersId;

  SellerRatingModel({
    this.ratingId,
    this.ratingSellerId,
    this.ratingUserId,
    this.ratingOrderId,
    this.ratingScore,
    this.ratingComment,
    this.ratingCreatedAt,
    this.ratingUpdatedAt,
    this.usersName,
    this.usersEmail,
    this.ordersDatetime,
    this.ordersTotalprice,
    this.ordersId,
  });

  SellerRatingModel.fromJson(Map<String, dynamic> json) {
    ratingId = json['rating_id']?.toString();
    ratingSellerId = json['rating_seller_id']?.toString();
    ratingUserId = json['rating_user_id']?.toString();
    ratingOrderId = json['rating_order_id']?.toString();
    ratingScore = json['rating_score']?.toString();
    ratingComment = json['rating_comment'];
    ratingCreatedAt = json['rating_created_at'];
    ratingUpdatedAt = json['rating_updated_at'];
    usersName = json['users_name'];
    usersEmail = json['users_email'];
    ordersDatetime = json['orders_datetime'];
    ordersTotalprice = json['orders_totalprice']?.toString();
    ordersId = json['orders_id']?.toString();
  }
}

// Model للإحصائيات
class SellerRatingStats {
  String? totalRatings;
  String? averageRating;
  String? fiveStars;
  String? fourStars;
  String? threeStars;
  String? twoStars;
  String? oneStar;
  String? latestRatingDate;
  String? firstRatingDate;

  SellerRatingStats({
    this.totalRatings,
    this.averageRating,
    this.fiveStars,
    this.fourStars,
    this.threeStars,
    this.twoStars,
    this.oneStar,
    this.latestRatingDate,
    this.firstRatingDate,
  });

  SellerRatingStats.fromJson(Map<String, dynamic> json) {
    totalRatings = json['total_ratings']?.toString() ?? "0";
    averageRating = json['average_rating']?.toString() ?? "0.0";
    fiveStars = json['five_stars']?.toString() ?? "0";
    fourStars = json['four_stars']?.toString() ?? "0";
    threeStars = json['three_stars']?.toString() ?? "0";
    twoStars = json['two_stars']?.toString() ?? "0";
    oneStar = json['one_star']?.toString() ?? "0";
    latestRatingDate = json['latest_rating_date'];
    firstRatingDate = json['first_rating_date'];
  }
}

// Data Source
class SellerRatingData {
  Crud crud;
  SellerRatingData(this.crud);

  getSellerRatings(String sellerId) async {
    var response = await crud.postData(AppLink.viewSellerRating, {
      "seller_id": sellerId
    });
    return response.fold((l) => l, (r) => r);
  }
}

// Controller
class SellerRatingsController extends GetxController {
  SellerRatingData sellerRatingData = SellerRatingData(Get.find());

  List<SellerRatingModel> ratings = [];
  SellerRatingStats? stats;

  late StatusRequest statusRequest;

  String sellerId = "";

  @override
  void onInit() {
    sellerId = Get.arguments['seller_id'] ?? "";
    if (sellerId.isNotEmpty) {
      getSellerRatings();
    }
    super.onInit();
  }

  getSellerRatings() async {
    statusRequest = StatusRequest.loading;
    update();

    var response = await sellerRatingData.getSellerRatings(sellerId);
    print("=== استجابة تقييمات البائع ===");
    print(response);

    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['data'] != null) {
        // جلب الإحصائيات
        if (response['data']['statistics'] != null) {
          stats = SellerRatingStats.fromJson(response['data']['statistics']);
        }

        // جلب التقييمات
        if (response['data']['ratings'] != null) {
          List responseData = response['data']['ratings'];
          ratings.addAll(responseData.map((e) => SellerRatingModel.fromJson(e)));
        }
      }
    } else {
      print("خطأ في جلب تقييمات البائع");
    }
    update();
  }

  refreshData() {
    ratings.clear();
    stats = null;
    getSellerRatings();
  }
}

// الصفحة الرئيسية
class SellerRatingsView extends StatelessWidget {
  const SellerRatingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(SellerRatingsController());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "تقييمات البائع",
          style: TextStyle(color: AppColor.grey),
        ),
        iconTheme: IconThemeData(color: AppColor.grey),
        centerTitle: true,
        backgroundColor: AppColor.backgroundcolor,
        elevation: 0.0,
      ),
      body: GetBuilder<SellerRatingsController>(
        builder: (controller) => HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: RefreshIndicator(
            onRefresh: () async {
              controller.refreshData();
            },
            child: ListView(
              padding: EdgeInsets.all(15),
              children: [
                // قسم الإحصائيات
                _buildStatsSection(controller.stats),
                SizedBox(height: 20),

                // قسم التقييمات
                _buildRatingsSection(controller.ratings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(SellerRatingStats? stats) {
    if (stats == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Text(
          "لا توجد إحصائيات متاحة",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColor.grey,
          ),
        ),
      );
    }

    double avgRating = double.tryParse(stats.averageRating ?? "0") ?? 0.0;
    int totalRatings = int.tryParse(stats.totalRatings ?? "0") ?? 0;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "إحصائيات التقييمات",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.black,
            ),
          ),
          SizedBox(height: 15),

          // التقييم العام
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < avgRating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  Text(
                    "$totalRatings تقييم",
                    style: TextStyle(
                      color: AppColor.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),

          // توزيع النجوم
          _buildStarDistribution(stats),
        ],
      ),
    );
  }

  Widget _buildStarDistribution(SellerRatingStats stats) {
    int total = int.tryParse(stats.totalRatings ?? "0") ?? 0;

    if (total == 0) {
      return Text(
        "لا توجد تقييمات بعد",
        style: TextStyle(color: AppColor.grey),
      );
    }

    return Column(
      children: [
        _buildStarRow(5, int.tryParse(stats.fiveStars ?? "0") ?? 0, total),
        _buildStarRow(4, int.tryParse(stats.fourStars ?? "0") ?? 0, total),
        _buildStarRow(3, int.tryParse(stats.threeStars ?? "0") ?? 0, total),
        _buildStarRow(2, int.tryParse(stats.twoStars ?? "0") ?? 0, total),
        _buildStarRow(1, int.tryParse(stats.oneStar ?? "0") ?? 0, total),
      ],
    );
  }

  Widget _buildStarRow(int stars, int count, int total) {
    double percentage = total > 0 ? (count / total) * 100 : 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$stars"),
          Icon(Icons.star, color: Colors.amber, size: 16),
          SizedBox(width: 10),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          SizedBox(width: 10),
          Text(
            "$count",
            style: TextStyle(fontSize: 12, color: AppColor.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection(List<SellerRatingModel> ratings) {
    if (ratings.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 50,
              color: AppColor.grey,
            ),
            SizedBox(height: 10),
            Text(
              "لا توجد تقييمات بعد",
              style: TextStyle(
                fontSize: 16,
                color: AppColor.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "التقييمات (${ratings.length})",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.black,
          ),
        ),
        SizedBox(height: 10),

        ...ratings.map((rating) => _buildRatingCard(rating)).toList(),
      ],
    );
  }

  Widget _buildRatingCard(SellerRatingModel rating) {
    int score = int.tryParse(rating.ratingScore ?? "0") ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات المستخدم والتقييم
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColor.primaryColor,
                child: Text(
                  (rating.usersName ?? "مستخدم").substring(0, 1).toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.usersName ?? "مستخدم مجهول",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < score ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        SizedBox(width: 5),
                        Text(
                          _formatDate(rating.ratingCreatedAt),
                          style: TextStyle(
                            color: AppColor.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // معلومات الطلب
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "طلب #${rating.ordersId}",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.grey,
                    ),
                  ),
                  Text(
                    "${rating.ordersTotalprice ?? "0"} د.ع",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // التعليق
          if (rating.ratingComment != null && rating.ratingComment!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.backgroundcolor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rating.ratingComment!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "";

    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }
}
