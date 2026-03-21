import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/voice_button.dart';
import '../../widgets/voice_text_field.dart';
import '../../services/accessibility_service.dart';
import '../../utils/theme.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _accessibility = AccessibilityService();
  String _selectedRole = 'VISUALLY_IMPAIRED';
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _accessibility.announceScreen(
        'Login Screen',
        'Enter your phone number to receive a verification code. '
        'Use the microphone button to speak your phone number.',
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Hero section
                  _buildHeroSection(),
                  const SizedBox(height: 40),
                  // Phone input
                  VoiceTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    voiceLabel: 'Enter your phone number',
                    hint: 'Example: +1 234 567 8900',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  // Role selection
                  _buildRoleSelector(),
                  const SizedBox(height: 32),
                  // Submit button
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) => VoiceButton(
                      label: 'GET VERIFICATION CODE',
                      voiceLabel: 'Get verification code button',
                      voiceHint:
                          'Double tap to receive a verification code on your phone',
                      icon: Icons.sms,
                      isLoading: auth.isLoading,
                      onPressed: () => _sendOtp(auth),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Semantics(
      header: true,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.accessibility_new,
                size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text('AssistBridge',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Help is just a tap away',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Semantics(
      label: 'Select your role',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('I am a:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildRoleCard(
                        'VISUALLY_IMPAIRED', '👤', 'User', 'I need help')),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildRoleCard(
                        'VOLUNTEER', '🤝', 'Volunteer', 'I want to help')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
      String role, String emoji, String label, String hint) {
    final isSelected = _selectedRole == role;
    return Semantics(
      label: '$label. $hint',
      selected: isSelected,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedRole = role);
          _accessibility.speak('Selected $label');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  )),
              const SizedBox(height: 4),
              Text(hint,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white70 : Colors.grey,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp(AuthProvider auth) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _accessibility.speak('Please enter your phone number');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    _accessibility.speak('Sending verification code');
    final success = await auth.sendOtp(phone);
    if (success && mounted) {
      _accessibility.speak('Code sent. Enter the 6 digit code.');
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(phone: phone, role: _selectedRole),
          ));
    } else if (mounted) {
      _accessibility.speak('Failed to send code. Please try again.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Failed to send OTP')),
      );
    }
  }
}
