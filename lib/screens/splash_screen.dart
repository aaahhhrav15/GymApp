import 'package:flutter/material.dart';
import 'package:gym_app_2/services/token_manager.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mLetterAnimationController;

  late Animation<double> _mLetterScaleAnimation;
  late Animation<double> _mLetterFadeAnimation;

  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for logo only
    _mLetterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400), // Much faster
      vsync: this,
    );

    // M Logo animations
    _mLetterScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mLetterAnimationController,
      curve: Curves.elasticOut,
    ));

    _mLetterFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mLetterAnimationController,
      curve: Curves.easeIn,
    ));

    // Animation listener - navigate when logo animation completes
    _mLetterAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_navigationStarted) {
        _navigationStarted = true;
        Future.delayed(const Duration(milliseconds: 200), () {
          // Much shorter delay
          _navigateToNextScreen();
        });
      }
    });

    // Start logo animation
    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      // Start almost immediately
      _mLetterAnimationController.forward();
    });
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Use isLoggedIn() which checks token existence, login flag, and expiry
      final isLoggedIn = await TokenManager.isLoggedIn();

      if (!mounted) return;

      if (isLoggedIn) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding',
          (route) => false,
        );
      }
    } catch (e) {
      print('Error checking authentication: $e');
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding',
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _mLetterAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.grey[50]!,
              Colors.green[25] ?? Colors.green[50]!.withOpacity(0.3),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.2,
                  colors: [
                    Colors.green.withOpacity(0.1),
                    Colors.transparent,
                    Colors.green.withOpacity(0.05),
                  ],
                ),
              ),
            ),

            // Main Content - Just Logo
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo "M" Animation
                  AnimatedBuilder(
                    animation: _mLetterAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _mLetterScaleAnimation.value,
                        child: FadeTransition(
                          opacity: _mLetterFadeAnimation,
                          child: Container(
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.cyan.withOpacity(0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/logo.jpg',
                                width: screenWidth * 0.3,
                                height: screenWidth * 0.3,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Simple fallback without the "M" text
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.grey[300],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom Brand Mark (optional, can be removed)
            Positioned(
              bottom: screenHeight * 0.06,
              left: 0,
              right: 0,
              child: Text(
                l10n.fitnessStrengthPower,
                style: TextStyle(
                  fontSize: screenWidth * 0.028,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  letterSpacing: screenWidth * 0.008,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
