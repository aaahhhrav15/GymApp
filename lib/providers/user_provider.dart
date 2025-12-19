import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';
import '../services/token_manager.dart';
import '../services/aws_service.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isUpdating = false;
  String _errorMessage = '';

  // Edit form variables
  String _editName = '';
  String _editPhone = '';
  double? _editWeight;
  double? _editHeight;
  XFile? _selectedProfileImage;

  final AwsService _awsService = AwsService();

  // Backend configuration
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://65.0.5.24/';
  static const String _usersEndpoint = 'users/';

  // Getters
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String get errorMessage => _errorMessage;

  // Edit form getters
  String get editName => _editName;
  String get editPhone => _editPhone;
  double? get editWeight => _editWeight;
  double? get editHeight => _editHeight;
  XFile? get selectedProfileImage => _selectedProfileImage;

  // Initialize the provider
  Future<void> initialize() async {
    await fetchUserProfile();
  }

  // Fetch user profile from backend
  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final headers = await TokenManager.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${baseUrl}${_usersEndpoint}me'),
        headers: headers,
      );

      debugPrint('User Profile Response Status: ${response.statusCode}');
      debugPrint('User Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userProfile = UserProfile.fromJson(data);
        _initializeEditForm();
      } else {
        _errorMessage = 'Failed to fetch profile: ${response.statusCode}';
        debugPrint('Failed to fetch user profile: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'Error fetching profile: $e';
      debugPrint('Error fetching user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize edit form with current user data
  void _initializeEditForm() {
    if (_userProfile != null) {
      _editName = _userProfile!.name;
      _editPhone = _userProfile!.phone;
      _editWeight = _userProfile!.weight;
      _editHeight = _userProfile!.height;
    }
  }

  // Update edit form fields
  void updateEditName(String value) {
    _editName = value;
    notifyListeners();
  }

  void updateEditPhone(String value) {
    _editPhone = value;
    notifyListeners();
  }

  void updateEditWeight(double? value) {
    _editWeight = value;
    notifyListeners();
  }

  void updateEditHeight(double? value) {
    _editHeight = value;
    notifyListeners();
  }

  // Pick profile image from camera
  Future<void> pickProfileImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedProfileImage = image;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking profile image from camera: $e');
    }
  }

  // Pick profile image from gallery
  Future<void> pickProfileImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedProfileImage = image;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking profile image from gallery: $e');
    }
  }

  // Remove selected profile image
  void removeSelectedProfileImage() {
    _selectedProfileImage = null;
    notifyListeners();
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile() async {
    _isUpdating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      Map<String, dynamic> updateData = {};

      // Add fields that have changed
      if (_editName.trim() != _userProfile?.name) {
        updateData['name'] = _editName.trim();
      }

      if (_editPhone.trim() != _userProfile?.phone) {
        updateData['phone'] = _editPhone.trim();
      }

      if (_editWeight != _userProfile?.weight) {
        updateData['weight'] = _editWeight;
      }

      if (_editHeight != _userProfile?.height) {
        updateData['height'] = _editHeight;
      }

      // Handle profile image upload if selected
      if (_selectedProfileImage != null) {
        debugPrint('UserProvider: Uploading profile image to S3...');

        final s3Result = await _awsService.uploadFileToS3(
          file: _selectedProfileImage!,
          folder: 'profile-images',
          contentType: 'image/jpeg',
        );

        if (s3Result['success']) {
          updateData['profileImage'] = s3Result['s3Key'];
          debugPrint(
              'UserProvider: Profile image uploaded successfully: ${s3Result['s3Key']}');
        } else {
          return {
            'success': false,
            'error': 'Failed to upload profile image: ${s3Result['error']}',
          };
        }
      }

      // If nothing to update
      if (updateData.isEmpty) {
        return {
          'success': false,
          'error': 'No changes to update',
        };
      }

      debugPrint('UserProvider: Updating profile with data: $updateData');

      // Send update request to backend
      final headers = await TokenManager.getAuthHeaders();
      final response = await http.patch(
        Uri.parse('${baseUrl}${_usersEndpoint}update'),
        headers: headers,
        body: jsonEncode(updateData),
      );

      debugPrint('Profile Update Response Status: ${response.statusCode}');
      debugPrint('Profile Update Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userProfile = UserProfile.fromJson(data);
        _selectedProfileImage = null; // Clear selected image
        _initializeEditForm(); // Reinitialize form with updated data

        // Update TokenManager with the new user data
        await TokenManager.updateUserData(_userProfile!.toJson());
        debugPrint('UserProvider: TokenManager updated with new user data');

        return {
          'success': true,
          'message': 'Profile updated successfully',
        };
      } else {
        return {
          'success': false,
          'error':
              'Failed to update profile: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return {
        'success': false,
        'error': 'Update failed: $e',
      };
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Reset edit form to current profile data
  void resetEditForm() {
    _initializeEditForm();
    _selectedProfileImage = null;
    notifyListeners();
  }

  // Check if there are unsaved changes
  bool get hasUnsavedChanges {
    if (_userProfile == null) return false;

    return _editName.trim() != _userProfile!.name ||
        _editPhone.trim() != _userProfile!.phone ||
        _editWeight != _userProfile!.weight ||
        _editHeight != _userProfile!.height ||
        _selectedProfileImage != null;
  }

  // Clear all data
  void clearData() {
    _userProfile = null;
    _selectedProfileImage = null;
    _errorMessage = '';
    _editName = '';
    _editPhone = '';
    _editWeight = null;
    _editHeight = null;
    notifyListeners();
  }
}
