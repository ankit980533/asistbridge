import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../services/accessibility_service.dart';

/// Large, accessible button with voice feedback for visually impaired users
class VoiceButton extends StatelessWidget {
  final String label;
  final String voiceLabel;
  final String? voiceHint;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final double height;
  
  const VoiceButton({
    super.key,
    required this.label,
    required this.voiceLabel,
    this.voiceHint,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final accessibility = AccessibilityService();
    
    return Semantics(
      label: voiceLabel,
      hint: voiceHint,
      button: true,
      enabled: !isLoading,
      child: GestureDetector(
        onLongPress: () {
          // Long press reads the button description
          accessibility.speak(voiceHint ?? voiceLabel);
          HapticFeedback.mediumImpact();
        },
        child: ElevatedButton(
          onPressed: isLoading ? null : () async {
            // Vibrate on tap
            if (await Vibration.hasVibrator() ?? false) {
              Vibration.vibrate(duration: 50);
            }
            HapticFeedback.lightImpact();
            onPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
            foregroundColor: textColor ?? Colors.white,
            minimumSize: Size(double.infinity, height),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 32),
                      const SizedBox(width: 16),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
