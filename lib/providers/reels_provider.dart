import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../models/reel_model.dart';
import '../services/reels_service.dart';
import '../services/moderation_service.dart';

class ReelsProvider with ChangeNotifier {
  final ReelsService _reelsService = ReelsService();
  List<ReelModel> _reels = [];
  List<ReelModel> _originalReels = []; // Keep original order
  List<String> _viewedReelIds = []; // Track viewed reels
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentIndex = 0;

  static const String _lastReelIndexKey = 'last_reel_index';
  static const String _hasViewedReelsKey = 'has_viewed_reels_before';
  static const String _viewedReelIdsKey = 'viewed_reel_ids';
  static const String _lastShuffleTimeKey = 'last_shuffle_time';

  // Getters
  List<ReelModel> get reels => _reels;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  int get currentIndex => _currentIndex;

  // Set current reel index
  void setCurrentIndex(int index) {
    _currentIndex = index;
    _saveLastReelIndex(index);
    
    // Track viewed reel
    if (index >= 0 && index < _reels.length) {
      final reelId = _reels[index].id;
      if (!_viewedReelIds.contains(reelId)) {
        _viewedReelIds.add(reelId);
        _saveViewedReelIds();
      }
    }
    
    notifyListeners();
  }

  // Save last viewed reel index to SharedPreferences
  Future<void> _saveLastReelIndex(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastReelIndexKey, index);
      await prefs.setBool(_hasViewedReelsKey, true);
    } catch (e) {
      debugPrint('Error saving last reel index: $e');
    }
  }

  // Get last viewed reel index from SharedPreferences
  Future<int> _getLastReelIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_lastReelIndexKey) ?? 0;
    } catch (e) {
      debugPrint('Error getting last reel index: $e');
      return 0;
    }
  }

  // Check if user has viewed reels before
  Future<bool> _hasViewedReelsBefore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasViewedReelsKey) ?? false;
    } catch (e) {
      debugPrint('Error checking if user has viewed reels before: $e');
      return false;
    }
  }

  // Save viewed reel IDs to SharedPreferences
  Future<void> _saveViewedReelIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_viewedReelIdsKey, _viewedReelIds);
    } catch (e) {
      debugPrint('Error saving viewed reel IDs: $e');
    }
  }

  // Load viewed reel IDs from SharedPreferences
  Future<void> _loadViewedReelIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _viewedReelIds = prefs.getStringList(_viewedReelIdsKey) ?? [];
    } catch (e) {
      debugPrint('Error loading viewed reel IDs: $e');
      _viewedReelIds = [];
    }
  }

  // Save last shuffle time
  Future<void> _saveLastShuffleTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastShuffleTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error saving last shuffle time: $e');
    }
  }

  // Get last shuffle time
  Future<int> _getLastShuffleTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_lastShuffleTimeKey) ?? 0;
    } catch (e) {
      debugPrint('Error getting last shuffle time: $e');
      return 0;
    }
  }

  // Shuffle reels to provide variety
  Future<void> _shuffleReelsIfNeeded() async {
    if (_reels.isEmpty) return;

    final lastShuffleTime = await _getLastShuffleTime();
    final now = DateTime.now().millisecondsSinceEpoch;
    const shuffleInterval = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

    // Shuffle if it's been more than 24 hours or if we've viewed most reels
    final shouldShuffle = (now - lastShuffleTime) > shuffleInterval ||
        _viewedReelIds.length >= (_reels.length * 0.7); // 70% viewed

    if (shouldShuffle) {
      debugPrint('Shuffling reels for variety');
      _reels.shuffle(Random());
      _viewedReelIds.clear(); // Reset viewed reels after shuffle
      await _saveViewedReelIds();
      await _saveLastShuffleTime();
    }
  }

  // Get initial reel index (resume or random)
  Future<int> getInitialReelIndex() async {
    await _loadViewedReelIds();
    await _shuffleReelsIfNeeded();

    final hasViewedBefore = await _hasViewedReelsBefore();

    if (!hasViewedBefore && _reels.isNotEmpty) {
      // First time user - show random reel
      final random = Random();
      final randomIndex = random.nextInt(_reels.length);
      debugPrint(
          'First time user - showing random reel at index: $randomIndex');
      return randomIndex;
    } else {
      // Returning user - show random unviewed reel if available, otherwise random
      final unviewedReels = <int>[];
      for (int i = 0; i < _reels.length; i++) {
        if (!_viewedReelIds.contains(_reels[i].id)) {
          unviewedReels.add(i);
        }
      }

      if (unviewedReels.isNotEmpty) {
        // Show random unviewed reel
        final random = Random();
        final randomUnviewedIndex = unviewedReels[random.nextInt(unviewedReels.length)];
        debugPrint('Returning user - showing random unviewed reel at index: $randomUnviewedIndex');
        return randomUnviewedIndex;
      } else {
        // All reels viewed, show random reel
        final random = Random();
        final randomIndex = random.nextInt(_reels.length);
        debugPrint('All reels viewed - showing random reel at index: $randomIndex');
        return randomIndex;
      }
    }
  }

  // Delete reel
  Future<bool> deleteReel(String reelId) async {
    try {
      final success = await ReelsService.deleteReel(reelId);
      if (success) {
        _reels.removeWhere((reel) => reel.id == reelId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error deleting reel: $e');
      return false;
    }
  }

  // Fetch reels from backend API
  Future<void> fetchReels({bool isRefresh = false}) async {
    if (isRefresh) {
      _reels.clear();
    }

    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final List<ReelModel> fetchedReels = await _reelsService.fetchReels();

      // Filter out blocked/reported content
      final filteredReels = <ReelModel>[];
      for (final reel in fetchedReels) {
        final shouldHide = await ModerationService.shouldHideContent(
          contentType: 'reel',
          contentId: reel.id,
          userId: reel.gymId, // Use gymId instead of customerId for gym-based content
        );

        if (!shouldHide) {
          filteredReels.add(reel);
        }
      }

      if (isRefresh) {
        _reels = filteredReels;
        _originalReels = List.from(filteredReels); // Keep original order
      } else {
        _reels.addAll(filteredReels);
        _originalReels.addAll(filteredReels); // Keep original order
      }

      _hasError = false;
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      debugPrint('Error fetching reels: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh reels
  Future<void> refreshReels() async {
    await fetchReels(isRefresh: true);
  }

  // Manually shuffle reels
  Future<void> shuffleReels() async {
    if (_reels.isEmpty) return;
    
    debugPrint('Manually shuffling reels');
    _reels.shuffle(Random());
    _viewedReelIds.clear();
    _currentIndex = 0;
    await _saveViewedReelIds();
    await _saveLastShuffleTime();
    notifyListeners();
  }

  // Reset to original order
  void resetToOriginalOrder() {
    if (_originalReels.isNotEmpty) {
      _reels = List.from(_originalReels);
      _currentIndex = 0;
      notifyListeners();
    }
  }

  // Clear all data
  void clearData() {
    _reels.clear();
    _originalReels.clear();
    _viewedReelIds.clear();
    _currentIndex = 0;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  // Get reel at specific index
  ReelModel? getReelAt(int index) {
    if (index >= 0 && index < _reels.length) {
      return _reels[index];
    }
    return null;
  }
}
