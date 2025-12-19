// lib/services/notifications_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationsService {
  static final NotificationsService _instance = NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  // Get all notifications for the user
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await ApiService.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}notifications?page=$page&limit=$limit'),
        headers: headers,
      );

      final result = await ApiService.handleResponse(response);

      if (result['success']) {
        final data = result['data'];
        final List<dynamic> notificationsJson = data['notifications'] ?? [];
        
        return notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(result['error'] ?? 'Failed to fetch notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final headers = await ApiService.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}notifications/unread-count'),
        headers: headers,
      );

      final result = await ApiService.handleResponse(response);

      if (result['success']) {
        final data = result['data'];
        return data['unreadCount'] ?? 0;
      } else {
        throw Exception(result['error'] ?? 'Failed to fetch unread count');
      }
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0; // Return 0 on error to avoid breaking the UI
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final headers = await ApiService.getHeaders();
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}notifications/$notificationId/read'),
        headers: headers,
      );

      final result = await ApiService.handleResponse(response);
      return result['success'];
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final headers = await ApiService.getHeaders();
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}notifications/mark-all-read'),
        headers: headers,
      );

      final result = await ApiService.handleResponse(response);
      return result['success'];
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete notification (only personal notifications)
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final headers = await ApiService.getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}notifications/$notificationId'),
        headers: headers,
      );

      final result = await ApiService.handleResponse(response);
      return result['success'];
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Get notifications with pagination info
  Future<Map<String, dynamic>> getNotificationsWithPagination({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await ApiService.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}notifications?page=$page&limit=$limit'),
        headers: headers,
      );

      final result = await ApiService.handleResponse(response);

      if (result['success']) {
        final data = result['data'];
        final List<dynamic> notificationsJson = data['notifications'] ?? [];
        
        return {
          'notifications': notificationsJson
              .map((json) => NotificationModel.fromJson(json))
              .toList(),
          'totalPages': data['totalPages'] ?? 1,
          'currentPage': data['currentPage'] ?? 1,
          'unreadCount': data['unreadCount'] ?? 0,
        };
      } else {
        throw Exception(result['error'] ?? 'Failed to fetch notifications');
      }
    } catch (e) {
      print('Error fetching notifications with pagination: $e');
      throw Exception('Failed to fetch notifications: $e');
    }
  }
}
