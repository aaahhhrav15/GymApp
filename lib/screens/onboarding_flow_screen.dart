import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import 'onboarding_screens/onboarding_height_weight_screen.dart';
import 'onboarding_screens/onboarding_dob_screen.dart';
import 'onboarding_screens/onboarding_diet_screen.dart';
import 'onboarding_screens/onboarding_lifestyle_screen.dart';
import 'onboarding_screens/onboarding_goal_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Consumer<OnboardingProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Progress indicator
                _buildProgressIndicator(provider.currentStep),
                
                // Page view with onboarding screens
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      OnboardingHeightWeightScreen(
                        onNext: () {
                          provider.nextStep();
                          _onStepChanged(provider.currentStep);
                        },
                        onSkip: () {
                          provider.nextStep();
                          _onStepChanged(provider.currentStep);
                        },
                      ),
                      OnboardingDOBScreen(
                        onNext: () {
                          provider.nextStep();
                          _onStepChanged(provider.currentStep);
                        },
                        onSkip: () {
                          provider.nextStep();
                          _onStepChanged(provider.currentStep);
                        },
                        onBack: () {
                          provider.previousStep();
                          _onStepChanged(provider.currentStep);
                        },
                      ),
                      OnboardingDietScreen(
                        onNext: () {
                          provider.nextStep();
                          _onStepChanged(provider.currentStep);
                        },
                        onSkip: () {
                          provider.nextStep();
                          _onStepChanged(provider.currentStep);
                        },
                        onBack: () {
                          provider.previousStep();
                          _onStepChanged(provider.currentStep);
                        },
                      ),
                      OnboardingLifestyleScreen(
                        onNext: () {
                          provider.nextStep();
                          _onStepChanged(provider.currentStep);
                        },
                        onSkip: () {
                          provider.nextStep();
                          _onStepChanged(provider.currentStep);
                        },
                        onBack: () {
                          provider.previousStep();
                          _onStepChanged(provider.currentStep);
                        },
                      ),
                      OnboardingGoalScreen(
                        onComplete: () async {
                          final success = await provider.saveOnboardingData();
                          if (success && mounted) {
                            Navigator.pushReplacementNamed(context, '/home');
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.error ?? 'Failed to save data'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                        onSkip: () async {
                          final success = await provider.saveOnboardingData();
                          if (success && mounted) {
                            Navigator.pushReplacementNamed(context, '/home');
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.error ?? 'Failed to save data'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                        onBack: () {
                          provider.previousStep();
                          _onStepChanged(provider.currentStep);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: index <= currentStep
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

