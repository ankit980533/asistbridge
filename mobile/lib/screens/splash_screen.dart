import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/accessibility_service.dart';
import 'auth/login_screen.dart';
import 'user/accessible_home_screen.dart';
import 'volunteer/volunteer_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _accessibility = AccessibilityService();
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize TTS in background (don't block)
    _accessibility.initialize();
    
    // Brief splash delay
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    
    // Check auth with timeout protection
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isAuthenticated = false;
    
    try {
      isAuthenticated = await authProvider.checkAuth()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
    } catch (e) {
      debugPrint('Auth check failed: $e');
    }
    
    if (!mounted) return;
    _navigateToDestination(isAuthenticated, authProvider);
  }

  void _navigateToDestination(bool isAuthenticated, AuthProvider authProvider) {
    Widget destination;
    
    if (!isAuthenticated) {
      _accessibility.speak('Welcome to AssistBridge. Please login to continue.');
      destination = const LoginScreen();
    } else if (authProvider.user!.isVolunteer) {
      _accessibility.speak('Welcome back ${authProvider.user!.name}');
      destination = const VolunteerHomeScreen();
    } else {
      _accessibility.speak('Welcome back ${authProvider.user!.name}');
      destination = const AccessibleHomeScreen();
    }
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Semantics(
          label: 'AssistBridge loading',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.accessibility_new, size: 100, 
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text('AssistBridge', 
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('Help Platform for Visually Impaired',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 48),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
