import 'dart:js' as js;

/// Gets Gemini API key from web environment (browser)
String? geminiApiKey() {
  try {
    return js.context['GEMINI_API_KEY'] as String?;
  } catch (e) {
    return null;
  }
}
