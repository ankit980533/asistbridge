import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../services/accessibility_service.dart';
import '../../utils/theme.dart';
import '../../widgets/voice_button.dart';
import 'accessible_raise_request_screen.dart';
import 'accessible_request_status_screen.dart';
import '../auth/login_screen.dart';

class AccessibleHomeScreen extends StatefulWidget {
  const AccessibleHomeScreen({super.key});

  @override
  State<AccessibleHomeScreen> createState() => _AccessibleHomeScreenState();
}

class _AccessibleHomeScreenState extends State<AccessibleHomeScreen>
    with SingleTickerProviderStateMixin {
  final _accessibility = AccessibilityService();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _accessibility.initialize();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _accessibility.announceScreen(
        'Home Screen',
        'Welcome ${auth.user?.name ?? ""}. You have 3 options. '
        'Swipe right to navigate between buttons. '
        'Double tap to select.',
      );
      Provider.of<RequestProvider>(context, listen: false).fetchUserRequests();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final requests = Provider.of<RequestProvider>(context);
    final activeCount = requests.activeRequests.length;

    return Scaffold(
      body: Column(
        children: [
          // Gradient header
          _buildHeader(auth, activeCount),
          // Action buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAnimatedCard(
                    index: 0,
                    child: _buildActionCard(
                      emoji: '🆘',
                      title: 'ASK FOR HELP',
                      subtitle: 'A volunteer will be assigned to assist you',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C853), Color(0xFF00E676)],
                      ),
                      icon: Icons.add_circle_outline,
                      onTap: _navigateToRaiseRequest,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedCard(
                    index: 1,
                    child: _buildActionCard(
                      emoji: '📋',
                      title: 'CHECK STATUS',
                      subtitle: 'View your help request updates',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2979FF), Color(0xFF448AFF)],
                      ),
                      icon: Icons.list_alt_rounded,
                      onTap: _navigateToStatus,
                    ),
                  ),
                  const Spacer(),
                  // Tip card
                  _buildAnimatedCard(
                    index: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Long press any button to hear what it does',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Logout
                  _buildAnimatedCard(
                    index: 3,
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () => _logout(auth),
                        icon: Icon(Icons.logout, color: Colors.grey.shade600),
                        label: Text('Logout',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth, int activeCount) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 28,
      ),
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14)),
                    Text(
                      auth.user?.name ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Voice Assistance toggle
          const SizedBox(height: 16),
          Semantics(
            label: _accessibility.isManualEnabled
                ? 'Voice assistance is on. Tap to turn off.'
                : 'Voice assistance is off. Tap to turn on.',
            toggled: _accessibility.isManualEnabled,
            child: GestureDetector(
              onTap: () => _toggleVoiceAssistance(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _accessibility.isManualEnabled
                          ? Icons.volume_up
                          : Icons.volume_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Voice Assistance',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Switch(
                      value: _accessibility.isManualEnabled,
                      onChanged: (_) => _toggleVoiceAssistance(),
                      activeColor: Colors.white,
                      activeTrackColor: Colors.white.withOpacity(0.4),
                      inactiveThumbColor: Colors.white.withOpacity(0.6),
                      inactiveTrackColor: Colors.white.withOpacity(0.15),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (activeCount > 0) ...[
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active,
                        color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$activeCount active request${activeCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    final delay = index * 0.15;
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(delay, delay + 0.5, curve: Curves.easeOut),
      ),
    );
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(delay, delay + 0.5, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }

  Widget _buildActionCard({
    required String emoji,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: gradient.colors.first.withOpacity(0.3),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          onLongPress: () {
            _accessibility.speak('$title. $subtitle');
            HapticFeedback.mediumImpact();
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: gradient),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          )),
                    ],
                  ),
                ),
                Icon(icon, color: Colors.white.withOpacity(0.7), size: 32),
              ],
            ),
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

  Future<void> _toggleVoiceAssistance() async {
    if (_accessibility.isManualEnabled) {
      // Turning OFF — no confirmation needed
      _accessibility.setManualEnabled(false);
      setState(() {});
    } else {
      // Turning ON — ask for confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Enable Voice Assistance?'),
          content: const Text(
              'The app will read out screen content and button labels aloud. '
              'This will turn off when you close the app.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor),
                child: const Text('Enable')),
          ],
        ),
      );

      if (confirmed == true) {
        _accessibility.setManualEnabled(true);
        setState(() {});
        _accessibility.speak('Voice assistance turned on');
      }
    }
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
