import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/token_manager.dart';
import 'dart:convert';

enum LoginState {
  initial,
  phoneInput,
  otpInput,
  loading,
  success,
  error,
}

class LoginProvider with ChangeNotifier {
  // State management
  LoginState _currentState = LoginState.phoneInput;
  String _phoneNumber = '';
  String _otp = '';
  String _errorMessage = '';
  int _otpTtl = 0;
  String _token = '';
  Map<String, dynamic> _user = {};

  // Getters
  LoginState get currentState => _currentState;
  String get phoneNumber => _phoneNumber;
  String get otp => _otp;
  String get errorMessage => _errorMessage;
  int get otpTtl => _otpTtl;
  String get token => _token;
  Map<String, dynamic> get user => _user;

  // Base URL for your backend API
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://65.0.5.24/';

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Initialize provider and check for existing token
  Future<void> initialize() async {
    try {
      final isLoggedIn = await TokenManager.isLoggedIn();

      if (isLoggedIn) {
        _token = await TokenManager.getToken() ?? '';
        _user = await TokenManager.getUserData() ?? {};
        _currentState = LoginState.success;
      } else {
        _currentState = LoginState.phoneInput;
      }

      notifyListeners();
    } catch (e) {
      _currentState = LoginState.phoneInput;
      notifyListeners();
    }
  }

  // Update phone number
  void updatePhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  // Update OTP
  void updateOtp(String otpValue) {
    _otp = otpValue;
    notifyListeners();
  }

  // Send OTP to phone number
  Future<bool> sendOtp() async {
    if (_phoneNumber.isEmpty) {
      _errorMessage = 'Please enter a phone number';
      notifyListeners();
      return false;
    }

    _currentState = LoginState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}auth/login-phone'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone': _phoneNumber,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['ok'] == true) {
        _otpTtl = data['ttl'] ?? 300;
        _currentState = LoginState.otpInput;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['error'] ?? 'Failed to send OTP';
        _currentState = LoginState.phoneInput;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error. Please check your connection.';
      _currentState = LoginState.phoneInput;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP and login
  Future<bool> verifyOtp() async {
    if (_otp.isEmpty) {
      _errorMessage = 'Please enter the OTP';
      notifyListeners();
      return false;
    }

    if (_otp.length != 6) {
      _errorMessage = 'OTP must be 6 digits';
      notifyListeners();
      return false;
    }

    _currentState = LoginState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone': _phoneNumber,
          'otp': _otp,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        _token = data['token'];
        _user = data['user'] ?? {};
        _currentState = LoginState.success;

        // Save token and user data to SharedPreferences
        await TokenManager.saveToken(token: _token, userData: _user);

        notifyListeners();
        return true;
      } else {
        _errorMessage = data['error'] ?? 'Invalid OTP';
        _currentState = LoginState.otpInput;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error. Please check your connection.';
      _currentState = LoginState.otpInput;
      notifyListeners();
      return false;
    }
  }

  // Reset to phone input state (go back from OTP input)
  void resetToPhoneInput() {
    _currentState = LoginState.phoneInput;
    _otp = '';
    _errorMessage = '';
    notifyListeners();
  }

  // Reset entire login state
  void resetLoginState() {
    _currentState = LoginState.phoneInput;
    _phoneNumber = '';
    _otp = '';
    _errorMessage = '';
    _otpTtl = 0;
    _token = '';
    _user = {};
    notifyListeners();
  }

  // Logout current user
  Future<void> logoutUser() async {
    await TokenManager.clearToken(); // Use TokenManager
    resetLoginState(); // Reset local state
  }

  // Format phone number for display
  String get formattedPhoneNumber {
    if (_phoneNumber.length >= 10) {
      final lastFour = _phoneNumber.substring(_phoneNumber.length - 4);
      final hidden = '*' * (_phoneNumber.length - 4);
      return '$hidden$lastFour';
    }
    return _phoneNumber;
  }

  // Check if phone number is valid
  bool get isPhoneNumberValid {
    if (_phoneNumber.isEmpty) return false;

    // Remove spaces, hyphens, and parentheses for validation
    String cleanedPhone = _phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it's a valid phone number (10-15 digits, optional + prefix)
    return RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(cleanedPhone);
  }

  // Check if OTP is valid
  bool get isOtpValid {
    return _otp.length == 6 && RegExp(r'^[0-9]{6}$').hasMatch(_otp);
  }

  // Get remaining OTP time (for countdown timer)
  String getOtpTimeRemaining(int secondsLeft) {
    final minutes = secondsLeft ~/ 60;
    final seconds = secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
