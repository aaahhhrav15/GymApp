// // lib/services/notification_debug_service.dart
// import 'package:permission_handler/permission_handler.dart';
// import 'water_notification_service.dart';

// class NotificationDebugService {
//   static Future<Map<String, dynamic>> getDebugInfo() async {
//     final debugInfo = <String, dynamic>{};

//     try {
//       // Check notification permission
//       final notificationStatus = await Permission.notification.status;
//       debugInfo['notification_permission'] = notificationStatus.toString();

//       // Check if notifications are enabled
//       final areEnabled =
//           await WaterNotificationService.areNotificationsEnabled();
//       debugInfo['notifications_enabled'] = areEnabled;

//       // Check if reminder is active
//       final isReminderActive = WaterNotificationService.isReminderActive;
//       debugInfo['reminder_active'] = isReminderActive;

//       // Check exact alarm permission (Android 12+)
//       final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
//       debugInfo['exact_alarm_permission'] = exactAlarmStatus.toString();

//       // Check if service is initialized
//       debugInfo['service_initialized'] = WaterNotificationService.isInitialized;
//     } catch (e) {
//       debugInfo['error'] = e.toString();
//     }

//     return debugInfo;
//   }

//   static Future<void> testNotification() async {
//     try {
//       await WaterNotificationService.initialize();
//       await WaterNotificationService.showTestNotification();
//     } catch (e) {
//       print('Test notification failed: $e');
//     }
//   }

//   static Future<void> forceStartReminders() async {
//     try {
//       await WaterNotificationService.initialize();
//       await WaterNotificationService.startReminders(
//         interval: const Duration(minutes: 1), // Test with 1 minute
//       );
//       print('Reminders started with 1-minute interval for testing');
//     } catch (e) {
//       print('Failed to start reminders: $e');
//     }
//   }

//   static void printDebugInfo() async {
//     final info = await getDebugInfo();
//     print('=== WATER NOTIFICATION DEBUG INFO ===');
//     info.forEach((key, value) {
//       print('$key: $value');
//     });
//     print('=====================================');
//   }
// }
