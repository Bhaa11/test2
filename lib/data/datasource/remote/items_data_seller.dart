import 'dart:io';
import '../../../../core/class/crud.dart';
import '../../../../linkapi.dart';

class ItemsDataSeller {
  Crud crud;
  ItemsDataSeller(this.crud);

  get(String sellerId) async {
    var response = await crud.postData(AppLink.itemsview, {
      "seller_id": sellerId
    });
    return response.fold((l) => l, (r) => r);
  }

  add(Map data, File file) async {
    var response = await crud.addRequestWithImageOne(AppLink.citemsadd, data, file);
    return response.fold((l) => l, (r) => r);
  }

  // دالة جديدة لرفع ملفات متعددة
  addMultiple(Map data, List<File> files) async {
    var response = await crud.addRequestWithMultipleFiles(AppLink.citemsadd, data, files);
    return response.fold((l) => l, (r) => r);
  }

  delete(Map data) async {
    var response = await crud.postData(AppLink.itemsdelete, data);
    return response.fold((l) => l, (r) => r);
  }

  edit(Map data, [File? file]) async {
    var response;
    if (file == null) {
      response = await crud.postData(AppLink.itemsedit, data);
    } else {
      response = await crud.addRequestWithImageOne(AppLink.itemsedit, data, file);
    }
    return response.fold((l) => l, (r) => r);
  }

  // دالة جديدة لتعديل مع ملفات متعددة
  editMultiple(Map data, List<File> files) async {
    var response = await crud.addRequestWithMultipleFiles(AppLink.itemsedit, data, files);
    return response.fold((l) => l, (r) => r);
  }
}
