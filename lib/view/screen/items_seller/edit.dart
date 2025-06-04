

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import '../../../controller/items_seller/edit_controller.dart';
import '../../../core/class/handlingdataview.dart';
import '../../../core/constant/color.dart';
import '../../../core/functions/validinput.dart';
import '../../../core/shared/custombutton.dart';
import '../../../core/shared/customdropdownsearch.dart';
import '../../../core/shared/customtextformglobal.dart';

class ItemsEdit extends StatelessWidget {
  const ItemsEdit({super.key});

  @override
  Widget build(BuildContext context) {
    ItemsEditController controller = Get.put(ItemsEditController());
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Items'),
        ),
        body: GetBuilder<ItemsEditController>(
            builder: (controller) => HandlingDataView(
              statusRequest: controller.statusRequest!,
              widget: Container(
                padding: EdgeInsets.all(10),
                child: Form(
                  key: controller.formState,
                  child: ListView(
                    children: [
                      CustomTextFormGlobal(
                          hinttext: "category name",
                          labeltext: "category name",
                          iconData: Icons.category,
                          mycontroller: controller.name,
                          valid: (val) {
                            return validInput(val!, 1, 50, "type");
                          },
                          isNumber: false),
                      CustomTextFormGlobal(
                          hinttext: "items name (Arabic)",
                          labeltext: "items name",
                          iconData: Icons.category,
                          mycontroller: controller.namear,
                          valid: (val) {
                            return validInput(val!, 1, 50, "type");
                          },
                          isNumber: false),
                      CustomTextFormGlobal(
                          hinttext: "description name",
                          labeltext: "description name",
                          iconData: Icons.category,
                          mycontroller: controller.desc,
                          valid: (val) {
                            return validInput(val!, 1, 200, "type");
                          },
                          isNumber: false),
                      CustomTextFormGlobal(
                          hinttext: "description name (Arabic)",
                          labeltext: "description name",
                          iconData: Icons.category,
                          mycontroller: controller.descar,
                          valid: (val) {
                            return validInput(val!, 1, 200, "type");
                          },
                          isNumber: false),
                      CustomTextFormGlobal(
                          hinttext: "count",
                          labeltext: "count",
                          iconData: Icons.category,
                          mycontroller: controller.count,
                          valid: (val) {
                            return validInput(val!, 1, 30, "type");
                          },
                          isNumber: true),
                      CustomTextFormGlobal(
                          hinttext: "price",
                          labeltext: "price",
                          iconData: Icons.category,
                          mycontroller: controller.price,
                          valid: (val) {
                            return validInput(val!, 1, 30, "type");
                          },
                          isNumber: true),                CustomTextFormGlobal(
                          hinttext: "discount",
                          labeltext: "discount",
                          iconData: Icons.category,
                          mycontroller: controller.discount,
                          valid: (val) {
                            return validInput(val!, 1, 30, "type");
                          },
                          isNumber: true),
                      CustomDropdownSearch(
                          title: "Choose Category",
                          listdata: controller.dropdownnlist, dropdownSelectedID: controller.catid! ,
                          dropdownSelectedName: controller.catname!),

                      SizedBox(height: 10),
                      RadioListTile(
                        title: Text("hide"),
                        value: "0",groupValue: controller.active,onChanged: (val) {
                        controller.changeStatusAction(val);
                      },),
                      RadioListTile(
                        title: Text("active"),
                        value: "1",groupValue: controller.active,onChanged: (val) {
                        controller.changeStatusAction(val);
                      },),
                      SizedBox(height: 10),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: MaterialButton(
                              color: AppColor.thirdColor,
                              textColor: AppColor.secondColor,
                              onPressed: () {
                                // controller.showOptionImage();;
                              },
                              child: Text("Choose items Image"))
                      ),

                      if (controller.file != null)
                        Image.file(controller.file!, width: 100 , height: 100),
                      CustomButton(
                        text: "حفض",
                        onPressed: () {
                          controller.editData();
                        },
                      ),
                    ],
                  ),
                ),
              ),))
    );
  }
}
