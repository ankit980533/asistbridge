import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/voice_button.dart';
import '../../services/accessibility_service.dart';
import '../user/accessible_home_screen.dart';
import '../volunteer/volunteer_home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String role;
  
  const OtpScreen({super.key, required this.phone, required this.role});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _accessibility = AccessibilityService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _accessibility.announceScreen(
        'Verification Screen',
        'Enter the 6 digit code sent to ${widget.phone}. '
        'Also enter your name so volunteers know who you are.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code'),
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
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Code sent to ${widget.phone}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Name input
              Semantics(
                label: 'Enter your name',
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 22),
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    labelStyle: const TextStyle(fontSize: 18),
                    hintText: 'So volunteers know who you are',
                    prefixIcon: const Icon(Icons.person, size: 28),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // OTP input - large digits
              Semantics(
                label: 'Enter 6 digit verification code',
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 36,
                    letterSpacing: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    labelStyle: const TextStyle(fontSize: 18),
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.all(24),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Consumer<AuthProvider>(
                builder: (context, auth, _) => VoiceButton(
                  label: 'VERIFY & LOGIN',
                  voiceLabel: 'Verify and login button',
                  voiceHint: 'Double tap to verify your code and login',
                  icon: Icons.check_circle,
                  isLoading: auth.isLoading,
                  onPressed: () => _verifyOtp(auth),
                ),
              ),
              
              const Spacer(),
              
              // Help text
              Semantics(
                child: const Text(
                  '💡 Didn\'t receive the code? Go back and try again.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtp(AuthProvider auth) async {
    final otp = _otpController.text.trim();
    final name = _nameController.text.trim();
    
    if (otp.length != 6) {
      _accessibility.speak('Please enter the 6 digit code');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6 digit OTP')),
      );
      return;
    }
    
    _accessibility.speak('Verifying code. Please wait.');
    
    final success = await auth.verifyOtp(
      widget.phone, otp, 
      name: name.isNotEmpty ? name : null,
      role: widget.role,
    );
    
    if (success && mounted) {
      // Enable/disable TTS based on role
      final isVolunteer = widget.role == 'VOLUNTEER';
      _accessibility.setRoleEnabled(!isVolunteer);
      
      if (!isVolunteer) {
        _accessibility.speak('Login successful. Welcome to AssistBridge.');
      }
      
      Widget destination = isVolunteer 
          ? const VolunteerHomeScreen() 
          : const AccessibleHomeScreen();
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } else if (mounted) {
      _accessibility.speak('Invalid code. Please try again.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Invalid OTP')),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
