import 'package:ecommercecourse/controller/settings_controller.dart';
import 'package:ecommercecourse/controller/items_seller/view_controller.dart';
import 'package:ecommercecourse/data/model/itemsmodel.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/linkapi.dart';
import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/core/class/crud.dart';
import 'package:ecommercecourse/core/functions/handingdatacontroller.dart';
import 'package:ecommercecourse/view/screen/sellerratings.dart';
import 'package:ecommercecourse/view/screen/wallet.dart';
import 'package:ecommercecourse/view/widget/custom_menu_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/services.dart';

// نموذج بيانات المستخدم
class UserProfileModel {
  String? usersName;
  String? usersDescription;
  String? usersPhone;
  String? usersImage;

  UserProfileModel({
    this.usersName,
    this.usersDescription,
    this.usersPhone,
    this.usersImage,
  });

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    usersName = json['users_name'];
    usersDescription = json['users_description'];
    usersPhone = json['users_phone'];
    usersImage = json['users_image'];

    // طباعة البيانات المستلمة
    print("=== UserProfileModel Data ===");
    print("Users Name: $usersName");
    print("Users Description: $usersDescription");
    print("Users Phone: $usersPhone");
    print("Users Image: $usersImage");
    print("============================");
  }
}

// الكنترولر المسؤول عن جلب بيانات الملف الشخصي
class ProfileController extends GetxController {
  Crud crud = Crud();
  late StatusRequest statusRequest;
  MyServices myServices = Get.find();

  UserProfileModel? userProfile;

  @override
  void onInit() {
    getUserProfile();
    super.onInit();
  }

  getUserProfile() async {
    statusRequest = StatusRequest.loading;
    update();

    print("=== Getting User Profile ===");
    print("User ID: ${myServices.sharedPreferences.getString("id")}");

    // هنا استدعاء الـ CRUD الذي يعيد Either<StatusRequest, Map>
    var either = await crud.postData(
      AppLink.getUserProfile,
      {
        "userid": myServices.sharedPreferences.getString("id"),
      },
    );

    // نفك الـ Either باستخدام fold:
    either.fold(
          (left) {
        // إذا جاء الـ left فهذا معناه فشل (StatusRequest فيه قيمة الخطأ)
        print("=== API Error ===");
        print("Error Status: $left");
        print("================");
        statusRequest = left;
        update();
      },
          (data) {
        // هنا data هو Map<String, dynamic>
        print("=== Raw API Response ===");
        print("Full Response: $data");
        print("Response Type: ${data.runtimeType}");
        print("=======================");

        statusRequest = handlingData(data);
        if (statusRequest == StatusRequest.success) {
          if (data['status'] == "success") {
            print("=== API Success Response ===");
            print("Status: ${data['status']}");
            print("Data Section: ${data['data']}");
            print("Data Type: ${data['data'].runtimeType}");
            print("===========================");

            userProfile = UserProfileModel.fromJson(data['data']);

            print("=== After Creating UserProfileModel ===");
            print("UserProfile Object: $userProfile");
            print("UserProfile Name: ${userProfile?.usersName}");
            print("UserProfile Description: ${userProfile?.usersDescription}");
            print("UserProfile Phone: ${userProfile?.usersPhone}");
            print("UserProfile Image: ${userProfile?.usersImage}");
            print("======================================");
          } else {
            print("=== API Failure Response ===");
            print("Status: ${data['status']}");
            print("Message: ${data['message'] ?? 'No message'}");
            print("===========================");
            statusRequest = StatusRequest.failure;
          }
        } else {
          print("=== Status Request Issue ===");
          print("Status Request: $statusRequest");
          print("Data: $data");
          print("===========================");
        }
        update();
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final SettingsController settingsController = Get.put(SettingsController());
  final ItemsControllerSeller itemsController = Get.put(ItemsControllerSeller());
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    print("=== ProfilePage Build ===");
    print("Building ProfilePage");
    print("========================");

    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الشخصي', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: AppColor.primaryColor),
            onPressed: () => _showMenuPopup(context),
          ),
        ],
      ),
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          print("=== GetBuilder Rebuild ===");
          print("Controller Status: ${controller.statusRequest}");
          print("User Profile: ${controller.userProfile}");
          print("=========================");

          if (controller.statusRequest == StatusRequest.loading) {
            return Center(child: CircularProgressIndicator());
          } else if (controller.statusRequest == StatusRequest.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('خطأ في تحميل البيانات'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.getUserProfile(),
                    child: Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(context, screenWidth),
                  _buildStatsSection(screenWidth),
                  _buildQuickActions(),
                  _buildProductsSection(context, screenWidth),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void _showMenuPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CustomMenuBottomSheet(),
    );
  }

