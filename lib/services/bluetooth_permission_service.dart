import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import '../screens/body_composition_screen.dart';

class BluetoothPermissionService {
  // Global callback to pause reels when navigating away
  static VoidCallback? onNavigateAwayFromReels;

  static Future<bool> checkAndNavigateToBodyComposition(
      BuildContext context) async {
    try {
      // Pause reels if callback is available
      onNavigateAwayFromReels?.call();

      // First, check if permissions are already granted
      bool hasPermissions = await _checkExistingPermissions();

      if (hasPermissions) {
        // Permissions already granted, navigate directly
        print(
            "✅ Permissions already granted, navigating to body composition screen");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MrMusclePage(),
          ),
        );
        return true;
      }

      // Permissions not granted, request them
      print("🔐 Requesting missing permissions...");
      bool permissionsGranted = await _requestPermissions();

      if (permissionsGranted) {
        // Add a delay to let the system settle after permission grant
        await Future.delayed(const Duration(milliseconds: 1500));

        if (context.mounted) {
          // Permissions granted, navigate to screen
          print("✅ Permissions granted, navigating to body composition screen");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MrMusclePage(),
            ),
          );
        }
        return true;
      } else {
        // Permissions denied, show dialog with Settings option
        if (context.mounted) {
          _showPermissionDeniedDialog(context);
        }
        return false;
      }
    } catch (e) {
      print('❌ Error checking permissions: $e');
      if (context.mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //         'Error accessing body composition features. Please try again.'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      }
      return false;
    }
  }

  static Future<bool> _checkExistingPermissions() async {
    try {
      if (Platform.isIOS) {
        // iOS permission check
        PermissionStatus location = await Permission.locationWhenInUse.status;
        PermissionStatus bluetooth = await Permission.bluetooth.status;

        print('iOS Permission Status - Location: $location, Bluetooth: $bluetooth');

        // On iOS 13+, Bluetooth Low Energy doesn't require explicit permission
        // Location is REQUIRED for BLE scanning - this is the critical permission
        bool locationOk = location == PermissionStatus.granted ||
            location == PermissionStatus.limited;
        
        // Bluetooth on iOS is handled automatically - just check it's not permanently denied
        // It might be "undetermined" until first BLE use, which is normal
        bool bluetoothOk = bluetooth != PermissionStatus.permanentlyDenied;

        print('iOS Permission Check - Location: $locationOk, Bluetooth OK: $bluetoothOk');

        // Location is the critical one - if location is granted, we're good
        return locationOk && bluetoothOk;
      } else {
        // Android permission check
        PermissionStatus bluetoothScan = await Permission.bluetoothScan.status;
        PermissionStatus bluetoothConnect =
            await Permission.bluetoothConnect.status;
        PermissionStatus location = await Permission.locationWhenInUse.status;

        return (bluetoothScan == PermissionStatus.granted ||
                bluetoothScan == PermissionStatus.limited) &&
            (bluetoothConnect == PermissionStatus.granted ||
                bluetoothConnect == PermissionStatus.limited) &&
            (location == PermissionStatus.granted ||
                location == PermissionStatus.limited);
      }
    } catch (e) {
      print('Error checking existing permissions: $e');
      return false;
    }
  }

  static Future<bool> _requestPermissions() async {
    try {
      if (Platform.isIOS) {
        // iOS permission request
        print('📱 Requesting iOS permissions using native method...');
        
        // Use native iOS method channel to request Location permission
        // This will show the native iOS system dialog like Apple Maps
        try {
          const platform = MethodChannel('com.mait.gym_attendance/permissions');
          final locationGranted = await platform.invokeMethod<bool>('requestLocationPermission') ?? false;
          print('Native iOS Location permission result: $locationGranted');

          // For iOS, Bluetooth permission is handled automatically when you use BLE
          // But we can check if it's available
          PermissionStatus bluetoothStatus = await Permission.bluetooth.status;
          print('iOS Bluetooth permission status: $bluetoothStatus');

          // Bluetooth on iOS doesn't need explicit permission for BLE scanning
          // It's granted automatically when you use CoreBluetooth
          bool bluetoothOk = bluetoothStatus != PermissionStatus.permanentlyDenied;

          print('iOS Permissions - Location: $locationGranted, Bluetooth OK: $bluetoothOk');

          // Location is the critical one - return true if location is granted
          // Bluetooth will work automatically when BLE is used
          return locationGranted && bluetoothOk;
        } catch (e) {
          print('Error using native iOS permission channel: $e');
          // Fallback to permission_handler
          PermissionStatus locationStatus = await Permission.locationWhenInUse.request();
          PermissionStatus bluetoothStatus = await Permission.bluetooth.status;
          
          bool locationGranted = locationStatus == PermissionStatus.granted ||
              locationStatus == PermissionStatus.limited;
          bool bluetoothOk = bluetoothStatus != PermissionStatus.permanentlyDenied;
          
          return locationGranted && bluetoothOk;
        }
      } else {
        // Android permission request
        print('🤖 Requesting Android permissions...');
        Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
          Permission.locationWhenInUse,
        ].request();

        // Check if all critical permissions were granted
        bool bluetoothGranted = (statuses[Permission.bluetoothScan] ==
                    PermissionStatus.granted ||
                statuses[Permission.bluetoothScan] == PermissionStatus.limited) &&
            (statuses[Permission.bluetoothConnect] == PermissionStatus.granted ||
                statuses[Permission.bluetoothConnect] ==
                    PermissionStatus.limited);

        bool locationGranted = statuses[Permission.locationWhenInUse] ==
                PermissionStatus.granted ||
            statuses[Permission.locationWhenInUse] == PermissionStatus.limited;

        return bluetoothGranted && locationGranted;
      }
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String message = Platform.isIOS
            ? 'Location permission is required for Bluetooth body composition devices on iOS. Please enable Location Services in Settings > Privacy & Security > Location Services, then select this app and choose "While Using the App".'
            : 'Bluetooth and Location permissions are required for body composition features. Please enable them in Settings.';
        
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
