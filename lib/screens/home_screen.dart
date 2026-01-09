import 'package:flutter/material.dart';
import 'package:gym_app_2/screens/products_screen.dart';
import 'package:provider/provider.dart';
import 'package:gym_app_2/screens/bmi_screen.dart';
import 'package:gym_app_2/screens/diet_plan_screen.dart';
import 'package:gym_app_2/screens/nutrition_screen.dart';
import 'package:gym_app_2/screens/sleep_screen.dart';
import 'package:gym_app_2/screens/step_screen.dart';
import 'package:gym_app_2/screens/water_screen.dart';
import '../l10n/app_localizations.dart';
import 'package:gym_app_2/widgets/bmi_widget.dart';
import 'package:gym_app_2/widgets/nutrition_widget.dart';
import 'package:gym_app_2/services/bluetooth_permission_service.dart';
import 'package:gym_app_2/widgets/sleep_widget.dart';
import 'package:gym_app_2/widgets/steps_widget.dart';
import 'package:gym_app_2/widgets/water_widget.dart';
import 'package:gym_app_2/widgets/body_composition_widget.dart';
import 'package:gym_app_2/widgets/recipes_widget.dart';
import 'package:gym_app_2/services/gym_service.dart';
import 'package:gym_app_2/providers/water_provider.dart';
import 'package:gym_app_2/providers/bmi_provider.dart';
import 'package:gym_app_2/providers/nutrition_provider.dart';
import 'package:gym_app_2/widgets/recipes_widget.dart';
import 'package:gym_app_2/providers/profile_provider.dart';
import 'package:gym_app_2/providers/notifications_provider.dart';
import 'package:gym_app_2/models/user_model.dart';
import 'package:gym_app_2/screens/notifications_screen.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart'; // Add this import
import 'discover_screen.dart'; // Add this import for DiscoverPage
import 'accountability_screen.dart'; // Add this import for AccountabilityScreen
import 'result_screen.dart'; // Add this import for ResultScreen
import 'workout_plans_screen.dart'; // Add this import for WorkoutPlansScreen
import 'body_composition_screen.dart'; // Add this import for Body Composition Screen
import 'workout_detail_screen.dart'; // Add this import for WorkoutDetailScreen
import 'package:gym_app_2/providers/workout_plans_provider.dart'; // Add this import for WorkoutPlansProvider
import 'qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _weekDays = [];
  late ScrollController _calendarScrollController;
  final double _dayItemWidth = 50.0; // Width of each day item including margins

  @override
  void initState() {
    super.initState();
    _calendarScrollController = ScrollController();
    _generateWeekDays();

    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
      _scrollToCurrentDay();
      // Reset nutrition provider to today when home screen initializes
      _resetNutritionToToday();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset nutrition to today when returning to home screen
    // Use a small delay to ensure route is fully active
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        final route = ModalRoute.of(context);
        if (route?.isCurrent == true) {
          _resetNutritionToToday();
        }
      }
    });
  }

  void _resetNutritionToToday() {
    final nutritionProvider = context.read<NutritionProvider>();
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (nutritionProvider.selectedDate != today) {
      nutritionProvider.resetToToday();
    }
  }

  Future<void> _initializeProviders() async {
    final profileProvider = context.read<ProfileProvider>();
    final workoutProvider = context.read<WorkoutPlansProvider>();

    // Step 1: Load from local storage for immediate UI display
    await profileProvider.loadFromLocalStorage();
    debugPrint('HomeScreen: Loaded profile from local storage');

    // Initialize workout plans provider
    await workoutProvider.fetchCurrentWorkoutPlan();
    debugPrint('HomeScreen: Fetched current workout plan');

    // Step 2: Initialize other providers with any available profile data
    await context.read<BMIProvider>().initialize();
    await context.read<WaterProvider>().initialize();
    
    // Initialize notifications provider to get unread count
    await context.read<NotificationsProvider>().initialize();
    debugPrint('HomeScreen: Initialized notifications');

    if (profileProvider.userProfile != null) {
      await context
          .read<BMIProvider>()
          .initializeFromBackendData(profileProvider.userProfile!);
      debugPrint('HomeScreen: Initialized BMI with local profile data');
    }

    // Step 3: Fetch fresh data from backend (connectivity-aware)
    // This will either update with fresh data or show offline status
    await profileProvider.fetchUserProfile();
    debugPrint(
        'HomeScreen: Profile fetch completed - Status: ${profileProvider.syncStatus}');

    // Step 4: Update BMI with potentially fresh data from backend
    if (profileProvider.userProfile != null) {
      await context
          .read<BMIProvider>()
          .initializeFromBackendData(profileProvider.userProfile!);
      debugPrint('HomeScreen: Updated BMI with fresh profile data');
    }
  }

  Future<void> _onRefresh() async {
    final profileProvider = context.read<ProfileProvider>();
    final workoutProvider = context.read<WorkoutPlansProvider>();
    final notificationsProvider = context.read<NotificationsProvider>();

    try {
      // Refresh all providers in parallel for better performance
      await Future.wait([
        profileProvider.fetchUserProfile(),
        workoutProvider.fetchCurrentWorkoutPlan(),
        notificationsProvider.refreshNotifications(),
        context.read<BMIProvider>().initialize(),
        context.read<WaterProvider>().initialize(),
      ]);

      // Update BMI with fresh profile data if available
      if (profileProvider.userProfile != null) {
        await context
            .read<BMIProvider>()
            .initializeFromBackendData(profileProvider.userProfile!);
      }

      debugPrint('HomeScreen: Refresh completed successfully');
    } catch (e) {
      debugPrint('HomeScreen: Refresh failed - $e');
    }
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    super.dispose();
  }

  void _generateWeekDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find the start of the current week (Sunday)
    int daysFromSunday = today.weekday % 7; // Sunday = 0, Monday = 1, etc.
    DateTime startOfWeek = today.subtract(Duration(days: daysFromSunday));

    // Generate week days
    _weekDays = List.generate(7, (index) {
      DateTime currentDay = startOfWeek.add(Duration(days: index));
      bool isToday = currentDay.day == today.day &&
          currentDay.month == today.month &&
          currentDay.year == today.year;

      // Get day abbreviation
      String dayAbbr = _getDayAbbreviation(currentDay.weekday);

      return {
        'day': dayAbbr,
        'date': currentDay.day,
        'fullDate': currentDay,
        'isToday': isToday,
        'index': index,
      };
    });

    // Set selected date to today initially
    _selectedDate = today;
  }

  void _scrollToCurrentDay() {
    // Find the index of today
    int todayIndex = _weekDays.indexWhere((day) => day['isToday'] == true);

    if (todayIndex != -1) {
      // Calculate the scroll position to center the current day
      double scrollPosition = (todayIndex * _dayItemWidth) -
          (MediaQuery.of(context).size.width / 2) +
          (_dayItemWidth / 2);

      // Ensure we don't scroll beyond bounds
      scrollPosition = scrollPosition.clamp(
        0.0,
        (_weekDays.length * _dayItemWidth) - MediaQuery.of(context).size.width,
      );

      _calendarScrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToSelectedDay(int selectedIndex) {
    // Calculate the scroll position to show the selected day
    double scrollPosition = (selectedIndex * _dayItemWidth) -
        (MediaQuery.of(context).size.width / 2) +
        (_dayItemWidth / 2);

    // Ensure we don't scroll beyond bounds
    scrollPosition = scrollPosition.clamp(
      0.0,
      (_weekDays.length * _dayItemWidth) - MediaQuery.of(context).size.width,
    );

    _calendarScrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return 'S';
      case DateTime.monday:
        return 'M';
      case DateTime.tuesday:
        return 'T';
      case DateTime.wednesday:
        return 'W';
      case DateTime.thursday:
        return 'T';
      case DateTime.friday:
        return 'F';
      case DateTime.saturday:
        return 'S';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // Navigation method for steps widget
  void _navigateToStepsDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StepsDetailScreen()),
    );
  }

  // Navigation method for BMI widget - now passes actual user BMI
  void _navigateToBMIDetail() {
    final bmiProvider = context.read<BMIProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BMIDetailScreen(
          initialBMI: bmiProvider.currentBMIValue,
          initialStatus: bmiProvider.currentBMIStatus,
        ),
      ),
    );
  }

  // Navigation method for Water widget
  void _navigateToWaterDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WaterDetailScreen()),
    );
  }

  //Navigate method for Nutrition screen
  void _navigateToNutritionDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DietPlanScreen()),
    );
  }

  //Navigate method for Sleep screen
  void _navigateToSleepDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SleepDetailScreen()),
    );
  }

  //Navigate method for Workout Plans screen
  void _navigateToWorkoutPlansDetail() {
    final workoutProvider = context.read<WorkoutPlansProvider>();

    // If there's a current active workout plan, navigate directly to its detail screen
    if (workoutProvider.currentWorkoutPlan != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutDetailScreen(
            workoutPlan: workoutProvider.currentWorkoutPlan!,
          ),
        ),
      );
    } else {
      // Fallback to the workout plans screen if no active plan
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WorkoutPlansScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final navBarHorizontalPadding = screenWidth * 0.05;
    final navBarBottomPadding = screenHeight * 0.012;
    final navBarInnerPadding = screenWidth * 0.02;
    final navBarBorderRadius = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content with PageView
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                _buildHomeContent(l10n),
                const DiscoverPage(), // Replace placeholder with DiscoverPage
                ProductsScreen(), // Replace placeholder with AnalyticsPage
                ProfileScreen(), // Replace placeholder with ProfileScreen
              ],
            ),

            // Floating Navigation Bar - moved down
            Positioned(
              left: navBarHorizontalPadding,
              right: navBarHorizontalPadding,
              bottom:
                  navBarBottomPadding, // Changed from 20 to 10 to move navbar downward
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: navBarInnerPadding,
                  vertical: navBarInnerPadding,
                ),
                decoration: BoxDecoration(
                  color: context.navBarBackground,
                  borderRadius: BorderRadius.circular(navBarBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, l10n.home),
                    _buildNavItem(
                        1, Icons.video_library_rounded, l10n.discover),
                    _buildElevatedBodyCompositionButton(),
                    _buildNavItem(2, Icons.shopping_bag_rounded, l10n.products),
                    _buildNavItem(3, Icons.person_rounded, l10n.profile),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(AppLocalizations l10n) {
    // Reset nutrition to today when home content is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _resetNutritionToToday();
      }
    });
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final contentPadding = screenWidth * 0.05;
    final topSpacing = screenHeight * 0.008;
    final sectionSpacing = screenHeight * 0.025;
    final rowSpacing = screenHeight * 0.018;
    final widgetSpacing = screenWidth * 0.04;
    final bottomSpacing = screenHeight * 0.12; // Space for bottom navigation

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Theme.of(context).colorScheme.primary,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //SizedBox(height: topSpacing),
              // Greeting Widget
              _buildGreeting(),

              SizedBox(height: sectionSpacing * 0.7),

              // Gym Banner (if available)
              _buildGymBanner(),

              SizedBox(height: sectionSpacing),

              // Scan QR Button
              // SizedBox(
              //   width: double.infinity,
              //   child: OutlinedButton.icon(
              //     onPressed: () {
              //       Navigator.of(context).push(
              //         MaterialPageRoute(builder: (_) => const QrScannerScreen()),
              //       );
              //     },
              //     icon: const Icon(Icons.qr_code_scanner),
              //     label: const Text('Scan QR to Mark Attendance'),
              //   ),
              // ),

              //SizedBox(height: rowSpacing),

              // Today Report Title
              Text(
                _selectedDate.day == DateTime.now().day &&
                        _selectedDate.month == DateTime.now().month &&
                        _selectedDate.year == DateTime.now().year
                    ? AppLocalizations.of(context)!.todayReport
                    : AppLocalizations.of(context)!.reportFor(
                        '${_selectedDate.day}/${_selectedDate.month}'),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
              ),

              SizedBox(height: rowSpacing),

              // First Row - Steps and BMI
              Row(
                children: [
                  Expanded(
                    child: StepsWidget(
                      onTap: _navigateToStepsDetail,
                    ),
                  ),
                  SizedBox(width: widgetSpacing),
                  Expanded(
                    child: Consumer<BMIProvider>(
                      builder: (context, bmiProvider, child) {
                        if (bmiProvider.isLoading) {
                          return _buildLoadingBMIWidget(l10n);
                        }

                        return BMIGaugeWidget(
                          bmiValue: bmiProvider.currentBMIValue,
                          status: bmiProvider.currentBMIStatus,
                          onTap: _navigateToBMIDetail,
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: rowSpacing),

              // Second Row - Water and Nutrition
              Row(
                children: [
                  Expanded(
                    child: WaterWidget(
                      onTap: _navigateToWaterDetail, // Add navigation
                    ),
                  ),
                  SizedBox(width: widgetSpacing),
                  Expanded(
                    child: NutritionWidget(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const NutritionDetailScreen()),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: rowSpacing),

              // Recipes Section (Full Width)
              const RecipesWidget(),

              //SizedBox(height: rowSpacing),

              // Body Composition Widget (Full Width)
              //const BodyCompositionWidget(),

              SizedBox(height: rowSpacing),

              // Sleep Widget (Full Width)
              // SleepWidget(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const SleepDetailScreen(),
              //       ),
              //     );
              //   },
              // ),

              //SizedBox(height: rowSpacing),

              // Recipes Section (Full Width)
              //const RecipesWidget(),

              //SizedBox(height: rowSpacing),

              // Diet Plan Widget (Full Width)
              _buildDietPlanWidget(l10n),

              SizedBox(height: rowSpacing),

              // Workout Plan Widget (Full Width)
              _buildWorkoutPlanWidget(l10n),

              SizedBox(height: rowSpacing),

              // Accountability Widget (Full Width)
              _buildAccountabilityWidget(l10n),

              SizedBox(height: rowSpacing),

              // Result Widget (Full Width)
              _buildResultWidget(l10n),

              SizedBox(height: bottomSpacing), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  /// Converts a string to title case (e.g., "john doe" -> "John Doe")
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildGreeting() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        // Get username from ProfileProvider, fallback to 'User' if not available
        final userName = _toTitleCase(profileProvider.userProfile?.name ?? 'User');
        final now = DateTime.now();
        final hour = now.hour;

        String greeting;
        IconData greetingIcon;
        List<Color> greetingGradient;
        
        if (hour >= 5 && hour < 12) {
          greeting = l10n.goodMorning;
          greetingIcon = Icons.wb_sunny_rounded;
          greetingGradient = [Colors.amber.shade400, Colors.orange.shade500];
        } else if (hour >= 12 && hour < 17) {
          greeting = l10n.goodAfternoon;
          greetingIcon = Icons.wb_sunny_outlined;
          greetingGradient = [Colors.orange.shade400, Colors.deepOrange.shade500];
        } else {
          greeting = l10n.goodEvening;
          greetingIcon = Icons.nightlight_round;
          greetingGradient = [Colors.indigo.shade400, Colors.purple.shade500];
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: screenWidth * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Greeting with icon
              Expanded(
                child: Row(
                  children: [
                    // Greeting icon with gradient background
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.025),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: greetingGradient,
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        boxShadow: [
                          BoxShadow(
                            color: greetingGradient[0].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        greetingIcon,
                        color: Colors.white,
                        size: screenWidth * 0.055,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.005),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: screenWidth * 0.055,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Right side - Notification and QR Scanner Icons
              Row(
                children: [
                  // Notification Icon - Vibrant design
                  Consumer<NotificationsProvider>(
                    builder: (context, notificationsProvider, child) {
                      final hasUnread = notificationsProvider.unreadCount > 0;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.12,
                          height: screenWidth * 0.12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: hasUnread
                                  ? [Colors.orange.shade400, Colors.deepOrange.shade500]
                                  : [Colors.indigo.shade400, Colors.indigo.shade600],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: hasUnread 
                                    ? Colors.deepOrange.withOpacity(0.4) 
                                    : Colors.indigo.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Notification icon
                              Icon(
                                hasUnread 
                                    ? Icons.notifications_active_rounded 
                                    : Icons.notifications_rounded,
                                color: Colors.white,
                                size: screenWidth * 0.06,
                              ),
                              // Badge
                              if (hasUnread)
                                Positioned(
                                  right: screenWidth * 0.005,
                                  top: screenWidth * 0.005,
                                  child: Container(
                                    padding: EdgeInsets.all(screenWidth * 0.012),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.deepOrange.shade500,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: screenWidth * 0.05,
                                      minHeight: screenWidth * 0.05,
                                    ),
                                    child: Center(
                                      child: Text(
                                        notificationsProvider.unreadCount > 9
                                            ? '9+'
                                            : notificationsProvider.unreadCount.toString(),
                                        style: TextStyle(
                                          color: Colors.deepOrange.shade600,
                                          fontSize: screenWidth * 0.028,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  // QR Scanner Icon - Vibrant design
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QrScannerScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.teal.shade400,
                            Colors.teal.shade600,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: screenWidth * 0.055,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGymBanner() {
    final width = MediaQuery.of(context).size.width;
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final user = profileProvider.userProfile;
        return FutureBuilder<Map<String, dynamic>?>(
          future: GymService.fetchUserGym(),
          builder: (context, snapshot) {
            // Debug: print connection state and potential errors
            // ignore: avoid_print
            print(
                '[GymBanner] state=${snapshot.connectionState} hasData=${snapshot.hasData} hasError=${snapshot.hasError}');
            if (snapshot.hasError) {
              // ignore: avoid_print
              print('[GymBanner] error=${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: width / 3,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              // ignore: avoid_print
              print('[GymBanner] no data from /gyms/fetch');
              return const SizedBox.shrink();
            }
            final gym = snapshot.data!;
            // ignore: avoid_print
            print('[GymBanner] gym json: ' + gym.toString());
            final bannerUrl = (gym['banner']) as String?;
            // ignore: avoid_print
            print('[GymBanner] resolved bannerUrl: ' + (bannerUrl ?? 'null'));
            if (bannerUrl == null || bannerUrl.isEmpty) {
              // ignore: avoid_print
              print('[GymBanner] bannerUrl empty - not rendering');
              return const SizedBox.shrink();
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 3 / 1,
                child: Image.network(
                  bannerUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(Icons.image_not_supported,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingBMIWidget(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final containerPadding = screenWidth * 0.04;
    final containerHeight = screenHeight * 0.17; // Match BMI widget height
    final borderRadius = screenWidth * 0.05;
    final iconSize = screenWidth * 0.05;
    final arrowIconSize = screenWidth * 0.03;
    final spacingSmall = screenWidth * 0.015;
    final textSize = screenWidth * 0.035;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      height: containerHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.accessibility,
                color: Colors.green[700]!,
                size: iconSize,
              ),
              SizedBox(width: spacingSmall),
              Text(
                l10n.bmi,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800]!,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: arrowIconSize,
                color: Colors.green[800]!.withOpacity(0.6),
              ),
            ],
          ),
          const Expanded(
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    Color? backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),

            const SizedBox(width: 20),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietPlanWidget(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: _navigateToNutritionDetail,
      child: Container(
        height: screenWidth * 0.3,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Container with gradient overlay
            Container(
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                image: const DecorationImage(
                  image: AssetImage('assets/images/DIET.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Theme.of(context).colorScheme.surface.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: screenWidth * 0.04),

            // Text Content with icon
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            color: Colors.white,
                            size: screenWidth * 0.045,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.025),
                        Text(
                          l10n.dietPlan,
                          style: TextStyle(
                            fontSize: screenWidth * 0.048,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      l10n.viewYourPersonalizedDiet,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Arrow Icon with background
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.04),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: screenWidth * 0.05,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutPlanWidget(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: _navigateToWorkoutPlansDetail,
      child: Container(
        height: screenWidth * 0.3,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Container with gradient overlay
            Container(
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                image: const DecorationImage(
                  image: AssetImage('assets/images/WORKOUT.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Theme.of(context).colorScheme.surface.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: screenWidth * 0.04),

            // Text Content with icon
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.deepOrange.shade400,
                                Colors.deepOrange.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: Colors.white,
                            size: screenWidth * 0.045,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.025),
                        Text(
                          l10n.workoutPlan,
                          style: TextStyle(
                            fontSize: screenWidth * 0.048,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      l10n.knowYourWorkoutPlans,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Arrow Icon with background
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.04),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: screenWidth * 0.05,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountabilityWidget(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AccountabilityScreen(),
          ),
        );
      },
      child: Container(
        height: screenWidth * 0.3,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Container with gradient overlay
            Container(
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                image: const DecorationImage(
                  image: AssetImage('assets/images/ACCOUNTABILITY.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Theme.of(context).colorScheme.surface.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: screenWidth * 0.04),

            // Text Content with icon
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.purple.shade400,
                                Colors.purple.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: screenWidth * 0.045,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.025),
                        Flexible(
                          child: Text(
                            l10n.accountability,
                            style: TextStyle(
                              fontSize: screenWidth * 0.048,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      l10n.trackProgressWithPhotos,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Arrow Icon with background
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.04),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: screenWidth * 0.05,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultWidget(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ResultScreen(),
          ),
        );
      },
      child: Container(
        height: screenWidth * 0.3,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Container with gradient overlay
            Container(
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                image: const DecorationImage(
                  image: AssetImage('assets/images/RESULTS.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Theme.of(context).colorScheme.surface.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: screenWidth * 0.04),

            // Text Content with icon
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.teal.shade400,
                                Colors.teal.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.trending_up_rounded,
                            color: Colors.white,
                            size: screenWidth * 0.045,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.025),
                        Text(
                          l10n.results,
                          style: TextStyle(
                            fontSize: screenWidth * 0.048,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      l10n.viewYourProgress,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Arrow Icon with background
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.04),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: screenWidth * 0.05,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionWidget() {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _navigateToNutritionDetail,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.lightBlue[50],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.nutrition,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Show nutrition summary with static data
            Row(
              children: [
                Expanded(
                  child: _buildNutritionStat(
                    l10n.calories,
                    '1,847',
                    'kcal',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildNutritionStat(
                    l10n.protein,
                    '89.2',
                    'g',
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildNutritionStat(
                    l10n.carbs,
                    '205.7',
                    'g',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildNutritionStat(
                    l10n.meals,
                    '3',
                    '',
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionStat(
      String label, String value, String unit, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_getMonthName(now.month)} ${now.year}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue[200]!, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.blue[600]),
                  const SizedBox(width: 4),
                  Text(
                    'This Week',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 60, // Fixed height for the calendar
            child: ListView.builder(
              controller: _calendarScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _weekDays.length,
              itemBuilder: (context, index) {
                return Container(
                  width: _dayItemWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildCalendarDay(_weekDays[index], index),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarDay(Map<String, dynamic> day, int index) {
    final isToday = day['isToday'] as bool;
    final isSelected = _selectedDate.day == (day['fullDate'] as DateTime).day &&
        _selectedDate.month == (day['fullDate'] as DateTime).month &&
        _selectedDate.year == (day['fullDate'] as DateTime).year;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = day['fullDate'] as DateTime;
        });
        // Scroll to show the selected day if it's not fully visible
        _scrollToSelectedDay(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 60,
        decoration: BoxDecoration(
          gradient: isToday
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                )
              : isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue[300]!, Colors.blue[500]!],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey[100]!, Colors.grey[50]!],
                    ),
          borderRadius: BorderRadius.circular(16),
          border: (isToday || isSelected)
              ? null
              : Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: (isToday || isSelected)
              ? [
                  BoxShadow(
                    color: (isToday ? Colors.blue[400]! : Colors.blue[300]!)
                        .withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day['day'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    (isToday || isSelected) ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: (isToday || isSelected)
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${day['date']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        (isToday || isSelected) ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(
    String title,
    String calories,
    String duration,
    String imagePath,
    Color overlayColor,
  ) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(color: overlayColor),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: overlayColor,
                    child: const Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: Colors.white70,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    overlayColor.withOpacity(0.3),
                    overlayColor.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(Icons.local_fire_department, calories),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.access_time, duration),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
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
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /* Widget _buildTodayPlanItem(
    String title,
    String subtitle,
    String percentage,
    double progress,
    String level,
    String imagePath,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.fitness_center,
                      color: Colors.grey[600],
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        level,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                const SizedBox(height: 12),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      percentage,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }*/

  Widget _buildNavItem(int index, IconData icon, String label) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isActive = _currentIndex == index;

    // Responsive sizing
    final iconPadding = screenWidth * 0.025; // Responsive padding
    final iconSize = screenWidth * 0.055; // Responsive icon size

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(iconPadding),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive
              ? Theme.of(context)
                  .colorScheme
                  .onPrimary // White/light color when selected
              : Colors.white.withOpacity(
                  0.6), // Light grey/white when unselected for dark navbar
          size: iconSize,
        ),
      ),
    );
  }

  // Helper method to build default profile icon
  Widget _buildDefaultProfileIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Icon(
        Icons.person,
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      ),
    );
  }

  // Helper method to build loading profile icon
  Widget _buildLoadingProfileIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Helper method to build elevated body composition button
  Widget _buildElevatedBodyCompositionButton() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing for the elevated button
    final buttonSize = screenWidth * 0.15; // Larger than regular nav items
    final iconSize = screenWidth * 0.08; // Larger icon
    final elevation = 8.0;

    return GestureDetector(
      onTap: () async {
        // Check permissions and navigate to body composition screen
        await BluetoothPermissionService.checkAndNavigateToBodyComposition(
            context);
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: elevation,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.monitor_weight, // Machine/scale icon
          color: Theme.of(context).colorScheme.onPrimary,
          size: iconSize,
        ),
      ),
    );
  }
}
