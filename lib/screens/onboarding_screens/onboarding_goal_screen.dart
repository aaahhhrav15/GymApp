import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingGoalScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  const OnboardingGoalScreen({
    super.key,
    required this.onComplete,
    required this.onSkip,
    required this.onBack,
  });

  @override
  State<OnboardingGoalScreen> createState() => _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends State<OnboardingGoalScreen> {
  String? _selectedGoal;

  final List<Map<String, dynamic>> _goalOptions = [
    {
      'value': 'weight-loss',
      'title': 'Weight Loss',
      'subtitle': 'Lose weight and burn fat',
      'icon': Icons.trending_down,
    },
    {
      'value': 'muscle-gain',
      'title': 'Muscle Gain',
      'subtitle': 'Build muscle and strength',
      'icon': Icons.trending_up,
    },
    {
      'value': 'maintenance',
      'title': 'Maintenance',
      'subtitle': 'Maintain current fitness level',
      'icon': Icons.balance,
    },
    {
      'value': 'endurance',
      'title': 'Endurance',
      'subtitle': 'Improve stamina and endurance',
      'icon': Icons.speed,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OnboardingProvider>();
      _selectedGoal = provider.goal;
      if (mounted) setState(() {});
    });
  }

  void _handleComplete() {
    if (_selectedGoal != null) {
      context.read<OnboardingProvider>().updateGoal(_selectedGoal);
    }
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.06;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.05),
          
          // Back Button
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            onPressed: widget.onBack,
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Title
          Text(
            'Your Goal',
            style: TextStyle(
              fontSize: screenWidth * 0.08,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Subtitle
          Text(
            'What do you want to achieve?',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.06),
          
          // Goal Options
          ..._goalOptions.map((option) => Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: _buildGoalOption(
                  title: option['title'] as String,
                  subtitle: option['subtitle'] as String,
                  value: option['value'] as String,
                  icon: option['icon'] as IconData,
                ),
              )),
          
          SizedBox(height: screenHeight * 0.04),
          
          // Complete Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _handleComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Consumer<OnboardingProvider>(
                builder: (context, provider, child) {
                  return provider.isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          'Complete',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                },
              ),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Skip Button
          Center(
            child: TextButton(
              onPressed: widget.onSkip,
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedGoal == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGoal = value;
        });
        context.read<OnboardingProvider>().updateGoal(value);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

