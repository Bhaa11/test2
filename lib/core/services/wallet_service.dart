import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../linkapi.dart';


class WalletService {

  static Future<Map<String, dynamic>> getWalletData(int userId) async {
    try {
      final response = await http.post(
        Uri.parse(AppLink.walletGet),
        body: {'userid': userId.toString()},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'fail', 'message': 'خطأ في الخادم'};
      }
    } catch (e) {
      return {'status': 'fail', 'message': 'خطأ في الاتصال'};
    }
  }

  static Future<Map<String, dynamic>> depositMoney(int userId, double amount, String description) async {
    try {
      final response = await http.post(
        Uri.parse(AppLink.walletDeposit),
        body: {
          'userid': userId.toString(),
          'amount': amount.toString(),
          'description': description,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'fail', 'message': 'خطأ في الخادم'};
      }
    } catch (e) {
      return {'status': 'fail', 'message': 'خطأ في الاتصال'};
    }
  }

  static Future<Map<String, dynamic>> withdrawMoney(int userId, double amount, String description) async {
    try {
      final response = await http.post(
        Uri.parse(AppLink.walletWithdraw),
        body: {
          'userid': userId.toString(),
          'amount': amount.toString(),
          'description': description,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'fail', 'message': 'خطأ في الخادم'};
      }
    } catch (e) {
      return {'status': 'fail', 'message': 'خطأ في الاتصال'};
    }
  }

  static Future<Map<String, dynamic>> getTransactions(int userId) async {
    try {
      final response = await http.post(
        Uri.parse(AppLink.walletTransactions),
        body: {'userid': userId.toString()},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'fail', 'message': 'خطأ في الخادم'};
      }
    } catch (e) {
      return {'status': 'fail', 'message': 'خطأ في الاتصال'};
    }
  }
}
