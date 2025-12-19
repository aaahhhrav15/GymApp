import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_app_2/services/token_manager.dart';
import 'package:gym_app_2/providers/login_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await TokenManager.isLoggedIn();
    if (!mounted) return;
    
    // Initialize LoginProvider if user is logged in
    if (loggedIn) {
      final loginProvider = context.read<LoginProvider>();
      await loginProvider.initialize();
    }
    
    setState(() {
      _isLoggedIn = loggedIn;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Route deterministically based on token presence
    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}


