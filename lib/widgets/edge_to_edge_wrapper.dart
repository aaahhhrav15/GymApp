import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper widget that handles edge-to-edge display for Android 15+
/// This widget ensures proper handling of system UI insets
class EdgeToEdgeWrapper extends StatelessWidget {
  final Widget child;
  
  const EdgeToEdgeWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false, // Allow content to extend to bottom
        child: child,
      ),
    );
  }
}

/// A widget that handles system UI overlay style changes
class SystemUIHandler extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;
  
  const SystemUIHandler({
    super.key,
    required this.child,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: child,
    );
  }
}
