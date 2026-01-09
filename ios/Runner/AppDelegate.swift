import Flutter
import UIKit
import CoreLocation
import CoreBluetooth
import CoreMotion
import UserNotifications
import HealthKit

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
  private var locationManager: CLLocationManager?
  private var locationPermissionResult: FlutterResult?
  private var bluetoothManager: CBPeripheralManager?
  private var pedometer: CMPedometer?
  private var stepUpdateTimer: Timer?
  private var lastStepCount: Int = 0
  private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
  
  // HealthKit
  private var healthStore: HKHealthStore?
  private var stepCountType: HKQuantityType?
  private var healthKitObserverQuery: HKObserverQuery?
  private var isHealthKitAuthorized = false
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Request notification permissions
    requestNotificationPermission()
    
    // Set notification center delegate to show notifications even when app is in foreground
    UNUserNotificationCenter.current().delegate = self
    
    // Set up method channels as soon as possible
    DispatchQueue.main.async { [weak self] in
      self?.setupPermissionChannel()
      self?.setupHelperChannel()
      self?.setupStepTrackingChannel()
    }
    
    // Initialize HealthKit
    initializeHealthKit()
    
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
      case "checkNotificationPermission":
        self.checkNotificationPermission(result: result)
      case "requestNotificationPermission":
        self.requestNotificationPermission()
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

  // MARK: - HealthKit Integration
  
  private func initializeHealthKit() {
    // Check if HealthKit is available on this device
    guard HKHealthStore.isHealthDataAvailable() else {
      print("❌ HealthKit is not available on this device")
      return
    }
    
    healthStore = HKHealthStore()
    stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)
    
    guard let stepCountType = stepCountType else {
      print("❌ Could not create step count quantity type")
      return
    }
    
    // Request authorization
    let readTypes: Set<HKObjectType> = [stepCountType]
    
    healthStore?.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, error in
      DispatchQueue.main.async {
        if let error = error {
          print("❌ HealthKit authorization error: \(error.localizedDescription)")
          self?.isHealthKitAuthorized = false
        } else if success {
          print("✅ HealthKit authorization granted")
          self?.isHealthKitAuthorized = true
          // Set up background delivery
          self?.setupHealthKitBackgroundDelivery()
          // Get initial step count
          self?.getStepsFromHealthKit()
        } else {
          print("❌ HealthKit authorization denied")
          self?.isHealthKitAuthorized = false
        }
      }
    }
  }
  
  private func setupHealthKitBackgroundDelivery() {
    guard let healthStore = healthStore,
          let stepCountType = stepCountType,
          isHealthKitAuthorized else {
      print("❌ Cannot set up HealthKit background delivery - not authorized")
      return
    }
    
    // Enable background delivery
    healthStore.enableBackgroundDelivery(for: stepCountType, frequency: .immediate) { success, error in
      if let error = error {
        print("❌ Error enabling HealthKit background delivery: \(error.localizedDescription)")
      } else if success {
        print("✅ HealthKit background delivery enabled")
      }
    }
    
    // Set up observer query for real-time updates
    healthKitObserverQuery = HKObserverQuery(sampleType: stepCountType, predicate: nil) { [weak self] query, completionHandler, error in
      if let error = error {
        print("❌ HealthKit observer query error: \(error.localizedDescription)")
        completionHandler()
        return
      }
      
      // Get updated step count
      self?.getStepsFromHealthKit()
      completionHandler()
    }
    
    if let observerQuery = healthKitObserverQuery {
      healthStore.execute(observerQuery)
      print("✅ HealthKit observer query started")
    }
  }
  
  private func getStepsFromHealthKit() {
    guard let healthStore = healthStore,
          let stepCountType = stepCountType,
          isHealthKitAuthorized else {
      print("⚠️ HealthKit not available, falling back to Core Motion")
      return
    }
    
    let calendar = Calendar.current
    let now = Date()
    let startOfDay = calendar.startOfDay(for: now)
    let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
    
    let query = HKStatisticsQuery(quantityType: stepCountType,
                                  quantitySamplePredicate: predicate,
                                  options: .cumulativeSum) { [weak self] query, statistics, error in
      guard let self = self else { return }
      
      if let error = error {
        print("❌ Error querying HealthKit steps: \(error.localizedDescription)")
        // Fall back to Core Motion
        self.updateStepCountFromPedometer()
        return
      }
      
      guard let statistics = statistics,
            let sum = statistics.sumQuantity() else {
        print("⚠️ No step data from HealthKit, falling back to Core Motion")
        self.updateStepCountFromPedometer()
        return
      }
      
      let steps = Int(sum.doubleValue(for: HKUnit.count()))
      self.lastStepCount = steps
      
      // Update SharedPreferences (Flutter format)
      let prefsName = "FlutterSharedPreferences"
      let sharedPrefs = UserDefaults(suiteName: prefsName) ?? UserDefaults.standard
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let todayString = dateFormatter.string(from: now)
      
      // Save steps from HealthKit (this is the authoritative source)
      sharedPrefs.set(steps, forKey: "flutter.daily_steps")
      sharedPrefs.set(todayString, forKey: "flutter.steps_date")
      // CRITICAL: Save timestamp for recovery detection (iOS optimization)
      sharedPrefs.set(Date().iso8601String, forKey: "flutter.last_periodic_save")
      sharedPrefs.synchronize()
      
      print("🏥 HealthKit step count updated: \(steps) steps")
      
      // Update notification more frequently (every 10 steps or every 30 seconds)
      // This matches Android behavior for better visibility
      self.updateStepNotification(steps: steps)
    }
    
    healthStore.execute(query)
  }
  
  private func getHistoricalStepsFromHealthKit(days: Int = 7, completion: @escaping ([String: Int]) -> Void) {
    guard let healthStore = healthStore,
          let stepCountType = stepCountType,
          isHealthKitAuthorized else {
      print("⚠️ HealthKit not available for historical data")
      completion([:])
      return
    }
    
    let calendar = Calendar.current
    let now = Date()
    var stepsByDate: [String: Int] = [:]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let group = DispatchGroup()
    
    for dayOffset in 0..<days {
      group.enter()
      let date = calendar.date(byAdding: .day, value: -dayOffset, to: now)!
      let startOfDay = calendar.startOfDay(for: date)
      let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
      let dateString = dateFormatter.string(from: date)
      
      let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
      
      let query = HKStatisticsQuery(quantityType: stepCountType,
                                    quantitySamplePredicate: predicate,
                                    options: .cumulativeSum) { query, statistics, error in
        defer { group.leave() }
        
        if let error = error {
          print("❌ Error querying HealthKit steps for \(dateString): \(error.localizedDescription)")
          stepsByDate[dateString] = 0
          return
        }
        
        if let statistics = statistics,
           let sum = statistics.sumQuantity() {
          let steps = Int(sum.doubleValue(for: HKUnit.count()))
          stepsByDate[dateString] = steps
        } else {
          stepsByDate[dateString] = 0
        }
      }
      
      healthStore.execute(query)
    }
    
    group.notify(queue: .main) {
      completion(stepsByDate)
    }
  }

  // MARK: - Step Tracking

  private func checkNotificationPermission(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      let isAuthorized = settings.authorizationStatus == .authorized && settings.alertSetting == .enabled
      result(isAuthorized)
    }
  }
  
  private func requestNotificationPermission() {
    // First check current status
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      print("📱 Current notification authorization status: \(settings.authorizationStatus.rawValue)")
      print("📱 Alert setting: \(settings.alertSetting.rawValue)")
      print("📱 Badge setting: \(settings.badgeSetting.rawValue)")
      print("📱 Sound setting: \(settings.soundSetting.rawValue)")
      
      // Only request if not determined
      if settings.authorizationStatus == .notDetermined {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
          if granted {
            print("✅ Notification permission granted")
            // Register notification category for step counter
            self.registerNotificationCategory()
            
            // Show a test notification to verify it works
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              self.showTestNotification()
            }
          } else {
            print("❌ Notification permission denied: \(error?.localizedDescription ?? "unknown")")
            if let error = error {
              print("❌ Error details: \(error)")
            }
          }
        }
      } else if settings.authorizationStatus == .authorized {
        print("✅ Notification permission already granted")
        self.registerNotificationCategory()
      } else {
        print("⚠️ Notification permission status: \(settings.authorizationStatus.rawValue)")
        print("⚠️ User needs to enable notifications in Settings")
      }
    }
  }
  
  private func showTestNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Step Counter"
    content.body = "Notification test - Step counter is active"
    content.sound = nil
    
    let request = UNNotificationRequest(
      identifier: "test_notification",
      content: content,
      trigger: nil
    )
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("❌ Test notification error: \(error)")
      } else {
        print("✅ Test notification sent successfully")
      }
    }
  }
  
  private func registerNotificationCategory() {
    // Create a notification category for step counter
    // This helps iOS treat it as a persistent notification
    let category = UNNotificationCategory(
      identifier: "STEP_COUNTER",
      actions: [],
      intentIdentifiers: [],
      options: [.customDismissAction]
    )
    
    UNUserNotificationCenter.current().setNotificationCategories([category])
    print("✅ Registered step counter notification category")
  }

  private func startBackgroundStepTracking() {
    // Try HealthKit first (preferred method)
    if isHealthKitAuthorized {
      print("🏥 Using HealthKit for step tracking")
      getStepsFromHealthKit()
      
      // CRITICAL: Set up periodic updates from HealthKit more frequently (every 30 seconds)
      // This ensures data is saved more often to prevent loss when app is killed (iOS optimization)
      stepUpdateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
        self?.getStepsFromHealthKit()
      }
      
      print("✅ Started HealthKit background step tracking")
      return
    }
    
    // Fallback to Core Motion if HealthKit is not available/authorized
    guard CMPedometer.isStepCountingAvailable() else {
      print("❌ Step counting not available on this device")
      return
    }

    print("📱 Falling back to Core Motion for step tracking")
    
    if pedometer == nil {
      pedometer = CMPedometer()
    }

    let calendar = Calendar.current
    let now = Date()
    let startOfDay = calendar.startOfDay(for: now)

    pedometer?.startUpdates(from: startOfDay) { [weak self] data, error in
      guard let self = self, let data = data else {
        if let error = error {
          print("❌ Error getting step data from Core Motion: \(error.localizedDescription)")
        }
        return
      }

      let steps = data.numberOfSteps.intValue
      self.lastStepCount = steps

      // Update SharedPreferences (Flutter format)
      let prefsName = "FlutterSharedPreferences"
      let sharedPrefs = UserDefaults(suiteName: prefsName) ?? UserDefaults.standard

      // Get current date string
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let todayString = dateFormatter.string(from: now)

      // Save steps
      sharedPrefs.set(steps, forKey: "flutter.daily_steps")
      sharedPrefs.set(todayString, forKey: "flutter.steps_date")
      // CRITICAL: Save timestamp for recovery detection (iOS optimization)
      sharedPrefs.set(Date().iso8601String, forKey: "flutter.last_periodic_save")
      sharedPrefs.synchronize()

      print("📱 Core Motion step count updated: \(steps) steps")

      // Update notification more frequently (every 10 steps or every 30 seconds)
      // This matches Android behavior for better visibility
      self.updateStepNotification(steps: steps)
    }

    // CRITICAL: Start periodic updates more frequently (every 30 seconds)
    // This ensures data is saved more often to prevent loss when app is killed (iOS optimization)
    stepUpdateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
      // Try HealthKit first, fallback to Core Motion
      if self?.isHealthKitAuthorized == true {
        self?.getStepsFromHealthKit()
      } else {
        self?.updateStepCountFromPedometer()
      }
    }

    print("✅ Started Core Motion background step tracking (fallback)")
  }

  private func stopBackgroundStepTracking() {
    // Stop HealthKit observer if running
    if let observerQuery = healthKitObserverQuery {
      healthStore?.stop(observerQuery)
      healthKitObserverQuery = nil
    }
    
    // Stop Core Motion updates
    pedometer?.stopUpdates()
    
    // Stop timer
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
      // CRITICAL: Save timestamp for recovery detection (iOS optimization)
      sharedPrefs.set(Date().iso8601String, forKey: "flutter.last_periodic_save")
      sharedPrefs.synchronize()

      // Update notification more frequently to match Android behavior
      self.updateStepNotification(steps: steps)
    }
  }

  private func getCurrentSteps(result: @escaping FlutterResult) {
    // Try HealthKit first
    if isHealthKitAuthorized, let healthStore = healthStore, let stepCountType = stepCountType {
      let calendar = Calendar.current
      let now = Date()
      let startOfDay = calendar.startOfDay(for: now)
      let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
      
      let query = HKStatisticsQuery(quantityType: stepCountType,
                                    quantitySamplePredicate: predicate,
                                    options: .cumulativeSum) { query, statistics, error in
        if let error = error {
          print("❌ Error getting steps from HealthKit: \(error.localizedDescription)")
          // Fallback to Core Motion
          self.getCurrentStepsFromCoreMotion(result: result)
          return
        }
        
        if let statistics = statistics, let sum = statistics.sumQuantity() {
          let steps = Int(sum.doubleValue(for: HKUnit.count()))
          result(steps)
        } else {
          // Fallback to Core Motion
          self.getCurrentStepsFromCoreMotion(result: result)
        }
      }
      
      healthStore.execute(query)
      return
    }
    
    // Fallback to Core Motion
    getCurrentStepsFromCoreMotion(result: result)
  }
  
  private func getCurrentStepsFromCoreMotion(result: @escaping FlutterResult) {
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
  private var lastNotificationSteps: Int = 0
  
  private func shouldUpdateNotification(steps: Int) -> Bool {
    // Update notification more frequently on iOS to match Android foreground service behavior
    // Update every 10 steps (similar to Android) or every 15 seconds minimum
    // This makes it more persistent like Android's foreground service notification
    let stepsChanged = abs(steps - lastNotificationSteps) >= 10
    let timeElapsed = lastNotificationUpdate == nil || Date().timeIntervalSince(lastNotificationUpdate!) >= 15
    
    return stepsChanged || timeElapsed
  }

  private func updateStepNotification(steps: Int) {
    // Check if we should update (to avoid too frequent updates)
    guard shouldUpdateNotification(steps: steps) else {
      return
    }
    
    // CRITICAL: Check notification authorization status before showing notification
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      guard settings.authorizationStatus == .authorized else {
        print("⚠️ Notification permission not granted. Status: \(settings.authorizationStatus.rawValue)")
        print("⚠️ Alert setting: \(settings.alertSetting.rawValue), Badge: \(settings.badgeSetting.rawValue)")
        
        // If not authorized, try requesting permission again
        if settings.authorizationStatus == .notDetermined {
          DispatchQueue.main.async { [weak self] in
            self?.requestNotificationPermission()
          }
        }
        return
      }
      
      // Check if alerts are enabled (required for notifications to show)
      guard settings.alertSetting == .enabled else {
        print("⚠️ Notification alerts are disabled in settings")
        return
      }
      
      DispatchQueue.main.async { [weak self] in
        self?.showStepNotification(steps: steps)
      }
    }
  }
  
  private func showStepNotification(steps: Int) {
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
    
    // Set category to make it more persistent (like Android foreground service)
    content.categoryIdentifier = "STEP_COUNTER"
    
    // Set thread identifier to group notifications (keeps them together)
    content.threadIdentifier = "step_counter"
    
    // Set interruption level to active (iOS 15+) - makes it more visible like foreground service
    // Using .active instead of .timeSensitive (which requires special entitlements)
    if #available(iOS 15.0, *) {
      content.interruptionLevel = .active
    }
    
    // Set relevance score (iOS 15+) - makes it more prominent in notification center
    // Higher score (1.0) means it appears more prominently, similar to foreground service
    if #available(iOS 15.0, *) {
      content.relevanceScore = 1.0
    }

    let request = UNNotificationRequest(
      identifier: "step_counter_notification",
      content: content,
      trigger: nil // Immediate notification
    )

    // Remove existing notification first, then add new one
    // This ensures the notification is always visible and updated
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["step_counter_notification"])
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["step_counter_notification"])
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("❌ Error showing step notification: \(error.localizedDescription)")
        print("❌ Error details: \(error)")
      } else {
        print("✅ Step notification updated: \(steps) steps")
        print("✅ Notification should be visible in notification center")
        self.lastNotificationUpdate = Date()
        self.lastNotificationSteps = steps
      }
    }
  }

  // Handle app entering background
  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    
    // Start background task to keep step tracking active (similar to Android foreground service)
    startBackgroundTask()
    
    // Ensure step tracking continues
    startBackgroundStepTracking()
  }
  
  // Start background task to keep app active (iOS equivalent of foreground service)
  private func startBackgroundTask() {
    // End any existing background task
    if backgroundTaskIdentifier != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
      backgroundTaskIdentifier = .invalid
    }
    
    // Start new background task
    backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "StepCounterBackgroundTask") { [weak self] in
      // Task expired, restart it
      self?.endBackgroundTask()
      self?.startBackgroundTask()
    }
    
    print("✅ Started background task for step counter (iOS foreground service equivalent)")
  }
  
  // End background task
  private func endBackgroundTask() {
    if backgroundTaskIdentifier != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
      backgroundTaskIdentifier = .invalid
      print("⏹️ Ended background task")
    }
  }

  // Handle app entering foreground
  override func applicationWillEnterForeground(_ application: UIApplication) {
    super.applicationWillEnterForeground(application)
    
    // End background task when app comes to foreground
    endBackgroundTask()
    
    // Update step count when app comes to foreground
    // Try HealthKit first, fallback to Core Motion
    if isHealthKitAuthorized {
      getStepsFromHealthKit()
    } else {
      updateStepCountFromPedometer()
    }
  }
  
  // MARK: - UNUserNotificationCenterDelegate
  
  // Show notifications even when app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Show notification banner and sound even when app is in foreground
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
  
  // Handle notification tap
  override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    // Handle notification tap if needed
    completionHandler()
  }
  
  // CRITICAL: Handle app termination - save data before app is killed
  // This is iOS-specific optimization to prevent data loss
  override func applicationWillTerminate(_ application: UIApplication) {
    super.applicationWillTerminate(application)
    print("⚠️ App will terminate - saving final step data")
    
    // Save current steps to SharedPreferences before termination
    let prefsName = "FlutterSharedPreferences"
    let sharedPrefs = UserDefaults(suiteName: prefsName) ?? UserDefaults.standard
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let todayString = dateFormatter.string(from: Date())
    
    // Get current steps (from HealthKit or Core Motion)
    let currentSteps = lastStepCount
    
    // Save immediately (can't wait for async HealthKit query on termination)
    sharedPrefs.set(currentSteps, forKey: "flutter.daily_steps")
    sharedPrefs.set(todayString, forKey: "flutter.steps_date")
    sharedPrefs.set(Date().iso8601String, forKey: "flutter.last_save_before_close")
    sharedPrefs.set(currentSteps, forKey: "flutter.last_saved_steps")
    sharedPrefs.set(todayString, forKey: "flutter.last_saved_date")
    sharedPrefs.synchronize()
    print("✅ Saved final steps on termination: \(currentSteps)")
    
    // Stop background tracking
    stopBackgroundStepTracking()
  }
}

// Helper extension for ISO8601 date string
extension Date {
  var iso8601String: String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: self)
  }
}
