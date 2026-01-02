import Flutter
import UIKit
import CoreLocation
import CoreBluetooth
import CoreMotion
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
  private var locationManager: CLLocationManager?
  private var locationPermissionResult: FlutterResult?
  private var bluetoothManager: CBPeripheralManager?
  private var pedometer: CMPedometer?
  private var stepUpdateTimer: Timer?
  private var lastStepCount: Int = 0
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Request notification permissions
    requestNotificationPermission()
    
    // Set up method channels as soon as possible
    DispatchQueue.main.async { [weak self] in
      self?.setupPermissionChannel()
      self?.setupHelperChannel()
      self?.setupStepTrackingChannel()
    }
    
    // Start step tracking in background
    startBackgroundStepTracking()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Required for notifications
  }
  
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    // Required for notifications
  }
  
  private func setupPermissionChannel() {
    // Try to get the FlutterViewController from the window
    var controller: FlutterViewController?
    
    if let window = self.window, let rootViewController = window.rootViewController as? FlutterViewController {
      controller = rootViewController
    } else {
      // If window isn't ready, try again after a delay
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
        self?.setupPermissionChannel()
      }
      return
    }
    
    guard let flutterController = controller else {
      // Retry after a short delay if controller isn't ready
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
        self?.setupPermissionChannel()
      }
      return
    }
    
    let permissionChannel = FlutterMethodChannel(
      name: "com.mait.gym_attendance/permissions",
      binaryMessenger: flutterController.binaryMessenger
    )
    
    permissionChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      
      if call.method == "requestLocationPermission" {
        self.requestLocationPermission(result: result)
      } else if call.method == "checkLocationPermission" {
        self.checkLocationPermission(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    print("✅ Permission method channel set up successfully")
  }
  
  private func setupHelperChannel() {
    // Try to get the FlutterViewController from the window
    var controller: FlutterViewController?
    
    if let window = self.window, let rootViewController = window.rootViewController as? FlutterViewController {
      controller = rootViewController
    } else {
      // If window isn't ready, try again after a delay
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
        self?.setupHelperChannel()
      }
      return
    }
    
    guard let flutterController = controller else {
      // Retry after a short delay if controller isn't ready
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
        self?.setupHelperChannel()
      }
      return
    }
    
    let helperChannel = FlutterMethodChannel(
      name: "flutter.native/helper",
      binaryMessenger: flutterController.binaryMessenger
    )
    
    helperChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      
      switch call.method {
      case "isBluetoothEnabled":
        self.checkBluetoothEnabled(result: result)
      case "isLocationEnabled":
        self.checkLocationEnabled(result: result)
      case "startStepCounterService":
        self.startBackgroundStepTracking()
        result(true)
      case "stopStepCounterService":
        self.stopBackgroundStepTracking()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    print("✅ Helper method channel set up successfully")
  }

  private func setupStepTrackingChannel() {
    var controller: FlutterViewController?
    
    if let window = self.window, let rootViewController = window.rootViewController as? FlutterViewController {
      controller = rootViewController
    } else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
        self?.setupStepTrackingChannel()
      }
      return
    }
    
    guard let flutterController = controller else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
        self?.setupStepTrackingChannel()
      }
      return
    }
    
    let stepChannel = FlutterMethodChannel(
      name: "flutter.native/step_tracking",
      binaryMessenger: flutterController.binaryMessenger
    )
    
    stepChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      
      switch call.method {
      case "getCurrentSteps":
        self.getCurrentSteps(result: result)
      case "startTracking":
        self.startBackgroundStepTracking()
        result(true)
      case "stopTracking":
        self.stopBackgroundStepTracking()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    print("✅ Step tracking method channel set up successfully")
  }
  
  private func checkBluetoothEnabled(result: @escaping FlutterResult) {
    if bluetoothManager == nil {
      bluetoothManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // On iOS, check Bluetooth state
    let state = bluetoothManager?.state ?? .unknown
    let isEnabled = (state == .poweredOn)
    
    print("🔵 iOS Bluetooth state: \(state.rawValue), Enabled: \(isEnabled)")
    result(isEnabled)
  }
  
  private func checkLocationEnabled(result: @escaping FlutterResult) {
    let status = CLLocationManager.authorizationStatus()
    let locationServicesEnabled = CLLocationManager.locationServicesEnabled()
    let isAuthorized = (status == .authorizedWhenInUse || status == .authorizedAlways)
    
    let isEnabled = locationServicesEnabled && isAuthorized
    
    print("📍 iOS Location services enabled: \(locationServicesEnabled), Authorized: \(isAuthorized), Enabled: \(isEnabled)")
    result(isEnabled)
  }
  
  // MARK: - CBPeripheralManagerDelegate
  
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    // Bluetooth state updated
    print("🔵 Bluetooth state updated: \(peripheral.state.rawValue)")
  }
  
  private func requestLocationPermission(result: @escaping FlutterResult) {
    locationPermissionResult = result
    
    if locationManager == nil {
      locationManager = CLLocationManager()
      locationManager?.delegate = self
    }
    
    let status = CLLocationManager.authorizationStatus()
    print("📍 iOS Location permission status: \(status.rawValue)")
    
    switch status {
    case .notDetermined:
      // Request permission - this will show the native iOS dialog
      print("📍 Requesting location permission - will show native iOS dialog")
      locationManager?.requestWhenInUseAuthorization()
      // Don't call result yet - wait for delegate callback
    case .authorizedWhenInUse, .authorizedAlways:
      print("📍 Location permission already granted")
      result(true)
      locationPermissionResult = nil
    case .denied:
      // Permission was denied - try requesting again (iOS might show dialog)
      print("📍 Location permission denied - attempting to request again")
      locationManager?.requestWhenInUseAuthorization()
      // Wait for delegate callback
    case .restricted:
      print("📍 Location permission restricted - user needs to go to Settings")
      result(false)
      locationPermissionResult = nil
    @unknown default:
      print("📍 Unknown location permission status")
      result(false)
      locationPermissionResult = nil
    }
  }
  
  private func checkLocationPermission(result: @escaping FlutterResult) {
    let status = CLLocationManager.authorizationStatus()
    result(status == .authorizedWhenInUse || status == .authorizedAlways)
  }
  
  // MARK: - CLLocationManagerDelegate
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    print("� Location authorization changed to: \(status.rawValue)")
    
    guard let result = locationPermissionResult else {
      // Permission was already handled or no callback waiting
      print("📍 No permission result callback waiting")
      return
    }
    
    switch status {
    case .authorizedWhenInUse:
      print("📍 Location permission granted: When In Use")
      result(true)
      locationPermissionResult = nil
    case .authorizedAlways:
      print("� Location permission granted: Always")
      result(true)
      locationPermissionResult = nil
    case .denied:
      print("📍 Location permission denied")
      result(false)
      locationPermissionResult = nil
    case .restricted:
      print("📍 Location permission restricted")
      result(false)
      locationPermissionResult = nil
    case .notDetermined:
      // Still waiting for user response - don't call result yet
      print("📍 Location permission still not determined - waiting for user")
      break
    @unknown default:
      print("� Unknown location permission status")
      result(false)
      locationPermissionResult = nil
    }
  }

  // MARK: - Step Tracking

  private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if granted {
        print("✅ Notification permission granted")
      } else {
        print("❌ Notification permission denied: \(error?.localizedDescription ?? "unknown")")
      }
    }
  }

  private func startBackgroundStepTracking() {
    guard CMPedometer.isStepCountingAvailable() else {
      print("❌ Step counting not available on this device")
      return
    }

    if pedometer == nil {
      pedometer = CMPedometer()
    }

    let calendar = Calendar.current
    let now = Date()
    let startOfDay = calendar.startOfDay(for: now)

    pedometer?.startUpdates(from: startOfDay) { [weak self] data, error in
      guard let self = self, let data = data else {
        if let error = error {
          print("❌ Error getting step data: \(error.localizedDescription)")
        }
        return
      }

      let steps = data.numberOfSteps.intValue
      self.lastStepCount = steps

      // Update SharedPreferences (Flutter format)
      let prefs = UserDefaults.standard
      let prefsName = "FlutterSharedPreferences"
      let sharedPrefs = UserDefaults(suiteName: prefsName) ?? UserDefaults.standard

      // Get current date string
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let todayString = dateFormatter.string(from: now)

      // Save steps
      sharedPrefs.set(steps, forKey: "flutter.daily_steps")
      sharedPrefs.set(todayString, forKey: "flutter.steps_date")
      sharedPrefs.synchronize()

      print("📱 iOS Step count updated: \(steps) steps")

      // Update notification every 100 steps or every 5 minutes
      if steps % 100 == 0 || self.shouldUpdateNotification() {
        self.updateStepNotification(steps: steps)
      }
    }

    // Start periodic updates every 2 minutes
    stepUpdateTimer = Timer.scheduledTimer(withTimeInterval: 120.0, repeats: true) { [weak self] _ in
      self?.updateStepCountFromPedometer()
    }

    print("✅ Started background step tracking on iOS")
  }

  private func stopBackgroundStepTracking() {
    pedometer?.stopUpdates()
    stepUpdateTimer?.invalidate()
    stepUpdateTimer = nil
    print("⏹️ Stopped background step tracking on iOS")
  }

  private func updateStepCountFromPedometer() {
    guard let pedometer = pedometer else { return }

    let calendar = Calendar.current
    let now = Date()
    let startOfDay = calendar.startOfDay(for: now)

    pedometer.queryPedometerData(from: startOfDay, to: now) { [weak self] data, error in
      guard let self = self, let data = data else {
        return
      }

      let steps = data.numberOfSteps.intValue
      self.lastStepCount = steps

      // Update SharedPreferences
      let prefsName = "FlutterSharedPreferences"
      let sharedPrefs = UserDefaults(suiteName: prefsName) ?? UserDefaults.standard

      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let todayString = dateFormatter.string(from: now)

      sharedPrefs.set(steps, forKey: "flutter.daily_steps")
      sharedPrefs.set(todayString, forKey: "flutter.steps_date")
      sharedPrefs.synchronize()

      self.updateStepNotification(steps: steps)
    }
  }

  private func getCurrentSteps(result: @escaping FlutterResult) {
    guard let pedometer = pedometer else {
      result(0)
      return
    }

    let calendar = Calendar.current
    let now = Date()
    let startOfDay = calendar.startOfDay(for: now)

    pedometer.queryPedometerData(from: startOfDay, to: now) { data, error in
      if let data = data {
        let steps = data.numberOfSteps.intValue
        result(steps)
      } else {
        result(0)
      }
    }
  }

  private var lastNotificationUpdate: Date?
  private func shouldUpdateNotification() -> Bool {
    guard let lastUpdate = lastNotificationUpdate else {
      lastNotificationUpdate = Date()
      return true
    }
    return Date().timeIntervalSince(lastUpdate) >= 300 // 5 minutes
  }

  private func updateStepNotification(steps: Int) {
    let content = UNMutableNotificationContent()
    content.title = "Step Counter Active"
    
    // Get daily goal from SharedPreferences
    let prefsName = "FlutterSharedPreferences"
    let sharedPrefs = UserDefaults(suiteName: prefsName) ?? UserDefaults.standard
    let dailyGoal = sharedPrefs.integer(forKey: "flutter.steps_daily_goal")
    let goal = dailyGoal > 0 ? dailyGoal : 10000
    
    content.body = "Steps today: \(steps) / \(goal)"
    content.sound = nil
    content.badge = nil

    let request = UNNotificationRequest(
      identifier: "step_counter_notification",
      content: content,
      trigger: nil // Immediate notification
    )

    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("❌ Error showing step notification: \(error.localizedDescription)")
      } else {
        print("✅ Step notification updated: \(steps) steps")
      }
    }

    lastNotificationUpdate = Date()
  }

  // Handle app entering background
  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    // Ensure step tracking continues
    startBackgroundStepTracking()
  }

  // Handle app entering foreground
  override func applicationWillEnterForeground(_ application: UIApplication) {
    super.applicationWillEnterForeground(application)
    // Update step count when app comes to foreground
    updateStepCountFromPedometer()
  }
}
