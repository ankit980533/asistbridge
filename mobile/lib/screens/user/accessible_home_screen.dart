import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../services/accessibility_service.dart';
import '../../widgets/voice_button.dart';
import 'accessible_raise_request_screen.dart';
import 'accessible_request_status_screen.dart';
import '../auth/login_screen.dart';

/// Simplified home screen designed for visually impaired users
/// Features: Large buttons, voice feedback, minimal navigation
class AccessibleHomeScreen extends StatefulWidget {
  const AccessibleHomeScreen({super.key});

  @override
  State<AccessibleHomeScreen> createState() => _AccessibleHomeScreenState();
}

class _AccessibleHomeScreenState extends State<AccessibleHomeScreen> {
  final _accessibility = AccessibilityService();

  @override
  void initState() {
    super.initState();
    _accessibility.initialize();
    
    // Announce screen on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _accessibility.announceScreen(
        'Home Screen',
        'Welcome ${auth.user?.name ?? ""}. You have 3 options. '
        'Swipe right to navigate between buttons. '
        'Double tap to select.',
      );
      
      // Fetch requests
      Provider.of<RequestProvider>(context, listen: false).fetchUserRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final requests = Provider.of<RequestProvider>(context);
    
    final activeCount = requests.activeRequests.length;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: Text(
            'Hi, ${auth.user?.name ?? "User"}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        toolbarHeight: 70,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status announcement
              if (activeCount > 0)
                Semantics(
                  liveRegion: true,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: Text(
                      'You have $activeCount active request${activeCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // Main action button - RAISE REQUEST
              VoiceButton(
                label: '🆘 ASK FOR HELP',
                voiceLabel: 'Ask for help button',
                voiceHint: 'Double tap to create a new help request. A volunteer will be assigned to assist you.',
                icon: Icons.add_circle,
                height: 100,
                backgroundColor: Colors.green.shade600,
                onPressed: () => _navigateToRaiseRequest(),
              ),
              
              const SizedBox(height: 24),
              
              // Check status button
              VoiceButton(
                label: '📋 CHECK STATUS',
                voiceLabel: 'Check request status button',
                voiceHint: 'Double tap to check the status of your help requests.',
                icon: Icons.list_alt,
                height: 100,
                backgroundColor: Colors.blue.shade600,
                onPressed: () => _navigateToStatus(),
              ),
              
              const SizedBox(height: 24),
              
              // Logout button
              VoiceButton(
                label: '🚪 LOGOUT',
                voiceLabel: 'Logout button',
                voiceHint: 'Double tap to sign out of your account.',
                icon: Icons.logout,
                height: 80,
                backgroundColor: Colors.grey.shade600,
                onPressed: () => _logout(auth),
              ),
              
              const Spacer(),
              
              // Help text
              Semantics(
                label: 'Help instructions',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '💡 Tip: Long press any button to hear what it does',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRaiseRequest() {
    _accessibility.speak('Opening help request form');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccessibleRaiseRequestScreen()),
    );
  }

  void _navigateToStatus() {
    _accessibility.speak('Opening request status');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccessibleRequestStatusScreen()),
    );
  }

  Future<void> _logout(AuthProvider auth) async {
    _accessibility.speak('Logging out');
    await auth.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
