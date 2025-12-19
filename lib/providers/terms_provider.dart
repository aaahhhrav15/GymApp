// lib/providers/terms_provider.dart
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';

class TermsProvider extends ChangeNotifier {
  bool _isAccepted = false;
  bool _isDialogOpen = false;
  bool _hasScrolledToEnd = false;
  bool _isLoading = false;

  // Getters
  bool get isAccepted => _isAccepted;
  bool get isDialogOpen => _isDialogOpen;
  bool get hasScrolledToEnd => _hasScrolledToEnd;
  bool get isLoading => _isLoading;
  bool get canAccept => _hasScrolledToEnd && !_isLoading;

  // Terms and conditions for login screen (now using localization)
  String getLoginTermsAndConditions(AppLocalizations l10n) => '''
${l10n.termsServiceTitle}

${l10n.termsIntro}

${l10n.zeroTolerancePolicy}
${l10n.zeroToleranceDesc}

${l10n.prohibitedContent}
${l10n.prohibitedContentDesc}
${l10n.prohibitedNudity}
${l10n.prohibitedViolence}
${l10n.prohibitedHateSpeech}
${l10n.prohibitedSpam}
${l10n.prohibitedCopyright}
${l10n.prohibitedPersonalInfo}
${l10n.prohibitedIllegal}
${l10n.prohibitedMinors}

${l10n.contentModeration}
${l10n.contentModerationDesc}

${l10n.reportingSystem}
${l10n.reportingSystemDesc}

${l10n.userSafety}
${l10n.userSafetyDesc}

${l10n.consequencesViolations}
${l10n.consequencesViolationsDesc}

${l10n.yourResponsibilities}
${l10n.yourResponsibilitiesDesc}

${l10n.ourCommitment}
${l10n.ourCommitmentDesc}

${l10n.privacy}
${l10n.privacyDesc}

${l10n.termination}
${l10n.terminationDesc}

${l10n.termsAcknowledgment}

${l10n.lastUpdated}

${l10n.termsContact}
''';

  // Get terms content based on context (now requires l10n)
  String getTermsForContext(String context, AppLocalizations l10n) {
    return getLoginTermsAndConditions(
        l10n); // Always return login terms with localization
  }

  TermsProvider() {
    // Start with unchecked state initially for each session
    _isAccepted = false;
    _isLoading = false;
  }

  // Open terms dialog
  void openDialog() {
    _isDialogOpen = true;
    _hasScrolledToEnd = false; // Reset scroll status when opening
    notifyListeners();
  }

  // Close terms dialog
  void closeDialog() {
    _isDialogOpen = false;
    _hasScrolledToEnd = false; // Reset scroll status when closing
    notifyListeners();
  }

  // Mark that user has scrolled to the end
  void markScrolledToEnd() {
    if (!_hasScrolledToEnd) {
      _hasScrolledToEnd = true;
      notifyListeners();
    }
  }

  // Accept terms and conditions
  Future<void> acceptTerms() async {
    if (!_hasScrolledToEnd) {
      print('Cannot accept terms: User has not scrolled to end');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      _isAccepted = true;
      closeDialog();

      print('Terms and conditions accepted successfully');
    } catch (e) {
      print('Error accepting terms: $e');
      _isAccepted = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Decline terms and conditions
  void declineTerms() {
    _isAccepted = false;
    _hasScrolledToEnd = false;
    closeDialog();
    notifyListeners();
    print('Terms and conditions declined');
  }

  // Reset acceptance status (for testing or logout)
  Future<void> resetAcceptance() async {
    try {
      _isAccepted = false;
      _hasScrolledToEnd = false;
      notifyListeners();
      print('Terms acceptance status reset');
    } catch (e) {
      print('Error resetting terms acceptance: $e');
    }
  }

  // Check if terms need to be shown (for login/reel upload)
  bool shouldShowTermsCheckbox() {
    return !_isAccepted;
  }

  // Toggle checkbox state (only for UI feedback, doesn't save acceptance)
  void toggleCheckbox(bool value) {
    if (value && !_isAccepted) {
      // If user tries to check but hasn't accepted terms, show dialog
      openDialog();
    }
    // Don't change _isAccepted here, only through acceptTerms()
  }
}
