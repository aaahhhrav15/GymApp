// lib/screens/notification_test_screen.dart
import 'package:flutter/material.dart';
import '../services/water_notification_service.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  String _status = 'Ready to test notifications';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 16),
                    Text(
                        'Reminders Active: ${WaterNotificationService.areRemindersActive}'),
                    Text(
                        'Scheduled Count: ${WaterNotificationService.scheduledRemindersCount}'),
                    Text(
                        'Reminder Interval: ${WaterNotificationService.reminderInterval} minutes'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testNotification,
              child: const Text('Test Immediate Notification'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _startReminders,
              child: const Text('Start Background Reminders'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _stopReminders,
              child: const Text('Stop All Reminders'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testGoalAchieved,
              child: const Text('Test Goal Achieved Notification'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _checkStatus,
              child: const Text('Refresh Status'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testNotification() async {
    try {
      setState(() {
        _status = 'Sending test notification...';
      });

      await WaterNotificationService.testNotification();

      setState(() {
        _status = 'Test notification sent! Check your notifications.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error sending test notification: $e';
      });
    }
  }

  Future<void> _startReminders() async {
    try {
      setState(() {
        _status = 'Starting background reminders...';
      });

      await WaterNotificationService.startReminders(
        interval: const Duration(minutes: 1), // 1 minute for testing
      );

      setState(() {
        _status =
            'Background reminders started! They will work even when app is closed.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error starting reminders: $e';
      });
    }
  }

  Future<void> _stopReminders() async {
    try {
      setState(() {
        _status = 'Stopping all reminders...';
      });

      await WaterNotificationService.stopReminders();

      setState(() {
        _status = 'All reminders stopped and cancelled.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error stopping reminders: $e';
      });
    }
  }

  Future<void> _testGoalAchieved() async {
    try {
      setState(() {
        _status = 'Sending goal achieved notification...';
      });

      await WaterNotificationService.showGoalAchievedNotification();

      setState(() {
        _status = 'Goal achieved notification sent!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error sending goal notification: $e';
      });
    }
  }

  void _checkStatus() {
    setState(() {
      _status = 'Status refreshed at ${DateTime.now().toString()}';
    });
  }
}
