import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import '../../linkapi.dart';

class OtpService {
  static const int _timeoutDuration = 30;

  Future<Map<String, dynamic>> checkUserExists(String phone) async {
    try {
      final response = await http.post(
        Uri.parse(AppLink.checkUser),
        body: {'phone': phone},
      ).timeout(Duration(seconds: _timeoutDuration));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('خطأ في الاتصال بالخادم (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('تحقق من الاتصال بالإنترنت');
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال');
    } on FormatException {
      throw Exception('خطأ في تحليل البيانات');
    } catch (e) {
      throw Exception('خطأ في فحص المستخدم: $e');
    }
  }

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse(AppLink.sendOtp),
        body: {'phone': phone},
      ).timeout(Duration(seconds: _timeoutDuration));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('خطأ في إرسال رمز التحقق (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('تحقق من الاتصال بالإنترنت');
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال');
    } on FormatException {
      throw Exception('خطأ في تحليل البيانات');
    } catch (e) {
      throw Exception('خطأ في إرسال رمز التحقق: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    try {
      final response = await http.post(
        Uri.parse(AppLink.verifyOtp),
        body: {
          'phone': phone,
          'code': code,
        },
      ).timeout(Duration(seconds: _timeoutDuration));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('خطأ في التحقق من الرمز (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('تحقق من الاتصال بالإنترنت');
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال');
    } on FormatException {
      throw Exception('خطأ في تحليل البيانات');
    } catch (e) {
      throw Exception('خطأ في التحقق من الرمز: $e');
    }
  }

  Future<Map<String, dynamic>> completeRegistration({
    required String phone,
    required String firstName,
    required String lastName,
    required bool isSeller,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppLink.completeRegistration),
        body: {
          'phone': phone,
          'firstName': firstName,
          'lastName': lastName,
          'isSeller': isSeller.toString(),
        },
      ).timeout(Duration(seconds: _timeoutDuration));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('خطأ في إكمال التسجيل (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('تحقق من الاتصال بالإنترنت');
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال');
    } on FormatException {
      throw Exception('خطأ في تحليل البيانات');
    } catch (e) {
      throw Exception('خطأ في إكمال التسجيل: $e');
    }
  }
}
