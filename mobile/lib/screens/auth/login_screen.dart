import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/voice_button.dart';
import '../../widgets/voice_text_field.dart';
import '../../services/accessibility_service.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _accessibility = AccessibilityService();
  String _selectedRole = 'VISUALLY_IMPAIRED';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _accessibility.announceScreen(
        'Login Screen',
        'Enter your phone number to receive a verification code. '
        'Use the microphone button to speak your phone number.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Semantics(
                header: true,
                child: Column(
                  children: [
                    Icon(Icons.accessibility_new, size: 80, 
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('AssistBridge',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text('Help is just a tap away',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // Phone input with voice support
              VoiceTextField(
                controller: _phoneController,
                label: 'Phone Number',
                voiceLabel: 'Enter your phone number',
                hint: 'Example: +1 234 567 8900',
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 24),
              
              // Role selection
              Semantics(
                label: 'Select your role',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('I am a:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRoleButton('VISUALLY_IMPAIRED', '👤 User', 'I need help'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildRoleButton('VOLUNTEER', '🤝 Volunteer', 'I want to help'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Consumer<AuthProvider>(
                builder: (context, auth, _) => VoiceButton(
                  label: 'GET VERIFICATION CODE',
                  voiceLabel: 'Get verification code button',
                  voiceHint: 'Double tap to receive a verification code on your phone',
                  icon: Icons.sms,
                  isLoading: auth.isLoading,
                  onPressed: () => _sendOtp(auth),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleButton(String role, String label, String hint) {
    final isSelected = _selectedRole == role;
    return Semantics(
      label: '$label. $hint',
      selected: isSelected,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedRole = role);
          _accessibility.speak('Selected $label');
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(label, style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              )),
              Text(hint, style: TextStyle(
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
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => OtpScreen(phone: phone, role: _selectedRole),
      ));
    } else if (mounted) {
      _accessibility.speak('Failed to send code. Please try again.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Failed to send OTP')),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
