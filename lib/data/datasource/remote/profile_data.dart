// lib/data/datasource/remote/profile_data.dart
import 'dart:io';
import 'package:ecommercecourse/core/class/crud.dart';
import 'package:ecommercecourse/linkapi.dart';

class ProfileData {
  final Crud crud;

  ProfileData(this.crud);

  /// جلب معلومات المستخدم
  Future<dynamic> getUserProfile(String userid) async {
    try {
      var response = await crud.postData(AppLink.getUserProfile, {
        "userid": userid,
      });
      return response.fold((l) => l, (r) => r);
    } catch (e) {
      print("Error in getUserProfile: $e");
      rethrow;
    }
  }

  /// تحديث معلومات المستخدم مع الصورة
  Future<dynamic> updateUserProfile({
    required String userid,
    required String username,
    required String userdescription,
    required String userphone,
    File? imageFile,
    String? imageold,
  }) async {
    try {
      var data = {
        "userid": userid,
        "username": username,
        "userdescription": userdescription,
        "userphone": userphone,
        "imageold": imageold ?? "",
      };

      var response = await crud.postRequestWithFile(
        AppLink.updateProfile,
        data,
        imageFile,
        "files",
      );
      return response.fold((l) => l, (r) => r);
    } catch (e) {
      print("Error in updateUserProfile: $e");
      rethrow;
    }
  }

  /// تحديث صورة المستخدم فقط
  Future<dynamic> updateUserImage({
    required String userid,
    required File imageFile,
    String? imageold,
  }) async {
    try {
      var data = {
        "userid": userid,
        "imageold": imageold ?? "",
      };

      var response = await crud.postRequestWithFile(
        AppLink.updateProfileImage,
        data,
        imageFile,
        "files",
      );
      return response.fold((l) => l, (r) => r);
    } catch (e) {
      print("Error in updateUserImage: $e");
      rethrow;
    }
  }

  /// حذف صورة المستخدم
  Future<dynamic> deleteUserImage({
    required String userid,
    required String imageName,
  }) async {
    try {
      var response = await crud.postData(AppLink.deleteProfileImage, {
        "userid": userid,
        "imagename": imageName,
      });
      return response.fold((l) => l, (r) => r);
    } catch (e) {
      print("Error in deleteUserImage: $e");
      rethrow;
    }
  }
}