  Widget _buildProfileHeader(BuildContext context, double screenWidth) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        final userProfile = controller.userProfile;

        print("=== Building Profile Header ===");
        print("User Profile in Header: $userProfile");
        print("User Name: ${userProfile?.usersName}");
        print("User Description: ${userProfile?.usersDescription}");
        print("User Phone: ${userProfile?.usersPhone}");
        print("User Image: ${userProfile?.usersImage}");
        print("===============================");

        return Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColor.primaryColor, width: 2),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl:
                        "${AppLink.imagestUsers}/${userProfile?.usersImage ?? 'default.png'}",
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColor.secondColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              SizedBox(width: screenWidth * 0.05),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            userProfile?.usersName ?? 'غير محدد',
                            style: Theme.of(context).textTheme.headlineSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              color: AppColor.primaryColor, size: 20),
                          onPressed: () => _showEditProfileDialog(context),
                        ),
                      ],
                    ),
                    if (userProfile?.usersPhone != null &&
                        userProfile!.usersPhone!.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              userProfile.usersPhone!,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (userProfile?.usersDescription != null &&
                        userProfile!.usersDescription!.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          userProfile.usersDescription!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[700]),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSection(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => Get.toNamed(AppRoute.ordershome),
            child: _buildStatItem(Icons.shopping_bag, 'الطلبات', '15'),
          ),
          GestureDetector(
            onTap: () {
              MyServices myServices = Get.find();
              Get.to(() => const SellerRatingsView(), arguments: {
                "seller_id":
                myServices.sharedPreferences.getString("id") ?? "1"
              });
            },
            child: _buildStatItem(Icons.star_border, 'التقييمات', '4.8'),
          ),
          GestureDetector(
            onTap: () {
              MyServices myServices = Get.find();
              Get.to(() => MyWallet(
                  userId: int.tryParse(
                      myServices.sharedPreferences.getString("id") ??
                          "1") ??
                      1));
            },
            child:
            _buildStatItem(Icons.account_balance_wallet, 'المحفظة', '\$250'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColor.primaryColor, size: 30),
        SizedBox(height: 8),
        Text(value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
              Icons.notifications_active, 'الإشعارات', () => Get.toNamed(AppRoute.addressview)),
          _buildActionButton(
              Icons.history, 'السجل', () => Get.toNamed(AppRoute.addressview)),
          _buildActionButton(Icons.support_agent, 'الدعم',
                  () => launchUrl(Uri.parse('tel:07707150740'))),
          _buildActionButton(
              Icons.logout, 'تسجيل خروج', settingsController.logout),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(icon: Icon(icon, color: AppColor.primaryColor), iconSize: 30, onPressed: onPressed),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildProductsSection(BuildContext context, double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('منتجاتي', style: Theme.of(context).textTheme.titleLarge),
              ElevatedButton.icon(
                icon: Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
                label: Text('إضافة منتج', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 5,
                  shadowColor: AppColor.primaryColor.withOpacity(0.3),
                ),
                onPressed: () => Get.toNamed(AppRoute.itemsadd),
              ),
            ],
          ),
          SizedBox(height: 15),
          GetBuilder<ItemsControllerSeller>(
            builder: (_) {
              if (itemsController.statusRequest == StatusRequest.loading) {
                return Center(child: CircularProgressIndicator());
              } else if (itemsController.statusRequest == StatusRequest.failure) {
                return Center(child: Text('خطأ في تحميل المنتجات'));
              } else {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: itemsController.data.length,
                  itemBuilder: (context, index) {
                    final item = itemsController.data[index] as ItemsModel;
                    return InkWell(
                      onTap: () => itemsController.goToPageEdit(item),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12, blurRadius: 6, spreadRadius: 2)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.vertical(top: Radius.circular(15)),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  imageUrl:
                                  "${AppLink.imagestItems}/${item.itemsImage}",
                                  placeholder: (context, url) =>
                                      Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.itemsName ?? '',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Text('\$ ${item.itemsPrice ?? ''}',
                                      style: TextStyle(color: AppColor.primaryColor)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: const EditProfileDialog(),
      ),
    );
  }
}

// حوار تعديل الملف الشخصي (مثال بسيط)
class EditProfileDialog extends StatelessWidget {
  const EditProfileDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'تعديل الملف الشخصي',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 20),
          Text('سيتم إضافة هذه الميزة قريباً'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
