import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'onboarding_screen.dart';
import '../providers/login_provider.dart';
import '../providers/terms_provider.dart';
import '../widgets/terms_checkbox.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 0;

  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset login state synchronously before build
    // This ensures users always start at phone input screen, especially after logout
    if (!_hasInitialized && mounted) {
      final loginProvider = context.read<LoginProvider>();
      // Always reset to ensure clean state - LoginProvider is a singleton so state persists
      // This is especially important when navigating to login after logout
      loginProvider.resetLoginState();
      // Also clear the controllers
      _phoneController.clear();
      _otpController.clear();
      _timer?.cancel();
      _hasInitialized = true;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startOtpTimer(int ttl) {
    _secondsRemaining = ttl;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final horizontalPadding = screenWidth * 0.06;
    final topSpacing = screenHeight * 0.025;
    final backButtonSize = screenWidth * 0.12;
    final backButtonRadius = screenWidth * 0.04;
    final backButtonIconSize = screenWidth * 0.05;
    final headerSpacing = screenHeight * 0.05;
    final titleFontSize = screenWidth * 0.08;
    final subtitleFontSize = screenWidth * 0.04;
    final sectionSpacing = screenHeight * 0.05;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Consumer<LoginProvider>(
          builder: (context, loginProvider, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: topSpacing),

                    // Back Button
                    GestureDetector(
                      onTap: () {
                        if (loginProvider.currentState == LoginState.otpInput) {
                          // Go back to phone input
                          loginProvider.resetToPhoneInput();
                          _otpController.clear();
                          _timer?.cancel();
                        } else {
                          // Go back to onboarding
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const OnboardingScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(backButtonSize * 0.33),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(backButtonRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .shadow
                                  .withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: backButtonIconSize,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),

                    SizedBox(height: headerSpacing),

                    // Welcome Section
                    Text(
                      loginProvider.currentState == LoginState.phoneInput
                          ? l10n.welcomeBack
                          : l10n.verifyYourPhone,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    Text(
                      loginProvider.currentState == LoginState.phoneInput
                          ? l10n.enterPhoneToSignIn
                          : '${l10n.verificationCodeSent}\n${loginProvider.formattedPhoneNumber}',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: sectionSpacing),

                    // Error Message
                    if (loginProvider.errorMessage.isNotEmpty)
                      _buildErrorMessage(loginProvider.errorMessage),

                    // Phone Number Input or OTP Input
                    if (loginProvider.currentState == LoginState.phoneInput)
                      _buildPhoneInputSection(loginProvider)
                    else
                      _buildOtpInputSection(loginProvider),

                    // Terms and Conditions Checkbox (only for phone input)
                    if (loginProvider.currentState == LoginState.phoneInput)
                      Consumer<TermsProvider>(
                        builder: (context, termsProvider, child) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.01,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01,
                            ),
                            child: TermsCheckbox(
                              text: l10n.agreeToTerms,
                              context: 'login',
                              onAccepted: () {
                                // Optional: Show success feedback or trigger any additional logic
                                print(l10n.termsAccepted);
                              },
                              onDeclined: () {
                                // Optional: Show info about requirement
                                // Snackbar removed - no longer showing messages
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(
                                //     content: Text(l10n.termsAcceptanceRequired),
                                //     backgroundColor:
                                //         Theme.of(context).colorScheme.error,
                                //     duration: Duration(
                                //         milliseconds: 800), // Reduced duration
                                //     behavior: SnackBarBehavior.floating,
                                //     margin: EdgeInsets.only(
                                //       top: 60, // Position at top
                                //       left: 16,
                                //       right: 16,
                                //       bottom:
                                //           MediaQuery.of(context).size.height -
                                //               140, // Push to top
                                //     ),
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(8),
                                //     ),
                                //   ),
                                // );
                              },
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 30),

                    // Action Button
                    Consumer<TermsProvider>(
                      builder: (context, termsProvider, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                _getButtonAction(loginProvider, termsProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              disabledBackgroundColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                            ),
                            child:
                                loginProvider.currentState == LoginState.loading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      )
                                    : Text(
                                        _getButtonText(loginProvider, l10n),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                          ),
                        );
                      },
                    ),

                    // OTP Timer and Resend
                    if (loginProvider.currentState == LoginState.otpInput) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            if (_secondsRemaining > 0) ...[
                              Text(
                                '${l10n.resendCodeIn} ${loginProvider.getOtpTimeRemaining(_secondsRemaining)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground
                                      .withOpacity(0.6),
                                ),
                              ),
                            ] else ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.didntReceiveCode,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () async {
                                      final success =
                                          await loginProvider.sendOtp();
                                      if (success) {
                                        _startOtpTimer(loginProvider.otpTtl);
                                      }
                                    },
                                    child: Text(
                                      l10n.resend,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Sign Up Link (only show on phone input)
                    if (loginProvider.currentState == LoginState.phoneInput)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.dontHaveAccount,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/register',
                              );
                            },
                            child: Text(
                              l10n.signUp,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhoneInputSection(LoginProvider loginProvider) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.phoneNumber,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) => loginProvider.updatePhoneNumber(value),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            hintText: l10n.enterYourPhoneNumber,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              fontSize: 15,
              fontStyle: FontStyle.italic,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInputSection(LoginProvider loginProvider) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.enterOtp,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          onChanged: (value) => loginProvider.updateOtp(value),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            hintText: l10n.enterSixDigitOtp,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              fontSize: 15,
              fontStyle: FontStyle.italic,
            ),
            counterText: '',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.error),
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

  VoidCallback? _getButtonAction(LoginProvider loginProvider,
      [TermsProvider? termsProvider]) {
    if (loginProvider.currentState == LoginState.loading) {
      return null;
    }

    if (loginProvider.currentState == LoginState.phoneInput) {
      // Use provided termsProvider or get it from context
      final terms =
          termsProvider ?? Provider.of<TermsProvider>(context, listen: false);
      return loginProvider.isPhoneNumberValid && terms.isAccepted
          ? () async {
              final success = await loginProvider.sendOtp();
              if (success) {
                _startOtpTimer(loginProvider.otpTtl);
              }
            }
          : null;
    } else {
      return loginProvider.isOtpValid
          ? () async {
              final success = await loginProvider.verifyOtp();
              if (success && mounted) {
                // Check if user needs onboarding
                final userData = loginProvider.user;
                final hasRegistered = userData['hasRegistered'];
                
                // Navigate to onboarding if hasRegistered is false or doesn't exist
                if (hasRegistered == false || hasRegistered == null) {
                  Navigator.pushReplacementNamed(context, '/onboarding-flow');
                } else {
                  // Navigate to home screen
                  Navigator.pushReplacementNamed(context, '/home');
                }
              }
            }
          : null;
    }
  }

  String _getButtonText(LoginProvider loginProvider, AppLocalizations l10n) {
    if (loginProvider.currentState == LoginState.phoneInput) {
      return l10n.sendOtp;
    } else {
      return l10n.submit;
    }
  }

  Widget _buildErrorMessage(String errorMessage) {
    final l10n = AppLocalizations.of(context)!;
    final isCrmError = errorMessage.contains('not registered in CRM') ||
        errorMessage.contains('contact your club head');

    if (isCrmError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_search_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.phoneNotRegistered,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.read<LoginProvider>().clearError(),
                  child: Icon(
                    Icons.close,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.phoneNotInCrm,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.contact_support_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.contactClubHead,
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Default error message for other errors
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => context.read<LoginProvider>().clearError(),
              child: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.error,
                size: 18,
              ),
            ),
          ],
        ),
      );
    }
  }
}
