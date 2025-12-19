import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:flutter/services.dart';

class GoogleSignupCompletionScreen extends StatefulWidget {
  final Map<String, dynamic> googleUserInfo;

  const GoogleSignupCompletionScreen({super.key, required this.googleUserInfo});

  @override
  State<GoogleSignupCompletionScreen> createState() =>
      _GoogleSignupCompletionScreenState();
}

class _GoogleSignupCompletionScreenState
    extends State<GoogleSignupCompletionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _gymCodeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedGender = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),

                // Welcome message with user info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    children: [
                      Text(
                        'Welcome, ${widget.googleUserInfo['name'] ?? 'User'}! 👋',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Just a few more details to get started',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Help us personalize your fitness journey',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 32),

                // Date of Birth Field
                _buildDateField(),

                const SizedBox(height: 20),

                // Gender Selection
                _buildGenderField(),

                const SizedBox(height: 20),

                Row(
                  children: [
                    // Weight Field
                    Expanded(
                      child: _buildInputField(
                        label: 'Weight (kg)',
                        controller: _weightController,
                        icon: Icons.monitor_weight_outlined,
                        hintText: 'Enter weight',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Enter weight';
                          }
                          final weight = int.tryParse(value!);
                          if (weight == null || weight < 20 || weight > 300) {
                            return 'Enter valid weight';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Height Field
                    Expanded(
                      child: _buildInputField(
                        label: 'Height (cm)',
                        controller: _heightController,
                        icon: Icons.height,
                        hintText: 'Enter height',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Enter height';
                          }
                          final height = int.tryParse(value!);
                          if (height == null || height < 100 || height > 250) {
                            return 'Enter valid height';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Gym Code Field (Optional)
                _buildGymCodeField(),

                const SizedBox(height: 20),

                // Complete Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Complete Setup',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
              fontStyle: FontStyle.italic,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showModernDatePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.grey[400]),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select your date of birth',
                  style: TextStyle(
                    color: _selectedDate != null
                        ? Colors.black87
                        : Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildGenderOption('Male', Icons.male),
            const SizedBox(width: 12),
            _buildGenderOption('Female', Icons.female),
            const SizedBox(width: 12),
            _buildGenderOption('Other', Icons.person_outline),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    bool isSelected = _selectedGender == gender;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.green : Colors.grey[400],
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                gender,
                style: TextStyle(
                  color: isSelected ? Colors.green : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGymCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Join Gym? (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _gymCodeController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.fitness_center_outlined,
              color: Colors.grey[400],
            ),
            hintText: 'Enter Your Club Code',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
              fontStyle: FontStyle.italic,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.green, width: 2),
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

  void _showModernDatePicker() {
    int selectedDay = _selectedDate?.day ?? 15;
    int selectedMonth = _selectedDate?.month ?? 6;
    int selectedYear = _selectedDate?.year ?? (DateTime.now().year - 25);

    final currentYear = DateTime.now().year;
    final years = List.generate(100, (index) => currentYear - 13 - index);
    final months = [
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Get days in selected month
            final daysInMonth = DateTime(
              selectedYear,
              selectedMonth + 1,
              0,
            ).day;
            final days = List.generate(daysInMonth, (index) => index + 1);

            // Ensure selected day is valid for the month
            if (selectedDay > daysInMonth) {
              selectedDay = daysInMonth;
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Date of Birth',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Date Picker Wheels
                  Expanded(
                    child: Row(
                      children: [
                        // Day Picker
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Day',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  itemExtent: 50,
                                  perspective: 0.005,
                                  diameterRatio: 1.2,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    setModalState(() {
                                      selectedDay = days[index];
                                    });
                                  },
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: days.length,
                                    builder: (context, index) {
                                      final isSelected =
                                          days[index] == selectedDay;
                                      return Center(
                                        child: Container(
                                          width: 60,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: isSelected
                                                ? Border.all(
                                                    color: Colors.green,
                                                    width: 2,
                                                  )
                                                : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${days[index]}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? Colors.green
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Month Picker
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              const Text(
                                'Month',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  itemExtent: 50,
                                  perspective: 0.005,
                                  diameterRatio: 1.2,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    setModalState(() {
                                      selectedMonth = index + 1;
                                    });
                                  },
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: months.length,
                                    builder: (context, index) {
                                      final isSelected =
                                          (index + 1) == selectedMonth;
                                      return Center(
                                        child: Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: isSelected
                                                ? Border.all(
                                                    color: Colors.green,
                                                    width: 2,
                                                  )
                                                : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              months[index],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? Colors.green
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Year Picker
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Year',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  itemExtent: 50,
                                  perspective: 0.005,
                                  diameterRatio: 1.2,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (index) {
                                    setModalState(() {
                                      selectedYear = years[index];
                                    });
                                  },
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: years.length,
                                    builder: (context, index) {
                                      final isSelected =
                                          years[index] == selectedYear;
                                      return Center(
                                        child: Container(
                                          width: 70,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: isSelected
                                                ? Border.all(
                                                    color: Colors.green,
                                                    width: 2,
                                                  )
                                                : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${years[index]}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? Colors.green
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(
                            selectedYear,
                            selectedMonth,
                            selectedDay,
                          );
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleComplete() async {
    // Validate required fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      // Snackbar removed - no longer showing error messages
      return;
    }

    if (_selectedGender.isEmpty) {
      // Snackbar removed - no longer showing error messages
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate saving user data
    await Future.delayed(const Duration(seconds: 2));

    // Print all collected data (in real app, save to database)
    print('Google User Info: ${widget.googleUserInfo}');
    print('Date of Birth: $_selectedDate');
    print('Gender: $_selectedGender');
    print('Weight: ${_weightController.text} kg');
    print('Height: ${_heightController.text} cm');
    print(
      'Club Code: ${_gymCodeController.text.isNotEmpty ? _gymCodeController.text : 'Not provided'}',
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showErrorSnackBar(String message) {
    // Snackbars removed - no longer showing error messages
  }

  @override
  void dispose() {
    _gymCodeController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}
