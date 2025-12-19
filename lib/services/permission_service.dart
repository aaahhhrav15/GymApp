import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PermissionService {
  static Future<void> requestAllPermissions() async {
    try {
      // List of permissions needed for the app
      List<Permission> permissions = [];

      if (Platform.isIOS) {
        // iOS permissions - use iOS-specific permission types
        permissions = [
          Permission.bluetooth, // iOS uses single bluetooth permission
          Permission.locationWhenInUse, // Location when in use
          Permission.camera,
          Permission.photos,
        ];
        // Note: Activity recognition on iOS is handled via Core Motion automatically
        // BluetoothScan and BluetoothConnect are Android-only
      } else if (Platform.isAndroid) {
        // Android permissions
        permissions = [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
          Permission.locationWhenInUse,
          Permission.activityRecognition,
          Permission.camera,
          Permission.photos,
        ];
      }

      // Request all permissions
      Map<Permission, PermissionStatus> statuses = await permissions.request();

      // Log permission results
      statuses.forEach((permission, status) {
        debugPrint('Permission ${permission.toString()}: ${status.toString()}');
      });

      // Handle denied permissions
      List<Permission> deniedPermissions = [];
      statuses.forEach((permission, status) {
        if (status.isDenied || status.isPermanentlyDenied) {
          deniedPermissions.add(permission);
        }
      });

      if (deniedPermissions.isNotEmpty) {
        debugPrint('Some permissions were denied: ${deniedPermissions.length}');
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  static Future<bool> isBluetoothPermissionGranted() async {
    if (Platform.isIOS) {
      // iOS uses single bluetooth permission
      final bluetoothStatus = await Permission.bluetooth.status;
      return bluetoothStatus.isGranted || bluetoothStatus == PermissionStatus.limited;
    } else {
      final bluetoothScan = await Permission.bluetoothScan.isGranted;
      final bluetoothConnect = await Permission.bluetoothConnect.isGranted;
      return bluetoothScan && bluetoothConnect;
    }
  }

  static Future<bool> isLocationPermissionGranted() async {
    // Check both "When In Use" and "Always" permissions
    final whenInUse = await Permission.locationWhenInUse.status;
    final always = await Permission.location.status;
    
    return whenInUse.isGranted || 
           whenInUse == PermissionStatus.limited ||
           always.isGranted ||
           always == PermissionStatus.limited;
  }

  static Future<bool> isActivityRecognitionGranted() async {
    return await Permission.activityRecognition.isGranted;
  }

  static Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }

  static Future<bool> isPhotoPermissionGranted() async {
    return await Permission.photos.isGranted;
  }

  static Future<void> requestBluetoothPermissions() async {
    if (Platform.isIOS) {
      // iOS uses single bluetooth permission
      await Permission.bluetooth.request();
    } else {
      // Android uses multiple bluetooth permissions
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
    }
  }

  static Future<void> requestLocationPermission() async {
    await Permission.locationWhenInUse.request();
  }

  static Future<void> requestActivityRecognitionPermission() async {
    await Permission.activityRecognition.request();
  }

  static Future<void> requestCameraPermission() async {
    await Permission.camera.request();
  }

  static Future<void> requestPhotoPermission() async {
    await Permission.photos.request();
  }

  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'bluetooth': await isBluetoothPermissionGranted(),
      'location': await isLocationPermissionGranted(),
      'activityRecognition': await isActivityRecognitionGranted(),
      'camera': await isCameraPermissionGranted(),
      'photos': await isPhotoPermissionGranted(),
    };
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Request body composition specific permissions (Bluetooth + Location)
  /// This should be called at app startup for iOS
  static Future<Map<String, bool>> requestBodyCompositionPermissions() async {
    try {
      if (Platform.isIOS) {
        // First check current status
        final currentLocationStatus = await Permission.locationWhenInUse.status;
        debugPrint('Current Location permission status: $currentLocationStatus');
        
        // If permanently denied, we can't request it again - user must go to Settings
        if (currentLocationStatus == PermissionStatus.permanentlyDenied) {
          debugPrint('⚠️ Location permission permanently denied - user must enable in Settings');
          return {
            'bluetooth': true, // Bluetooth doesn't need explicit permission on iOS
            'location': false,
            'needsSettings': true, // Flag to indicate user needs to go to Settings
          };
        }
        
        // If denied (but not permanently), we can still try to request via native method
        // iOS might show the dialog again or guide user to Settings
        if (currentLocationStatus == PermissionStatus.denied) {
          debugPrint('⚠️ Location permission denied - will attempt native request');
        }
        
        // iOS: Use native method channel to request Location permission
        // This will trigger the native iOS system dialog like Apple Maps
        try {
          const platform = MethodChannel('com.mait.gym_attendance/permissions');
          
          // Add a small delay to ensure method channel is set up
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Request with timeout to prevent hanging
          final locationGranted = await platform.invokeMethod<bool>('requestLocationPermission')
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  debugPrint('⚠️ Permission request timed out');
                  return false;
                },
              ) ?? false;
          
          debugPrint('Native iOS Location permission result: $locationGranted');
          
          // Re-check status after request (user might have selected "Always")
          final finalLocationStatus = await Permission.locationWhenInUse.status;
          final finalLocationAlwaysStatus = await Permission.location.status;
          
          // Check if either "When In Use" or "Always" is granted
          final isLocationGranted = locationGranted || 
              finalLocationStatus.isGranted || 
              finalLocationStatus == PermissionStatus.limited ||
              finalLocationAlwaysStatus.isGranted ||
              finalLocationAlwaysStatus == PermissionStatus.limited;
          
          debugPrint('Final Location status - WhenInUse: $finalLocationStatus, Always: $finalLocationAlwaysStatus, Granted: $isLocationGranted');
          
          // Check Bluetooth status (might be undetermined until first BLE use)
          final bluetoothStatus = await Permission.bluetooth.status;
          
          debugPrint('Body Composition Permissions - Bluetooth: $bluetoothStatus, Location: $isLocationGranted');
          
          return {
            'bluetooth': bluetoothStatus != PermissionStatus.permanentlyDenied,
            'location': isLocationGranted,
          };
        } catch (e) {
          debugPrint('Error using native iOS permission channel: $e');
          debugPrint('Falling back to permission_handler package');
          
          // Fallback to permission_handler
          try {
            final locationStatus = await Permission.locationWhenInUse.request()
                .timeout(const Duration(seconds: 5));
            final bluetoothStatus = await Permission.bluetooth.status;
            
            // Check both when in use and always
            final locationAlwaysStatus = await Permission.location.status;
            final isLocationGranted = locationStatus.isGranted || 
                locationStatus == PermissionStatus.limited ||
                locationAlwaysStatus.isGranted ||
                locationAlwaysStatus == PermissionStatus.limited;
            
            return {
              'bluetooth': bluetoothStatus != PermissionStatus.permanentlyDenied,
              'location': isLocationGranted,
            };
          } catch (fallbackError) {
            debugPrint('Error in fallback permission request: $fallbackError');
            // Return current status without requesting
            final currentStatus = await Permission.locationWhenInUse.status;
            final currentAlwaysStatus = await Permission.location.status;
            final isGranted = currentStatus.isGranted || 
                currentStatus == PermissionStatus.limited ||
                currentAlwaysStatus.isGranted ||
                currentAlwaysStatus == PermissionStatus.limited;
            
            return {
              'bluetooth': true,
              'location': isGranted,
            };
          }
        }
      } else {
        // Android: Request Bluetooth and Location permissions
        final statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
        ].request();
        
        final bluetoothGranted = (statuses[Permission.bluetoothScan]?.isGranted ?? false) &&
            (statuses[Permission.bluetoothConnect]?.isGranted ?? false);
        final locationGranted = statuses[Permission.locationWhenInUse]?.isGranted ?? false;
        
        return {
          'bluetooth': bluetoothGranted,
          'location': locationGranted,
        };
      }
    } catch (e) {
      debugPrint('Error requesting body composition permissions: $e');
      return {
        'bluetooth': false,
        'location': false,
      };
    }
  }
}
