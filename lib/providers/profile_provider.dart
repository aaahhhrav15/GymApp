import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gym_app_2/models/user_model.dart';
import 'package:gym_app_2/services/profile_service.dart';
import '../services/aws_service.dart';
import '../services/token_manager.dart';
import '../services/connectivity_service.dart';

class ProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;

  // Edit form variables
  String _editName = '';
  String _editPhone = '';
  double? _editWeight;
  double? _editHeight;
  DateTime? _editBirthday;
  String? _editGender;
  XFile? _selectedProfileImage;

  final AwsService _awsService = AwsService();
  final ConnectivityService _connectivityService = ConnectivityService();

  // Flag to track if we've loaded data from local storage
  bool _loadedFromLocalStorage = false;

  // Sync status tracking
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  String? _syncError;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  bool get hasError => _error != null;

  // Sync status getters
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get syncError => _syncError;
  bool get isOnline => _connectivityService.isConnected;

  // Edit form getters
  String get editName => _editName;
  String get editPhone => _editPhone;
  double? get editWeight => _editWeight;
  double? get editHeight => _editHeight;
  DateTime? get editBirthday => _editBirthday;
  String? get editGender => _editGender;
  XFile? get selectedProfileImage => _selectedProfileImage;

  /// Fetch user profile data with connectivity-aware strategy
  /// - When online: Always try backend first, fallback to local if API fails
  /// - When offline: Use local data only
  /// - Force refresh: Always try backend regardless of connectivity
  Future<void> fetchUserProfile({bool forceRefresh = false}) async {
    _isLoading = true;
    _isSyncing = true;
    _error = null;
    _syncError = null;
    notifyListeners();

    try {
      final isConnected = _connectivityService.isConnected;
      debugPrint('ProfileProvider: Connectivity status: $isConnected');

      // Strategy 1: If offline and not forced, use local data only
      if (!isConnected && !forceRefresh) {
        await _loadFromLocalStorage();
        if (_userProfile != null) {
          debugPrint('ProfileProvider: Using local data (offline mode)');
          _syncError = 'Offline - showing cached data';
          return;
        } else {
          throw Exception(
              'No internet connection and no cached data available');
        }
      }

      // Strategy 2: If online or forced, try backend first
      if (isConnected || forceRefresh) {
        try {
          debugPrint('ProfileProvider: Fetching fresh data from backend API');
          _userProfile = await ProfileService.getUserProfile();

          // Success: Update local storage with fresh backend data
          if (_userProfile != null) {
            await TokenManager.updateUserData(_userProfile!.toJson());
            _lastSyncTime = DateTime.now();
            debugPrint('ProfileProvider: Successfully synced with backend');
          }

          _initializeEditForm();
          _error = null;
          _syncError = null;
          return;
        } catch (apiError) {
          debugPrint('ProfileProvider: Backend API failed: $apiError');
          _syncError = 'Sync failed: ${apiError.toString()}';

          // Check if it's an authentication error
          if (apiError.toString().contains('401') ||
              apiError.toString().contains('Unauthorized')) {
            await _handleAuthError();
            return;
          }

          // If forced refresh fails, don't fallback to local data
          if (forceRefresh) {
            throw apiError;
          }

          // Fallback to local data if available
          await _loadFromLocalStorage();
          if (_userProfile != null) {
            debugPrint('ProfileProvider: Using cached data after API failure');
            _syncError = 'Using cached data - sync failed';
            return;
          } else {
            throw Exception('Backend failed and no cached data available');
          }
        }
      }

      // Strategy 3: Final fallback - load from local storage
      await _loadFromLocalStorage();
      if (_userProfile == null) {
        throw Exception('No profile data available');
      }
    } catch (e) {
      _error = e.toString();
      _syncError = e.toString();
      debugPrint('ProfileProvider: Error fetching profile: $_error');
      _userProfile = null;
    } finally {
      _isLoading = false;
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Internal method to load data from local storage
  Future<void> _loadFromLocalStorage() async {
    final userData = await TokenManager.getUserData();
    if (userData != null) {
      _userProfile = UserProfile.fromJson(userData);
      _initializeEditForm();
      debugPrint('ProfileProvider: Loaded profile from local storage');
    }
  }

  /// Load user profile directly from local storage (TokenManager) without API call
  /// This provides fast initial data loading for UI rendering
  Future<void> loadFromLocalStorage() async {
    if (_loadedFromLocalStorage) return; // Avoid duplicate loading

    try {
      final userData = await TokenManager.getUserData();
      if (userData != null) {
        _userProfile = UserProfile.fromJson(userData);
        _initializeEditForm();
        _loadedFromLocalStorage = true;
        notifyListeners();
        debugPrint(
            'ProfileProvider: Loaded user data from TokenManager local storage');
      }
    } catch (e) {
      debugPrint(
          'ProfileProvider: Error loading from local storage: ${e.toString()}');
    }
  }

  /// Normalize birthday to local midnight (date-only, no time component)
  /// This prevents timezone issues when dates are stored/loaded
  /// Creates a date in local timezone at midnight
  static DateTime _normalizeBirthday(DateTime date) {
    // If date is already in local timezone, extract components directly
    // Otherwise convert to local first
    final local = date.isUtc ? date.toLocal() : date;
    // Create new DateTime in local timezone at midnight
    return DateTime(local.year, local.month, local.day);
  }

  /// Handle authentication error by clearing data
  Future<void> _handleAuthError() async {
    try {
      // Clear profile data
      clearProfile();

      // Clear token and user data
      await TokenManager.clearToken();

      print('Authentication error - user data cleared');
    } catch (e) {
      print('Error handling auth error: $e');
    }
  }

  /// Initialize edit form with current user data
  void _initializeEditForm() {
    if (_userProfile != null) {
      _editName = _userProfile!.name;
      _editPhone = _userProfile!.phone;
      _editWeight = _userProfile!.weight;
      _editHeight = _userProfile!.height;
      // Birthday is already normalized in UserProfile.fromJson, so use it directly
      _editBirthday = _userProfile!.birthday;
      _editGender = _userProfile!.gender;
    }
  }

  /// Update edit form fields
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

  void updateEditBirthday(DateTime? value) {
    // Normalize birthday to local midnight when setting
    _editBirthday = value != null ? _normalizeBirthday(value) : null;
    notifyListeners();
  }

  void updateEditGender(String? value) {
    _editGender = value;
    notifyListeners();
  }

  /// Pick profile image from camera
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

  /// Pick profile image from gallery
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

  /// Remove selected profile image
  void removeSelectedProfileImage() {
    _selectedProfileImage = null;
    notifyListeners();
  }

  /// Update user profile with connectivity-aware strategy
  /// - Always requires internet connection for updates
  /// - Updates backend first, then local storage
  /// - Provides clear feedback about connectivity and sync status
  Future<Map<String, dynamic>> updateProfile() async {
    _isUpdating = true;
    _isSyncing = true;
    _error = null;
    _syncError = null;
    notifyListeners();

    try {
      // Check internet connectivity first
      final isConnected = _connectivityService.isConnected;
      if (!isConnected) {
        return {
          'success': false,
          'error':
              'No internet connection. Profile updates require an active internet connection.',
          'requiresInternet': true,
        };
      }

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

      if (_editBirthday != _userProfile?.birthday) {
        // Send birthday as UTC date at midnight to avoid timezone conversion issues
        // This ensures the date remains the same regardless of timezone
        if (_editBirthday != null) {
          final normalized = _normalizeBirthday(_editBirthday!);
          // Create UTC date at midnight for the selected date
          final utcDate = DateTime.utc(normalized.year, normalized.month, normalized.day);
          updateData['birthday'] = utcDate.toIso8601String();
        } else {
          updateData['birthday'] = null;
        }
      }

      if (_editGender != _userProfile?.gender) {
        updateData['gender'] = _editGender;
      }

      // Handle profile image upload if selected
      if (_selectedProfileImage != null) {
        debugPrint('ProfileProvider: Uploading profile image to S3...');

        final s3Result = await _awsService.uploadFileToS3(
          file: _selectedProfileImage!,
          folder: 'profile-images',
          contentType: 'image/jpeg',
        );

        if (s3Result['success']) {
          updateData['profileImage'] = s3Result['s3Key'];
          debugPrint(
              'ProfileProvider: Profile image uploaded successfully: ${s3Result['s3Key']}');
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

      debugPrint('ProfileProvider: Updating profile with data: $updateData');

      // CRITICAL: Update backend first, only then update local storage
      final result = await ProfileService.updateUserProfile(updateData);

      if (result['success']) {
        // Backend update successful - now update local data
        _userProfile = UserProfile.fromJson(result['data']);
        _selectedProfileImage = null; // Clear selected image
        _initializeEditForm(); // Reinitialize form with updated data

        // Update local storage with the fresh backend data
        await TokenManager.updateUserData(_userProfile!.toJson());
        _lastSyncTime = DateTime.now();
        _syncError = null;

        debugPrint(
            'ProfileProvider: Profile updated successfully - backend and local storage synced');

        return {
          'success': true,
          'message': 'Profile updated successfully',
        };
      } else {
        // Backend update failed
        _syncError = 'Update failed: ${result['error'] ?? 'Unknown error'}';

        // Check if it's an authentication error
        if (result['authError'] == true) {
          await _handleAuthError();
        }

        return result;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _syncError = 'Update failed: $e';

      return {
        'success': false,
        'error': 'Update failed: $e',
      };
    } finally {
      _isUpdating = false;
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Reset edit form to current profile data
  void resetEditForm() {
    _initializeEditForm();
    _selectedProfileImage = null;
    notifyListeners();
  }

  /// Check if there are unsaved changes
  bool get hasUnsavedChanges {
    if (_userProfile == null) return false;

    // Compare birthdays by date components (year, month, day) to handle timezone normalization
    bool birthdayChanged = false;
    if (_editBirthday != null && _userProfile!.birthday != null) {
      birthdayChanged = _editBirthday!.year != _userProfile!.birthday!.year ||
          _editBirthday!.month != _userProfile!.birthday!.month ||
          _editBirthday!.day != _userProfile!.birthday!.day;
    } else {
      birthdayChanged = _editBirthday != _userProfile!.birthday;
    }

    return _editName.trim() != _userProfile!.name ||
        _editPhone.trim() != _userProfile!.phone ||
        _editWeight != _userProfile!.weight ||
        _editHeight != _userProfile!.height ||
        birthdayChanged ||
        _editGender != _userProfile!.gender ||
        _selectedProfileImage != null;
  }

  /// Refresh user profile data from backend API
  Future<void> refreshProfile() async {
    debugPrint('ProfileProvider: Force refreshing user data from backend');
    await fetchUserProfile(forceRefresh: true);
  }

  /// Manually sync with backend - useful for pull-to-refresh functionality
  Future<bool> syncWithBackend() async {
    if (!_connectivityService.isConnected) {
      _syncError = 'No internet connection available for sync';
      notifyListeners();
      return false;
    }

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      debugPrint('ProfileProvider: Manual sync with backend initiated');

      final freshProfile = await ProfileService.getUserProfile();
      if (freshProfile != null) {
        _userProfile = freshProfile;
        await TokenManager.updateUserData(_userProfile!.toJson());
        _initializeEditForm();
        _lastSyncTime = DateTime.now();
        _syncError = null;

        debugPrint('ProfileProvider: Manual sync completed successfully');
        return true;
      }
      return false;
    } catch (e) {
      _syncError = 'Sync failed: $e';
      debugPrint('ProfileProvider: Manual sync failed: $e');

      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        await _handleAuthError();
      }

      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Check if data needs syncing (based on last sync time)
  bool get needsSync {
    if (_lastSyncTime == null) return true;
    final timeSinceSync = DateTime.now().difference(_lastSyncTime!);
    return timeSinceSync.inMinutes > 5; // Consider data stale after 5 minutes
  }

  /// Clear profile data (for logout)
  void clearProfile() {
    _userProfile = null;
    _selectedProfileImage = null;
    _error = null;
    _syncError = null;
    _editName = '';
    _editPhone = '';
    _editWeight = null;
    _editHeight = null;
    _editBirthday = null;
    _editGender = null;
    _isLoading = false;
    _isUpdating = false;
    _isSyncing = false;
    _lastSyncTime = null;
    _loadedFromLocalStorage = false;
    notifyListeners();
  }

  /// Get sync status for UI display
  String get syncStatus {
    if (_isSyncing) return 'Syncing...';
    if (_syncError != null) return _syncError!;
    if (!_connectivityService.isConnected) return 'Offline';
    if (_lastSyncTime != null) {
      final timeSinceSync = DateTime.now().difference(_lastSyncTime!);
      if (timeSinceSync.inMinutes < 1) return 'Just synced';
      if (timeSinceSync.inMinutes < 60)
        return 'Synced ${timeSinceSync.inMinutes}m ago';
      if (timeSinceSync.inHours < 24)
        return 'Synced ${timeSinceSync.inHours}h ago';
      return 'Synced ${timeSinceSync.inDays}d ago';
    }
    return 'Not synced';
  }

  /// Check if profile data is potentially stale
  bool get isDataStale {
    if (!_connectivityService.isConnected) return false; // Can't sync anyway
    return needsSync || _syncError != null;
  }
}
