import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/bmi_provider.dart';
import '../providers/profile_provider.dart';
import 'dart:async';
import '../l10n/app_localizations.dart';

class BMIDetailScreen extends StatefulWidget {
  final double? initialBMI;
  final String? initialStatus;

  const BMIDetailScreen({super.key, this.initialBMI, this.initialStatus});

  @override
  State<BMIDetailScreen> createState() => _BMIDetailScreenState();
}

class _BMIDetailScreenState extends State<BMIDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _drawerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _drawerAnimation;

  // For fast increment/decrement
  Timer? _weightTimer;
  Timer? _ageTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _drawerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize animations
    _animationController.forward();
    if (context.read<BMIProvider>().hasBMIData) {
      _drawerAnimationController.forward();
    }

    // Initialize BMI provider with user profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      final bmiProvider = context.read<BMIProvider>();

      // Initialize BMI provider with user profile (if available)
      bmiProvider.initialize(userProfile: profileProvider.userProfile);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _drawerAnimationController.dispose();
    _weightTimer?.cancel();
    _ageTimer?.cancel();
    super.dispose();
  }

  void _closeDrawer() {
    if (_drawerAnimation.value > 0.1) {
      _drawerAnimationController.reverse();
    }
  }

  void _openDrawer() {
    _drawerAnimationController.forward();
  }

  void _calculateBMI() async {
    final bmiProvider = context.read<BMIProvider>();

    try {
      // Calculate and save BMI using provider
      await bmiProvider.calculateBMI();

      // Open the drawer to show results
      _openDrawer();
    } catch (e) {
      // Handle error
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Failed to calculate BMI: $e'),
      //     backgroundColor: Theme.of(context).colorScheme.error,
      //   ),
      // );
    }
  }

  String _getBMIStatus(double bmi) {
    final l10n = AppLocalizations.of(context)!;
    if (bmi < 18.5) return l10n.underweight;
    if (bmi < 25) return l10n.normal;
    if (bmi < 30) return l10n.overweight;
    return l10n.obese;
  }

  String _getBMIDescription(double bmi) {
    final l10n = AppLocalizations.of(context)!;
    if (bmi < 18.5) {
      return l10n.bmiUnderweightDescription;
    } else if (bmi < 25) {
      return l10n.bmiNormalDescription;
    } else if (bmi < 30) {
      return l10n.bmiOverweightDescription;
    } else {
      return l10n.bmiObeseDescription;
    }
  }

  // Weight increment/decrement methods
  void _startWeightIncrement() {
    _weightTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _incrementWeight();
    });
  }

  void _startWeightDecrement() {
    _weightTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _decrementWeight();
    });
  }

  void _stopWeightTimer() {
    _weightTimer?.cancel();
  }

  void _incrementWeight() {
    final bmiProvider = context.read<BMIProvider>();
    bmiProvider.incrementWeight();
  }

  void _decrementWeight() {
    final bmiProvider = context.read<BMIProvider>();
    bmiProvider.decrementWeight();
  }

  // Age increment/decrement methods
  void _startAgeIncrement() {
    _ageTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _incrementAge();
    });
  }

  void _startAgeDecrement() {
    _ageTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _decrementAge();
    });
  }

  void _stopAgeTimer() {
    _ageTimer?.cancel();
  }

  void _incrementAge() {
    final bmiProvider = context.read<BMIProvider>();
    bmiProvider.incrementAge();
  }

  void _decrementAge() {
    final bmiProvider = context.read<BMIProvider>();
    bmiProvider.decrementAge();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final horizontalPadding = screenWidth * 0.06;
    final contentSpacing = screenHeight * 0.025;
    final bottomDrawerSpacing = screenHeight * 0.15;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<BMIProvider>(
            builder: (context, bmiProvider, child) {
              if (bmiProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Stack(
                children: [
                  Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                          child: Column(
                            children: [
                              SizedBox(height: contentSpacing),
                              _buildCalculatorContent(),
                              SizedBox(height: bottomDrawerSpacing),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Overlay for detecting taps outside drawer
                  AnimatedBuilder(
                    animation: _drawerAnimation,
                    builder: (context, child) {
                      if (_drawerAnimation.value > 0.1) {
                        return GestureDetector(
                          onTap: _closeDrawer,
                          child: Container(
                            color:
                                Theme.of(context).colorScheme.scrim.withOpacity(
                                      0.3 * _drawerAnimation.value,
                                    ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Result Drawer with FAB
                  AnimatedBuilder(
                    animation: _drawerAnimation,
                    builder: (context, child) {
                      final drawerHeight = screenHeight * 0.6;
                      final closedOffset = drawerHeight * 0.9;

                      return Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            closedOffset * (1 - _drawerAnimation.value),
                          ),
                          child: _buildResultDrawerWithFAB(),
                        ),
                      );
                    },
                  ),

                  // Static FAB when no result
                  if (!bmiProvider.hasBMIData)
                    Positioned(
                      bottom: screenHeight * 0.04,
                      left: 0,
                      right: 0,
                      child: Center(child: _buildStaticExtendedFAB()),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.bmiCalculator,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildCalculatorContent() {
    return Consumer<BMIProvider>(
      builder: (context, bmiProvider, child) {
        return Column(
          children: [
            _buildGenderSelector(),
            const SizedBox(height: 24),
            _buildHeightSlider(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildWeightSelector()),
                const SizedBox(width: 16),
                Expanded(child: _buildAgeSelector()),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultDrawerWithFAB() {
    return Consumer<BMIProvider>(
      builder: (context, bmiProvider, child) {
        if (!bmiProvider.hasBMIData) return const SizedBox.shrink();

        final bmi = bmiProvider.currentBMIValue;
        final screenHeight = MediaQuery.of(context).size.height;
        final drawerHeight = screenHeight * 0.6;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Main drawer with swipe gesture
            GestureDetector(
              onPanUpdate: (details) {
                // Handle swipe down gesture - make it more sensitive
                if (details.delta.dy > 0) {
                  final newValue =
                      _drawerAnimation.value - (details.delta.dy / 150);
                  _drawerAnimationController.value = newValue.clamp(0.0, 1.0);
                }
                // Handle swipe up gesture
                else if (details.delta.dy < 0) {
                  final newValue =
                      _drawerAnimation.value + (details.delta.dy.abs() / 150);
                  _drawerAnimationController.value = newValue.clamp(0.0, 1.0);
                }
              },
              onPanEnd: (details) {
                // Auto close/open based on velocity or position
                if (details.velocity.pixelsPerSecond.dy > 300) {
                  // Fast swipe down - close immediately
                  _closeDrawer();
                } else if (details.velocity.pixelsPerSecond.dy < -300) {
                  // Fast swipe up - open immediately
                  _openDrawer();
                } else {
                  // Slow drag - decide based on position
                  if (_drawerAnimation.value < 0.5) {
                    _closeDrawer();
                  } else {
                    _openDrawer();
                  }
                }
              },
              child: ClipPath(
                clipper: ExtendedFABCutoutClipper(),
                child: Container(
                  height: drawerHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 70),

                      // Enhanced swipe indicator - make it more prominent and tappable
                      GestureDetector(
                        onTap: () {
                          // Tap on handle to toggle drawer
                          if (_drawerAnimation.value > 0.5) {
                            _closeDrawer();
                          } else {
                            _openDrawer();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.yourBMIis,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface
                                      .withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${bmi.toStringAsFixed(1)} kg/m²',
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '(${bmiProvider.currentBMIStatus})',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onInverseSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  _getBMIDescription(bmi),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onInverseSurface
                                        .withOpacity(0.7),
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Quick link to citations
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/citations');
                                },
                                icon: const Icon(Icons.info_outline, size: 16),
                                label: Text(AppLocalizations.of(context)!
                                    .medicalReferences),
                              ),
                              // Citations button
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/citations');
                                },
                                icon: const Icon(Icons.info_outline, size: 16),
                                label: Text(AppLocalizations.of(context)!
                                    .viewMedicalReferences),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface
                                      .withOpacity(0.8),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onInverseSurface
                                        .withOpacity(0.3),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Enhanced FAB with better touch handling
            Positioned(
              top: -25,
              left: 0,
              right: 0,
              child: Center(child: _buildDrawerFAB()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawerFAB() {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _drawerAnimation,
      builder: (context, child) {
        final isDrawerOpen = _drawerAnimation.value > 0.5;
        final buttonText = isDrawerOpen ? l10n.recheck : l10n.calculate;
        final buttonIcon =
            isDrawerOpen ? Icons.refresh_rounded : Icons.calculate_rounded;

        return Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(25), // Back to original
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact(); // Add haptic feedback
              if (isDrawerOpen) {
                _closeDrawer();
              } else {
                _calculateBMI();
              }
            },
            borderRadius: BorderRadius.circular(25), // Back to original
            splashColor:
                Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.3),
            highlightColor:
                Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50, // Back to original height
              width: 140, // Back to original width
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(25), // Back to original
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onInverseSurface
                      .withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.8),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .onInverseSurface
                        .withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      buttonIcon,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      size: 18,
                    ), // Back to original
                    const SizedBox(width: 8), // Back to original
                    Text(
                      buttonText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildGenderCard(
              l10n.male, Icons.male, Theme.of(context).colorScheme.tertiary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGenderCard(l10n.female, Icons.female,
              Theme.of(context).colorScheme.secondary),
        ),
      ],
    );
  }

  Widget _buildGenderCard(String gender, IconData icon, Color color) {
    return Consumer<BMIProvider>(
      builder: (context, bmiProvider, child) {
        final isSelected = bmiProvider.selectedGender == gender;

        return GestureDetector(
          onTap: () {
            bmiProvider.updateGender(gender);
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 12),
                Text(
                  gender,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeightSlider() {
    return Consumer<BMIProvider>(
      builder: (context, bmiProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.heightInCm,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${bmiProvider.height.round()}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final height = 155 + (index * 5);
                    final isSelected =
                        (bmiProvider.height - height).abs() < 2.5;

                    return Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 2,
                            height:
                                isSelected ? 20 : (index % 2 == 0 ? 15 : 10),
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.4),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$height',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 5,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 18),
                ),
                child: Slider(
                  value: bmiProvider.height,
                  min: 150,
                  max: 200,
                  divisions: 50,
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor:
                      Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  onChanged: (value) {
                    bmiProvider.updateHeight(value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeightSelector() {
    return Consumer<BMIProvider>(
      builder: (context, bmiProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.weightInKg,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Slideable Weight Display
              GestureDetector(
                onPanUpdate: (details) {
                  // Calculate weight change based on horizontal drag
                  final sensitivity = 0.5; // Adjust sensitivity
                  final deltaWeight = (-details.delta.dx * sensitivity).round();

                  if (deltaWeight != 0) {
                    final newWeight =
                        (bmiProvider.weight + deltaWeight).clamp(30, 300);
                    if (newWeight != bmiProvider.weight) {
                      bmiProvider.updateWeight(newWeight);
                      // Add haptic feedback for weight changes
                      HapticFeedback.selectionClick();
                    }
                  }
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      // Scale indicator at top center
                      Positioned(
                        top: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 2,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                      // Weight display
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              '${bmiProvider.weight - 1}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                            Text(
                              '${bmiProvider.weight}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${bmiProvider.weight + 1}',
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // +/- Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (bmiProvider.weight > 30) {
                        bmiProvider.updateWeight(bmiProvider.weight - 1);
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (bmiProvider.weight < 300) {
                        bmiProvider.updateWeight(bmiProvider.weight + 1);
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildAgeSelector() {
    return Consumer<BMIProvider>(
      builder: (context, bmiProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.age,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 60,
                child: Center(
                  child: Text(
                    '${bmiProvider.age}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (bmiProvider.age > 10) {
                        bmiProvider.updateAge(bmiProvider.age - 1);
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (bmiProvider.age < 100) {
                        bmiProvider.updateAge(bmiProvider.age + 1);
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildStaticExtendedFAB() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(25), // Back to original
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _calculateBMI();
        },
        borderRadius: BorderRadius.circular(25), // Back to original
        splashColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
        highlightColor:
            Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
        child: Container(
          height: 50, // Back to original height
          width: 140, // Back to original width
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(25), // Back to original
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calculate_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 18,
                ), // Back to original
                SizedBox(width: 8), // Back to original
                Text(
                  AppLocalizations.of(context)!.calculate,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExtendedFABCutoutClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    final fabWidth = 90.0; // Back to original
    final fabHeight = 60.0; // Back to original
    final fabRadius = fabHeight / 2;
    final centerX = size.width / 2;
    final fabTop = 0.0;

    final left = centerX - fabWidth / 2;
    final right = centerX + fabWidth / 2;

    path.moveTo(0, 24);
    path.quadraticBezierTo(0, 0, 24, 0);

    path.lineTo(left - fabRadius, fabTop);

    path.arcToPoint(
      Offset(left, fabTop + fabRadius),
      radius: Radius.circular(fabRadius),
      clockwise: false,
    );

    path.lineTo(right, fabTop + fabRadius);

    path.arcToPoint(
      Offset(right + fabRadius, fabTop),
      radius: Radius.circular(fabRadius),
      clockwise: false,
    );

    path.lineTo(size.width - 24, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 24);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
