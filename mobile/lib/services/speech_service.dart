import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  
  SpeechService._internal();
  
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize();
    return _isInitialized;
  }
  
  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized;
  
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }
  
  Future<void> stopListening() async {
    await _speech.stop();
  }
  
  Future<void> cancel() async {
    await _speech.cancel();
  }
}
