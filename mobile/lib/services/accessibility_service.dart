import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  
  AccessibilityService._internal();
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      // TTS initialization failed, continue without it
      _isInitialized = true;
    }
  }
  
  Future<void> speak(String text) async {
    try {
      if (!_isInitialized) await initialize();
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      // Silently fail if TTS not available
    }
  }
  
  Future<void> speakWithDelay(String text, {int delayMs = 500}) async {
    await Future.delayed(Duration(milliseconds: delayMs));
    await speak(text);
  }
  
  Future<void> stop() async {
    await _tts.stop();
  }
  
  // Announce screen change
  Future<void> announceScreen(String screenName, String instructions) async {
    await speak('$screenName. $instructions');
  }
  
  // Announce action result
  Future<void> announceResult(bool success, String message) async {
    final prefix = success ? 'Success.' : 'Error.';
    await speak('$prefix $message');
  }
}

// Accessibility helper widget that speaks on focus
class SpeakOnFocus extends StatelessWidget {
  final Widget child;
  final String announcement;
  
  const SpeakOnFocus({
    super.key,
    required this.child,
    required this.announcement,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          AccessibilityService().speak(announcement);
        }
      },
      child: child,
    );
  }
}
