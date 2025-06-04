import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

import '../../view/widget/customappbar.dart';

imageUploadCamera() async {
  final PickedFile? file = await ImagePicker().getImage(source: ImageSource.camera, imageQuality: 90);
  if (file != null) {
    return File(file.path);
  } else {
    return null;
  }
}

fileUploadGallery([isSvg = false]) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: isSvg
        ? ["svg", "SVG"]
        : ["png", "PNG", "jpg", "jpeg", "gif"],
  );

  if (result != null) {
    return File(result.files.single.path!);
  } else {
    return null;
  }
}

// دالة جديدة لاختيار ملفات متعددة
multipleFilesUploadGallery() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ["png", "PNG", "jpg", "jpeg", "gif", "mp4", "mov", "avi", "mkv"],
    allowMultiple: true,
  );

  if (result != null) {
    return result.files.map((file) => File(file.path!)).toList();
  } else {
    return null;
  }
}

showbottommenu(Future<void> Function() imageUploadCameraFunc, Future<void> Function() fileUploadGalleryFunc) {
  Get.bottomSheet(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "اختيار صورة",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColor.primaryColor,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 25),
              _buildOptionButton(
                icon: Icons.camera_alt_rounded,
                text: "التقاط صورة",
                color: AppColor.primaryColor,
                onTap: () async {
                  await imageUploadCameraFunc();
                  Get.back();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Divider(thickness: 1.2, color: Colors.grey.withOpacity(0.2)),
              ),
              _buildOptionButton(
                icon: Icons.photo_library_rounded,
                text: "اختيار من الاستوديو",
                color: Colors.green,
                onTap: () async {
                  await fileUploadGalleryFunc();
                  Get.back();
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
    enableDrag: true,
  );
}

// دالة جديدة لعرض خيارات الملفات المتعددة
showMultipleFilesBottomMenu(Future<void> Function() multipleFilesUploadFunc) {
  Get.bottomSheet(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "اختيار الملفات",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColor.primaryColor,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 25),
              _buildOptionButton(
                icon: Icons.perm_media_rounded,
                text: "اختيار صور وفيديوهات (حتى 10 ملفات)",
                color: AppColor.primaryColor,
                onTap: () async {
                  await multipleFilesUploadFunc();
                  Get.back();
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
    enableDrag: true,
  );
}

Widget _buildOptionButton({
  required IconData icon,
  required String text,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                letterSpacing: 0.3,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    ),
  );
}
