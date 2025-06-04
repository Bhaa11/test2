// settings_data.dart
import 'dart:io';
import 'package:ecommercecourse/core/class/crud.dart';
import 'package:ecommercecourse/linkapi.dart';

class SettingsData {
  Crud crud;
  SettingsData(this.crud);

  updateProfile({
    required String userid,
    required String username,
    required String userdescription,
    required String userphone,
    required String imageold,
    File? image,
  }) async {
    var data = {
      "userid": userid,
      "username": username,
      "userdescription": userdescription,
      "userphone": userphone,
      "imageold": imageold,
    };

    if (image != null) {
      return await crud.addRequestWithImageOne(
          AppLink.updateProfile,
          data,
          image,
          "files"
      );
    } else {
      return await crud.postData(AppLink.updateProfile, data);
    }
  }
}
