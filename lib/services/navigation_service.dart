import 'package:flutter/material.dart';

/// Navigation service for global navigation without context
/// This allows navigation from anywhere in the app, including services
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a named route
  static void navigateTo(String routeName, {bool removeUntil = false}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      if (removeUntil) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          routeName,
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamed(routeName);
      }
    }
  }

  /// Navigate to login page and clear navigation stack
  static void navigateToLogin() {
    navigateTo('/login', removeUntil: true);
  }
}
