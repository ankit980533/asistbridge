import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/voice_button.dart';
import '../../services/accessibility_service.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
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
  final _api = ApiService();
  String _selectedRole = 'VISUALLY_IMPAIRED';
  String _countryCode = '+91';
  String? _autoFilledName;
  String? _existingRole; // role from backend lookup
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'USA'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'UK'},
    {'code': '+61', 'flag': '🇦🇺', 'name': 'Australia'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
    {'code': '+966', 'flag': '🇸🇦', 'name': 'Saudi Arabia'},
    {'code': '+65', 'flag': '🇸🇬', 'name': 'Singapore'},
    {'code': '+81', 'flag': '🇯🇵', 'name': 'Japan'},
  ];

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
    _phoneController.addListener(_onPhoneChanged);

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
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  DateTime? _lastLookup;
  Future<void> _onPhoneChanged() async {
    final raw = _phoneController.text.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (raw.length < 10) {
      if (_autoFilledName != null || _existingRole != null) {
        setState(() {
          _autoFilledName = null;
          _existingRole = null;
        });
      }
      return;
    }
    // If user already typed country code, don't prepend again
    final fullPhone = raw.startsWith('+') ? raw : '$_countryCode$raw';
    final now = DateTime.now();
    _lastLookup = now;
    await Future.delayed(const Duration(milliseconds: 500));
    if (_lastLookup != now || !mounted) return;

    try {
      final response = await _api.post(
        ApiConstants.lookupPhone,
        data: {'phone': fullPhone},
        retry: false,
      );
      final data = response.data['data'] as Map<String, dynamic>?;
      if (mounted && data != null && data.isNotEmpty && data['name'] != null) {
        setState(() {
          _autoFilledName = data['name'] as String;
          _existingRole = data['role'] as String?;
        });
      } else if (mounted) {
        setState(() {
          _autoFilledName = null;
          _existingRole = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _autoFilledName = null;
          _existingRole = null;
        });
      }
    }
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
                  _buildHeroSection(),
                  const SizedBox(height: 40),
                  _buildPhoneInput(),
                  if (_autoFilledName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.green.shade600),
                          const SizedBox(width: 6),
                          Text(
                            'Welcome back, $_autoFilledName',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildRoleSelector(),
                  const SizedBox(height: 32),
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

  Widget _buildPhoneInput() {
    final currentCountry = _countryCodes.firstWhere(
      (c) => c['code'] == _countryCode,
    );
    return Semantics(
      label: 'Phone number with country code',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Country code dropdown
          GestureDetector(
            onTap: _showCountryCodePicker,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currentCountry['flag']!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 4),
                  Text(_countryCode,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Phone number field
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '9876543210',
                prefixIcon: const Icon(Icons.phone, size: 24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: _countryCodes.length,
        itemBuilder: (ctx, i) {
          final c = _countryCodes[i];
          final isSelected = c['code'] == _countryCode;
          return ListTile(
            leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
            title: Text('${c['name']} (${c['code']})'),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                : null,
            onTap: () {
              setState(() => _countryCode = c['code']!);
              Navigator.pop(ctx);
              // Re-trigger lookup with new country code
              _onPhoneChanged();
            },
          );
        },
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
        onTap: () => _onRoleTapped(role, label),
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

  /// When user taps a role, just select it. Confirmation happens at send OTP time.
  Future<void> _onRoleTapped(String role, String label) async {
    if (_selectedRole == role) return;
    setState(() => _selectedRole = role);
    _accessibility.speak('Selected $label');
  }

  Future<void> _sendOtp(AuthProvider auth) async {
    final raw = _phoneController.text.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (raw.isEmpty) {
      _accessibility.speak('Please enter your phone number');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    final phone = raw.startsWith('+') ? raw : '$_countryCode$raw';
    
    // Check if this is a role switch for an existing user
    final isRoleSwitch = _existingRole != null && _existingRole != _selectedRole;

    // If existing user is logging in with a different role, confirm first
    if (isRoleSwitch) {
      final currentLabel = _existingRole == 'VOLUNTEER' ? 'Volunteer' : 'User';
      final newLabel = _selectedRole == 'VOLUNTEER' ? 'Volunteer' : 'User';
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Switch Role?'),
          content: Text(
            'You are currently registered as a $currentLabel. '
            'Logging in as $newLabel will switch your role.\n\n'
            'Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
              child: Text('Yes, switch to $newLabel'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    _accessibility.speak('Sending verification code');
    final success = await auth.sendOtp(phone);
    if (success && mounted) {
      _accessibility.speak('Code sent. Enter the 6 digit code.');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            phone: phone,
            role: _selectedRole,
            autoFilledName: _autoFilledName,
            switchRole: isRoleSwitch,
          ),
        ),
      );
    } else if (mounted) {
      _accessibility.speak('Failed to send code. Please try again.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Failed to send OTP')),
      );
    }
  }
}
