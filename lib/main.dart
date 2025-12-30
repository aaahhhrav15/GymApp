import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gym_app_2/providers/cart_provider.dart';
import 'package:gym_app_2/providers/diet_plan_provider.dart';
import 'package:gym_app_2/providers/payment_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';

import 'screens/analytics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/accountability_screen.dart';
import 'screens/reels_screen.dart';
import 'screens/result_screen.dart';
import 'screens/awareness_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/products_screen.dart';
import 'screens/citations_screen.dart';
import 'screens/onboarding_flow_screen.dart';
import 'services/token_manager.dart';
import 'widgets/auth_wrapper.dart';
import 'providers/accountability_provider.dart';
import 'providers/reels_provider.dart';
import 'providers/result_provider.dart';
import 'providers/water_provider.dart';
import 'providers/login_provider.dart';
import 'providers/bmi_provider.dart';
import 'providers/awareness_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/workout_plans_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/product_provider.dart';
import 'providers/steps_provider.dart';
import 'providers/sleep_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/body_composition_provider.dart';
import 'providers/terms_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/onboarding_provider.dart';
import 'theme/app_theme.dart';
import 'services/connectivity_service.dart';
import 'l10n/app_localizations.dart';
import 'services/water_notification_service.dart';
import 'services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/edge_to_edge_wrapper.dart';
import 'services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await ConnectivityService().initialize();

  // Request all permissions at app startup (non-blocking)
  // This ensures all necessary permissions are requested when the app launches
  // We do this asynchronously so it doesn't block app startup
  _requestPermissionsAsync();

  // Initialize and handle daily reset for water reminders on app start
  await WaterNotificationService.handleDailyReset();

  // Configure system UI for edge-to-edge support
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

