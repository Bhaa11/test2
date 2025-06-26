import 'package:ecommercecourse/controller/settings_controller.dart';
import 'package:ecommercecourse/controller/items_seller/view_controller.dart';
import 'package:ecommercecourse/controller/profile_controller.dart';
import 'package:ecommercecourse/data/model/itemsmodel.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/linkapi.dart';
import 'package:ecommercecourse/core/class/statusrequest.dart';
import 'package:ecommercecourse/view/screen/sellerratings.dart';
import 'package:ecommercecourse/view/screen/wallet.dart';
import 'package:ecommercecourse/view/widget/custom_menu_bottom_sheet.dart';
import 'package:ecommercecourse/view/widget/home/product_badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/services/services.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final SettingsController settingsController = Get.put(SettingsController());
  final ItemsControllerSeller itemsController = Get.put(ItemsControllerSeller());

  @override
  Widget build(BuildContext context) {
    // إنشاء ProfileController مرة واحدة فقط
    final ProfileController profileController = Get.put(ProfileController(), permanent: true);

    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الشخصي'.tr, style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: AppColor.primaryColor),
            onPressed: () => _showMenuPopup(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await profileController.getUserProfile();
          await itemsController.getData();
        },
        color: AppColor.primaryColor,
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        displacement: 40,
        child: GetBuilder<ProfileController>(
          builder: (controller) {
            if (controller.statusRequest == StatusRequest.loading) {
              return Center(child: CircularProgressIndicator());
            } else if (controller.statusRequest == StatusRequest.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('خطأ في تحميل البيانات'.tr),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.getUserProfile(),
                      child: Text('إعادة المحاولة'.tr),
                    ),
                  ],
                ),
              );
            } else {
              return AnimationLimiter(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: AnimationConfiguration.staggeredList(
                    position: 0,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(
                        child: Column(
                          children: [
                            _buildProfileHeader(context, screenWidth, controller),
                            _buildStatsSection(screenWidth),
                            _buildQuickActions(),
                            _buildProductsSection(context, screenWidth),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
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

  Widget _buildProfileHeader(BuildContext context, double screenWidth, ProfileController controller) {
    final userProfile = controller.currentUser;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => _showEditProfileDialog(context),
                child: Container(
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
                        userProfile?.usersName ?? 'غير محدد'.tr,
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
            child: _buildStatItem(Icons.shopping_bag, 'الطلبات'.tr, '15'),
          ),
          GestureDetector(
            onTap: () {
              MyServices myServices = Get.find();
              Get.to(() => const SellerRatingsView(), arguments: {
                "seller_id":
                myServices.sharedPreferences.getString("id") ?? "1"
              });
            },
            child: _buildStatItem(Icons.star_border, 'التقييمات'.tr, '4.8'),
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
            _buildStatItem(Icons.account_balance_wallet, 'المحفظة'.tr, '\$250'),
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
              Icons.notifications_active, 'الإشعارات'.tr, () => Get.toNamed(AppRoute.addressview)),
          _buildActionButton(
              Icons.history, 'السجل'.tr, () => Get.toNamed(AppRoute.addressview)),
          _buildActionButton(Icons.support_agent, 'الدعم'.tr,
                  () => launchUrl(Uri.parse('tel:07707150740'))),
          _buildActionButton(
              Icons.logout, 'تسجيل خروج'.tr, settingsController.logout),
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
              Text('منتجاتي'.tr, style: Theme.of(context).textTheme.titleLarge),
              ElevatedButton.icon(
                icon: Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
                label: Text('إضافة منتج'.tr, style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                return Center(child: Text('خطأ في تحميل المنتجات'.tr));
              } else {
                return _buildEnhancedItemsList();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedItemsList() {
    if (itemsController.data.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 15),
              Text(
                'لا توجد منتجات متاحة حالياً'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: (itemsController.data.length / 2).ceil(),
        cacheExtent: 1500,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
        itemBuilder: (context, index) {
          int firstIndex = index * 2;
          int secondIndex = firstIndex + 1;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildProductCard(
                          itemsController.data[firstIndex] as ItemsModel,
                          firstIndex,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (secondIndex < itemsController.data.length)
                        Expanded(
                          child: _buildProductCard(
                            itemsController.data[secondIndex] as ItemsModel,
                            secondIndex,
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(ItemsModel itemsModel, int index) {
    double discount = double.tryParse(itemsModel.itemsDiscount ?? "0") ?? 0;
    double originalPrice = double.tryParse(itemsModel.itemsPrice ?? "0") ?? 0;
    double deliveryPrice = 0;
    bool hasDiscount = discount > 0;
    bool hasFreeDelivery = deliveryPrice == 0;

    // استخراج الصورة الأولى
    String firstImage = _getFirstImage(itemsModel.itemsImage);

    return VisibilityDetector(
      key: Key('product-${itemsModel.itemsId}-$index'),
      onVisibilityChanged: (visibilityInfo) {
        // يمكن إضافة منطق إضافي هنا عند الحاجة
      },
      child: GestureDetector(
        onTap: () => itemsController.goToPageEdit(itemsModel),
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة المنتج
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: firstImage.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: "${AppLink.imagestItems}/$firstImage",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                          memCacheWidth: 400,
                          memCacheHeight: 400,
                          maxWidthDiskCache: 400,
                          maxHeightDiskCache: 400,
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 300),
                        )
                            : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // تفاصيل المنتج
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // اسم المنتج
                          Text(
                            itemsModel.itemsName ?? "",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColor.black,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                          ),

                          const SizedBox(height: 4),

                          // عدد القطع المتوفرة
                          Builder(
                            builder: (context) {
                              int itemCount = int.tryParse(itemsModel.itemsCount ?? '0') ?? 0;
                              bool isOutOfStock = itemCount == 0;

                              return Text(
                                isOutOfStock ? "نفذ المخزون".tr : "متوفر: ".tr + "${itemsModel.itemsCount}" + " قطعة".tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isOutOfStock ? Colors.red : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),


                          const SizedBox(height: 4),

                          // الأسعار
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasDiscount) ...[
                                Text(
                                  "${itemsModel.itemsPriceDiscount} " + "د.ع".tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                Text(
                                  "${itemsModel.itemsPrice} " + "د.ع".tr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  "${itemsModel.itemsPrice} " + "د.ع".tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // الشارات
              Positioned(
                top: 6,
                right: 6,
                child: ProductBadges.buildBadgesColumn(
                  hasDiscount: hasDiscount,
                  discount: discount,
                  hasFreeDelivery: hasFreeDelivery,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة استخراج الصورة الأولى
  String _getFirstImage(String? itemsImage) {
    if (itemsImage == null || itemsImage.isEmpty) return '';

    try {
      // محاولة تحليل JSON
      if (itemsImage.startsWith('{') || itemsImage.startsWith('[')) {
        final decoded = itemsImage.replaceAll(RegExp(r'[{}"\[\]]'), '');
        final parts = decoded.split(',');
        for (String part in parts) {
          if (part.contains('images:')) {
            final imagePart = part.split('images:')[1];
            final images = imagePart.split(',');
            if (images.isNotEmpty) {
              return images[0].trim();
            }
          }
        }
      }

      // إذا لم يكن JSON، إرجاع النص كما هو
      return itemsImage;
    } catch (e) {
      // في حالة الخطأ، إرجاع النص الأصلي
      return itemsImage;
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    // التأكد من وجود ProfileController
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: const EditProfileDialog(),
      ),
    );
  }
}

// حوار تعديل الملف الشخصي (محدث)
class EditProfileDialog extends StatelessWidget {
  const EditProfileDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(),
              if (controller.statusRequest == StatusRequest.loading)
                Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  ),
                )
              else ...[
                _buildAvatarSection(controller),
                SizedBox(height: 20),
                _buildTextFields(controller),
                SizedBox(height: 30),
                _buildActionButtons(controller),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: EdgeInsets.only(bottom: 15),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: AppColor.primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'تعديل الملف الشخصي'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.secondColor,
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.grey.shade700,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(ProfileController controller) {
    return GestureDetector(
      onTap: () => controller.showImagePickerOptions(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.primaryColor, width: 3),
            ),
            child: ClipOval(
              child: controller.selectedImage != null
                  ? Image.file(
                controller.selectedImage!,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              )
                  : controller.currentImageUrl != null &&
                  controller.currentImageUrl!.isNotEmpty
                  ? Image.network(
                "${AppLink.imagestUsers}/${controller.currentImageUrl}",
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.secondColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFields(ProfileController controller) {
    return Column(
      children: [
        _buildTextField(
          controller: controller.nameController,
          labelText: 'الاسم الكامل'.tr,
          prefixIcon: Icons.person,
        ),
        SizedBox(height: 15),
        _buildTextField(
          controller: controller.descriptionController,
          labelText: 'وصف المتجر'.tr,
          prefixIcon: Icons.store,
          maxLines: 3,
          isDescription: true,
        ),
        SizedBox(height: 15),
        _buildTextField(
          controller: controller.phoneController,
          labelText: 'رقم الهاتف'.tr,
          prefixIcon: Icons.phone,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    int maxLines = 1,
    bool isDescription = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: 20, vertical: isDescription ? 10 : 5),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: AppColor.primaryColor),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: EdgeInsets.only(top: isDescription ? 0 : 0),
            child: Icon(prefixIcon, color: AppColor.primaryColor),
          ),
          alignLabelWithHint: isDescription,
          hintText: isDescription ? 'اكتب وصفاً مختصراً عن متجرك...'.tr : null,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
        ),
        textAlignVertical: isDescription
            ? TextAlignVertical.top
            : TextAlignVertical.center,
      ),
    );
  }

  Widget _buildActionButtons(ProfileController controller) {
    return controller.updateStatusRequest == StatusRequest.loading
        ? Center(
      child: CircularProgressIndicator(
        color: AppColor.primaryColor,
      ),
    )
        : Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade700,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: Text('إلغاء'.tr),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => controller.updateProfile(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: Text(
              'حفظ التغييرات'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
