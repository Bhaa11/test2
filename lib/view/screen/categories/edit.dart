
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../controller/categories/edit_controller.dart';
import '../../../core/class/handlingdataview.dart';
import '../../../core/constant/color.dart';
import '../../../core/functions/uploadfile.dart';
import '../../../core/functions/validinput.dart';
import '../../../core/shared/custombutton.dart';
import '../../../core/shared/customtextformglobal.dart';

class CategoriesEdit extends StatelessWidget {
  const CategoriesEdit({super.key});

  @override
  Widget build(BuildContext context) {
    CategoriesEditController controller = Get.put(CategoriesEditController());
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Categories'),
        ),
        body: GetBuilder<CategoriesEditController>(
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
                            return validInput(val!, 1, 30, "type");
                          },
                          isNumber: false),
                      CustomTextFormGlobal(
                          hinttext: "category name (Arabic)",
                          labeltext: "category name",
                          iconData: Icons.category,
                          mycontroller: controller.namear,
                          valid: (val) {
                            return validInput(val!, 1, 30, "type");
                          },
                          isNumber: false),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: MaterialButton(
                              color: AppColor.thirdColor,
                              textColor: AppColor.secondColor,
                              onPressed: () {
                                controller.chooseImage();
                              },
                              child: Text("Choose Category Image"))),

                      if (controller.file != null)
                        SvgPicture.file(controller.file!),
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
