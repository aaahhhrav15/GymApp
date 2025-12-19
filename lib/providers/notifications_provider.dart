// lib/providers/notifications_provider.dart
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notifications_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsService _notificationsService = NotificationsService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isInitialized = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreData = false;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get hasMoreData {
    print('Getting hasMoreData: $_hasMoreData, notifications count: ${_notifications.length}');
    // TEMPORARY FIX: Always return false if we have notifications
    if (_notifications.isNotEmpty) {
      print('FORCING hasMoreData to false because we have ${_notifications.length} notifications');
      return false;
    }
    return _hasMoreData;
  }

  // Initialize notifications
  Future<void> initialize() async {
    print('=== INITIALIZE NOTIFICATIONS CALLED ===');
    if (_isInitialized) {
      print('Already initialized, returning');
      return;
    }

    print('Setting loading to true...');
    _isLoading = true;
    notifyListeners();

    try {
      print('Calling refreshNotifications...');
      await refreshNotifications();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing notifications: $e');
      // Still mark as initialized even if there's an error to prevent infinite loading
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh notifications (reload from first page)
  Future<void> refreshNotifications() async {
    print('=== REFRESH NOTIFICATIONS CALLED ===');
    try {
      print('Calling notifications service...');
      final result = await _notificationsService.getNotificationsWithPagination(
        page: 1,
        limit: 20,
      );
      print('Service returned result: ${result != null}');

      final notifications = result['notifications'] ?? [];
      _notifications = notifications;
      _unreadCount = result['unreadCount'] ?? 0;
      _currentPage = result['currentPage'] ?? 1;
      _totalPages = result['totalPages'] ?? 1;
      
      // Simple logic: if we got fewer notifications than the limit, we've reached the end
      final limit = 20;
      _hasMoreData = notifications.length >= limit;
      
      // TEMPORARY FIX: Force hasMoreData to false if we have notifications
      if (notifications.isNotEmpty) {
        _hasMoreData = false;
        print('FORCED hasMoreData to false because we have notifications');
      }

      print('=== NOTIFICATIONS DEBUG ===');
      print('Notifications received: ${notifications.length}');
      print('Unread count: $_unreadCount');
      print('Limit: $limit');
      print('hasMoreData will be: ${notifications.length >= limit}');
      print('Current _hasMoreData: $_hasMoreData');
      print('==========================');

      notifyListeners();
    } catch (e) {
      print('Error refreshing notifications: $e');
      // Try to at least update the unread count even if fetching notifications fails
      try {
        await updateUnreadCount();
      } catch (countError) {
        print('Error updating unread count after refresh failure: $countError');
      }
      // Don't rethrow to prevent breaking the UI
      // The error will be handled by the UI showing appropriate states
    }
  }

  // Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (!_hasMoreData || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _notificationsService.getNotificationsWithPagination(
        page: nextPage,
        limit: 20,
      );

      final newNotifications = result['notifications'] ?? [];
      _notifications.addAll(newNotifications);
      _unreadCount = result['unreadCount'] ?? _unreadCount;
      _currentPage = result['currentPage'] ?? nextPage;
      _totalPages = result['totalPages'] ?? _totalPages;
      
      // Simple logic: if we got fewer notifications than the limit, we've reached the end
      final limit = 20;
      _hasMoreData = newNotifications.length >= limit;

      notifyListeners();
    } catch (e) {
      print('Error loading more notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationsService.markAsRead(notificationId);
      if (success) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(read: true);
          if (_unreadCount > 0) {
            _unreadCount--;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final success = await _notificationsService.markAllAsRead();
      if (success) {
        // Update local state
        _notifications = _notifications
            .map((n) => n.copyWith(read: true))
            .toList();
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationsService.deleteNotification(notificationId);
      if (success) {
        // Remove from local state
        _notifications.removeWhere((n) => n.id == notificationId);
        
        // Update unread count if the deleted notification was unread
        final deletedNotification = _notifications.firstWhere(
          (n) => n.id == notificationId,
          orElse: () => NotificationModel(
            id: '',
            type: '',
            title: '',
            message: '',
            read: true,
            gymId: '',
            expiresAt: DateTime.now(),
            broadcast: false,
            createdAt: DateTime.now(),
          ),
        );
        
        if (!deletedNotification.read && _unreadCount > 0) {
          _unreadCount--;
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Update unread count (useful for periodic updates)
  Future<void> updateUnreadCount() async {
    try {
      final count = await _notificationsService.getUnreadCount();
      _unreadCount = count;
      notifyListeners();
    } catch (e) {
      print('Error updating unread count: $e');
      // Don't rethrow here as this is a background operation
    }
  }

  // Quick refresh - just update count without loading all notifications
  // This is faster and can be called more frequently
  Future<void> quickRefresh() async {
    try {
      await updateUnreadCount();
      print('Quick refresh completed - unread count: $_unreadCount');
    } catch (e) {
      print('Error in quick refresh: $e');
    }
  }

  // Clear all notifications (for logout)
  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    _isInitialized = false;
    _currentPage = 1;
    _totalPages = 1;
    _hasMoreData = false;
    notifyListeners();
  }

  // Force refresh notifications (reset state)
  Future<void> forceRefresh() async {
    print('=== FORCE REFRESH CALLED ===');
    _hasMoreData = false; // Reset to false
    _isInitialized = false; // Allow re-initialization
    notifyListeners();
    await initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
