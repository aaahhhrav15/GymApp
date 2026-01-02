import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingDOBScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  const OnboardingDOBScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onBack,
  });

  @override
  State<OnboardingDOBScreen> createState() => _OnboardingDOBScreenState();
}

class _OnboardingDOBScreenState extends State<OnboardingDOBScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OnboardingProvider>();
      _selectedDate = provider.birthday;
      if (mounted) setState(() {});
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 100);
    final DateTime lastDate = DateTime(now.year - 10);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      context.read<OnboardingProvider>().updateBirthday(picked);
    }
  }

  void _handleNext() {
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
            'Date of Birth',
            style: TextStyle(
              fontSize: screenWidth * 0.08,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Subtitle
          Text(
            'When were you born?',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.06),
          
          // Date Picker Button
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Select your date of birth',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedDate != null
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.4),
                            fontStyle: _selectedDate == null
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ],
              ),
            ),
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
}



