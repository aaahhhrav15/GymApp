// lib/models/notification_model.dart
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool read;
  final String gymId;
  final String? userId;
  final DateTime expiresAt;
  final bool broadcast;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.gymId,
    this.userId,
    required this.expiresAt,
    required this.broadcast,
    this.actionUrl,
    this.metadata,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      // Helper function to safely convert to string
      String safeString(dynamic value) {
        if (value == null) return '';
        return value.toString();
      }

      // Helper function to safely convert to bool
      bool safeBool(dynamic value) {
        if (value == null) return false;
        if (value is bool) return value;
        if (value is String) {
          return value.toLowerCase() == 'true';
        }
        return false;
      }

      // Helper function to safely parse DateTime
      DateTime safeDateTime(dynamic value) {
        if (value == null) return DateTime.now();
        if (value is DateTime) return value;
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            print('Error parsing DateTime: $value, error: $e');
            return DateTime.now();
          }
        }
        return DateTime.now();
      }

      return NotificationModel(
        id: safeString(json['_id']),
        type: safeString(json['type']),
        title: safeString(json['title']),
        message: safeString(json['message']),
        read: safeBool(json['read']),
        gymId: json['gymId'] is String ? json['gymId'] : json['gymId']?['_id']?.toString() ?? '',
        userId: json['userId'] is String ? json['userId'] : json['userId']?['_id']?.toString(),
        expiresAt: safeDateTime(json['expiresAt']),
        broadcast: safeBool(json['broadcast']),
        actionUrl: json['actionUrl']?.toString(),
        metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] : null,
        createdAt: safeDateTime(json['createdAt']),
      );
    } catch (e) {
      print('Error parsing NotificationModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'title': title,
      'message': message,
      'read': read,
      'gymId': gymId,
      'userId': userId,
      'expiresAt': expiresAt.toIso8601String(),
      'broadcast': broadcast,
      'actionUrl': actionUrl,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    bool? read,
    String? gymId,
    String? userId,
    DateTime? expiresAt,
    bool? broadcast,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      read: read ?? this.read,
      gymId: gymId ?? this.gymId,
      userId: userId ?? this.userId,
      expiresAt: expiresAt ?? this.expiresAt,
      broadcast: broadcast ?? this.broadcast,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $type, title: $title, read: $read)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
