import 'package:ecommercecourse/controller/address/add_controller.dart';
import 'package:ecommercecourse/core/class/handlingdataview.dart';
import 'package:ecommercecourse/core/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressAdd extends StatelessWidget {
  const AddressAdd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AddAddressController controllerpage = Get.put(AddAddressController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('add new address'),
      ),
      body: Container(
        child: GetBuilder<AddAddressController>(
          builder: (controllerpage) => HandlingDataView(
            statusRequest: controllerpage.statusRequest,
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // تم إزالة أي إشارات أو أكواد تتعلق بخريطة Google
                MaterialButton(
                  minWidth: 200,
                  onPressed: () {
                    controllerpage.goToPageAddDetailsAddress();
                  },
                  child: const Text("اكمال", style: TextStyle(fontSize: 18)),
                  color: AppColor.primaryColor,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}