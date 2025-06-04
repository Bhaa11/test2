import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:path/path.dart';
import '../../../../core/class/statusrequest.dart';
import '../../../../core/functions/checkinternet.dart';
import 'package:http/http.dart' as http;

String _basicAuth = 'Basic ${base64Encode(utf8.encode('dddd:sdfsdfsdfsdfsdf'))}';
Map<String, String> _myheaders = {
  'authorization': _basicAuth
};

class Crud {
  // دالة POST عادية بدون ملفات
  Future<Either<StatusRequest, Map>> postData(String linkurl, Map data) async {
    try {
      if (await checkInternet()) {
        var response = await http.post(
          Uri.parse(linkurl),
          body: data,
          headers: _myheaders,
        );
        print(response.statusCode);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          print(responsebody);
          return Right(responsebody);
        } else {
          return const Left(StatusRequest.serverfailure);
        }
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } catch (_) {
      return const Left(StatusRequest.serverfailure);
    }
  }

  // دالة POST مع ملف واحد (للملف الشخصي)
  Future<Either<StatusRequest, Map>> postRequestWithFile(
      String url,
      Map data,
      File? file,
      [String? namerequest]
      ) async {
    try {
      if (await checkInternet()) {
        namerequest ??= "files";
        var uri = Uri.parse(url);
        var request = http.MultipartRequest("POST", uri);
        request.headers.addAll(_myheaders);

        // إضافة الملف إذا كان موجوداً
        if (file != null) {
          var length = await file.length();
          var stream = http.ByteStream(file.openRead());
          var multipartFile = http.MultipartFile(
              namerequest,
              stream,
              length,
              filename: basename(file.path)
          );
          request.files.add(multipartFile);
        }

        // إضافة البيانات
        data.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        var myrequest = await request.send();
        var response = await http.Response.fromStream(myrequest);

        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          return Right(responsebody);
        } else {
          return const Left(StatusRequest.serverfailure);
        }
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } catch (e) {
      print("Error in postRequestWithFile: $e");
      return const Left(StatusRequest.serverfailure);
    }
  }

  // دالة POST مع ملف واحد (الاسم القديم للتوافق)
  Future<Either<StatusRequest, Map>> addRequestWithImageOne(
      String url,
      Map data,
      File? image,
      [String? namerequest]
      ) async {
    return await postRequestWithFile(url, data, image, namerequest);
  }

  // دالة POST مع ملفات متعددة
  Future<Either<StatusRequest, Map>> addRequestWithMultipleFiles(
      String url,
      Map data,
      List<File> files,
      [String? namerequest]
      ) async {
    try {
      if (await checkInternet()) {
        namerequest ??= "files";
        var uri = Uri.parse(url);
        var request = http.MultipartRequest("POST", uri);
        request.headers.addAll(_myheaders);

        // إضافة جميع الملفات
        for (int i = 0; i < files.length; i++) {
          File file = files[i];
          var length = await file.length();
          var stream = http.ByteStream(file.openRead());
          var multipartFile = http.MultipartFile(
              "${namerequest}_$i",
              stream,
              length,
              filename: basename(file.path)
          );
          request.files.add(multipartFile);
        }

        // إضافة البيانات
        data.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        var myrequest = await request.send();
        var response = await http.Response.fromStream(myrequest);

        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          return Right(responsebody);
        } else {
          return const Left(StatusRequest.serverfailure);
        }
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } catch (e) {
      print("Error in addRequestWithMultipleFiles: $e");
      return const Left(StatusRequest.serverfailure);
    }
  }

  // دالة POST مع ملفات متعددة بأسماء مختلفة
  Future<Either<StatusRequest, Map>> postRequestWithMultipleFiles(
      String url,
      Map data,
      Map<String, File> files
      ) async {
    try {
      if (await checkInternet()) {
        var uri = Uri.parse(url);
        var request = http.MultipartRequest("POST", uri);
        request.headers.addAll(_myheaders);

        // إضافة الملفات بأسمائها المحددة
        for (String fieldName in files.keys) {
          File file = files[fieldName]!;
          var length = await file.length();
          var stream = http.ByteStream(file.openRead());
          var multipartFile = http.MultipartFile(
              fieldName,
              stream,
              length,
              filename: basename(file.path)
          );
          request.files.add(multipartFile);
        }

        // إضافة البيانات
        data.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        var myrequest = await request.send();
        var response = await http.Response.fromStream(myrequest);

        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          return Right(responsebody);
        } else {
          return const Left(StatusRequest.serverfailure);
        }
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } catch (e) {
      print("Error in postRequestWithMultipleFiles: $e");
      return const Left(StatusRequest.serverfailure);
    }
  }

  // دالة GET
  Future<Either<StatusRequest, Map>> getData(String linkurl) async {
    try {
      if (await checkInternet()) {
        var response = await http.get(
          Uri.parse(linkurl),
          headers: _myheaders,
        );
        print("GET Response Status Code: ${response.statusCode}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          print("GET Response Body: $responsebody");
          return Right(responsebody);
        } else {
          return const Left(StatusRequest.serverfailure);
        }
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } catch (e) {
      print("Error in getData: $e");
      return const Left(StatusRequest.serverfailure);
    }
  }

  // دالة PUT
  Future<Either<StatusRequest, Map>> putData(String linkurl, Map data) async {
    try {
      if (await checkInternet()) {
        var response = await http.put(
          Uri.parse(linkurl),
          body: data,
          headers: _myheaders,
        );
        print("PUT Response Status Code: ${response.statusCode}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          print("PUT Response Body: $responsebody");
          return Right(responsebody);
        } else {
          return const Left(StatusRequest.serverfailure);
        }
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } catch (e) {
      print("Error in putData: $e");
      return const Left(StatusRequest.serverfailure);
    }
  }

  // دالة DELETE
  Future<Either<StatusRequest, Map>> deleteData(String linkurl, Map data) async {
    try {
      if (await checkInternet()) {
        var response = await http.delete(
          Uri.parse(linkurl),
          body: data,
          headers: _myheaders,
        );
        print("DELETE Response Status Code: ${response.statusCode}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          print("DELETE Response Body: $responsebody");
          return Right(responsebody);
        } else {
          return const Left(StatusRequest.serverfailure);
        }
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } catch (e) {
      print("Error in deleteData: $e");
      return const Left(StatusRequest.serverfailure);
    }
  }
}
