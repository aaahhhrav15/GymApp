import 'dart:developer';
import '../services/api_service.dart';
import '../services/token_manager.dart';

class AuthDebug {
  static Future<void> debugTokenStatus() async {
    final token = await TokenManager.getToken();
    final isLoggedIn = await TokenManager.isLoggedIn();
    final userData = await TokenManager.getUserData();

    log('=== AUTH DEBUG ===');
    log('Token: ${token?.substring(0, 20) ?? 'null'}...');
    log('Is Logged In: $isLoggedIn');
    log('User Data: $userData');
    log('Base URL: ${ApiService.baseUrl}');
    log('==================');
  }

  static Future<void> testConnection() async {
    final canConnect = await ApiService.testConnection();
    log('=== CONNECTION DEBUG ===');
    log('Can connect to backend: $canConnect');
    log('Testing URL: ${ApiService.baseUrl}health');
    log('========================');
  }

  static Future<void> testHeaders() async {
    final headers = await ApiService.getHeaders();
    log('=== HEADERS DEBUG ===');
    log('Headers: $headers');
    log('====================');
  }
}
