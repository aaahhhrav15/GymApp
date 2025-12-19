// import 'package:flutter/material.dart';
// import '../theme/app_theme.dart';
// import 'package:provider/provider.dart';
// import '../providers/water_provider.dart';
// import '../services/water_notification_service.dart';
// import '../services/notification_debug_service.dart';

// class WaterDebugScreen extends StatefulWidget {
//   const WaterDebugScreen({super.key});

//   @override
//   State<WaterDebugScreen> createState() => _WaterDebugScreenState();
// }

// class _WaterDebugScreenState extends State<WaterDebugScreen> {
//   Map<String, dynamic> _debugInfo = {};
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadDebugInfo();
//   }

//   Future<void> _loadDebugInfo() async {
//     setState(() => _isLoading = true);

//     try {
//       final info = await NotificationDebugService.getDebugInfo();
//       setState(() => _debugInfo = info);
//     } catch (e) {
//       setState(() => _debugInfo = {'error': e.toString()});
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       appBar: AppBar(
//         title: const Text('Water Notifications Debug'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 1,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Debug Info Card
//                   Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.bug_report, color: Colors.orange[600]),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 'Debug Information',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           ..._debugInfo.entries.map((entry) => Padding(
//                                 padding: const EdgeInsets.only(bottom: 8),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Expanded(
//                                       flex: 2,
//                                       child: Text(
//                                         '${entry.key}:',
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       flex: 3,
//                                       child: Text(
//                                         entry.value.toString(),
//                                         style: TextStyle(
//                                           color: _getStatusColor(entry.value),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Test Actions Card
//                   Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.play_arrow, color: Colors.green[600]),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 'Test Actions',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),

//                           // Test Notification Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               onPressed: () =>
//                                   NotificationDebugService.testNotification(),
//                               icon: const Icon(Icons.notification_add),
//                               label: const Text('Send Test Notification'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue[600],
//                                 foregroundColor: Colors.white,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 12),

//                           // Start Reminders Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               onPressed: () async {
//                                 await WaterNotificationService.startReminders(
//                                   interval: const Duration(
//                                       minutes: 1), // Test with 1 minute
//                                 );
//                                 // ScaffoldMessenger.of(context).showSnackBar(
                                 // //                                   const SnackBar(
                                 // //                                       content: Text(
                                 // //                                           'Started 1-minute test reminders')),
//                                 );
//                                 await _loadDebugInfo(); // Refresh debug info
//                               },
//                               icon: const Icon(Icons.play_circle),
//                               label: const Text('Start Test Reminders (1 min)'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green[600],
//                                 foregroundColor: Colors.white,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 12),

//                           // Stop Reminders Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 WaterNotificationService.stopReminders();
//                                 // ScaffoldMessenger.of(context).showSnackBar(
                                 // //                                   const SnackBar(
                                 // //                                       content: Text('Stopped reminders')),
//                                 );
//                                 _loadDebugInfo(); // Refresh debug info
//                               },
//                               icon: const Icon(Icons.stop_circle),
//                               label: const Text('Stop Reminders'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red[600],
//                                 foregroundColor: Colors.white,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 12),

//                           // Initialize Service Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               onPressed: () async {
//                                 await WaterNotificationService.initialize();
//                                 // ScaffoldMessenger.of(context).showSnackBar(
                                 // //                                   const SnackBar(
                                 // //                                       content: Text('Service initialized')),
//                                 );
//                                 await _loadDebugInfo(); // Refresh debug info
//                               },
//                               icon: const Icon(Icons.refresh),
//                               label: const Text('Initialize Service'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.orange[600],
//                                 foregroundColor: Colors.white,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 12),

//                           // Refresh Debug Info Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: OutlinedButton.icon(
//                               onPressed: _loadDebugInfo,
//                               icon: const Icon(Icons.refresh),
//                               label: const Text('Refresh Debug Info'),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Water Provider Status
//                   Consumer<WaterProvider>(
//                     builder: (context, waterProvider, child) {
//                       return Card(
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(Icons.water_drop,
//                                       color: Colors.blue[600]),
//                                   const SizedBox(width: 8),
//                                   const Text(
//                                     'Water Provider Status',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),
//                               _buildStatusRow('Reminder Enabled',
//                                   waterProvider.reminderEnabled),
//                               _buildStatusRow('Reminder Interval',
//                                   '${waterProvider.reminderInterval} minutes'),
//                               _buildStatusRow(
//                                   'Daily Goal', '${waterProvider.dailyGoal}ml'),
//                               _buildStatusRow('Current Intake',
//                                   '${waterProvider.currentIntake}ml'),
//                               _buildStatusRow('Goal Achieved',
//                                   waterProvider.isGoalAchieved),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildStatusRow(String label, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               '$label:',
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value.toString(),
//               style: TextStyle(color: _getStatusColor(value)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(dynamic value) {
//     if (value is bool) {
//       return value ? Colors.green[600]! : Colors.red[600]!;
//     } else if (value.toString().contains('granted')) {
//       return Colors.green[600]!;
//     } else if (value.toString().contains('denied')) {
//       return Colors.red[600]!;
//     } else if (value.toString().contains('true')) {
//       return Colors.green[600]!;
//     } else if (value.toString().contains('false')) {
//       return Colors.red[600]!;
//     }
//     return Colors.black87;
//   }
// }
