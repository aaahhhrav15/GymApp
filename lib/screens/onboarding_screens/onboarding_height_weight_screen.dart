import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingHeightWeightScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingHeightWeightScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<OnboardingHeightWeightScreen> createState() =>
      _OnboardingHeightWeightScreenState();
}

class _OnboardingHeightWeightScreenState
    extends State<OnboardingHeightWeightScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OnboardingProvider>();
      if (provider.height != null) {
        _heightController.text = provider.height!.toStringAsFixed(1);
      }
      if (provider.weight != null) {
        _weightController.text = provider.weight!.toStringAsFixed(1);
      }
    });
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final provider = context.read<OnboardingProvider>();
    if (_heightController.text.isNotEmpty) {
      provider.updateHeight(double.tryParse(_heightController.text));
    }
    if (_weightController.text.isNotEmpty) {
      provider.updateWeight(double.tryParse(_weightController.text));
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
          
          // Title
          Text(
            'Height & Weight',
            style: TextStyle(
              fontSize: screenWidth * 0.08,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Subtitle
          Text(
            'Help us personalize your experience',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.06),
          
          // Height Input
          _buildInputField(
            label: 'Height (cm)',
            controller: _heightController,
            icon: Icons.height,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          
          SizedBox(height: screenHeight * 0.03),
          
          // Weight Input
          _buildInputField(
            label: 'Weight (kg)',
            controller: _weightController,
            icon: Icons.monitor_weight,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            hintText: 'Enter $label',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              fontSize: 15,
              fontStyle: FontStyle.italic,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}



