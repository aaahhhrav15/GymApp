import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:icdevicemanager_flutter/icdevicemanager_flutter.dart';
import 'package:icdevicemanager_flutter/ic_bluetooth_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/profile_provider.dart';

class MrMusclePage extends StatefulWidget {
  const MrMusclePage({super.key});

  @override
  _MrMusclePageState createState() => _MrMusclePageState();
}

class _MrMusclePageState extends State<MrMusclePage>
    with WidgetsBindingObserver
    implements ICDeviceManagerDelegate, ICScanDeviceDelegate {
  ICWeightData? lastData;
  List<ICDevice> devices = [];

  bool isScanning = false;
  bool isConnected = false;
  bool _scanningSessionActive = false; // Track if we're in an active scanning session
  bool _isMeasuring = false; // Track if data is being measured (data coming but not stabilized)
  bool hasUserProfile = false;
  bool useMetricUnits = true; // true for metric, false for imperial
  bool _isCheckingServices =
      false; // Track if we're periodically checking services
  Timer? _serviceCheckTimer; // Timer for periodic service checking
  Timer? _scanTimeoutTimer; // Timer for scan timeout
  bool _waitingForPermissionRetry = false; // Track if we're waiting for permission retry

  // Stored body composition data (for persistent display)
  bool hasStoredData = false;
  double storedWeight = 0.0;
  double storedBmi = 0.0;
  double storedBodyFat = 0.0;
  double storedMuscle = 0.0;
  double storedWater = 0.0;
  double storedBoneMass = 0.0;
  double storedBmr = 0.0;
  double storedSubcutaneousFat = 0.0;
  double storedVisceralFat = 0.0;
  double storedProtein = 0.0;
  double storedSkeletalMuscle = 0.0;
  DateTime? lastMeasurementTime;
  
  // Track last saved stabilized measurement to prevent duplicate saves
  double? _lastSavedStabilizedWeight;
  DateTime? _lastSavedStabilizedTime;

  // User profile data
  String userName = "";
  DateTime? userDOB;
  int userAge = 25;
  double? userHeight; // cm or inches - nullable to detect missing
  double? userWeight; // kg or lbs
  double targetWeight = 75.0; // kg or lbs
  ICSexType userSex = ICSexType.ICSexTypeMale;
  bool _hasCheckedHeight = false; // Track if we've checked for height

  // Helper function to normalize date to local midnight (date-only, no time component)
  // This prevents timezone issues when dates are stored/loaded
  DateTime _normalizeToLocalMidnight(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Listen for app lifecycle changes
    // Load user profile first, then check for height
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUserProfile();
      _loadSavedBodyCompositionData();
      _checkRequiredServices();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app comes back to foreground, check if permissions were granted
    if (state == AppLifecycleState.resumed && _waitingForPermissionRetry) {
      print('📱 App resumed - checking if permissions were granted...');
      Future.delayed(const Duration(milliseconds: 500), () {
        _retryPermissionCheck();
      });
    }
  }

  // Check if Bluetooth and Location services are enabled
  Future<void> _checkRequiredServices() async {
    print('🔍 Checking required services...');

    bool bluetoothEnabled = await _isBluetoothEnabled();
    bool locationEnabled = await _isLocationEnabled();

    print('📱 Bluetooth enabled: $bluetoothEnabled');
    print('📍 Location enabled: $locationEnabled');

    if (!bluetoothEnabled || !locationEnabled) {
      print('⚠️ Services missing - showing dialog');
      _showServicesDialog(bluetoothEnabled, locationEnabled);
    } else {
      print('✅ All services enabled - proceeding with SDK initialization');
      // Delay SDK initialization to prevent crashes
      _delayedSDKInitialization();
    }
  }

  // Check if Bluetooth is enabled
  Future<bool> _isBluetoothEnabled() async {
    try {
      // Use platform channel to check actual Bluetooth service status
      const platform = MethodChannel('flutter.native/helper');
      final result = await platform.invokeMethod('isBluetoothEnabled');
      print('🔵 Bluetooth service enabled: $result');
      return result as bool;
    } catch (e) {
      print('❌ Error checking Bluetooth status: $e');
      // Fallback: Check permissions if platform channel fails
      try {
        var bluetoothStatus = await Permission.bluetooth.status;
        return bluetoothStatus.isGranted;
      } catch (fallbackError) {
        print('❌ Fallback permission check also failed: $fallbackError');
        return false;
      }
    }
  }

  // Check if Location services are enabled
  Future<bool> _isLocationEnabled() async {
    try {
      // Use platform channel to check actual Location service status
      const platform = MethodChannel('flutter.native/helper');
      final result = await platform.invokeMethod('isLocationEnabled');
      print('📍 Location service enabled (native): $result');
      return result as bool;
    } catch (e) {
      print('❌ Error checking Location status via native: $e');
      // Fallback: Check permissions if platform channel fails
      try {
        // Check both "When In Use" and "Always" permissions on iOS
        final locationWhenInUseStatus = await Permission.locationWhenInUse.status;
        final locationAlwaysStatus = await Permission.location.status;
        
        final isGranted = locationWhenInUseStatus.isGranted || 
                         locationWhenInUseStatus == PermissionStatus.limited ||
                         locationAlwaysStatus.isGranted ||
                         locationAlwaysStatus == PermissionStatus.limited;
        
        print('📍 Location permission check (fallback) - WhenInUse: $locationWhenInUseStatus, Always: $locationAlwaysStatus, Granted: $isGranted');
        return isGranted;
      } catch (fallbackError) {
        print('❌ Fallback permission check also failed: $fallbackError');
        return false;
      }
    }
  }

  // Show dialog when services are not enabled
  void _showServicesDialog(bool bluetoothEnabled, bool locationEnabled) {
    if (!mounted) {
      print('❌ Widget not mounted, cannot show dialog');
      return;
    }

    print(
        '🚨 Showing services dialog - Bluetooth: $bluetoothEnabled, Location: $locationEnabled');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'Services Required',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To use Body Composition features, please enable:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 15),
              if (!bluetoothEnabled)
                Row(
                  children: [
                    Icon(Icons.bluetooth, color: Colors.blue, size: 24),
                    SizedBox(width: 10),
                    Text('Bluetooth', style: TextStyle(fontSize: 16)),
                  ],
                ),
              if (!locationEnabled)
                Padding(
                  padding: EdgeInsets.only(top: !bluetoothEnabled ? 8 : 0),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 24),
                      SizedBox(width: 10),
                      Text('Location Services', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              SizedBox(height: 15),
              Text(
                'Please enable these services from your device settings. The app will automatically detect when they are enabled.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to previous screen
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );

    // Start periodic checking for services in the background
    _startPeriodicServiceCheck();
  }

  // Start periodic checking to detect when services are enabled
  void _startPeriodicServiceCheck() {
    if (_isCheckingServices) return; // Already checking

    _isCheckingServices = true;
    print('🔄 Starting periodic service check...');

    // Check every 2 seconds
    _serviceCheckTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        _isCheckingServices = false;
        _serviceCheckTimer = null;
        return;
      }

      bool bluetoothEnabled = await _isBluetoothEnabled();
      bool locationEnabled = await _isLocationEnabled();

      print(
          '🔍 Periodic check - Bluetooth: $bluetoothEnabled, Location: $locationEnabled');

      // If both services are now enabled, close dialog and proceed
      if (bluetoothEnabled && locationEnabled) {
        print('✅ Services enabled! Closing dialog and proceeding...');
        timer.cancel();
        _isCheckingServices = false;
        _serviceCheckTimer = null;

        // Close the dialog if it's open
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Show success message
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //         '✅ Services enabled! You can now use Body Composition features.'),
        //     backgroundColor: Colors.green,
        //     duration: Duration(seconds: 3),
        //   ),
        // );

        // Initialize SDK
        _delayedSDKInitialization();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceCheckTimer?.cancel();
    _scanTimeoutTimer?.cancel();
    super.dispose();
  }

  // Retry permission check after user returns from Settings
  Future<void> _retryPermissionCheck() async {
    if (!mounted) return;
    
    print('🔄 Retrying permission check...');
    _waitingForPermissionRetry = false;
    
    // Check permissions again
    bool hasPermission = false;
    if (Platform.isIOS) {
      try {
        const platform = MethodChannel('com.mait.gym_attendance/permissions');
        final nativeCheck = await platform.invokeMethod<bool>('checkLocationPermission') ?? false;
        
        final currentWhenInUse = await Permission.locationWhenInUse.status;
        final currentAlways = await Permission.location.status;
        
        hasPermission = nativeCheck || 
                       currentWhenInUse.isGranted || 
                       currentWhenInUse == PermissionStatus.limited ||
                       currentAlways.isGranted ||
                       currentAlways == PermissionStatus.limited;
        
        print('📱 Permission retry check - Native: $nativeCheck, WhenInUse: $currentWhenInUse, Always: $currentAlways, HasPermission: $hasPermission');
      } catch (e) {
        print('❌ Error in permission retry check: $e');
      }
    } else {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();
      hasPermission = statuses.values.every((s) => s.isGranted);
    }
    
    if (hasPermission) {
      print('✅ Permission granted! Proceeding with scan...');
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('✅ Permission granted! Starting scan...'),
        //     backgroundColor: Colors.green,
        //     duration: const Duration(seconds: 2),
        //   ),
        // );
        // Automatically start scan
        _requestPermissionsAndScan();
      }
    } else {
      print('⚠️ Permission still not granted');
    }
  }

  Future<void> _delayedSDKInitialization() async {
    try {
      // Wait for the widget to be fully built and permissions to settle
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        print("🔄 Starting delayed SDK initialization...");
        _initializeSDK();
      }
    } catch (e) {
      print("❌ Error in delayed SDK initialization: $e");
      // Don't crash the app, just log the error
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      // First, try to load from ProfileProvider (backend data)
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      
      // Always fetch fresh profile data when opening this page
      print("🔄 Fetching user profile from backend...");
      await profileProvider.fetchUserProfile();
      
      if (profileProvider.userProfile != null) {
        final profile = profileProvider.userProfile!;
        
        // Load all required fields from profile
        userName = profile.name;
        // Normalize birthday to local midnight to avoid timezone issues
        userDOB = profile.birthday != null ? _normalizeToLocalMidnight(profile.birthday!) : null;
        userHeight = profile.height;
        userWeight = profile.weight;
        
        // Calculate age from birthday
        if (userDOB != null) {
          final now = DateTime.now();
          userAge = now.year - userDOB!.year;
          if (now.month < userDOB!.month ||
              (now.month == userDOB!.month && now.day < userDOB!.day)) {
            userAge--;
          }
        }
        
        // Set gender/sex from profile
        if (profile.gender != null) {
          final genderLower = profile.gender!.toLowerCase();
          if (genderLower.contains('male') || genderLower == 'm') {
            userSex = ICSexType.ICSexTypeMale;
          } else if (genderLower.contains('female') || genderLower == 'f') {
            userSex = ICSexType.ICSexTypeFemale;
          }
        }
        
        hasUserProfile = true;
        
        print("✅ Loaded user profile from ProfileProvider: Name=$userName, Age=$userAge, Height=${userHeight ?? 'not set'}cm, Weight=${userWeight ?? 'not set'}kg, Sex=$userSex, DOB=${userDOB?.toString() ?? 'not set'}");
        
        // Check for missing details
        final missingDetails = _checkMissingDetails();
        
        if (missingDetails.isNotEmpty) {
          if (mounted && !_hasCheckedHeight) {
            _hasCheckedHeight = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showMissingDetailsDialog(missingDetails);
            });
          }
        } else {
          // All details available, update SDK
          _updateUserInfo();
        }
        
        // Update UI to reflect the loaded data
        if (mounted) {
          setState(() {});
        }
      } else {
        // ProfileProvider has no data - show message to fetch from profile
        print("⚠️ ProfileProvider has no data");
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showFetchProfileDialog();
          });
        }
        // Fallback to SharedPreferences
        await _loadUserProfileFromSharedPreferences();
      }
    } catch (e) {
      print("❌ Error loading user profile from ProfileProvider: $e");
      // Show error message
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFetchProfileDialog();
        });
      }
      // Fallback to SharedPreferences on error
      await _loadUserProfileFromSharedPreferences();
    }
  }
  
  // Check which details are missing
  List<String> _checkMissingDetails() {
    List<String> missing = [];
    
    if (userHeight == null || userHeight! <= 0) {
      missing.add('Height');
    }
    if (userWeight == null || userWeight! <= 0) {
      missing.add('Weight');
    }
    if (userDOB == null) {
      missing.add('Date of Birth');
    }
    if (userName.isEmpty) {
      missing.add('Name');
    }
    if (userSex == null) {
      missing.add('Gender');
    }
    
    return missing;
  }
  
  // Show dialog for missing details
  void _showMissingDetailsDialog(List<String> missingDetails) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Details Missing'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('The following details are missing from your profile:'),
              const SizedBox(height: 12),
              ...missingDetails.map((detail) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8),
                    const SizedBox(width: 8),
                    Text(detail),
                  ],
                ),
              )),
              const SizedBox(height: 12),
              const Text(
                'Please fetch your details from the profile page to ensure accurate body composition measurements.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to profile screen
                Navigator.pushNamed(context, '/profile');
              },
              child: const Text('Go to Profile'),
            ),
          ],
        );
      },
    );
  }
  
  // Show dialog to fetch profile
  void _showFetchProfileDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Not Found'),
          content: const Text(
            'Please fetch your details from the profile page to ensure accurate body composition measurements.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to profile screen
                Navigator.pushNamed(context, '/profile');
              },
              child: const Text('Go to Profile'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _loadUserProfileFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved user profile or use defaults
      userName = prefs.getString('user_name') ?? "";
      userAge = prefs.getInt('user_age') ?? 25;
      userHeight = prefs.getDouble('user_height');
      userWeight = prefs.getDouble('user_weight');
      targetWeight = prefs.getDouble('target_weight') ?? 75.0;
      userSex = ICSexType.values[prefs.getInt('user_sex') ?? 0];
      useMetricUnits = prefs.getBool('use_metric_units') ?? true;
      hasUserProfile = prefs.getBool('has_user_profile') ?? false;

      // Load DOB if available
      final dobTimestamp = prefs.getInt('user_dob');
      if (dobTimestamp != null) {
        // Normalize to local midnight to avoid timezone issues
        final loadedDate = DateTime.fromMillisecondsSinceEpoch(dobTimestamp);
        userDOB = _normalizeToLocalMidnight(loadedDate);
        // Calculate age from DOB
        if (userDOB != null) {
          userAge = DateTime.now().year - userDOB!.year;
          if (DateTime.now().month < userDOB!.month ||
              (DateTime.now().month == userDOB!.month &&
                  DateTime.now().day < userDOB!.day)) {
            userAge--;
          }
        }
      }

      print("Loaded user profile from SharedPreferences: Name=$userName, Age=$userAge, Height=${userHeight ?? 'not set'}, Weight=${userWeight ?? 'not set'}, Sex=$userSex");
      
      // Check if height is missing
      if ((userHeight == null || userHeight! <= 0) && mounted && !_hasCheckedHeight) {
        _hasCheckedHeight = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showHeightRequiredDialog();
        });
      } else if (userHeight != null && userHeight! > 0) {
        _updateUserInfo();
      }
    } catch (e) {
      print("Error loading user profile from SharedPreferences: $e");
    }
  }
  
  void _showHeightRequiredDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final TextEditingController heightController = TextEditingController();
        bool isMetric = useMetricUnits;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Height Required'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Height is required for accurate body composition measurements. Please enter your height.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: heightController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: isMetric ? 'Height (cm)' : 'Height (inches)',
                            hintText: isMetric ? 'e.g., 175' : 'e.g., 69',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Unit: '),
                      Radio<bool>(
                        value: true,
                        groupValue: isMetric,
                        onChanged: (value) {
                          setState(() {
                            isMetric = value ?? true;
                          });
                        },
                      ),
                      const Text('cm'),
                      Radio<bool>(
                        value: false,
                        groupValue: isMetric,
                        onChanged: (value) {
                          setState(() {
                            isMetric = value ?? false;
                          });
                        },
                      ),
                      const Text('inches'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _hasCheckedHeight = false; // Allow checking again later
                  },
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final heightText = heightController.text.trim();
                    if (heightText.isNotEmpty) {
                      final heightValue = double.tryParse(heightText);
                      if (heightValue != null && heightValue > 0) {
                        setState(() {
                          userHeight = heightValue;
                          useMetricUnits = isMetric;
                        });
                        
                        // Save to SharedPreferences
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setDouble('user_height', heightValue);
                          prefs.setBool('use_metric_units', isMetric);
                        });
                        
                        // Update SDK with new height
                        _updateUserInfo();
                        
                        Navigator.of(context).pop();
                      } else {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     content: Text('Please enter a valid height'),
                        //     backgroundColor: Colors.red,
                        //   ),
                        // );
                      }
                    } else {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text('Please enter your height'),
                      //     backgroundColor: Colors.red,
                      //   ),
                      // );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadSavedBodyCompositionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we have saved body composition data
      final hasLastMeasurement = prefs.containsKey('last_weight_kg');

      if (hasLastMeasurement) {
        // Load the saved measurement data into our variables
        final lastMeasureTime = prefs.getInt('last_measure_time') ?? 0;

        setState(() {
          hasStoredData = true;
          storedWeight = prefs.getDouble('last_weight_kg') ?? 0.0;
          storedBmi = prefs.getDouble('last_bmi') ?? 0.0;
          storedBodyFat = prefs.getDouble('last_body_fat_percent') ?? 0.0;
          storedMuscle = prefs.getDouble('last_muscle_percent') ?? 0.0;
          storedWater = prefs.getDouble('last_water_percent') ?? 0.0;
          storedBoneMass = prefs.getDouble('last_bone_mass_kg') ?? 0.0;
          storedBmr = prefs.getDouble('last_bmr') ?? 0.0;
          storedSubcutaneousFat =
              prefs.getDouble('last_subcutaneous_fat_percent') ?? 0.0;
          storedVisceralFat = prefs.getDouble('last_visceral_fat') ?? 0.0;
          storedProtein = prefs.getDouble('last_protein_percent') ?? 0.0;
          storedSkeletalMuscle = prefs.getDouble('last_sm_percent') ?? 0.0;
          lastMeasurementTime =
              DateTime.fromMillisecondsSinceEpoch(lastMeasureTime);
        });

        final measurementDate =
            DateTime.fromMillisecondsSinceEpoch(lastMeasureTime);
        final timeDiff = DateTime.now().difference(measurementDate);
        String timeAgo;

        if (timeDiff.inDays > 0) {
          timeAgo =
              "${timeDiff.inDays} day${timeDiff.inDays > 1 ? 's' : ''} ago";
        } else if (timeDiff.inHours > 0) {
          timeAgo =
              "${timeDiff.inHours} hour${timeDiff.inHours > 1 ? 's' : ''} ago";
        } else {
          timeAgo =
              "${timeDiff.inMinutes} minute${timeDiff.inMinutes > 1 ? 's' : ''} ago";
        }

        print("✅ Loaded saved body composition data from $timeAgo");
        print(
            "Weight: ${storedWeight}kg, Body Fat: ${storedBodyFat}%, Muscle: ${storedMuscle}%");
      } else {
        print("ℹ️ No saved body composition data found");
      }
    } catch (e) {
      print("❌ Error loading saved body composition data: $e");
    }
  }

  void _initializeSDK() {
    try {
      print("🔄 Initializing SDK...");

      // Don't initialize SDK immediately - add a flag to control when to actually use it
      print("✅ SDK initialization skipped to prevent crashes");
      print("ℹ️ Bluetooth features will be available when manually triggered");

      // Instead of initializing immediately, just prepare the user info
      try {
        _updateUserInfo();
      } catch (e) {
        print("❌ Error updating user info: $e");
      }
    } catch (e) {
      print("❌ Error in SDK initialization: $e");
      // Show user-friendly error message but don't crash
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Bluetooth setup encountered an issue'),
        //     backgroundColor: Colors.orange,
        //     duration: Duration(seconds: 2),
        //   ),
        // );
      }
    }
  }

  // New method to actually initialize SDK only when needed
  Future<bool> _initializeSDKWhenNeeded() async {
    try {
      print("🔄 Actually initializing SDK now...");

      // Set BOTH delegates - both are required for scanning to work!
      print("🔧 Setting device manager delegate...");
      IcBluetoothSdk.instance.setDeviceManagerDelegate(this);
      print("🔧 Setting scan delegate...");
      IcBluetoothSdk.instance.setDeviceScanDelegate(this); // ✅ Critical for scanning!
      
      print("✅ Set device manager delegate and scan delegate");
      print("📱 Delegate type: ${this.runtimeType}");
      print("📱 Delegate implements ICScanDeviceDelegate: ${this is ICScanDeviceDelegate}");

      // Wait a bit for delegates to be registered
      await Future.delayed(Duration(milliseconds: 500));

      // Create config
      final config = ICDeviceManagerConfig();
      print("📋 Created SDK config");

      // Initialize SDK
      print("🔄 Calling initSDK...");
      IcBluetoothSdk.instance.initSDK(config);
      print("✅ initSDK called");

      // Wait for initialization to complete (iOS needs more time)
      print("⏳ Waiting for SDK initialization to complete...");
      await Future.delayed(Duration(milliseconds: 1500));

      print("✅ SDK initialized successfully when needed");
      print("📱 Ready to scan for devices");
      return true;
    } catch (e) {
      print("❌ Error actually initializing SDK: $e");
      print("❌ Error stack trace: ${StackTrace.current}");
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Bluetooth SDK error: ${e.toString()}'),
        //     backgroundColor: Colors.red,
        //     duration: Duration(seconds: 3),
        //   ),
        // );
      }
      return false;
    }
  }

  void _updateUserInfo() {
    // Check if we have required data
    if (userHeight == null || userHeight! <= 0) {
      print("⚠️ Cannot update SDK user info: Height is missing or invalid");
      return;
    }
    
    if (userWeight == null || userWeight! <= 0) {
      print("⚠️ Cannot update SDK user info: Weight is missing or invalid");
      return;
    }
    
    // Convert to metric units for SDK (SDK expects cm and kg)
    double heightCm = useMetricUnits ? userHeight! : userHeight! * 2.54;
    double weightKg = useMetricUnits ? userWeight! : userWeight! * 0.453592;
    double targetWeightKg =
        useMetricUnits ? targetWeight : targetWeight * 0.453592;

    // Create user info for accurate body fat calculation
    ICUserInfo userInfo = ICUserInfo();
    userInfo.sex = userSex;
    userInfo.age = userAge;
    userInfo.height = heightCm.round(); // cm
    userInfo.weight = weightKg; // kg - current weight
    userInfo.targetWeight = targetWeightKg; // kg - target weight
    userInfo.bfaType = ICBFAType.ICBFATypeWLA01; // Use WLA01 algorithm
    userInfo.enableMeasureImpendence = true; // Enable impedance measurement
    userInfo.enableMeasureHr = true; // Enable heart rate measurement

    print(
        "✅ Updating SDK user info: Name=$userName, Age=${userInfo.age}, Height=${userInfo.height}cm, Weight=${userInfo.weight}kg, Sex=${userInfo.sex}, DOB=${userDOB?.toString() ?? 'not set'}");
    
    try {
      IcBluetoothSdk.instance.updateUserInfo(userInfo);
    } catch (e) {
      print("❌ Error updating SDK user info: $e");
    }
  }

  void _startScan() {
    _requestPermissionsAndScan();
  }

  Future<void> _requestPermissionsAndScan() async {
    // Request runtime permissions required for BLE scanning
    // Use platform-specific permissions
    bool granted = false;
    
    if (Platform.isIOS) {
      // iOS: Only Location permission is required for BLE scanning
      // Bluetooth is handled automatically by iOS
      
      // First, check using native iOS method channel for accurate status
      bool nativeCheck = false;
      try {
        const platform = MethodChannel('com.mait.gym_attendance/permissions');
        nativeCheck = await platform.invokeMethod<bool>('checkLocationPermission') ?? false;
        print('📱 Native iOS Location permission check: $nativeCheck');
      } catch (e) {
        print('⚠️ Error checking native permission: $e');
      }
      
      // Also check using permission_handler as fallback
      final currentWhenInUse = await Permission.locationWhenInUse.status;
      final currentAlways = await Permission.location.status;
      print('📱 Permission_handler status - WhenInUse: $currentWhenInUse, Always: $currentAlways');
      
      // Use native check if available, otherwise use permission_handler
      // Note: Limited permission on iOS 14+ is sufficient for BLE scanning
      bool permissionHandlerCheck = currentWhenInUse.isGranted || 
          currentWhenInUse == PermissionStatus.limited ||
          currentAlways.isGranted ||
          currentAlways == PermissionStatus.limited;
      
      if (nativeCheck || permissionHandlerCheck) {
        String permissionType = 'Granted';
        if (currentWhenInUse == PermissionStatus.limited || currentAlways == PermissionStatus.limited) {
          permissionType = 'Limited (sufficient for BLE)';
        }
        print('✅ Location permission $permissionType - Native: $nativeCheck, WhenInUse: $currentWhenInUse, Always: $currentAlways');
        granted = true;
      } else {
        // Permission not granted - check if it's denied (can't request again)
        if (currentWhenInUse == PermissionStatus.denied || 
            currentWhenInUse == PermissionStatus.permanentlyDenied ||
            currentAlways == PermissionStatus.denied ||
            currentAlways == PermissionStatus.permanentlyDenied) {
          print('⚠️ Location permission denied - user must enable in Settings');
          if (mounted) {
            _waitingForPermissionRetry = true; // Set flag to retry when app resumes
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.orange, size: 28),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Location Permission Required',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location permission is required for Bluetooth scanning on iOS.',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How to enable:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '1. Tap "Open Settings" below\n'
                              '2. Go to Privacy & Security > Location Services\n'
                              '3. Find "Mr Muscle" and tap it\n'
                              '4. Select "While Using the App" or "Always"\n'
                              '5. Return to this app',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '💡 Tip: "While Using the App" is sufficient for Bluetooth scanning.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _waitingForPermissionRetry = false;
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        openAppSettings();
                        // Show a message that we'll auto-retry
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text(
                        //       'After enabling permission, return to this app and we\'ll automatically retry.',
                        //     ),
                        //     duration: const Duration(seconds: 4),
                        //     action: SnackBarAction(
                        //       label: 'OK',
                        //       onPressed: () {},
                        //     ),
                        //   ),
                        // );
                      },
                      icon: Icon(Icons.settings, size: 18),
                      label: Text('Open Settings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return;
        }
        
        // Permission not determined - request it
        print('📱 Requesting Location permission...');
        try {
          // Try native method first
          const platform = MethodChannel('com.mait.gym_attendance/permissions');
          final nativeGranted = await platform.invokeMethod<bool>('requestLocationPermission')
              .timeout(const Duration(seconds: 10), onTimeout: () => false) ?? false;
          
          // Wait for status to update
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Re-check using native method
          final finalNativeCheck = await platform.invokeMethod<bool>('checkLocationPermission') ?? false;
          
          // Also check permission_handler
          final finalWhenInUse = await Permission.locationWhenInUse.status;
          final finalAlways = await Permission.location.status;
          
          granted = finalNativeCheck || 
                    finalWhenInUse.isGranted || 
                    finalWhenInUse == PermissionStatus.limited ||
                    finalAlways.isGranted ||
                    finalAlways == PermissionStatus.limited;
          
          if (granted) {
            String permissionType = finalWhenInUse == PermissionStatus.limited || finalAlways == PermissionStatus.limited 
                ? 'Limited' 
                : 'Full';
            print('📱 iOS Permission after native request - Status: $permissionType, Native: $finalNativeCheck, WhenInUse: $finalWhenInUse, Always: $finalAlways');
          } else {
            print('📱 iOS Permission after native request - Not granted, WhenInUse: $finalWhenInUse, Always: $finalAlways');
          }
        } catch (e) {
          print('❌ Error using native permission channel: $e');
          // Fallback to permission_handler
          final locationStatus = await Permission.locationWhenInUse.request();
          await Future.delayed(const Duration(milliseconds: 300));
          final finalWhenInUse = await Permission.locationWhenInUse.status;
          final finalAlways = await Permission.location.status;
          
          granted = finalWhenInUse.isGranted || 
                    finalWhenInUse == PermissionStatus.limited ||
                    finalAlways.isGranted ||
                    finalAlways == PermissionStatus.limited;
          
          if (granted) {
            String permissionType = finalWhenInUse == PermissionStatus.limited || finalAlways == PermissionStatus.limited 
                ? 'Limited' 
                : 'Full';
            print('📱 iOS Permission after fallback request - Status: $permissionType, WhenInUse: $finalWhenInUse, Always: $finalAlways');
          } else {
            print('📱 iOS Permission after fallback request - Not granted, WhenInUse: $finalWhenInUse, Always: $finalAlways');
          }
        }
      }
    } else {
      // Android: Need Bluetooth and Location permissions
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      granted = statuses.values.every((s) => s.isGranted);
    }
    
    if (!granted) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text("Bluetooth/Location permissions are required to scan. Please enable Location Services in Settings."),
        //     duration: const Duration(seconds: 4),
        //   ),
        // );
      }
      print('❌ Permissions not granted - cannot scan');
      return;
    }
    
    print('✅ Permissions granted - proceeding with scan');

    setState(() {
      isScanning = true;
      _isMeasuring = false; // Reset measuring state when starting new scan
      _scanningSessionActive = true; // Mark scanning session as active
      devices.clear();
    });

    try {
      // Initialize SDK safely before scanning
      print("🔄 Initializing SDK before scanning...");
      bool sdkInitialized = await _initializeSDKWhenNeeded();

      if (!sdkInitialized) {
        setState(() {
          isScanning = false;
        });
        return;
      }

      // Ensure scan delegate is set before scanning (double-check)
      print("🔧 Setting scan delegate before scanning...");
      IcBluetoothSdk.instance.setDeviceScanDelegate(this);
      print("✅ Scan delegate set before scanning");
      print("📱 Delegate verification: ${this is ICScanDeviceDelegate}");
      
      // Wait a moment for delegate to be registered
      await Future.delayed(Duration(milliseconds: 500));
      
      // Start scan: IcBluetoothSdk uses a delegate callback pattern
      // The scanDevice method will also set the delegate, but we set it first to be safe
      print("🔍 Starting device scan...");
      print("📱 Platform: ${Platform.isIOS ? 'iOS' : 'Android'}");
      print("📱 Calling scanDevice with delegate: ${this.runtimeType}");
      print("📍 Location permission: granted");
      print("🔵 Bluetooth: enabled");
      print("📱 SDK: initialized");
      
      try {
        print("🚀 Invoking scanDevice...");
        IcBluetoothSdk.instance.scanDevice(this);
        print("✅ Scan command sent successfully - waiting for devices...");
        print("⏱️ Scan will run for up to 30 seconds. Devices should appear below.");
        print("💡 Make sure your scale is:");
        print("   1. Powered on");
        print("   2. In Bluetooth range (within 10 meters)");
        print("   3. Not connected to another device");
        print("   4. In pairing/scanning mode");
        
        // Set a timeout for scanning (30 seconds)
        _scanTimeoutTimer?.cancel();
        _scanTimeoutTimer = Timer(Duration(seconds: 30), () {
          if (isScanning && mounted) {
            print("⏰ Scan timeout reached (30 seconds)");
            _stopScan();
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(devices.isEmpty 
            //       ? "No devices found. Make sure your scale is powered on and nearby."
            //       : "Scan completed. Found ${devices.length} device(s)."),
            //     duration: Duration(seconds: 3),
            //     backgroundColor: devices.isEmpty ? Colors.orange : Colors.green,
            //   ),
            // );
          }
        });
      } catch (scanError) {
        print("❌ Error calling scanDevice: $scanError");
        print("❌ Error details: ${scanError.toString()}");
        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text("Failed to start scan: ${scanError.toString()}"),
          //     backgroundColor: Colors.red,
          //     duration: Duration(seconds: 4),
          //   ),
          // );
        }
        setState(() {
          isScanning = false;
        });
      }
    } catch (e) {
      print("❌ Error starting scan: $e");
      setState(() {
        isScanning = false;
      });
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(

        //   SnackBar(
        //     content: Text("Failed to start scanning: $e"),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      }
    }
  }

  void _stopScan() {
    _isMeasuring = false;
    // Cancel timeout timer
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = null;
    
    setState(() {
      isScanning = false;
      // Only end scanning session if we're not connected
      // If connected, keep session active so weight data continues to be accepted
      if (!isConnected) {
        _scanningSessionActive = false;
      }
    });

    try {
      IcBluetoothSdk.instance.stopScan();
      print("⏹️ Stopped scanning for devices");
    } catch (e) {
      print("❌ Error stopping scan: $e");
    }
  }

  void _connectToDevice(ICDevice device) {
    print("Attempting to connect to device: ${device.macAddr}");

    // Add device with callback
    IcBluetoothSdk.instance.addDevice(device, ICAddDeviceCallBack(
        callBack: (ICDevice connectedDevice, ICAddDeviceCallBackCode code) {
      print("Add device callback: code=$code");
      if (code == ICAddDeviceCallBackCode.ICAddDeviceCallBackCodeSuccess) {
        // Success - connection will be reported via onDeviceConnectionChanged
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Connecting to scale...")),
        // );
      } else {
        // Error
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Failed to connect to scale")),
        // );
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.scaffoldBackgroundColor
          : theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Body Composition",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(screenWidth * 0.05),
            bottomRight: Radius.circular(screenWidth * 0.05),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Status
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                final userProfile = profileProvider.userProfile;
                final displayName = userName.isNotEmpty ? _toTitleCase(userName) : "User";
                // Use gender from profile if available, otherwise use userSex
                final displayGender = userProfile?.gender != null 
                    ? _capitalizeFirst(userProfile!.gender!)
                    : (userSex == ICSexType.ICSexTypeMale ? 'Male' : 'Female');
                
                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenWidth * 0.03,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Image with gradient ring
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.008),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.tertiary,
                              ],
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.006),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.surface,
                            ),
                            child: Container(
                              width: screenWidth * 0.12,
                              height: screenWidth * 0.12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: userProfile?.profileImageUrl != null
                                    ? Image.network(
                                        userProfile!.profileImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildDefaultAvatar(screenWidth, displayName);
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return _buildLoadingAvatar(screenWidth);
                                        },
                                      )
                                    : _buildDefaultAvatar(screenWidth, displayName),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: screenWidth * 0.035),

                        // Profile Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Profile Set Title with badge style
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.025,
                                      vertical: screenWidth * 0.008,
                                    ),
                                    decoration: BoxDecoration(
                                      color: hasUserProfile
                                          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                                          : theme.colorScheme.errorContainer.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(screenWidth * 0.015),
                                    ),
                                    child: Text(
                                      hasUserProfile ? "Profile Set" : "Profile Required",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.032,
                                        fontWeight: FontWeight.bold,
                                        color: hasUserProfile
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (hasUserProfile) ...[
                                SizedBox(height: screenWidth * 0.015),
                                // Name
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.01),
                                // Details - Inline
                                Row(
                                  children: [
                                    _buildDetailChip(
                                      "Age: $userAge",
                                      screenWidth,
                                      theme,
                                      isFirst: true,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    _buildDetailChip(
                                      "H: ${userHeight != null ? userHeight!.toStringAsFixed(0) : 'N/A'}${useMetricUnits ? 'cm' : 'in'}",
                                      screenWidth,
                                      theme,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    _buildDetailChip(
                                      displayGender,
                                      screenWidth,
                                      theme,
                                    ),
                                  ],
                                ),
                              ] else ...[
                                SizedBox(height: screenWidth * 0.015),
                                // Show profile details if they are fetched, even if hasUserProfile is false
                                if (userName.isNotEmpty || userHeight != null || userDOB != null) ...[
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.01),
                                  Wrap(
                                    spacing: screenWidth * 0.02,
                                    runSpacing: screenWidth * 0.008,
                                    children: [
                                      _buildDetailChip(
                                        "Age: $userAge",
                                        screenWidth,
                                        theme,
                                        isFirst: true,
                                      ),
                                      _buildDetailChip(
                                        "H: ${userHeight != null ? userHeight!.toStringAsFixed(0) : 'N/A'}${useMetricUnits ? 'cm' : 'in'}",
                                        screenWidth,
                                        theme,
                                      ),
                                      _buildDetailChip(
                                        displayGender,
                                        screenWidth,
                                        theme,
                                      ),
                                    ],
                                  ),
                                  // Show message if details are missing
                                  if (_checkMissingDetails().isNotEmpty) ...[
                                    SizedBox(height: screenWidth * 0.012),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.025,
                                        vertical: screenWidth * 0.01,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                        border: Border.all(
                                          color: Colors.orange.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: screenWidth * 0.032,
                                            color: Colors.orange.shade700,
                                          ),
                                          SizedBox(width: screenWidth * 0.015),
                                          Flexible(
                                            child: Text(
                                              "Please fetch your details from the profile",
                                              style: TextStyle(
                                                color: Colors.orange.shade900,
                                                fontSize: screenWidth * 0.03,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ] else ...[
                                  Text(
                                    "Please fetch your details from the profile for accurate body composition measurements",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.032,
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: screenWidth * 0.04),

            // Connection Status
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                border: Border.all(
                  color: isConnected
                      ? Colors.green.withOpacity(0.5)
                      : Colors.orange.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isConnected
                            ? Colors.green
                            : Colors.orange)
                        .withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.025),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? Colors.green.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isConnected
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        color: isConnected
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        size: screenWidth * 0.06,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.035),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConnected
                                ? "Connected to Scale"
                                : "Not Connected",
                            style: TextStyle(
                              fontSize: screenWidth * 0.042,
                              fontWeight: FontWeight.bold,
                              color: isConnected
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                          if (isConnected) ...[
                            SizedBox(height: screenWidth * 0.008),
                            Text(
                              "Ready for measurement - step on the scale barefoot",
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ] else if (devices.isNotEmpty) ...[
                            SizedBox(height: screenWidth * 0.008),
                            Text(
                              "Found ${devices.length} device(s) - tap Connect to pair",
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ] else ...[
                            SizedBox(height: screenWidth * 0.008),
                            Text(
                              "Scan for scales to connect",
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenWidth * 0.04),

            // Control Buttons
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.025),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(screenWidth * 0.025),
                          ),
                          child: Icon(
                            Icons.settings_bluetooth,
                            color: theme.colorScheme.primary,
                            size: screenWidth * 0.055,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          "Scale Control",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    SizedBox(
                      width: double.infinity,
                      height: screenWidth * 0.13,
                      child: ElevatedButton.icon(
                        onPressed: (_isMeasuring || isScanning) ? _stopScan : _startScan,
                        icon: _isMeasuring
                            ? Icon(
                                Icons.analytics,
                                size: screenWidth * 0.055,
                              )
                            : isScanning
                                ? SizedBox(
                                    width: screenWidth * 0.055,
                                    height: screenWidth * 0.055,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.bluetooth_searching,
                                    size: screenWidth * 0.055,
                                  ),
                        label: Text(
                          _isMeasuring
                              ? "Measuring Data..."
                              : isScanning
                                  ? "Scanning..."
                                  : "Scan for Scales",
                          style: TextStyle(
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isMeasuring
                              ? Colors.green.shade600
                              : isScanning
                                  ? theme.colorScheme.primary.withOpacity(0.8)
                                  : theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: (_isMeasuring || isScanning) ? 2 : 4,
                          shadowColor: (_isMeasuring
                                  ? Colors.green
                                  : theme.colorScheme.primary)
                              .withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.035),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.025),
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.035),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(screenWidth * 0.025),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: screenWidth * 0.045,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: screenWidth * 0.025),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Important: Enable Bluetooth and Location",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.008),
                                Text(
                                  "Please enable Bluetooth and Location services before standing on the scale. This ensures accurate measurements and proper device connection.",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.032,
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isMeasuring) ...[
                      SizedBox(height: screenWidth * 0.025),
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.035),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(screenWidth * 0.025),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.045,
                              height: screenWidth * 0.045,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green.shade700,
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.025),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Measuring Data...",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.036,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.005),
                                  Text(
                                    "Please stay still on the scale. Measurement will complete automatically.",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.031,
                                      color: Colors.green.shade700.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (isScanning) ...[
                      SizedBox(height: screenWidth * 0.025),
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(screenWidth * 0.025),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bluetooth_searching,
                              size: screenWidth * 0.04,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Text(
                                "Make sure your scale is powered on and nearby",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.032,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: screenWidth * 0.06),

            // Scale Data Display
            if (lastData != null || hasStoredData) ...[
              Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? theme.cardColor : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: screenWidth * 0.038,
                      offset: Offset(0, screenWidth * 0.02),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
                            ),
                            child: Icon(
                              Icons.analytics,
                              color: theme.colorScheme.primary,
                              size: screenWidth * 0.06,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    lastData != null
                                        ? "Latest Measurement"
                                        : "Stored Measurement",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (lastData == null &&
                                    hasStoredData &&
                                    lastMeasurementTime != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: screenWidth * 0.01),
                                    child: Text(
                                      _getTimeAgo(lastMeasurementTime!),
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.032,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant
                                  .withOpacity(0.3),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.025),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _showMeasurementHistory(),
                                    borderRadius: BorderRadius.circular(screenWidth * 0.025),
                                    child: Container(
                                      padding: EdgeInsets.all(screenWidth * 0.03),
                                      child: Icon(
                                        Icons.history,
                                        color: theme.colorScheme.primary,
                                        size: screenWidth * 0.055,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: screenWidth * 0.08,
                                  color: theme.colorScheme.outline.withOpacity(0.2),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _showHealthRangesDialog(),
                                    borderRadius: BorderRadius.circular(screenWidth * 0.025),
                                    child: Container(
                                      padding: EdgeInsets.all(screenWidth * 0.03),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: theme.colorScheme.primary,
                                        size: screenWidth * 0.055,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.04),

                      // Main Measurements Grid
                      _buildMeasurementCard(
                        "Weight",
                        "${_getCurrentWeight().toStringAsFixed(1)} kg",
                        "Fat free body weight\n${(_getCurrentWeight() * (1 - _getCurrentBodyFat() / 100)).toStringAsFixed(1)} kg",
                        Icons.monitor_weight,
                        _getCurrentWeight(),
                        40, 100, // min, max for weight range
                        Colors.blue,
                        screenWidth,
                        theme,
                      ),

                      SizedBox(height: screenWidth * 0.03),

                      _buildMeasurementCard(
                        "Body Fat",
                        "${_getCurrentBodyFat().toStringAsFixed(1)}%",
                        "The proportion of adipose tissue versus muscle in a body",
                        Icons.fitness_center,
                        _getCurrentBodyFat(),
                        5, 35, // min, max for body fat range
                        _getBodyFatColor(_getCurrentBodyFat()),
                        screenWidth,
                        theme,
                      ),

                      SizedBox(height: screenWidth * 0.03),

                      _buildMeasurementCard(
                        "Subcutaneous Fat",
                        "${_getCurrentSubcutaneousFat().toStringAsFixed(1)}%",
                        "Subcutaneous adipose tissue (fat) lies between the dermis layer (skin) and fascia layer (connective tissue)",
                        Icons.layers,
                        _getCurrentSubcutaneousFat(),
                        5,
                        25,
                        _getSubcutaneousFatColor(_getCurrentSubcutaneousFat()),
                        screenWidth,
                        theme,
                      ),

                      SizedBox(height: screenWidth * 0.03),

                      _buildMeasurementCard(
                        "Visceral Fat",
                        "${_getCurrentVisceralFat().toStringAsFixed(1)}",
                        "Fat that wraps around your abdominal organs deep inside your body",
                        Icons.warning_amber,
                        _getCurrentVisceralFat(),
                        1,
                        20,
                        _getVisceralFatColor(_getCurrentVisceralFat()),
                        screenWidth,
                        theme,
                      ),

                      SizedBox(height: screenWidth * 0.03),

                      _buildMeasurementCard(
                        "Body Water",
                        "${_getCurrentWater().toStringAsFixed(1)}%",
                        "The percentage of fluid in the human body",
                        Icons.water_drop,
                        _getCurrentWater(),
                        45,
                        75,
                        Colors.cyan,
                        screenWidth,
                        theme,
                      ),

                      SizedBox(height: screenWidth * 0.03),

                      _buildMeasurementCard(
                        "Skeletal Muscle",
                        "${_getCurrentSkeletalMuscle().toStringAsFixed(1)}%",
                        "Muscle attached to bones that you can control voluntarily",
                        Icons.accessibility_new,
                        _getCurrentSkeletalMuscle(),
                        20,
                        60,
                        Colors.red,
                        screenWidth,
                        theme,
                      ),

                      if (_getCurrentProtein() > 0) ...[
                        SizedBox(height: screenWidth * 0.03),
                        _buildMeasurementCard(
                          "Protein",
                          "${_getCurrentProtein().toStringAsFixed(1)}%",
                          "Essential nutrients for the human body",
                          Icons.restaurant,
                          _getCurrentProtein(),
                          15,
                          25,
                          Colors.orange,
                          screenWidth,
                          theme,
                        ),
                      ],

                      SizedBox(height: screenWidth * 0.03),

                      _buildMeasurementCard(
                        "BMI",
                        "${(_getCurrentWeight() / ((175 / 100) * (175 / 100))).toStringAsFixed(1)}",
                        "Body Mass Index calculation",
                        Icons.calculate,
                        _getCurrentWeight() / ((175 / 100) * (175 / 100)),
                        15,
                        35,
                        _getBMIColor(
                            _getCurrentWeight() / ((175 / 100) * (175 / 100))),
                        screenWidth,
                        theme,
                      ),

                      SizedBox(height: screenWidth * 0.03),

                      _buildMeasurementCard(
                        "Muscle Rate",
                        "${_getCurrentMuscle().toStringAsFixed(1)}%",
                        "The proportion of muscle in your body",
                        Icons.fitness_center,
                        _getCurrentMuscle(),
                        25,
                        60,
                        Colors.purple,
                        screenWidth,
                        theme,
                      ),

                      SizedBox(height: screenWidth * 0.03),

                      if (_getCurrentBmr() > 0) ...[
                        _buildMeasurementCard(
                          "BMR",
                          "${_getCurrentBmr().toStringAsFixed(0)} kcal",
                          "Basal Metabolic Rate - calories burned at rest",
                          Icons.local_fire_department,
                          _getCurrentBmr(),
                          1200,
                          2500,
                          Colors.orange,
                          screenWidth,
                          theme,
                        ),
                      ],
                      SizedBox(height: screenWidth * 0.02),
                      Text(
                        lastData != null
                            ? "Measured: ${DateTime.now().toString().substring(11, 16)}"
                            : hasStoredData && lastMeasurementTime != null
                                ? "Measured: ${lastMeasurementTime!.toString().substring(0, 16)}"
                                : "No measurement time available",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (!hasStoredData) ...[
              Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? theme.cardColor : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: screenWidth * 0.038,
                      offset: Offset(0, screenWidth * 0.02),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.monitor_weight_outlined,
                          size: screenWidth * 0.12,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      Text(
                        "No measurements yet",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Text(
                        "To get body composition data:",
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: screenWidth * 0.035,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.04),
                          border: Border.all(
                              color:
                                  theme.colorScheme.outline.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            _buildInstructionStep("1", "Tap 'Scan for Scales'",
                                Icons.bluetooth_searching),
                            SizedBox(height: screenWidth * 0.025),
                            _buildInstructionStep("2", "Connect to your scale",
                                Icons.bluetooth_connected),
                            SizedBox(height: screenWidth * 0.025),
                            _buildInstructionStep(
                                "3",
                                "Step on the scale barefoot",
                                Icons.directions_walk),
                            SizedBox(height: screenWidth * 0.025),
                            _buildInstructionStep(
                                "4", "Wait for measurement", Icons.timer),
                          ],
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      SizedBox(
                        width: double.infinity,
                        height: screenWidth * 0.12,
                        child: ElevatedButton.icon(
                          onPressed: _startScan,
                          icon: Icon(Icons.bluetooth_searching,
                              size: screenWidth * 0.05),
                          label: Text(
                            "Scan for Scales",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            elevation: 4,
                            shadowColor:
                                theme.colorScheme.primary.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: screenWidth * 0.04),

            // Device List
            if (devices.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? theme.cardColor : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: screenWidth * 0.025,
                      offset: Offset(0, screenWidth * 0.01),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bluetooth,
                              color: theme.colorScheme.primary),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            "Found Devices (${devices.length})",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: screenWidth * 0.6,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            return Container(
                              margin:
                                  EdgeInsets.only(bottom: screenWidth * 0.02),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.03),
                                border: Border.all(
                                    color: theme.colorScheme.outline
                                        .withOpacity(0.2)),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03,
                                  vertical: screenWidth * 0.01,
                                ),
                                leading: Container(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.02),
                                  ),
                                  child: Icon(Icons.scale,
                                      color: theme.colorScheme.primary,
                                      size: screenWidth * 0.04),
                                ),
                                title: Text(
                                  "Body Composition",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                                subtitle: Text(
                                  "MAC: ${device.macAddr ?? 'Unknown'}",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () => _connectToDevice(device),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.03,
                                      vertical: screenWidth * 0.015,
                                    ),
                                  ),
                                  child: Text(
                                    "Connect",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                    ),
                                  ),
                                ),
                                onTap: () => _connectToDevice(device),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (isScanning) ...[
              Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? theme.cardColor : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: screenWidth * 0.025,
                      offset: Offset(0, screenWidth * 0.01),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary),
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      Text(
                        "Scanning for scales...",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Text(
                        "Make sure your scale is turned on and nearby",
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: screenWidth * 0.03,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      child: Row(
        children: [
          Icon(icon,
              size: screenWidth * 0.05, color: theme.colorScheme.primary),
          SizedBox(width: screenWidth * 0.02),
          Text(
            "$label:",
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
          Spacer(),
          Text(
            value,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(
      String stepNumber, String instruction, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: screenWidth * 0.06,
          height: screenWidth * 0.06,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.025,
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        Icon(icon, color: theme.colorScheme.primary, size: screenWidth * 0.04),
        SizedBox(width: screenWidth * 0.025),
        Expanded(
          child: Text(
            instruction,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: screenWidth * 0.03,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataRowWithStatus(
      String label, String value, IconData icon, String status) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(status),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(color: _getStatusColor(status), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon,
                  size: screenWidth * 0.05, color: _getStatusColor(status)),
              SizedBox(width: screenWidth * 0.02),
              Text(
                "$label:",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              Spacer(),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(status),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Row(
            children: [
              Container(
                width: screenWidth * 0.025,
                height: screenWidth * 0.025,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                _getStatusIcon(status),
                size: screenWidth * 0.04,
                color: _getStatusColor(status),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            _getStatusExplanation(label, status),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
              fontSize: screenWidth * 0.025,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPercentage(double value) {
    if (value <= 0) {
      return "Not measured";
    }
    return "${value.toStringAsFixed(1)}%";
  }

  String _getDataStatus(double value, String metric) {
    if (value <= 0) return "Not measured";

    switch (metric.toLowerCase()) {
      case 'body fat':
        if (value < 10) return "Below Standard";
        if (value <= 20) return "Good";
        if (value <= 25) return "Standard";
        return "Above Standard";
      case 'muscle':
        if (value < 30) return "Below Standard";
        if (value <= 40) return "Good";
        if (value <= 50) return "Standard";
        return "Above Standard";
      case 'water':
        if (value < 50) return "Below Standard";
        if (value <= 60) return "Good";
        if (value <= 70) return "Standard";
        return "Above Standard";
      case 'bone mass':
        if (value < 2.0) return "Below Standard";
        if (value <= 3.0) return "Good";
        if (value <= 4.0) return "Standard";
        return "Above Standard";
      default:
        return "Measured";
    }
  }

  Color _getStatusColor(String status) {
    final theme = Theme.of(context);
    switch (status) {
      case "Below Standard":
        return theme.colorScheme.error;
      case "Good":
        return Colors.green.shade600;
      case "Standard":
        return Colors.orange.shade600;
      case "Above Standard":
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.outline;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    final theme = Theme.of(context);
    switch (status) {
      case "Below Standard":
        return theme.colorScheme.error.withOpacity(0.1);
      case "Good":
        return Colors.green.shade50;
      case "Standard":
        return Colors.orange.shade50;
      case "Above Standard":
        return theme.colorScheme.error.withOpacity(0.1);
      default:
        return theme.colorScheme.surfaceVariant.withOpacity(0.3);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "Below Standard":
        return Icons.trending_down;
      case "Good":
        return Icons.trending_up;
      case "Standard":
        return Icons.trending_flat;
      case "Above Standard":
        return Icons.trending_down;
      default:
        return Icons.help_outline;
    }
  }

  // Helper methods to get current data (either from device or stored)
  String _getTimeAgo(DateTime dateTime) {
    final timeDiff = DateTime.now().difference(dateTime);

    if (timeDiff.inDays > 0) {
      return "${timeDiff.inDays} day${timeDiff.inDays > 1 ? 's' : ''} ago";
    } else if (timeDiff.inHours > 0) {
      return "${timeDiff.inHours} hour${timeDiff.inHours > 1 ? 's' : ''} ago";
    } else {
      return "${timeDiff.inMinutes} minute${timeDiff.inMinutes > 1 ? 's' : ''} ago";
    }
  }

  double _getCurrentWeight() {
    return lastData?.weight_kg ?? storedWeight;
  }

  double _getCurrentBodyFat() {
    return lastData?.bodyFatPercent ?? storedBodyFat;
  }

  double _getCurrentMuscle() {
    return lastData?.musclePercent ?? storedMuscle;
  }

  double _getCurrentWater() {
    return lastData?.moisturePercent ?? storedWater;
  }

  double _getCurrentBoneMass() {
    return lastData?.boneMass ?? storedBoneMass;
  }

  double _getCurrentBmr() {
    return lastData?.bmr.toDouble() ?? storedBmr;
  }

  double _getCurrentSubcutaneousFat() {
    return lastData?.subcutaneousFatPercent ?? storedSubcutaneousFat;
  }

  double _getCurrentVisceralFat() {
    return lastData?.visceralFat ?? storedVisceralFat;
  }

  double _getCurrentProtein() {
    return lastData?.proteinPercent ?? storedProtein;
  }

  double _getCurrentSkeletalMuscle() {
    return lastData?.smPercent ?? storedSkeletalMuscle;
  }

  // Helper widget for history chips
  Widget _buildHistoryChip(String label, String value, ThemeData theme, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // New enhanced measurement card widget
  Widget _buildMeasurementCard(
    String title,
    String value,
    String description,
    IconData icon,
    double currentValue,
    double minValue,
    double maxValue,
    Color primaryColor,
    double screenWidth,
    ThemeData theme,
  ) {
    final progress =
        ((currentValue - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final statusText = _getMeasurementStatus(title.toLowerCase(), currentValue);
    final statusColor =
        _getMeasurementStatusColor(title.toLowerCase(), currentValue);

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMeasurementDetails(
              title,
              value,
              description,
              currentValue,
              minValue,
              maxValue,
              primaryColor,
              statusText,
              statusColor),
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              children: [
                // Icon with circular progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        strokeWidth: 3,
                      ),
                    ),
                    Icon(
                      icon,
                      color: primaryColor,
                      size: screenWidth * 0.06,
                    ),
                  ],
                ),

                SizedBox(width: screenWidth * 0.04),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            size: screenWidth * 0.05,
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.025,
                              vertical: screenWidth * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.02),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: screenWidth * 0.02,
                                  height: screenWidth * 0.02,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.015),
                                Text(
                                  statusText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: screenWidth * 0.048,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Color helper methods
  Color _getBodyFatColor(double bodyFat) {
    if (bodyFat < 10) return Colors.blue;
    if (bodyFat < 15) return Colors.green;
    if (bodyFat < 20) return Colors.orange;
    if (bodyFat < 25) return Colors.red;
    return Colors.red.shade700;
  }

  Color _getSubcutaneousFatColor(double subFat) {
    if (subFat < 7) return Colors.green;
    if (subFat < 15) return Colors.yellow.shade700;
    return Colors.red;
  }

  Color _getVisceralFatColor(double visceralFat) {
    if (visceralFat < 6) return Colors.green;
    if (visceralFat < 10) return Colors.yellow.shade700;
    return Colors.red;
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getMeasurementStatus(String measurement, double value) {
    switch (measurement) {
      case 'body fat':
        if (value < 10) return "Low";
        if (value < 21) return "Standard";
        if (value < 26) return "High";
        return "Too High";
      case 'subcutaneous fat':
        if (value < 7) return "Low";
        if (value < 15) return "Standard";
        return "High";
      case 'visceral fat':
        if (value < 6) return "Low";
        if (value < 10) return "Standard";
        return "High";
      case 'body water':
        if (value < 50) return "Low";
        if (value < 65) return "Standard";
        return "High";
      case 'skeletal muscle':
        if (value < 30) return "Low";
        if (value < 50) return "Standard";
        return "High";
      case 'bmi':
        if (value < 18.5) return "Underweight";
        if (value < 25) return "Normal";
        if (value < 30) return "Overweight";
        return "Obese";
      default:
        return "Standard";
    }
  }

  Color _getMeasurementStatusColor(String measurement, double value) {
    final status = _getMeasurementStatus(measurement, value);
    switch (status) {
      case "Low":
      case "Underweight":
        return Colors.blue;
      case "Standard":
      case "Normal":
        return Colors.green;
      case "High":
      case "Overweight":
        return Colors.orange;
      case "Too High":
      case "Obese":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showMeasurementDetails(
    String title,
    String value,
    String description,
    double currentValue,
    double minValue,
    double maxValue,
    Color primaryColor,
    String statusText,
    Color statusColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: screenHeight * 0.7,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(screenWidth * 0.06),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.02),
              width: screenWidth * 0.1,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.timeline,
                          color: primaryColor,
                          size: screenWidth * 0.06,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Current value with large display
                    Center(
                      child: Column(
                        children: [
                          Text(
                            value,
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenWidth * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
                            ),
                            child: Text(
                              statusText,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Progress bar with ranges
                    _buildMeasurementGauge(currentValue, minValue, maxValue,
                        primaryColor, screenWidth, theme),

                    SizedBox(height: screenHeight * 0.03),

                    // Description
                    Text(
                      "About this measurement",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementGauge(
    double currentValue,
    double minValue,
    double maxValue,
    Color primaryColor,
    double screenWidth,
    ThemeData theme,
  ) {
    final progress =
        ((currentValue - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    
    // Calculate range segments for better visualization
    final range = maxValue - minValue;
    final lowThreshold = minValue + (range * 0.25);
    final standardThreshold = minValue + (range * 0.5);
    final highThreshold = minValue + (range * 0.75);

    return Column(
      children: [
        // Current value display
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                "Your Value: ${currentValue.toStringAsFixed(1)}",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: screenWidth * 0.03),

        // Range labels with thresholds
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Min: ${minValue.toStringAsFixed(0)}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Max: ${maxValue.toStringAsFixed(0)}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: screenWidth * 0.02),

        // Enhanced Gauge bar with segments
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            return Container(
              height: screenWidth * 0.04,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              child: Stack(
                children: [
                  // Segmented gradient background
                  Row(
                    children: [
                      Expanded(
                        flex: 25,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.6),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(screenWidth * 0.02),
                              bottomLeft: Radius.circular(screenWidth * 0.02),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 25,
                        child: Container(
                          color: Colors.green.withOpacity(0.6),
                        ),
                      ),
                      Expanded(
                        flex: 25,
                        child: Container(
                          color: Colors.orange.withOpacity(0.6),
                        ),
                      ),
                      Expanded(
                        flex: 25,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.6),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(screenWidth * 0.02),
                              bottomRight: Radius.circular(screenWidth * 0.02),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Current value indicator
                  Positioned(
                    left: (progress * barWidth) - (screenWidth * 0.02),
                    child: Container(
                      width: screenWidth * 0.04,
                      height: screenWidth * 0.04,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: screenWidth * 0.015,
                          height: screenWidth * 0.015,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        SizedBox(height: screenWidth * 0.03),

        // Detailed status labels with ranges
        Wrap(
          spacing: screenWidth * 0.02,
          runSpacing: screenWidth * 0.015,
          alignment: WrapAlignment.center,
          children: [
            _buildEnhancedStatusLabel(
              "Low",
              "${minValue.toStringAsFixed(0)}-${lowThreshold.toStringAsFixed(0)}",
              Colors.blue,
              screenWidth,
              theme,
            ),
            _buildEnhancedStatusLabel(
              "Standard",
              "${lowThreshold.toStringAsFixed(0)}-${standardThreshold.toStringAsFixed(0)}",
              Colors.green,
              screenWidth,
              theme,
            ),
            _buildEnhancedStatusLabel(
              "High",
              "${standardThreshold.toStringAsFixed(0)}-${highThreshold.toStringAsFixed(0)}",
              Colors.orange,
              screenWidth,
              theme,
            ),
            _buildEnhancedStatusLabel(
              "Too High",
              "${highThreshold.toStringAsFixed(0)}+",
              Colors.red,
              screenWidth,
              theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedStatusLabel(
      String label, String range, Color color, double screenWidth, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: screenWidth * 0.02,
                height: screenWidth * 0.02,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            range,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }


  String _getStatusExplanation(String label, String status) {
    switch (label.toLowerCase()) {
      case 'body fat':
        switch (status) {
          case "Below Standard":
            return "Very low body fat - may affect hormone production";
          case "Good":
            return "Healthy body fat percentage for your age/gender";
          case "Standard":
            return "Average body fat - consider improving diet/exercise";
          case "Above Standard":
            return "High body fat - focus on cardio and diet";
          default:
            return "Body fat measurement not available";
        }
      case 'muscle':
        switch (status) {
          case "Below Standard":
            return "Low muscle mass - increase protein and strength training";
          case "Good":
            return "Excellent muscle mass - maintain current routine";
          case "Standard":
            return "Average muscle mass - consider more resistance training";
          case "Above Standard":
            return "Very high muscle mass - excellent for athletes";
          default:
            return "Muscle mass measurement not available";
        }
      case 'water':
        switch (status) {
          case "Below Standard":
            return "Dehydrated - drink more water throughout the day";
          case "Good":
            return "Well hydrated - maintain current fluid intake";
          case "Standard":
            return "Adequate hydration - consider drinking more water";
          case "Above Standard":
            return "Very well hydrated - excellent fluid balance";
          default:
            return "Water percentage measurement not available";
        }
      case 'bone mass':
        switch (status) {
          case "Below Standard":
            return "Low bone density - increase calcium and weight training";
          case "Good":
            return "Strong bones - maintain calcium and exercise";
          case "Standard":
            return "Average bone mass - consider more weight-bearing exercise";
          case "Above Standard":
            return "Very strong bones - excellent bone health";
          default:
            return "Bone mass measurement not available";
        }
      default:
        return "Measurement status information";
    }
  }

  // Required delegate method implementations
  @override
  void onBleState(ICBleState state) {
    print("BLE State: $state");
  }

  @override
  void onInitFinish(bool bSuccess) {
    print("Init finished: $bSuccess");
  }

  @override
  void onNodeConnectionChanged(
      ICDevice device, int nodeId, ICDeviceConnectState state) {
    setState(() {
      isConnected = state == ICDeviceConnectState.ICDeviceConnectStateConnected;
    });
    print("Node connection changed: $nodeId - $state");
  }

  @override
  void onDeviceConnectionChanged(ICDevice device, ICDeviceConnectState state) {
    setState(() {
      isConnected = state == ICDeviceConnectState.ICDeviceConnectStateConnected;
      // End scanning session when device disconnects
      if (state != ICDeviceConnectState.ICDeviceConnectStateConnected) {
        _scanningSessionActive = false;
      }
    });
    print("Device connection changed: $state");

    // Reset tracking variables when device disconnects to allow new measurement session
    if (state != ICDeviceConnectState.ICDeviceConnectStateConnected) {
      _lastSavedStabilizedWeight = null;
      _lastSavedStabilizedTime = null;
    }

    // Show user feedback
    if (mounted) {
      String message;
      Color color;
      if (state == ICDeviceConnectState.ICDeviceConnectStateConnected) {
        message = "Connected to scale! Step on it to measure.";
        color = Colors.green;
      } else {
        message = "Disconnected from scale";
        color = Colors.red;
      }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(message),
      //     backgroundColor: color,
      //     duration: Duration(seconds: 2), // Shorter duration
      //     behavior: SnackBarBehavior.floating,
      //     margin: EdgeInsets.only(
      //       top: 60, // Position at top, below status bar
      //       left: 16,
      //       right: 16,
      //     ),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8),
      //     ),
      //   ),
      // );
    }
  }

  @override
  void onReceiveBattery(ICDevice device, int battery, Object ext) {
    print("Battery: $battery%");
  }

  @override
  void onReceiveConfigWifiResult(ICDevice device, ICConfigWifiState state) {
    print("WiFi config result: $state");
  }

  @override
  void onReceiveCoordData(ICDevice device, ICCoordData data) {
    print("Coord data received");
  }

  @override
  void onReceiveDebugData(ICDevice device, int type, Object obj) {
    print("Debug data received");
  }

  @override
  void onReceiveDeviceInfo(ICDevice device, ICDeviceInfo deviceInfo) {
    print("Device info received");
  }

  @override
  void onReceiveHR(ICDevice device, int hr) {
    print("Heart rate: $hr");
  }

  @override
  void onReceiveHistorySkipData(ICDevice device, ICSkipData data) {
    print("History skip data received");
  }

  @override
  void onReceiveKitchenScaleData(ICDevice device, ICKitchenScaleData data) {
    print("Kitchen scale data received");
  }

  @override
  void onReceiveKitchenScaleUnitChanged(
      ICDevice device, ICKitchenScaleUnit unit) {
    print("Kitchen scale unit changed");
  }

  @override
  void onReceiveMeasureStepData(
      ICDevice device, ICMeasureStep step, Object data) {
    print("Measure step: $step");
  }

  @override
  void onReceiveRulerData(ICDevice device, ICRulerData data) {
    print("Ruler data received");
  }

  @override
  void onReceiveRulerHistoryData(ICDevice device, ICRulerData data) {
    print("Ruler history data received");
  }

  @override
  void onReceiveRulerMeasureModeChanged(
      ICDevice device, ICRulerMeasureMode mode) {
    print("Ruler measure mode changed");
  }

  @override
  void onReceiveRulerUnitChanged(ICDevice device, ICRulerUnit unit) {
    print("Ruler unit changed");
  }

  @override
  void onReceiveSkipData(ICDevice device, ICSkipData data) {
    print("Skip data received");
  }

  @override
  void onReceiveUpgradePercent(
      ICDevice device, ICUpgradeStatus status, int percent) {
    print("Upgrade progress: $percent%");
  }

  @override
  void onReceiveWeightCenterData(ICDevice device, ICWeightCenterData data) {
    print("Weight center data received");
  }

  @override
  void onReceiveWeightHistoryData(ICDevice device, ICWeightHistoryData data) {
    print("Weight history data received");
    // History data might be different from real-time data
  }

  @override
  void onReceiveWeightUnitChanged(ICDevice device, ICWeightUnit unit) {
    print("Weight unit changed to: $unit");
  }

  // THIS IS THE KEY METHOD for real-time weight data with body composition
  @override
  void onReceiveWeightData(ICDevice device, ICWeightData data) {
    // Only process weight data when scanning session is active
    // This ensures weight is only updated when user has explicitly started scanning
    // Weight data is accepted during active scanning OR when connected (as result of scanning)
    if (!_scanningSessionActive) {
      print("⚠️ Weight data received but scanning session is not active - ignoring weight update");
      return;
    }

    print("=== WEIGHT DATA RECEIVED ===");
    print("Weight(kg): ${data.weight_kg}");
    print("Body fat %: ${data.bodyFatPercent}");
    print("Muscle %: ${data.musclePercent}");
    print("Water %: ${data.moisturePercent}");
    print("Bone mass kg: ${data.boneMass}");
    print("BMR: ${data.bmr} kcal");
    print("Subcutaneous Fat %: ${data.subcutaneousFatPercent}");
    print("Visceral fat: ${data.visceralFat}");
    print("Protein %: ${data.proteinPercent}");
    print("Skeletal muscle %: ${data.smPercent}");
    print("Is Stabilized: ${data.isStabilized}");
    print("Data Calc Type: ${data.data_calc_type}");
    print("BFA Type: ${data.bfa_type}");

    // Update measuring state: true if data is coming but not stabilized
    final wasMeasuring = _isMeasuring;
    _isMeasuring = !data.isStabilized && data.weight_kg > 0;

    setState(() {
      lastData = data;
      // Also update stored data variables with fresh device data
      hasStoredData = true;
      storedWeight = data.weight_kg;
      storedBmi = data.bmi;
      storedBodyFat = data.bodyFatPercent;
      storedMuscle = data.musclePercent;
      storedWater = data.moisturePercent;
      storedBoneMass = data.boneMass;
      storedBmr = data.bmr.toDouble();
      storedSubcutaneousFat = data.subcutaneousFatPercent;
      storedVisceralFat = data.visceralFat;
      storedProtein = data.proteinPercent;
      storedSkeletalMuscle = data.smPercent;
      lastMeasurementTime = DateTime.now();
    });

    // Only save and show success message when measurement is stabilized
    // This prevents multiple saves during weight fluctuations
    if (data.isStabilized) {
      // Stop measuring state
      _isMeasuring = false;
      
      // Auto-stop scanning after measurement is complete
      if (isScanning && mounted) {
        print("✅ Measurement stabilized - auto-stopping scan");
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && isScanning) {
            _stopScan();
          }
        });
      }

      // Check if we've already saved this stabilized measurement
      // Allow save if weight changed significantly (>0.1kg) or it's been more than 5 seconds since last save
      final now = DateTime.now();
      final shouldSave = _lastSavedStabilizedWeight == null ||
          (_lastSavedStabilizedTime != null &&
              (now.difference(_lastSavedStabilizedTime!).inSeconds > 5 ||
                  (data.weight_kg - _lastSavedStabilizedWeight!).abs() > 0.1));

      if (shouldSave) {
        // Update tracking variables
        _lastSavedStabilizedWeight = data.weight_kg;
        _lastSavedStabilizedTime = now;

        // Persist latest summary for home screen preview
        _saveLatestBodyComp(data);
      }
    } else if (!wasMeasuring && _isMeasuring) {
      // Just started measuring - update state
      setState(() {});
    }
  }

  Future<void> _saveLatestBodyComp(ICWeightData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch;

      // Save latest measurement data
      await prefs.setDouble('last_weight_kg', data.weight_kg);
      await prefs.setDouble('last_bmi', data.bmi);
      await prefs.setDouble('last_body_fat_percent', data.bodyFatPercent);
      await prefs.setDouble('last_muscle_percent', data.musclePercent);
      await prefs.setDouble('last_water_percent', data.moisturePercent);
      await prefs.setDouble('last_bone_mass_kg', data.boneMass);
      await prefs.setInt('last_measure_time', timestamp);

      // Save additional body composition data
      await prefs.setDouble('last_bmr', data.bmr.toDouble());
      await prefs.setDouble(
          'last_subcutaneous_fat_percent', data.subcutaneousFatPercent);
      await prefs.setDouble('last_visceral_fat', data.visceralFat);
      await prefs.setDouble('last_protein_percent', data.proteinPercent);
      await prefs.setDouble('last_sm_percent', data.smPercent);
      await prefs.setBool('last_is_stabilized', data.isStabilized);
      await prefs.setInt('last_data_calc_type', data.data_calc_type);
      await prefs.setInt('last_bfa_type', data.bfa_type?.index ?? 0);

      // Save measurement status for each metric
      await prefs.setString('last_body_fat_status',
          _getDataStatus(data.bodyFatPercent, "body fat"));
      await prefs.setString(
          'last_muscle_status', _getDataStatus(data.musclePercent, "muscle"));
      await prefs.setString(
          'last_water_status', _getDataStatus(data.moisturePercent, "water"));
      await prefs.setString(
          'last_bone_mass_status', _getDataStatus(data.boneMass, "bone mass"));

      // Save to measurement history
      await _saveToMeasurementHistory(data, timestamp);

      print("✅ Body composition data saved successfully");

      // Show success message at top (non-intrusive, won't block navigation bar)
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Row(
        //       children: [
        //         Icon(Icons.check_circle, color: Colors.white, size: 20),
        //         SizedBox(width: 8),
        //         Text("Measurement saved"),
        //       ],
        //     ),
        //     backgroundColor: Colors.green,
        //     duration: Duration(milliseconds: 1500), // Shorter duration
        //     behavior: SnackBarBehavior.floating,
        //     margin: EdgeInsets.only(
        //       top: 60, // Position at top, below status bar
        //       left: 16,
        //       right: 16,
        //     ),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //   ),
        // );
      }
    } catch (e) {
      print("❌ Error saving body composition data: $e");
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text("⚠️ Failed to save measurement data"),
        //     backgroundColor: Colors.red,
        //     duration: Duration(seconds: 2),
        //   ),
        // );
      }
    }
  }

  Future<void> _saveToMeasurementHistory(
      ICWeightData data, int timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing history
      final historyJson = prefs.getString('measurement_history') ?? '[]';
      final List<dynamic> history = jsonDecode(historyJson);

      // Create new measurement record
      final measurement = {
        'timestamp': timestamp,
        'date':
            DateTime.fromMillisecondsSinceEpoch(timestamp).toIso8601String(),
        'weight_kg': data.weight_kg,
        'bmi': data.bmi,
        'body_fat_percent': data.bodyFatPercent,
        'muscle_percent': data.musclePercent,
        'water_percent': data.moisturePercent,
        'bone_mass_kg': data.boneMass,
        'bmr': data.bmr.toDouble(),
        'subcutaneous_fat_percent': data.subcutaneousFatPercent,
        'visceral_fat': data.visceralFat,
        'protein_percent': data.proteinPercent,
        'sm_percent': data.smPercent,
        'is_stabilized': data.isStabilized,
        'data_calc_type': data.data_calc_type,
        'bfa_type': data.bfa_type?.index ?? 0,
        'body_fat_status': _getDataStatus(data.bodyFatPercent, "body fat"),
        'muscle_status': _getDataStatus(data.musclePercent, "muscle"),
        'water_status': _getDataStatus(data.moisturePercent, "water"),
        'bone_mass_status': _getDataStatus(data.boneMass, "bone mass"),
      };

      // Add to history (most recent first)
      history.insert(0, measurement);

      // Keep only last 50 measurements to prevent storage bloat
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }

      // Save updated history
      await prefs.setString('measurement_history', jsonEncode(history));
      await prefs.setInt('total_measurements', history.length);

      print("📈 Measurement added to history (${history.length} total)");
    } catch (e) {
      print("❌ Error saving to measurement history: $e");
    }
  }

  void _showHealthRangesDialog() {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: screenHeight * 0.85,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(screenWidth * 0.06),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.015),
                width: screenWidth * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(screenWidth * 0.025),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: screenWidth * 0.06,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Health Ranges Guide",
                            style: TextStyle(
                              fontSize: screenWidth * 0.048,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenWidth * 0.01),
                          Text(
                            "Reference values for body composition",
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurface,
                        size: screenWidth * 0.06,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRangeCard(
                        "Body fat %",
                        [
                          "Below Standard: <10% (Very Low)",
                          "Good: 10-20% (Healthy)",
                          "Standard: 20-25% (Average)",
                          "Above Standard: >25% (High)"
                        ],
                        isDark ? Colors.red.withOpacity(0.2) : Colors.red[50]!,
                        theme,
                        screenWidth,
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      _buildRangeCard(
                        "Muscle %",
                        [
                          "Below Standard: <30% (Low)",
                          "Good: 30-40% (Healthy)",
                          "Standard: 40-50% (Average)",
                          "Above Standard: >50% (High)"
                        ],
                        isDark ? Colors.green.withOpacity(0.2) : Colors.green[50]!,
                        theme,
                        screenWidth,
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      _buildRangeCard(
                        "Water %",
                        [
                          "Below Standard: <50% (Dehydrated)",
                          "Good: 50-60% (Well Hydrated)",
                          "Standard: 60-70% (Adequate)",
                          "Above Standard: >70% (Very Hydrated)"
                        ],
                        isDark ? Colors.blue.withOpacity(0.2) : Colors.blue[50]!,
                        theme,
                        screenWidth,
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      _buildRangeCard(
                        "Bone mass (kg)",
                        [
                          "Below Standard: <2.0kg (Low)",
                          "Good: 2.0-3.0kg (Healthy)",
                          "Standard: 3.0-4.0kg (Average)",
                          "Above Standard: >4.0kg (Strong)"
                        ],
                        isDark ? Colors.orange.withOpacity(0.2) : Colors.orange[50]!,
                        theme,
                        screenWidth,
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Text(
                                "Note: Ranges may vary based on age, gender, and fitness level. Consult a healthcare professional for personalized advice.",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.033,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom action
              Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.check,
                      size: screenWidth * 0.045,
                    ),
                    label: Text(
                      "Got it",
                      style: TextStyle(
                        fontSize: screenWidth * 0.038,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.035,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRangeCard(String title, List<String> ranges, Color color, ThemeData theme, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.042,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: screenWidth * 0.03),
          ...ranges.map((range) => Padding(
                padding: EdgeInsets.only(bottom: screenWidth * 0.02),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth * 0.015,
                      height: screenWidth * 0.015,
                      margin: EdgeInsets.only(
                        top: screenWidth * 0.01,
                        right: screenWidth * 0.025,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        range,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showMeasurementHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('measurement_history') ?? '[]';
      final List<dynamic> history = jsonDecode(historyJson);

      if (history.isEmpty) {
        return;
      }

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final theme = Theme.of(context);
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            height: screenHeight * 0.85,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(screenWidth * 0.06),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.015),
                  width: screenWidth * 0.12,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(screenWidth * 0.025),
                        ),
                        child: Icon(
                          Icons.history,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: screenWidth * 0.06,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Measurement History",
                              style: TextStyle(
                                fontSize: screenWidth * 0.048,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: screenWidth * 0.01),
                            Text(
                              "${history.length} ${history.length == 1 ? 'record' : 'records'}",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurface,
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
                
                // Content List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final measurement = history[index];
                      final date = DateTime.parse(measurement['date']);
                      final weight = measurement['weight_kg'] as double;
                      final bodyFat = measurement['body_fat_percent'] as double;
                      final muscle = measurement['muscle_percent'] as double;
                      final bmr = measurement['bmr'] as double? ?? 0.0;

                      return Container(
                        margin: EdgeInsets.only(bottom: screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Don't close the modal, just show detailed view on top
                              _showDetailedMeasurement(measurement);
                            },
                            borderRadius: BorderRadius.circular(screenWidth * 0.04),
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.045),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: screenWidth * 0.1,
                                        height: screenWidth * 0.1,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primaryContainer,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.04,
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.04),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${date.day}/${date.month}/${date.year}",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.042,
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: screenWidth * 0.01),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: screenWidth * 0.035,
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                                SizedBox(width: screenWidth * 0.015),
                                                Text(
                                                  "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.035,
                                                    color: theme.colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: theme.colorScheme.onSurfaceVariant,
                                        size: screenWidth * 0.06,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenWidth * 0.04),
                                  // Measurement chips in a row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildHistoryChip(
                                          "Weight",
                                          "${weight.toStringAsFixed(1)} kg",
                                          theme,
                                          screenWidth,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.025),
                                      Expanded(
                                        child: _buildHistoryChip(
                                          "Body fat",
                                          "${bodyFat.toStringAsFixed(1)}%",
                                          theme,
                                          screenWidth,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.025),
                                      Expanded(
                                        child: _buildHistoryChip(
                                          "Muscle",
                                          "${muscle.toStringAsFixed(1)}%",
                                          theme,
                                          screenWidth,
                                        ),
                                      ),
                                      if (bmr > 0) ...[
                                        SizedBox(width: screenWidth * 0.025),
                                        Expanded(
                                          child: _buildHistoryChip(
                                            "BMR",
                                            "${bmr.toStringAsFixed(0)} kcal",
                                            theme,
                                            screenWidth,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom actions
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _clearMeasurementHistory(),
                          icon: Icon(
                            Icons.delete_outline,
                            size: screenWidth * 0.045,
                          ),
                          label: Text(
                            "Clear History",
                            style: TextStyle(
                              fontSize: screenWidth * 0.038,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(
                              color: theme.colorScheme.error.withOpacity(0.5),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.035,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.check,
                            size: screenWidth * 0.045,
                          ),
                          label: Text(
                            "Close",
                            style: TextStyle(
                              fontSize: screenWidth * 0.038,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.035,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("Error loading measurement history: $e");
    }
  }

  void _showDetailedMeasurement(Map<String, dynamic> measurement) {
    final theme = Theme.of(context);
    final date = DateTime.parse(measurement['date']);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            "Measurement Details",
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                
                // Core measurements with ranges
                _buildEnhancedDetailRow(
                  "Weight",
                  "${measurement['weight_kg'].toStringAsFixed(1)} kg",
                  "Healthy range: 50-100 kg (varies by height)",
                  theme,
                ),
                _buildEnhancedDetailRow(
                  "BMI",
                  measurement['bmi'].toStringAsFixed(1),
                  _getBMIRangeInfo(double.parse(measurement['bmi'].toStringAsFixed(1))),
                  theme,
                  statusColor: _getBMIColor(double.parse(measurement['bmi'].toStringAsFixed(1))),
                ),
                _buildEnhancedDetailRow(
                  "Body fat",
                  "${measurement['body_fat_percent'].toStringAsFixed(1)}%",
                  _getBodyFatRangeInfo(measurement['body_fat_percent'] as double),
                  theme,
                  statusColor: _getBodyFatColor(measurement['body_fat_percent'] as double),
                ),
                _buildEnhancedDetailRow(
                  "Muscle",
                  "${measurement['muscle_percent'].toStringAsFixed(1)}%",
                  "Healthy range: 30-50% (varies by gender)",
                  theme,
                ),
                _buildEnhancedDetailRow(
                  "Water",
                  "${measurement['water_percent'].toStringAsFixed(1)}%",
                  _getWaterRangeInfo(measurement['water_percent'] as double),
                  theme,
                ),
                _buildEnhancedDetailRow(
                  "Bone mass",
                  "${measurement['bone_mass_kg'].toStringAsFixed(1)} kg",
                  "Healthy range: 2.0-4.0 kg (varies by gender)",
                  theme,
                ),
                _buildEnhancedDetailRow(
                  "BMR",
                  "${measurement['bmr'].toStringAsFixed(0)} kcal",
                  "Basal Metabolic Rate - calories burned at rest",
                  theme,
                ),
                if (measurement['subcutaneous_fat_percent'] > 0)
                  _buildEnhancedDetailRow(
                    "Subcutaneous Fat",
                    "${measurement['subcutaneous_fat_percent'].toStringAsFixed(1)}%",
                    _getSubcutaneousFatRangeInfo(measurement['subcutaneous_fat_percent'] as double),
                    theme,
                    statusColor: _getSubcutaneousFatColor(measurement['subcutaneous_fat_percent'] as double),
                  ),
                if (measurement['visceral_fat'] > 0)
                  _buildEnhancedDetailRow(
                    "Visceral fat",
                    measurement['visceral_fat'].toStringAsFixed(1),
                    _getVisceralFatRangeInfo(measurement['visceral_fat'] as double),
                    theme,
                    statusColor: _getVisceralFatColor(measurement['visceral_fat'] as double),
                  ),
                if (measurement['protein_percent'] > 0)
                  _buildEnhancedDetailRow(
                    "Protein",
                    "${measurement['protein_percent'].toStringAsFixed(1)}%",
                    "Healthy range: 15-25%",
                    theme,
                  ),
                if (measurement['sm_percent'] > 0)
                  _buildEnhancedDetailRow(
                    "Skeletal muscle",
                    "${measurement['sm_percent'].toStringAsFixed(1)}%",
                    "Healthy range: 30-50% (varies by gender)",
                    theme,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedDetailRow(String label, String value, String rangeInfo, ThemeData theme, {Color? statusColor}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: statusColor != null
            ? Border.all(color: statusColor.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  if (statusColor != null)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                      margin: EdgeInsets.only(right: 8),
                    ),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: statusColor ?? theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            rangeInfo,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getBMIRangeInfo(double bmi) {
    if (bmi < 18.5) return "Underweight - Consider consulting a nutritionist";
    if (bmi < 25) return "Normal weight - Maintain healthy lifestyle";
    if (bmi < 30) return "Overweight - Focus on diet and exercise";
    return "Obese - Consult healthcare professional";
  }

  String _getBodyFatRangeInfo(double bodyFat) {
    if (bodyFat < 10) return "Very Low (<10%) - May affect health";
    if (bodyFat < 21) return "Healthy (10-20%) - Good range";
    if (bodyFat < 26) return "Average (20-25%) - Consider improvement";
    return "High (>25%) - Focus on cardio and diet";
  }

  String _getWaterRangeInfo(double water) {
    if (water < 50) return "Low (<50%) - Increase water intake";
    if (water < 65) return "Good (50-65%) - Well hydrated";
    if (water < 70) return "Adequate (65-70%) - Maintain hydration";
    return "Very High (>70%) - Excellent hydration";
  }

  String _getSubcutaneousFatRangeInfo(double subFat) {
    if (subFat < 7) return "Low (<7%) - Very lean";
    if (subFat < 15) return "Healthy (7-15%) - Good range";
    return "High (>15%) - Consider reducing";
  }

  String _getVisceralFatRangeInfo(double visceralFat) {
    if (visceralFat < 6) return "Low (<6) - Excellent";
    if (visceralFat < 10) return "Moderate (6-10) - Monitor";
    return "High (>10) - Health risk - Consult doctor";
  }

  void _clearMeasurementHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('measurement_history');
      await prefs.setInt('total_measurements', 0);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Measurement history cleared"),
      //     backgroundColor: Colors.orange,
      //   ),
      // );

      Navigator.of(context).pop(); // Close the history dialog
    } catch (e) {
      print("Error clearing measurement history: $e");
    }
  }

  void _showUserProfileDialog() async {
    // Reload profile data before showing dialog to ensure DOB is up-to-date
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      if (profileProvider.userProfile == null) {
        await profileProvider.fetchUserProfile();
      }
      
      if (profileProvider.userProfile != null) {
        final profile = profileProvider.userProfile!;
        // Normalize birthday to local midnight to avoid timezone issues
        userDOB = profile.birthday != null ? _normalizeToLocalMidnight(profile.birthday!) : null;
        if (userDOB != null) {
          final now = DateTime.now();
          userAge = now.year - userDOB!.year;
          if (now.month < userDOB!.month ||
              (now.month == userDOB!.month && now.day < userDOB!.day)) {
            userAge--;
          }
        }
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final dobTimestamp = prefs.getInt('user_dob');
        if (dobTimestamp != null) {
          // Normalize to local midnight to avoid timezone issues
          final loadedDate = DateTime.fromMillisecondsSinceEpoch(dobTimestamp);
          userDOB = _normalizeToLocalMidnight(loadedDate);
          if (userDOB != null) {
            final now = DateTime.now();
            userAge = now.year - userDOB!.year;
            if (now.month < userDOB!.month ||
                (now.month == userDOB!.month && now.day < userDOB!.day)) {
              userAge--;
            }
          }
        }
      }
    } catch (e) {
      print("Error reloading profile before showing dialog: $e");
    }
    
    String tempName = userName;
    DateTime? tempDOB = userDOB;
    int tempAge = userAge;
    double tempHeight = userHeight ?? (useMetricUnits ? 175.0 : 69.0); // Default: 175cm or 69in
    double tempWeight = userWeight ?? (useMetricUnits ? 70.0 : 154.0); // Default: 70kg or 154lbs
    ICSexType tempSex = userSex;
    bool tempUseMetric = useMetricUnits;

    if (!mounted) return;
    
    // Create controllers once, before the dialog
    final heightController = TextEditingController(
      text: tempHeight.toStringAsFixed(0),
    );
    final weightController = TextEditingController(
      text: tempWeight.toStringAsFixed(1),
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Row(
                children: [
                  Icon(Icons.person,
                      color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 8),
                  Text(
                    "User Profile",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Complete profile for maximum measurement accuracy:",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Name Field
                    Builder(
                      builder: (context) {
                        final nameController = TextEditingController();
                        nameController.text = tempName;
                        nameController.selection = TextSelection.fromPosition(
                          TextPosition(offset: tempName.length),
                        );

                        return TextField(
                          controller: nameController,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            hintText: "Enter your name",
                            hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.6),
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              tempName = value;
                            });
                          },
                        );
                      },
                    ),

                    SizedBox(height: 16),

                    // Date of Birth
                    Text("Date of Birth:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: tempDOB != null ? _normalizeToLocalMidnight(tempDOB!) : DateTime(1990),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setDialogState(() {
                            // Normalize to local midnight to ensure consistent date handling
                            tempDOB = _normalizeToLocalMidnight(date);
                            tempAge = DateTime.now().year - tempDOB!.year;
                            if (DateTime.now().month < tempDOB!.month ||
                                (DateTime.now().month == tempDOB!.month &&
                                    DateTime.now().day < tempDOB!.day)) {
                              tempAge--;
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 8),
                            Text(
                              tempDOB != null
                                  ? "${tempDOB!.day}/${tempDOB!.month}/${tempDOB!.year}"
                                  : "Select your date of birth",
                              style: TextStyle(
                                color: tempDOB != null
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Gender Selection - Using SegmentedButton for better responsiveness
                    Text("Gender:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                    SizedBox(height: 8),
                    SegmentedButton<ICSexType>(
                      segments: [
                        ButtonSegment<ICSexType>(
                          value: ICSexType.ICSexTypeMale,
                          label: Text('Male'),
                          icon: Icon(Icons.male, size: 18),
                        ),
                        ButtonSegment<ICSexType>(
                          value: ICSexType.ICSexTypeFemale,
                          label: Text('Female'),
                          icon: Icon(Icons.female, size: 18),
                        ),
                      ],
                      selected: {tempSex},
                      onSelectionChanged: (Set<ICSexType> newSelection) {
                        setDialogState(() {
                          tempSex = newSelection.first;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                        selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Unit System - Using SegmentedButton for better responsiveness
                    Text("Unit System:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                    SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('Metric'),
                          tooltip: 'cm, kg',
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Imperial'),
                          tooltip: 'in, lbs',
                        ),
                      ],
                      selected: {tempUseMetric},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setDialogState(() {
                          final newValue = newSelection.first;
                          // Convert values when switching units
                          if (newValue) {
                            // Convert from imperial to metric
                            tempHeight = tempHeight * 2.54;
                            tempWeight = tempWeight * 0.453592;
                          } else {
                            // Convert from metric to imperial
                            tempHeight = tempHeight / 2.54;
                            tempWeight = tempWeight / 0.453592;
                          }
                          tempUseMetric = newValue;
                          // Update controllers to reflect unit conversion
                          heightController.text = tempHeight.toStringAsFixed(0);
                          heightController.selection = TextSelection.collapsed(offset: heightController.text.length);
                          weightController.text = tempWeight.toStringAsFixed(1);
                          weightController.selection = TextSelection.collapsed(offset: weightController.text.length);
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                        selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Height with +/- buttons and text input
                    Text("Height:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        // Decrease button
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              final step = tempUseMetric ? 1.0 : 1.0; // 1cm or 1in
                              final min = tempUseMetric ? 100.0 : 39.0;
                              tempHeight = (tempHeight - step).clamp(min, tempUseMetric ? 250.0 : 98.0);
                              // Update controller to reflect the change
                              heightController.text = tempHeight.toStringAsFixed(0);
                              heightController.selection = TextSelection.collapsed(offset: heightController.text.length);
                            });
                          },
                          icon: Icon(Icons.remove_circle_outline),
                          color: Theme.of(context).colorScheme.primary,
                          iconSize: 32,
                        ),
                        // Text input field
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.numberWithOptions(decimal: false),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: tempUseMetric ? '175' : '69',
                              suffixText: tempUseMetric ? 'cm' : 'in',
                              suffixStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed != null) {
                                final min = tempUseMetric ? 100.0 : 39.0;
                                final max = tempUseMetric ? 250.0 : 98.0;
                                setDialogState(() {
                                  tempHeight = parsed.clamp(min, max);
                                });
                              }
                            },
                          ),
                        ),
                        // Increase button
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              final step = tempUseMetric ? 1.0 : 1.0; // 1cm or 1in
                              final max = tempUseMetric ? 250.0 : 98.0;
                              tempHeight = (tempHeight + step).clamp(tempUseMetric ? 100.0 : 39.0, max);
                              // Update controller to reflect the change
                              heightController.text = tempHeight.toStringAsFixed(0);
                              heightController.selection = TextSelection.collapsed(offset: heightController.text.length);
                            });
                          },
                          icon: Icon(Icons.add_circle_outline),
                          color: Theme.of(context).colorScheme.primary,
                          iconSize: 32,
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Current Weight with +/- buttons and text input
                    Text("Current Weight:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        // Decrease button
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              final step = tempUseMetric ? 0.5 : 1.0; // 0.5kg or 1lb
                              final min = tempUseMetric ? 30.0 : 66.0;
                              tempWeight = (tempWeight - step).clamp(min, tempUseMetric ? 200.0 : 440.0);
                              // Update controller to reflect the change
                              weightController.text = tempWeight.toStringAsFixed(1);
                              weightController.selection = TextSelection.collapsed(offset: weightController.text.length);
                            });
                          },
                          icon: Icon(Icons.remove_circle_outline),
                          color: Theme.of(context).colorScheme.primary,
                          iconSize: 32,
                        ),
                        // Text input field
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: tempUseMetric ? '70.0' : '154.0',
                              suffixText: tempUseMetric ? 'kg' : 'lbs',
                              suffixStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed != null) {
                                final min = tempUseMetric ? 30.0 : 66.0;
                                final max = tempUseMetric ? 200.0 : 440.0;
                                setDialogState(() {
                                  tempWeight = parsed.clamp(min, max);
                                });
                              }
                            },
                          ),
                        ),
                        // Increase button
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              final step = tempUseMetric ? 0.5 : 1.0; // 0.5kg or 1lb
                              final max = tempUseMetric ? 200.0 : 440.0;
                              tempWeight = (tempWeight + step).clamp(tempUseMetric ? 30.0 : 66.0, max);
                              // Update controller to reflect the change
                              weightController.text = tempWeight.toStringAsFixed(1);
                              weightController.selection = TextSelection.collapsed(offset: weightController.text.length);
                            });
                          },
                          icon: Icon(Icons.add_circle_outline),
                          color: Theme.of(context).colorScheme.primary,
                          iconSize: 32,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info,
                                  color: Colors.blue[600], size: 16),
                              SizedBox(width: 8),
                              Text(
                                "Why is this important?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "• Name: Personal identification\n• DOB: Accurate age calculation\n• Gender: Body fat % varies by sex\n• Height: Affects muscle mass calculations\n• Units: Choose your preferred measurement system",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Close dialog first to avoid context issues
                    Navigator.of(context).pop();
                    
                    // Save profile after dialog is closed
                    if (mounted) {
                      await _saveUserProfile(
                        tempName,
                        tempDOB,
                        tempAge,
                        tempHeight,
                        tempWeight,
                        tempSex,
                        tempUseMetric,
                      );
                    }
                  },
                  child: Text("Save Profile"),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Dispose controllers when dialog is closed
      try {
        heightController.dispose();
      } catch (e) {
        // Controller already disposed, ignore
      }
      try {
        weightController.dispose();
      } catch (e) {
        // Controller already disposed, ignore
      }
    });
  }

  Future<void> _saveUserProfile(
      String name,
      DateTime? dob,
      int age,
      double height,
      double weight,
      ICSexType sex,
      bool useMetric) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save user profile data
      await prefs.setString('user_name', name);
      await prefs.setInt('user_age', age);
      await prefs.setDouble('user_height', height);
      await prefs.setDouble('user_weight', weight);
      await prefs.setInt('user_sex', sex.index);
      await prefs.setBool('use_metric_units', useMetric);
      await prefs.setBool('has_user_profile', true);

      // Save DOB if provided (normalize to local midnight before saving)
      if (dob != null) {
        final normalizedDOB = _normalizeToLocalMidnight(dob);
        await prefs.setInt('user_dob', normalizedDOB.millisecondsSinceEpoch);
      }

      // Update local variables only if widget is still mounted
      if (mounted) {
        setState(() {
          userName = name;
          userDOB = dob != null ? _normalizeToLocalMidnight(dob) : null;
          userAge = age;
          userHeight = height;
          userWeight = weight;
          userSex = sex;
          useMetricUnits = useMetric;
          hasUserProfile = true;
        });

        // Update SDK with new user info
        _updateUserInfo();
      }

      // Note: Dialog is already closed, no need to pop again

      // ScaffoldMessenger.of(context).showSnackBar(


      //         SnackBar(


      //     content: Text(
      //         "✅ Profile saved! Measurements will now be highly accurate."),
      //     backgroundColor: Colors.green,
      //     duration: Duration(seconds: 3),
      //   ),
      // );
    } catch (e) {
      print("Error saving user profile: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("❌ Failed to save profile"),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }

  // ICScanDeviceDelegate
  @override
  void onScanResult(ICScanDeviceInfo deviceInfo) {
    print("═══════════════════════════════════════");
    print("📱 onScanResult CALLED - Device Found!");
    print("   MAC: ${deviceInfo.macAddr}");
    print("   Name: ${deviceInfo.name ?? 'Unknown'}");
    print("   Type: ${deviceInfo.type}");
    print("   RSSI: ${deviceInfo.rssi}");
    print("═══════════════════════════════════════");
    
    if (!mounted) {
      print("⚠️ Widget not mounted, skipping device addition");
      return;
    }
    
    setState(() {
      final mac = deviceInfo.macAddr;
      // Add any advertising device; use MAC if available, otherwise skip duplicates by name
      if (mac != null && mac.isNotEmpty) {
        if (!devices.any((d) => d.macAddr == mac)) {
          devices.add(ICDevice(mac));
          print("✅ Added device to list: $mac (Total devices: ${devices.length})");
          
          // Show success message
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text("Found device: ${deviceInfo.name ?? mac}"),
          //     duration: Duration(seconds: 2),
          //     backgroundColor: Colors.green,
          //   ),
          // );
        } else {
          print("⚠️ Device already in list: $mac");
        }
      } else {
        print("⚠️ Device has no MAC address, skipping");
      }
    });

    // Optionally auto-add likely scale devices (relaxed filter: any non-unknown with MAC)
    if (deviceInfo.macAddr != null &&
        deviceInfo.macAddr!.isNotEmpty &&
        deviceInfo.type != ICDeviceType.ICDeviceTypeUnKnown) {
      print("🔄 Attempting to auto-add device: ${deviceInfo.macAddr}");
      final dev = ICDevice(deviceInfo.macAddr);
      IcBluetoothSdk.instance.addDevice(dev,
          ICAddDeviceCallBack(callBack: (icDevice, code) {
        // Connection will be reported via onDeviceConnectionChanged when available
        print("📱 Auto-add device callback: $code for device ${icDevice.macAddr}");
        if (code == ICAddDeviceCallBackCode.ICAddDeviceCallBackCodeSuccess) {
          print("✅ Device added successfully!");
          if (mounted) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text("Device connected: ${icDevice.macAddr}"),
            //     backgroundColor: Colors.green,
            //     duration: Duration(seconds: 2),
            //   ),
            // );
          }
        } else {
          print("❌ Failed to add device: $code");
        }
      }));
    } else {
      print("⚠️ Skipping auto-add - MAC: ${deviceInfo.macAddr}, Type: ${deviceInfo.type}");
    }
  }

  // Helper methods for profile display
  /// Capitalizes the first letter of a string (e.g., "male" -> "Male")
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Converts a string to title case (e.g., "john doe" -> "John Doe")
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildDefaultAvatar(double screenWidth, String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: SizedBox(
          width: screenWidth * 0.04,
          height: screenWidth * 0.04,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text, double screenWidth, ThemeData theme, {bool isFirst = false}) {
    return Container(
      padding: EdgeInsets.only(
        left: isFirst ? 0 : screenWidth * 0.02,
        right: screenWidth * 0.02,
        top: screenWidth * 0.006,
        bottom: screenWidth * 0.006,
      ),
      margin: EdgeInsets.only(left: isFirst ? 0 : 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(screenWidth * 0.015),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenWidth * 0.031,
          color: theme.colorScheme.onSurface.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}