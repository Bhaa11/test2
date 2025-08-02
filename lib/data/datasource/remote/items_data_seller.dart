import 'dart:io';
import 'package:dartz/dartz.dart';

import 'package:ecommercecourse/core/class/statusrequest.dart';

import '../../../../core/class/crud.dart';
import '../../../../linkapi.dart';

class ItemsDataSeller {
  Crud crud;
  ItemsDataSeller(this.crud);

  Future get(String sellerId, {int lastItemId = 0}) async {
    var response = await crud.postData(AppLink.itemsview, {
      "seller_id": sellerId,
      "last_item_id": lastItemId.toString()
    });
    return response.fold((l) => l, (r) => r);
  }

  add(Map data, File file) async {
    var response = await crud.addRequestWithImageOne(AppLink.citemsadd, data, file);
    return response.fold((l) => l, (r) => r);
  }

  addMultiple(Map data, List<File> files) async {
    var response = await crud.addRequestWithMultipleFiles(AppLink.citemsadd, data, files);
    return response.fold((l) => l, (r) => r);
  }

  delete(Map data) async {
    var response = await crud.postData(AppLink.itemsdelete, data);
    return response.fold((l) => l, (r) => r);
  }

  edit(Map data, [File? file]) async {
    Either<StatusRequest, Map> response;
    if (file == null) {
      response = await crud.postData(AppLink.itemsedit, data);
    } else {
      response = await crud.addRequestWithImageOne(AppLink.itemsedit, data, file);
    }
    return response.fold((l) => l, (r) => r);
  }

  editMultiple(Map data, List<File> files) async {
    var response = await crud.addRequestWithMultipleFiles(AppLink.itemsedit, data, files);
    return response.fold((l) => l, (r) => r);
  }
}