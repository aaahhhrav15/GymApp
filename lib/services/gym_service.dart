import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'token_manager.dart';

class GymService {
  static Future<Map<String, dynamic>?> fetchUserGym() async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      final url = '${ApiService.baseUrl}gyms/fetch';
      final res = await http.get(Uri.parse(url), headers: headers);
      if (kDebugMode) {
        print('GymService GET /gyms/fetch -> ${res.statusCode}');
      }
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('GymService error: $e');
      }
      return null;
    }
  }
}


