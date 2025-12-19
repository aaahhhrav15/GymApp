import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'token_manager.dart';

class AttendanceService {
  static Future<Map<String, dynamic>> markAttendance(String gymCode) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = '${ApiService.baseUrl}attendance/mark/$gymCode';
    final res = await http.post(Uri.parse(url), headers: headers);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return {'success': true, 'data': json.decode(res.body)};
    }
    return {'success': false, 'error': res.body};
  }
}


