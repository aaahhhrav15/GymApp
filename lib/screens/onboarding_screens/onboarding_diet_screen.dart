import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingDietScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  const OnboardingDietScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onBack,
  });

  @override
  State<OnboardingDietScreen> createState() => _OnboardingDietScreenState();
}

class _OnboardingDietScreenState extends State<OnboardingDietScreen> {
  String? _selectedDiet;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OnboardingProvider>();
      _selectedDiet = provider.dietPreference;
      if (mounted) setState(() {});
    });
  }

  void _handleNext() {
    if (_selectedDiet != null) {
      context.read<OnboardingProvider>().updateDietPreference(_selectedDiet);
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
            'Diet Preference',
            style: TextStyle(
              fontSize: screenWidth * 0.08,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Subtitle
          Text(
            'What is your dietary preference?',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.06),
          
          // Veg Option
          _buildDietOption(
            title: 'Vegetarian',
            subtitle: 'Plant-based diet',
            value: 'veg',
            icon: Icons.eco,
          ),
          
          SizedBox(height: screenHeight * 0.03),
          
          // Non-Veg Option
          _buildDietOption(
            title: 'Non-Vegetarian',
            subtitle: 'Includes meat and fish',
            value: 'non-veg',
            icon: Icons.restaurant,
          ),
          
          SizedBox(height: screenHeight * 0.08),
          
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

  Widget _buildDietOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedDiet == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDiet = value;
        });
        context.read<OnboardingProvider>().updateDietPreference(value);
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