// Request permissions asynchronously without blocking app startup
void _requestPermissionsAsync() async {
  try {
    debugPrint('📱 Requesting all permissions at app startup...');
    
    // Check location permission status first
    final locationStatus = await Permission.locationWhenInUse.status;
    final locationAlwaysStatus = await Permission.location.status;
    debugPrint('📍 Initial Location permission status - WhenInUse: $locationStatus, Always: $locationAlwaysStatus');
    
    // If already granted, skip requesting
    if (locationStatus.isGranted || 
        locationStatus == PermissionStatus.limited ||
        locationAlwaysStatus.isGranted ||
        locationAlwaysStatus == PermissionStatus.limited) {
      debugPrint('✅ Location permission already granted - skipping request');
      return;
    }
    
    // Request all general permissions with timeout
    await PermissionService.requestAllPermissions().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('⚠️ Permission request timed out - continuing anyway');
      },
    );
    
    // Specifically request body composition permissions (Bluetooth + Location)
    // This is important for iOS where permissions must be requested before use
    // This will show the native iOS permission dialogs if status is notDetermined
    final bodyCompositionPerms = await PermissionService.requestBodyCompositionPermissions().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('⚠️ Body composition permission request timed out');
        return <String, bool>{'bluetooth': false, 'location': false};
      },
    );
    
    debugPrint('📱 Body composition permissions result: $bodyCompositionPerms');
    
    // Check final status after request (user might have selected "Always")
    final finalLocationStatus = await Permission.locationWhenInUse.status;
    final finalLocationAlwaysStatus = await Permission.location.status;
    debugPrint('📍 Final Location permission status - WhenInUse: $finalLocationStatus, Always: $finalLocationAlwaysStatus');
    
    // Check if either is granted
    final isLocationGranted = finalLocationStatus.isGranted || 
        finalLocationStatus == PermissionStatus.limited ||
        finalLocationAlwaysStatus.isGranted ||
        finalLocationAlwaysStatus == PermissionStatus.limited;
    
    if (isLocationGranted) {
      debugPrint('✅ Location permission granted successfully!');
    } else if (finalLocationStatus == PermissionStatus.denied || 
               finalLocationStatus == PermissionStatus.permanentlyDenied) {
      debugPrint('⚠️ Location permission is denied - user must enable in Settings > Privacy & Security > Location Services');
    }
  } catch (e) {
    debugPrint('❌ Error requesting permissions: $e');
    // Don't block app startup - continue anyway
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize notifications when app starts
    _initializeNotificationsOnStart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // App resumed from background - sync steps and reschedule water reminders
      print('App resumed - syncing steps and rescheduling water reminders');
      _syncStepsOnResume();
      _rescheduleWaterRemindersOnResume();
      _updateNotificationsOnResume();
    }
  }

  void _syncStepsOnResume() {
    // Get the steps provider and sync - use a delayed call to ensure context is available
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final stepsProvider =
              Provider.of<StepsProvider>(context, listen: false);
          stepsProvider.refresh();
          print('Steps synced successfully on app resume');
        } catch (e) {
          print('Error syncing steps on app resume: $e');
        }
      });
    } catch (e) {
      print('Error setting up steps sync on app resume: $e');
    }
  }

  void _rescheduleWaterRemindersOnResume() {
    // Reschedule water reminders when app resumes
    try {
      WaterNotificationService.handleDailyReset();
    } catch (e) {
      print('Error rescheduling water reminders on app resume: $e');
    }
  }

  void _updateNotificationsOnResume() {
    // Update notifications when app resumes - fetch both count and notifications
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final notificationsProvider =
              Provider.of<NotificationsProvider>(context, listen: false);
          // Refresh notifications to get latest data and update badge count
          // This will update both the notifications list and the unread count
          notificationsProvider.refreshNotifications();
          print('Notifications refreshed successfully on app resume');
        } catch (e) {
          print('Error updating notifications on app resume: $e');
        }
      });
    } catch (e) {
      print('Error setting up notifications update on app resume: $e');
    }
  }

  // Initialize notifications when app starts (only if user is authenticated)
  void _initializeNotificationsOnStart() async {
    try {
      // Check if user is logged in before initializing
      final isLoggedIn = await TokenManager.isLoggedIn();
      if (!isLoggedIn) {
        print('User not logged in, skipping notifications initialization');
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final notificationsProvider =
              Provider.of<NotificationsProvider>(context, listen: false);
          // Initialize notifications to fetch count and list
          // This will update the badge count immediately
          notificationsProvider.initialize();
          print('Notifications initialized successfully on app start');
        } catch (e) {
          print('Error initializing notifications on app start: $e');
        }
      });
    } catch (e) {
      print('Error setting up notifications initialization on app start: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AccountabilityProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => BodyCompositionProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ReelsProvider()),
        ChangeNotifierProvider(create: (_) => ResultProvider()),
        ChangeNotifierProvider(create: (_) => DietPlanProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => BMIProvider()),
        ChangeNotifierProvider(create: (_) => AwarenessProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutPlansProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutDayProvider()),
        // ProfileProvider should be initialized early and load data immediately
        ChangeNotifierProvider(
          create: (_) => ProfileProvider()..loadFromLocalStorage(),
        ),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => StepsProvider()),
        ChangeNotifierProvider(create: (_) => SleepProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        // BodyCompositionProvider depends on ProfileProvider for user data
        ChangeNotifierProxyProvider<ProfileProvider, BodyCompositionProvider>(
          create: (context) => BodyCompositionProvider(
            profileProvider:
                Provider.of<ProfileProvider>(context, listen: false),
          ),
          update: (context, profileProvider, bodyCompositionProvider) {
            // Update body composition provider when profile data changes
            if (bodyCompositionProvider != null) {
              bodyCompositionProvider.updateFromProfileProvider();
              return bodyCompositionProvider;
            }
            return BodyCompositionProvider(profileProvider: profileProvider);
          },
        ),
        ChangeNotifierProvider(create: (_) => TermsProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            title: 'Mr Muscle',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('hi', ''), // Hindi
              Locale('mr', ''), // Marathi
            ],
            builder: (context, child) {
              return SystemUIHandler(
                isDarkMode: themeProvider.themeMode == ThemeMode.dark,
                child: EdgeToEdgeWrapper(child: child!),
              );
            },
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              // Public routes that don't require authentication
              final publicRoutes = [
                '/splash',
                '/onboarding',
                '/onboarding-flow',
                '/register',
                '/login',
              ];

              // If route is public, return it directly
              if (publicRoutes.contains(settings.name)) {
                switch (settings.name) {
                  case '/splash':
                    return MaterialPageRoute(builder: (_) => const SplashScreen());
                  case '/onboarding':
                    return MaterialPageRoute(builder: (_) => const OnboardingScreen());
                  case '/onboarding-flow':
                    return MaterialPageRoute(builder: (_) => const OnboardingFlowScreen());
                  case '/register':
                    return MaterialPageRoute(builder: (_) => const RegisterScreen());
                  case '/login':
                    return MaterialPageRoute(builder: (_) => const LoginScreen());
                  default:
                    return MaterialPageRoute(builder: (_) => const SplashScreen());
                }
              }

              // Protected routes - wrap with AuthWrapper
              return MaterialPageRoute(
                builder: (context) => AuthWrapper(
                  redirectRoute: '/login',
                  child: _buildProtectedRoute(settings.name ?? '/home'),
                ),
              );
            },
            routes: {
              // Public routes
              '/splash': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/onboarding-flow': (context) => const OnboardingFlowScreen(),
              '/register': (context) => const RegisterScreen(),
              '/login': (context) => const LoginScreen(),
              // Protected routes - wrapped with AuthWrapper
              '/home': (context) => AuthWrapper(
                    redirectRoute: '/login',
                    child: const HomeScreen(),
                  ),
              '/analytics': (context) => AuthWrapper(
                    redirectRoute: '/login',
                    child: AnalyticsPage(),
                  ),
              '/profile': (context) => AuthWrapper(
                    redirectRoute: '/login',
                    child: const ProfileScreen(),
                  ),
              '/discover': (context) => AuthWrapper(
                    redirectRoute: '/login',
                    child: const DiscoverPage(),
                  ),
              '/accountability': (context) => AuthWrapper(
                    redirectRoute: '/login',
                    child: const AccountabilityScreen(),
                  ),
              '/reels': (context) => AuthWrapper(
                    redirectRoute: '/login',
                    child: const ReelsScreen(),
                  ),
              '/results': (context) => AuthWrapper(
                    redirectRoute: '/login',
                    child: const ResultScreen(),
                  ),
              '/awareness': (context) => AuthWrapper(
                    redirectRoute: '/login',
                    child: const AwarenessScreen(),
                  ),
              '/products': (context) => AuthWrapper(
                    redirectRoute: '/login',
                    child: const ProductsScreen(),
                  ),
              '/citations': (context) => AuthWrapper(
                    redirectRoute: '/login',
                    child: const CitationsScreen(),
                  ),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  // Helper method to build protected routes
  Widget _buildProtectedRoute(String routeName) {
    switch (routeName) {
      case '/home':
        return const HomeScreen();
      case '/analytics':
        return AnalyticsPage();
      case '/profile':
        return const ProfileScreen();
      case '/discover':
        return const DiscoverPage();
      case '/accountability':
        return const AccountabilityScreen();
      case '/reels':
        return const ReelsScreen();
      case '/results':
        return const ResultScreen();
      case '/awareness':
        return const AwarenessScreen();
      case '/products':
        return const ProductsScreen();
      case '/citations':
        return const CitationsScreen();
      default:
        return const HomeScreen();
    }
  }
}
