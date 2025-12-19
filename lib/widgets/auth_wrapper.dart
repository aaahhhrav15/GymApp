import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_app_2/services/token_manager.dart';

/// A wrapper widget that checks authentication status and redirects to login if not authenticated
/// Production-optimized: Checks on init, route changes, and app resume (not continuously)
class AuthWrapper extends StatefulWidget {
  final Widget child;
  final Widget? loadingWidget;
  final String? redirectRoute;

  const AuthWrapper({
    super.key,
    required this.child,
    this.loadingWidget,
    this.redirectRoute,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;
  Timer? _safetyCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthentication();
    // Safety check every 30 seconds (lightweight, catches expiration without being heavy)
    _safetyCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkAuthentication();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _safetyCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Check authentication when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _checkAuthentication();
    }
  }

  // Note: We don't check in didChangeDependencies as it's called too frequently
  // Instead, we rely on:
  // 1. Initial check in initState
  // 2. App lifecycle changes (resume from background)
  // 3. Safety timer (every 30 seconds)
  // 4. API calls will check via getAuthHeaders()

  Future<void> _checkAuthentication() async {
    try {
      final isLoggedIn = await TokenManager.isLoggedIn();
      
      if (!mounted) return;
      
      // If authentication status changed, update state
      if (_isAuthenticated != isLoggedIn || _isCheckingAuth) {
        setState(() {
          _isAuthenticated = isLoggedIn;
          _isCheckingAuth = false;
        });
      }
      
      if (!isLoggedIn) {
        _redirectToLogin();
      }
    } catch (e) {
      if (mounted) {
        print('Error checking authentication: $e');
        _redirectToLogin();
      }
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        widget.redirectRoute ?? '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return widget.loadingWidget ?? _buildDefaultLoadingWidget();
    }

    if (!_isAuthenticated) {
      return _buildDefaultLoadingWidget();
    }

    return widget.child;
  }

  Widget _buildDefaultLoadingWidget() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
