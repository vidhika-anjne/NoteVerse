import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/gemini_webconfig.dart';

class GeminiService {
  Future<String> summarizeText(String text) async {
    try {
      final apiKey = geminiApiKey();
      if (apiKey == null || apiKey.isEmpty || apiKey == 'your_gemini_api_key_here') {
        debugPrint('Gemini API key not configured');
        return 'API key not configured';
      }

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Read and summarize the contents of the file for study notes to be understood and learnt easily.\n'
                      'Output only plain text without any Markdown formatting, headings, or special symbols:\n$text',
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final summary =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return summary ?? 'No summary generated';
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
        return 'Failed to summarize. Status: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error summarizing text: $e');
      return 'Error occurred while summarizing text.';
    }
  }
}
