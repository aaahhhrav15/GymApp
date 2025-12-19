// import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
// import 'package:flutter/services.dart';
// import 'onboarding_screen.dart';
// import '../services/api_service.dart'; // Add this import

// class RegistrationScreen extends StatefulWidget {
//   const RegistrationScreen({super.key});

//   @override
//   State<RegistrationScreen> createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends State<RegistrationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final PageController _pageController = PageController();
//   int _currentStep = 0;

//   // Form controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   final TextEditingController _gymCodeController = TextEditingController();
//   final TextEditingController _weightController = TextEditingController();
//   final TextEditingController _heightController = TextEditingController();

//   DateTime? _selectedDate;
//   String _selectedGender = '';
//   String _selectedCountryCode = '+91';
//   String _selectedCountryFlag = '🇮🇳';
//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;
//   bool _isLoading = false; // Add loading state

//   // Country codes data
//   final List<Map<String, String>> _countryCodes = [
//     {'code': '+91', 'flag': '🇮🇳', 'country': 'India'},
//     {'code': '+1', 'flag': '🇺🇸', 'country': 'United States'},
//     {'code': '+44', 'flag': '🇬🇧', 'country': 'United Kingdom'},
//     {'code': '+61', 'flag': '🇦🇺', 'country': 'Australia'},
//     {'code': '+81', 'flag': '🇯🇵', 'country': 'Japan'},
//     {'code': '+49', 'flag': '🇩🇪', 'country': 'Germany'},
//     {'code': '+33', 'flag': '🇫🇷', 'country': 'France'},
//     {'code': '+86', 'flag': '🇨🇳', 'country': 'China'},
//     {'code': '+7', 'flag': '🇷🇺', 'country': 'Russia'},
//     {'code': '+55', 'flag': '🇧🇷', 'country': 'Brazil'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             _buildHeader(),

//             // Progress Indicator
//             _buildProgressIndicator(),

//             // Form Content
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [_buildPersonalInfoStep(), _buildPhysicalInfoStep()],
//               ),
//             ),

//             // Bottom Navigation
//             _buildBottomNavigation(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () {
//               if (_currentStep > 0) {
//                 setState(() {
//                   _currentStep--;
//                 });
//                 _pageController.previousPage(
//                   duration: const Duration(milliseconds: 300),
//                   curve: Curves.easeInOut,
//                 );
//               } else {
//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(
//                     builder: (context) => const OnboardingScreen(),
//                   ),
//                   (route) => false,
//                 );
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: const Icon(Icons.arrow_back_ios, size: 20),
//             ),
//           ),
//           const Expanded(
//             child: Center(
//               child: Text(
//                 'Create Account',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 44),
//         ],
//       ),
//     );
//   }

//   Widget _buildProgressIndicator() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.green,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Container(
//               height: 4,
//               decoration: BoxDecoration(
//                 color: _currentStep >= 1 ? Colors.green : Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPersonalInfoStep() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 10),

//             const Text(
//               'Personal Information',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),

//             const SizedBox(height: 8),

//             Text(
//               'Please fill in your details to continue',
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             ),

//             const SizedBox(height: 32),

//             // Name Field
//             _buildInputField(
//               label: 'Full Name',
//               controller: _nameController,
//               icon: Icons.person_outline,
//               hintText: 'Enter your full name',
//               validator: (value) {
//                 if (value?.isEmpty ?? true) {
//                   return 'Please enter your name';
//                 }
//                 return null;
//               },
//             ),

//             const SizedBox(height: 20),

//             // Email Field
//             _buildInputField(
//               label: 'Email Address',
//               controller: _emailController,
//               icon: Icons.email_outlined,
//               hintText: 'Enter your email address',
//               keyboardType: TextInputType.emailAddress,
//               validator: (value) {
//                 if (value?.isEmpty ?? true) {
//                   return 'Please enter your email';
//                 }
//                 if (!RegExp(
//                   r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                 ).hasMatch(value!)) {
//                   return 'Please enter a valid email';
//                 }
//                 return null;
//               },
//             ),

//             const SizedBox(height: 20),

//             // Password Field
//             _buildPasswordField(),

//             const SizedBox(height: 20),

//             // Confirm Password Field
//             _buildConfirmPasswordField(),

//             const SizedBox(height: 20),

//             // Phone Number Field
//             _buildPhoneField(),

