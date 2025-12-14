import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  TtsService() {
    _initTts();
  }

  void _initTts() async {
    // Common settings
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.9);

    // Language fallback
    await _tts.setLanguage("en-US");

    // Web-specific config
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> pause() async {
    await _tts.pause();
  }

  // Future<void> resume() async {
  //   await _tts.resume();
  // }

  void dispose() {
    _tts.stop();
  }
}
