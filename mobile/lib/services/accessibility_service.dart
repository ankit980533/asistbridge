import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS behavior:
///   - System TalkBack ON → TTS always ON (follows system)
///   - System TalkBack OFF → manual toggle, default OFF every app launch
///   - User manually enables → stays ON until app is closed
///   - App restart → manual toggle resets to OFF
class AccessibilityService {
  static final AccessibilityService _instance =
      AccessibilityService._internal();
  factory AccessibilityService() => _instance;

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _roleEnabled = true;
  bool _manualEnabled = false; // resets every app launch, never persisted
  bool _screenReaderActive = false;

  AccessibilityService._internal();

  /// TTS speaks only when role allows AND (system TalkBack is on OR user manually enabled).
  bool get isActive => _roleEnabled && (_screenReaderActive || _manualEnabled);

  /// Whether user has manually toggled voice on this session.
  bool get isManualEnabled => _manualEnabled;

  /// Whether system screen reader is active.
  bool get isScreenReaderActive => _screenReaderActive;

  /// Set by role — false for volunteers.
  void setRoleEnabled(bool enabled) {
    _roleEnabled = enabled;
    if (!enabled) _tts.stop();
  }

  /// Manual toggle — not persisted, resets on app restart.
  void setManualEnabled(bool enabled) {
    _manualEnabled = enabled;
    if (!enabled) _tts.stop();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      _isInitialized = true;
    }
  }

  void updateScreenReaderStatus(BuildContext context) {
    _screenReaderActive = MediaQuery.of(context).accessibleNavigation;
  }

  Future<void> speak(String text) async {
    if (!isActive) return;
    try {
      if (_screenReaderActive) {
        SemanticsService.announce(text, TextDirection.ltr);
      } else {
        if (!_isInitialized) await initialize();
        await _tts.stop();
        await _tts.speak(text);
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> speakWithDelay(String text, {int delayMs = 500}) async {
    await Future.delayed(Duration(milliseconds: delayMs));
    await speak(text);
  }

  Future<void> stop() async { await _tts.stop(); }

  Future<void> announceScreen(String screenName, String instructions) async {
    await speak('$screenName. $instructions');
  }

  Future<void> announceResult(bool success, String message) async {
    final prefix = success ? 'Success.' : 'Error.';
    await speak('$prefix $message');
  }
}

class SpeakOnFocus extends StatelessWidget {
  final Widget child;
  final String announcement;
  const SpeakOnFocus({super.key, required this.child, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) AccessibilityService().speak(announcement);
      },
      child: child,
    );
  }
}
