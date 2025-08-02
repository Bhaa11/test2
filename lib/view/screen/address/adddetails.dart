import 'package:ecommercecourse/controller/address/add_controller.dart';
import 'package:ecommercecourse/controller/address/adddetails_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/shared/custombutton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes.dart';

class AddressAddDetails extends StatelessWidget {
  const AddressAddDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AddAddressDetailsController controller =
    Get.put(AddAddressDetailsController());
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
          title: const Text(
            'إضافة عنوان جديد',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          elevation: 2,
          shadowColor: Colors.grey.withOpacity(0.1),
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: GetBuilder<AddAddressDetailsController>(
              builder: (controller) => HandlingDataView(
                statusRequest: controller.statusRequest,
                widget: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'تفاصيل العنوان',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 32),
                      _buildCityDropdown(controller: controller),
                      const SizedBox(height: 24),
                      _buildInputField(
                        controller: controller.street,
                        label: "المدينة",
                        icon: Icons.streetview_outlined,
                        hint: "المدينة و أقرب نقطة دالة",
                      ),
                      const SizedBox(height: 24),
                      _buildInputField(
                        controller: controller.name,
                        label: "اسم العنوان",
                        icon: Icons.assignment_ind_outlined,
                        hint: "مثلاً: المنزل، المكتب",
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: CustomButton(
                          text: "حفظ العنوان",
                          onPressed: () async {
                            await controller.addAddress();
                            if (Get.arguments?['fromCart'] == true) {
                              Get.offNamed('/cart'); // تأكد من أن مسار صفحة Cart معرف بشكل صحيح
                            } else {
                              Get.back();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityDropdown({required AddAddressDetailsController controller}) {
    final List<String> iraqiGovernorates = [
      'بغداد',
      'أربيل',
      'ديالى',
      'البصرة',
      'دهوك',
      'السليمانية',
      'كركوك',
      'الأنبار',
      'نينوى',
      'كربلاء',
      'النجف',
      'القادسية',
      'المثنى',
      'ميسان',
      'واسط',
      'بابل',
      'صلاح الدين',
      'حلبجة',
      'ذي قار',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'المحافظة',
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: controller.city.text.isEmpty ? null : controller.city.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.location_city_outlined, color: Colors.grey[500]),
              hintText: "اختر المحافظة",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
            items: iraqiGovernorates.map((String governorate) {
              return DropdownMenuItem<String>(
                value: governorate,
                child: Text(governorate),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.city.text = newValue;
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(icon, color: Colors.grey[500]),
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
          ),
        ),
      ],
    );
  }
}
