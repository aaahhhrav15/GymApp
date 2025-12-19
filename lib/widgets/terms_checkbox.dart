// lib/widgets/terms_checkbox.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/terms_provider.dart';
import 'terms_dialog.dart';

class TermsCheckbox extends StatelessWidget {
  final String text;
  final String context; // 'login'
  final VoidCallback? onAccepted;
  final VoidCallback? onDeclined;
  final bool isRequired;

  const TermsCheckbox({
    super.key,
    this.text = 'I agree to the Terms and Conditions',
    this.context = 'login', // Default to login context
    this.onAccepted,
    this.onDeclined,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    return Consumer<TermsProvider>(
      builder: (context, termsProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: mediaQuery.size.width * 0.01,
            vertical: mediaQuery.size.height * 0.005,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: termsProvider.isAccepted,
                  onChanged: termsProvider.isLoading
                      ? null
                      : (bool? value) =>
                          _handleCheckboxTap(context, value ?? false),
                  activeColor: theme.colorScheme.primary,
                  checkColor: theme.colorScheme.onPrimary,
                  side: BorderSide(
                    color: theme.colorScheme.outline,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              SizedBox(width: mediaQuery.size.width * 0.025),

              // Terms text with link
              Expanded(
                child: GestureDetector(
                  onTap: () => _showTermsDialog(context),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: mediaQuery.size.width < 360 ? 13 : 14,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(text: text.split('Terms and Conditions')[0]),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: mediaQuery.size.width < 360 ? 13 : 14,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.colorScheme.primary,
                          ),
                        ),
                        if (text.contains('Terms and Conditions') &&
                            text.split('Terms and Conditions').length > 1)
                          TextSpan(text: text.split('Terms and Conditions')[1]),
                      ],
                    ),
                  ),
                ),
              ),

              // Required indicator
              if (isRequired && !termsProvider.isAccepted)
                Container(
                  margin: EdgeInsets.only(left: mediaQuery.size.width * 0.01),
                  child: Text(
                    '*',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleCheckboxTap(BuildContext context, bool value) {
    final termsProvider = context.read<TermsProvider>();

    if (value && !termsProvider.isAccepted) {
      // If trying to check but not accepted, show terms dialog
      _showTermsDialog(context);
    } else if (!value && termsProvider.isAccepted) {
      // If unchecking accepted terms, reset acceptance
      termsProvider.resetAcceptance();
      onDeclined?.call();
    }
  }

  void _showTermsDialog(BuildContext context) {
    String dialogTitle = 'Terms and Conditions';

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => TermsDialog(
        title: dialogTitle,
        context: this.context,
        onAccepted: () {
          onAccepted?.call();
          // Show success feedback
          _showAcceptanceFeedback(context);
        },
        onDeclined: onDeclined,
      ),
    );
  }

  void _showAcceptanceFeedback(BuildContext context) {
    // Snackbars removed - no longer showing acceptance feedback
  }
}