//             const SizedBox(height: 20),

//             // Date of Birth Field
//             _buildDateField(),

//             const SizedBox(height: 20),

//             // Gender Selection
//             _buildGenderField(),

//             const SizedBox(height: 20),

//             // Gym Code Field (Optional)
//             _buildGymCodeField(),

//             const SizedBox(height: 100), // Space for bottom button
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPhysicalInfoStep() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 20),

//           const Text(
//             'Physical Information',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),

//           const SizedBox(height: 8),

//           Text(
//             'Help us personalize your fitness journey',
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),

//           const SizedBox(height: 32),

//           Row(
//             children: [
//               // Weight Field
//               Expanded(
//                 child: _buildInputField(
//                   label: 'Weight (kg)',
//                   controller: _weightController,
//                   icon: Icons.monitor_weight_outlined,
//                   hintText: 'Enter weight',
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   validator: (value) {
//                     if (value?.isEmpty ?? true) {
//                       return 'Enter weight';
//                     }
//                     final weight = int.tryParse(value!);
//                     if (weight == null || weight < 20 || weight > 300) {
//                       return 'Enter valid weight';
//                     }
//                     return null;
//                   },
//                 ),
//               ),

//               const SizedBox(width: 16),

//               // Height Field
//               Expanded(
//                 child: _buildInputField(
//                   label: 'Height (cm)',
//                   controller: _heightController,
//                   icon: Icons.height,
//                   hintText: 'Enter height',
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   validator: (value) {
//                     if (value?.isEmpty ?? true) {
//                       return 'Enter height';
//                     }
//                     final height = int.tryParse(value!);
//                     if (height == null || height < 100 || height > 250) {
//                       return 'Enter valid height';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 40),

//           // Summary Card
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Summary',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildSummaryRow('Name', _nameController.text),
//                 _buildSummaryRow('Email', _emailController.text),
//                 _buildSummaryRow(
//                   'Phone',
//                   '$_selectedCountryCode ${_phoneController.text}',
//                 ),
//                 _buildSummaryRow(
//                   'Date of Birth',
//                   _selectedDate != null
//                       ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
//                       : '',
//                 ),
//                 _buildSummaryRow('Gender', _selectedGender),
//                 _buildSummaryRow(
//                   'Gym Code',
//                   _gymCodeController.text.isEmpty
//                       ? 'Not provided'
//                       : _gymCodeController.text,
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 100), // Space for bottom button
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 80,
//             child: Text(
//               label,
//               style: TextStyle(color: Colors.grey[600], fontSize: 14),
//             ),
//           ),
//           const Text(': ', style: TextStyle(color: Colors.grey)),
//           Expanded(
//             child: Text(
//               value.isNotEmpty ? value : 'Not provided',
//               style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInputField({
//     required String label,
//     required TextEditingController controller,
//     required IconData icon,
//     String? hintText,
//     TextInputType keyboardType = TextInputType.text,
//     List<TextInputFormatter>? inputFormatters,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           inputFormatters: inputFormatters,
//           validator: validator,
//           decoration: InputDecoration(
//             prefixIcon: Icon(icon, color: Colors.grey[400]),
//             hintText: hintText,
//             hintStyle: TextStyle(
//               color: Colors.grey[400],
//               fontSize: 15,
//               fontStyle: FontStyle.italic,
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(color: Colors.grey.shade200),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(color: Colors.grey.shade200),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Colors.green, width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Colors.red),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 16,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPasswordField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'New Password',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _passwordController,
//           obscureText: !_isPasswordVisible,
//           validator: (value) {
//             if (value?.isEmpty ?? true) {
//               return 'Please enter a password';
//             }
//             if (value!.length < 6) {
//               return 'Password must be at least 6 characters';
//             }
//             return null;
//           },
//           decoration: InputDecoration(
//             prefixIcon: Icon(Icons.lock_outlined, color: Colors.grey[400]),
//             hintText: 'Enter your password',
//             hintStyle: TextStyle(
//               color: Colors.grey[400],
//               fontSize: 15,
//               fontStyle: FontStyle.italic,
//             ),
//             suffixIcon: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _isPasswordVisible = !_isPasswordVisible;
//                 });
//               },
//               child: Icon(
//                 _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                 color: Colors.grey[400],
//               ),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(color: Colors.grey.shade200),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(color: Colors.grey.shade200),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Colors.green, width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Colors.red),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 16,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildConfirmPasswordField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Confirm Password',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _confirmPasswordController,
//           obscureText: !_isConfirmPasswordVisible,
//           validator: (value) {
//             if (value?.isEmpty ?? true) {
//               return 'Please confirm your password';
//             }
//             if (value != _passwordController.text) {
//               return 'Passwords do not match';
//             }
//             return null;
//           },
//           decoration: InputDecoration(
//             prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
//             hintText: 'Re-enter your password',
//             hintStyle: TextStyle(
//               color: Colors.grey[400],
//               fontSize: 15,
//               fontStyle: FontStyle.italic,
//             ),
//             suffixIcon: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
//                 });
//               },
//               child: Icon(
//                 _isConfirmPasswordVisible
//                     ? Icons.visibility
//                     : Icons.visibility_off,
//                 color: Colors.grey[400],
//               ),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(color: Colors.grey.shade200),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(color: Colors.grey.shade200),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Colors.green, width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Colors.red),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 16,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildGymCodeField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: const TextSpan(
//             children: [
//               TextSpan(
//                 text: 'Join Gym? (Optional)',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _gymCodeController,
//           textCapitalization: TextCapitalization.characters,
//           decoration: InputDecoration(
//             prefixIcon: Icon(
//               Icons.fitness_center_outlined,
//               color: Colors.grey[400],
//             ),
//             hintText: 'Enter Your Gym Code',
//             hintStyle: TextStyle(
//               color: Colors.grey[400],
//               fontSize: 15,
//               fontStyle: FontStyle.italic,
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(color: Colors.grey.shade200),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(color: Colors.grey.shade200),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Colors.green, width: 2),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 16,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPhoneField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Phone Number',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             // Country Code Selector
//             GestureDetector(
//               onTap: _showCountryCodePicker,
//               child: Container(
//                 width: 100,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 16,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(color: Colors.grey.shade200),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       _selectedCountryFlag,
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         _selectedCountryCode,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 14,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Icon(
//                       Icons.arrow_drop_down,
//                       color: Colors.grey[400],
//                       size: 20,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Phone Number Field
//             Expanded(
//               child: TextFormField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'Please enter your phone number';
//                   }
//                   if (value!.length < 10) {
//                     return 'Please enter a valid phone number';
//                   }
//                   return null;
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Enter phone number',
//                   hintStyle: TextStyle(
//                     color: Colors.grey[400],
//                     fontSize: 15,
//                     fontStyle: FontStyle.italic,
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide(color: Colors.grey.shade200),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide(color: Colors.grey.shade200),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: const BorderSide(color: Colors.green, width: 2),
//                   ),
//                   errorBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: const BorderSide(color: Colors.red),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 16,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildDateField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Date of Birth',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: _showModernDatePicker,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border.all(color: Colors.grey.shade200),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.calendar_today_outlined, color: Colors.grey[400]),
//                 const SizedBox(width: 12),
//                 Text(
//                   _selectedDate != null
//                       ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
//                       : 'Select your date of birth',
//                   style: TextStyle(
//                     color: _selectedDate != null
//                         ? Colors.black87
//                         : Colors.grey[400],
//                     fontSize: 16,
//                   ),
//                 ),
//                 const Spacer(),
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   size: 16,
//                   color: Colors.grey[400],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildGenderField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Gender',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             _buildGenderOption('Male', Icons.male),
//             const SizedBox(width: 12),
//             _buildGenderOption('Female', Icons.female),
//             const SizedBox(width: 12),
//             _buildGenderOption('Other', Icons.person_outline),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildGenderOption(String gender, IconData icon) {
//     bool isSelected = _selectedGender == gender;

//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _selectedGender = gender;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
//             border: Border.all(
//               color: isSelected ? Colors.green : Colors.grey.shade200,
//               width: isSelected ? 2 : 1,
//             ),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             children: [
//               Icon(
//                 icon,
//                 color: isSelected ? Colors.green : Colors.grey[400],
//                 size: 28,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 gender,
//                 style: TextStyle(
//                   color: isSelected ? Colors.green : Colors.grey[600],
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomNavigation() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       child: SizedBox(
//         width: double.infinity,
//         height: 56,
//         child: ElevatedButton(
//           onPressed: _isLoading ? null : _handleNextButton,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.black87,
//             foregroundColor: Colors.white,
//             elevation: 0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(28),
//             ),
//             disabledBackgroundColor: Colors.grey[300],
//           ),
//           child: _isLoading
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//               : Text(
//                   _currentStep == 0 ? 'Continue' : 'Create Account',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }

//   void _handleNextButton() {
//     if (_currentStep == 0) {
//       if (_validateFirstStep()) {
//         setState(() {
//           _currentStep = 1;
//         });
//         _pageController.nextPage(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       }
//     } else {
//       if (_validateSecondStep()) {
//         _submitForm();
//       }
//     }
//   }

//   bool _validateFirstStep() {
//     if (!(_formKey.currentState?.validate() ?? false)) {
//       return false;
//     }

//     if (_selectedDate == null) {
//       _showErrorSnackBar('Please select your date of birth');
//       return false;
//     }

//     if (_selectedGender.isEmpty) {
//       _showErrorSnackBar('Please select your gender');
//       return false;
//     }

//     return true;
//   }

//   bool _validateSecondStep() {
//     if (_weightController.text.isEmpty) {
//       _showErrorSnackBar('Please enter your weight');
//       return false;
//     }

//     if (_heightController.text.isEmpty) {
//       _showErrorSnackBar('Please enter your height');
//       return false;
//     }

//     return true;
//   }

//   void _submitForm() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Format date for API
//       final dateOfBirth =
//           '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

//       // Call API
//       final result = await ApiService.register(
//         name: _nameController.text.trim(),
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//         phone: _phoneController.text.trim(),
//         countryCode: _selectedCountryCode,
//         dateOfBirth: dateOfBirth,
//         gender: _selectedGender,
//         weight: _weightController.text,
//         height: _heightController.text,
//         gymCode: _gymCodeController.text.trim().isEmpty
//             ? null
//             : _gymCodeController.text.trim(),
//       );

//       if (result['success']) {
//         // Registration successful
//         _showSuccessSnackBar('Account created successfully!');

//         // Navigate to home screen
//         if (mounted) {
//           Navigator.pushReplacementNamed(context, '/home');
//         }
//       } else {
//         // Registration failed
//         _showErrorSnackBar(result['error'] ?? 'Registration failed');
//       }
//     } catch (e) {
//       _showErrorSnackBar('Network error. Please check your connection.');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showCountryCodePicker() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           height: 400,
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Select Country',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _countryCodes.length,
//                   itemBuilder: (context, index) {
//                     final country = _countryCodes[index];
//                     return ListTile(
//                       leading: Text(
//                         country['flag']!,
//                         style: const TextStyle(fontSize: 24),
//                       ),
//                       title: Text(
//                         country['country']!,
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                       trailing: Text(
//                         country['code']!,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 14,
//                         ),
//                       ),
//                       onTap: () {
//                         setState(() {
//                           _selectedCountryCode = country['code']!;
//                           _selectedCountryFlag = country['flag']!;
//                         });
//                         Navigator.pop(context);
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showModernDatePicker() {
//     int selectedDay = _selectedDate?.day ?? 15;
//     int selectedMonth = _selectedDate?.month ?? 6;
//     int selectedYear = _selectedDate?.year ?? (DateTime.now().year - 25);

//     final currentYear = DateTime.now().year;
//     final years = List.generate(100, (index) => currentYear - 13 - index);
//     final months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             final daysInMonth = DateTime(
//               selectedYear,
//               selectedMonth + 1,
//               0,
//             ).day;
//             final days = List.generate(daysInMonth, (index) => index + 1);

//             if (selectedDay > daysInMonth) {
//               selectedDay = daysInMonth;
//             }

//             return Container(
//               height: MediaQuery.of(context).size.height * 0.5,
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Select Date of Birth',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 20),
//                   Expanded(
//                     child: Row(
//                       children: [
//                         // Day Picker
//                         Expanded(
//                           child: Column(
//                             children: [
//                               const Text(
//                                 'Day',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Expanded(
//                                 child: ListWheelScrollView.useDelegate(
//                                   itemExtent: 50,
//                                   perspective: 0.005,
//                                   diameterRatio: 1.2,
//                                   physics: const FixedExtentScrollPhysics(),
//                                   onSelectedItemChanged: (index) {
//                                     setModalState(() {
//                                       selectedDay = days[index];
//                                     });
//                                   },
//                                   childDelegate: ListWheelChildBuilderDelegate(
//                                     childCount: days.length,
//                                     builder: (context, index) {
//                                       final isSelected =
//                                           days[index] == selectedDay;
//                                       return Center(
//                                         child: Container(
//                                           width: 60,
//                                           decoration: BoxDecoration(
//                                             color: isSelected
//                                                 ? Colors.green.withOpacity(0.1)
//                                                 : Colors.transparent,
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                             border: isSelected
//                                                 ? Border.all(
//                                                     color: Colors.green,
//                                                     width: 2,
//                                                   )
//                                                 : null,
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               '${days[index]}',
//                                               style: TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: isSelected
//                                                     ? FontWeight.bold
//                                                     : FontWeight.normal,
//                                                 color: isSelected
//                                                     ? Colors.green
//                                                     : Colors.black87,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Month Picker
//                         Expanded(
//                           flex: 2,
//                           child: Column(
//                             children: [
//                               const Text(
//                                 'Month',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Expanded(
//                                 child: ListWheelScrollView.useDelegate(
//                                   itemExtent: 50,
//                                   perspective: 0.005,
//                                   diameterRatio: 1.2,
//                                   physics: const FixedExtentScrollPhysics(),
//                                   onSelectedItemChanged: (index) {
//                                     setModalState(() {
//                                       selectedMonth = index + 1;
//                                     });
//                                   },
//                                   childDelegate: ListWheelChildBuilderDelegate(
//                                     childCount: months.length,
//                                     builder: (context, index) {
//                                       final isSelected =
//                                           (index + 1) == selectedMonth;
//                                       return Center(
//                                         child: Container(
//                                           width: 100,
//                                           decoration: BoxDecoration(
//                                             color: isSelected
//                                                 ? Colors.green.withOpacity(0.1)
//                                                 : Colors.transparent,
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                             border: isSelected
//                                                 ? Border.all(
//                                                     color: Colors.green,
//                                                     width: 2,
//                                                   )
//                                                 : null,
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               months[index],
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: isSelected
//                                                     ? FontWeight.bold
//                                                     : FontWeight.normal,
//                                                 color: isSelected
//                                                     ? Colors.green
//                                                     : Colors.black87,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Year Picker
//                         Expanded(
//                           child: Column(
//                             children: [
//                               const Text(
//                                 'Year',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Expanded(
//                                 child: ListWheelScrollView.useDelegate(
//                                   itemExtent: 50,
//                                   perspective: 0.005,
//                                   diameterRatio: 1.2,
//                                   physics: const FixedExtentScrollPhysics(),
//                                   onSelectedItemChanged: (index) {
//                                     setModalState(() {
//                                       selectedYear = years[index];
//                                     });
//                                   },
//                                   childDelegate: ListWheelChildBuilderDelegate(
//                                     childCount: years.length,
//                                     builder: (context, index) {
//                                       final isSelected =
//                                           years[index] == selectedYear;
//                                       return Center(
//                                         child: Container(
//                                           width: 70,
//                                           decoration: BoxDecoration(
//                                             color: isSelected
//                                                 ? Colors.green.withOpacity(0.1)
//                                                 : Colors.transparent,
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                             border: isSelected
//                                                 ? Border.all(
//                                                     color: Colors.green,
//                                                     width: 2,
//                                                   )
//                                                 : null,
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               '${years[index]}',
//                                               style: TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: isSelected
//                                                     ? FontWeight.bold
//                                                     : FontWeight.normal,
//                                                 color: isSelected
//                                                     ? Colors.green
//                                                     : Colors.black87,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Confirm Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _selectedDate = DateTime(
//                             selectedYear,
//                             selectedMonth,
//                             selectedDay,
//                           );
//                         });
//                         Navigator.pop(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       ),
//                       child: const Text(
//                         'Confirm',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     if (mounted) {
//       // ScaffoldMessenger.of(context).showSnackBar(
       // //         SnackBar(
       // //           content: Text(message),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     }
//   }

//   void _showSuccessSnackBar(String message) {
//     if (mounted) {
//       // ScaffoldMessenger.of(context).showSnackBar(
       // //         SnackBar(
       // //           content: Text(message),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _gymCodeController.dispose();
//     _weightController.dispose();
//     _heightController.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }
// }
