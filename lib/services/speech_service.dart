import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Wraps the speech_to_text plugin for ingredient voice input.
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) => print('Speech error: ${error.errorMsg}'),
    );
    return _isInitialized;
  }

  bool get isAvailable => _isInitialized;
  bool get isListening => _speech.isListening;

  /// Start listening. Calls [onResult] with recognized words.
  Future<void> startListening({
    required Function(String recognizedWords) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) throw Exception('Speech recognition not available');
    }

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      localeId: localeId,
      listenMode: stt.ListenMode.dictation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  void dispose() {
    _speech.cancel();
  }
}
