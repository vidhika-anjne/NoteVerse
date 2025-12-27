import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SecureGeminiService {
  static const String _functionsUrl = 'https://us-central1-noteverse-d7eb2.cloudfunctions.net';

  /// Securely summarize text using Firebase Functions
  static Future<String> summarizeText(String text) async {
    try {
      // Get current user token for authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return "Authentication required";
      }

      final idToken = await user.getIdToken();
      
      final response = await http.post(
        Uri.parse('$_functionsUrl/summarizeText'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          return result['summary'] as String? ?? "No summary generated";
        } else {
          debugPrint('Summarization failed: ${result['error']}');
          return "Failed to summarize: ${result['error']}";
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
        return "Failed to summarize. Status: ${response.statusCode}";
      }
    } catch (e) {
      debugPrint('Error summarizing text: $e');
      return "Error occurred while summarizing text.";
    }
  }
}
