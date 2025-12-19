// lib/screens/analytics_screen.dart - Fixed version
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bmi_widget.dart'; // Import your custom widget
import '../widgets/steps_widget.dart'; // Import steps widget
import '../widgets/water_widget.dart'; // Import water widget
import '../widgets/nutrition_widget.dart'; // Import nutrition widget
import '../widgets/sleep_widget.dart'; // Import sleep widget
import '../services/api_service.dart'; // Add this import
import 'step_screen.dart'; // Import the steps detail screen
import 'bmi_screen.dart'; // Import the BMI detail screen
import 'water_screen.dart'; // Import the water detail screen
import 'nutrition_screen.dart';
import 'sleep_screen.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _weekDays = [];
  late ScrollController _calendarScrollController;
  final double _dayItemWidth = 50.0; // Width of each day item including margins

  // User BMI data
  double _userBMI = 22.4; // Default fallback value
  String _userBMIStatus = 'Normal'; // Default fallback status
  bool _isLoadingBMI = true;

  @override
  void initState() {
    super.initState();
    _calendarScrollController = ScrollController();
    _generateWeekDays();
    _loadUserBMI(); // Load user's actual BMI

    // Scroll to current day after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDay();
    });
  }

  // Load and calculate user's BMI from profile
  Future<void> _loadUserBMI() async {
    try {
      // First try to get cached user data
      Map<String, dynamic>? userData = await ApiService.getUserData();

      // If no cached data, fetch from API
      if (userData == null) {
        final result = await ApiService.getProfile();
        if (result['success']) {
          userData = result['data']['user'];
        }
      }

      if (userData != null && mounted) {
        // Extract weight and height from user data
        final weight =
            double.tryParse(userData['weight']?.toString() ?? '58') ?? 58.0;
        final height =
            double.tryParse(userData['height']?.toString() ?? '172') ?? 172.0;

        // Calculate BMI
        final heightInMeters = height / 100;
        final bmi = weight / (heightInMeters * heightInMeters);

        // Get BMI status
        String status;
        if (bmi < 18.5) {
          status = 'Underweight';
        } else if (bmi < 25) {
          status = 'Normal';
        } else if (bmi < 30) {
          status = 'Overweight';
        } else {
          status = 'Obese';
        }

        setState(() {
          _userBMI = bmi;
          _userBMIStatus = status;
          _isLoadingBMI = false;
        });
      } else {
        // If no user data available, use defaults
        setState(() {
          _isLoadingBMI = false;
        });
      }
    } catch (e) {
      // Handle error - use defaults
      setState(() {
        _isLoadingBMI = false;
      });
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BMIDetailScreen(
          initialBMI: _userBMI,
          initialStatus: _userBMIStatus,
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
      MaterialPageRoute(builder: (context) => const NutritionDetailScreen()),
    );
  }

  //Navigate method for Sleep screen
  void _navigateToSleepDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SleepDetailScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final padding = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.055;
    final sectionSpacing = screenHeight * 0.025;
    final rowSpacing = screenWidth * 0.04;
    final topSpacing = screenHeight * 0.025;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: topSpacing),

              // Calendar
              _buildCalendar(),

              SizedBox(height: sectionSpacing),

              // Today Report Title
              Text(
                _selectedDate.day == DateTime.now().day &&
                        _selectedDate.month == DateTime.now().month &&
                        _selectedDate.year == DateTime.now().year
                    ? 'Today Report'
                    : 'Report for ${_selectedDate.day}/${_selectedDate.month}',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: topSpacing),

              // First Row - Steps and BMI
              Row(
                children: [
                  Expanded(
                    child: StepsWidget(
                      onTap: _navigateToStepsDetail,
                    ),
                  ),
                  SizedBox(width: rowSpacing),
                  Expanded(
                    child: _isLoadingBMI
                        ? _buildLoadingBMIWidget()
                        : BMIGaugeWidget(
                            bmiValue: _userBMI,
                            status: _userBMIStatus,
                            onTap: _navigateToBMIDetail,
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
                  SizedBox(width: rowSpacing),
                  Expanded(
                    child: NutritionWidget(
                      onTap: _navigateToNutritionDetail,
                    ),
                  ),
                ],
              ),

              SizedBox(height: rowSpacing),

              // Sleep Widget (Full Width) - Now using the custom widget
              // SleepWidget(
              //   sleepHours: 7,
              //   sleepMinutes: 32,
              //   sleepTime: '22:30',
              //   wakeTime: '06:02',
              //   quality: 'Good',
              //   sleepData: const [
              //     20,
              //     35,
              //     25,
              //     40,
              //     30,
              //     38,
              //     32,
              //     22,
              //     42,
              //     18,
              //     35,
              //     25,
              //   ],
              //   deepSleepData: const [
              //     false,
              //     true,
              //     false,
              //     true,
              //     false,
              //     true,
              //     false,
              //     false,
              //     true,
              //     false,
              //     true,
              //     false,
              //   ],
              //   onTap: _navigateToSleepDetail, // Add navigation
              // ),

              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  // Loading widget for BMI while data is being fetched
  Widget _buildLoadingBMIWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(20),
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
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'BMI',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800]!,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
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
}
//
