import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/speech_service.dart';
import '../services/accessibility_service.dart';

/// Text field with voice input support for visually impaired users
class VoiceTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String voiceLabel;
  final String? hint;
  final int maxLines;
  final TextInputType keyboardType;
  final bool autofocus;
  
  const VoiceTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.voiceLabel,
    this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
  });

  @override
  State<VoiceTextField> createState() => _VoiceTextFieldState();
}

class _VoiceTextFieldState extends State<VoiceTextField> {
  final _speechService = SpeechService();
  final _accessibility = AccessibilityService();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speechService.initialize();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() => _isListening = false);
      _accessibility.speak('Stopped listening. ${widget.controller.text.isNotEmpty ? "You said: ${widget.controller.text}" : "No text captured."}');
    } else {
      setState(() => _isListening = true);
      HapticFeedback.mediumImpact();
      _accessibility.speak('Listening. Speak now.');
      
      await _speechService.startListening(
        onResult: (text) {
          setState(() => widget.controller.text = text);
        },
      );
      
      // Auto-stop after 15 seconds
      await Future.delayed(const Duration(seconds: 15));
      if (_isListening) {
        await _speechService.stopListening();
        setState(() => _isListening = false);
        if (widget.controller.text.isNotEmpty) {
          _accessibility.speak('You said: ${widget.controller.text}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.voiceLabel,
      hint: 'Double tap to type, or tap microphone button to speak',
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            autofocus: widget.autofocus,
            style: const TextStyle(fontSize: 20),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: const TextStyle(fontSize: 18),
              hintText: widget.hint ?? 'Tap microphone to speak',
              hintStyle: const TextStyle(fontSize: 16),
              contentPadding: const EdgeInsets.all(20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  width: 3,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Large microphone button
          Semantics(
            label: _isListening ? 'Stop listening' : 'Start voice input',
            button: true,
            child: GestureDetector(
              onTap: _toggleListening,
              child: Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  color: _isListening ? Colors.red : Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isListening ? 'STOP LISTENING' : 'TAP TO SPEAK',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isListening)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Semantics(
                liveRegion: true,
                child: const Text(
                  '🎤 Listening... Speak clearly',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
