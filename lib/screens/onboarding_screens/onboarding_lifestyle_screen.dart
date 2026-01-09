import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingLifestyleScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  const OnboardingLifestyleScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onBack,
  });

  @override
  State<OnboardingLifestyleScreen> createState() =>
      _OnboardingLifestyleScreenState();
}

class _OnboardingLifestyleScreenState extends State<OnboardingLifestyleScreen> {
  String? _selectedLifestyle;

  final List<Map<String, dynamic>> _lifestyleOptions = [
    {
      'value': 'sedentary',
      'title': 'Sedentary',
      'subtitle': 'Little or no exercise',
      'icon': Icons.chair,
    },
    {
      'value': 'lightly-active',
      'title': 'Lightly Active',
      'subtitle': 'Light exercise 1-3 days/week',
      'icon': Icons.directions_walk,
    },
    {
      'value': 'active',
      'title': 'Active',
      'subtitle': 'Moderate exercise 3-5 days/week',
      'icon': Icons.fitness_center,
    },
    {
      'value': 'very-active',
      'title': 'Very Active',
      'subtitle': 'Hard exercise 6-7 days/week',
      'icon': Icons.sports_gymnastics,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OnboardingProvider>();
      _selectedLifestyle = provider.lifestyle;
      if (mounted) setState(() {});
    });
  }

  void _handleNext() {
    if (_selectedLifestyle != null) {
      context.read<OnboardingProvider>().updateLifestyle(_selectedLifestyle);
    }
    widget.onNext();
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
            'Lifestyle',
            style: TextStyle(
              fontSize: screenWidth * 0.08,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Subtitle
          Text(
            'How active are you?',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.06),
          
          // Lifestyle Options
          ..._lifestyleOptions.map((option) => Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: _buildLifestyleOption(
                  title: option['title'] as String,
                  subtitle: option['subtitle'] as String,
                  value: option['value'] as String,
                  icon: option['icon'] as IconData,
                ),
              )),
          
          SizedBox(height: screenHeight * 0.04),
          
          // Next Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
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

  Widget _buildLifestyleOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedLifestyle == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLifestyle = value;
        });
        context.read<OnboardingProvider>().updateLifestyle(value);
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





