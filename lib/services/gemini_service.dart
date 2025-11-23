import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<String> summarizeText(String text) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      print("❌ Gemini API key not found. Check your .env file.");
      return "API key missing";
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                  "Summarize this file for study notes to be understood and learnt easily.\n"
                      "Output only plain text without any Markdown formatting, headings, or special symbols:\n$text",
                }
              ]
            }
          ]
        }),
      );

      print("➡️ Status Code: ${response.statusCode}");
      print("➡️ Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final summary =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return summary ?? "No summary generated.";
      } else {
        return "Failed to summarize. Status: ${response.statusCode}";
      }
    } catch (e, stackTrace) {
      print("❌ Exception occurred: $e");
      print(stackTrace);
      return "Error occurred while summarizing text.";
    }
  }
}