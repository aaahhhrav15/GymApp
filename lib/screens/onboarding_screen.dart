import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final horizontalPadding = screenWidth * 0.06;
    final borderRadius = screenWidth * 0.05;
    final iconSize = screenWidth * 0.2;
    final titleFontSize = screenWidth * 0.08;
    final subtitleFontSize = screenWidth * 0.04;
    final buttonHeight = screenHeight * 0.07;
    final sectionSpacing = screenHeight * 0.05;
    final smallSpacing = screenHeight * 0.025;
    final buttonFontSize = screenWidth * 0.045;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              // Main Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Image.asset(
                      'assets/images/fitness_women.jpg', // Add your image to assets folder
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.8),
                                Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  size: iconSize,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  l10n.addImageToAssets,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: subtitleFontSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: sectionSpacing),

              // Title Text
              Text(
                l10n.whereverYouAre,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),

              // Subtitle with styled text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: l10n.health,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: l10n.isNumberOne,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: smallSpacing),

              // Description
              Text(
                l10n.noInstantWay,
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: sectionSpacing),

              // Progress Indicator
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       width: screenWidth * 0.1,
              //       height: screenHeight * 0.005,
              //       decoration: BoxDecoration(
              //         color: Theme.of(context).colorScheme.primary,
              //         borderRadius: BorderRadius.circular(2),
              //       ),
              //     ),
              //     SizedBox(width: screenWidth * 0.02),
              //     Container(
              //       width: screenWidth * 0.05,
              //       height: screenHeight * 0.005,
              //       decoration: BoxDecoration(
              //         color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              //         borderRadius: BorderRadius.circular(2),
              //       ),
              //     ),
              //   ],
              // ),

              SizedBox(height: sectionSpacing),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to registration screen instead of home
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(buttonHeight * 0.5),
                    ),
                  ),
                  child: Text(
                    l10n.getStarted,
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: smallSpacing),

              // Already have an account section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      // Navigate to login screen
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      l10n.login,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: smallSpacing),
            ],
          ),
        ),
      ),
    );
  }
}
