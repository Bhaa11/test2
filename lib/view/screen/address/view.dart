import 'package:ecommercecourse/controller/address/view_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/data/model/addressmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AddressView extends StatelessWidget {
  const AddressView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(AddressViewController());
    return WillPopScope(
      onWillPop: () async {
        if (Get.arguments?['fromCart'] == true) {
          Get.offNamed(AppRoute.cart);
        } else {
          Get.offNamed(AppRoute.homepage);
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'العناوين',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColor.primaryColor.withOpacity(0.8),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (Get.arguments?['fromCart'] == true) {
                Get.offNamed(AppRoute.cart);
              } else {
                Get.offNamed(AppRoute.homepage);
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoute.addressadddetails, arguments: Get.arguments),
          backgroundColor: AppColor.primaryColor,
          icon: Icon(MdiIcons.mapMarkerPlusOutline),
          label: Text('إضافة عنوان جديد'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        body: GetBuilder<AddressViewController>(
          builder: (controller) => HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(),
                  SizedBox(height: 20),
                  Expanded(
                    child: _buildAddressList(controller),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(MdiIcons.mapMarkerOutline, color: AppColor.primaryColor),
          SizedBox(width: 10),
          Text(
            'عناوين التوصيل الخاصة بك',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(AddressViewController controller) {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      itemCount: controller.data.length,
      separatorBuilder: (context, index) => SizedBox(height: 15),
      itemBuilder: (context, i) => AddressCard(
        addressModel: controller.data[i],
        // عند السحب يتم التأكيد هنا ومن ثم الحذف مباشرةً
        onSwipeDelete: () =>
            controller.deleteAddress(controller.data[i].addressId!),
        // عند الضغط على أيقونة الحذف يتم عرض مربع تأكيد منفصل
        onIconDelete: () => _showIconDeleteDialog(context, controller, i),
      ),
    );
  }

  void _showIconDeleteDialog(
      BuildContext context, AddressViewController controller, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف العنوان'),
        content: Text('هل أنت متأكد من رغبتك في حذف هذا العنوان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteAddress(controller.data[index].addressId!);
              Navigator.pop(context);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final AddressModel addressModel;
  final VoidCallback onSwipeDelete;
  final VoidCallback onIconDelete;

  const AddressCard({
    Key? key,
    required this.addressModel,
    required this.onSwipeDelete,
    required this.onIconDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(addressModel.addressId.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(MdiIcons.deleteForeverOutline, color: Colors.red),
      ),
      confirmDismiss: (direction) async {
        final bool? confirmed = await _showSwipeDeleteDialog(context);
        if (confirmed != null && confirmed) {
          onSwipeDelete();
          return true;
        } else {
          return false;
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  addressModel.addressName!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(MdiIcons.deleteOutline, color: Colors.grey[400]),
                  onPressed: onIconDelete,
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildAddressDetail(
                MdiIcons.cityVariantOutline, addressModel.addressCity!),
            _buildAddressDetail(
                MdiIcons.roadVariant, addressModel.addressStreet!),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetail(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColor.primaryColor),
          SizedBox(width: 10),
          Text(text, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Future<bool?> _showSwipeDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من رغبتك في حذف هذا العنوان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}