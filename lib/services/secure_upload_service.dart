import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class SecureUploadService {
  static const String _functionsUrl = 'https://us-central1-noteverse-d7eb2.cloudfunctions.net';

  /// Securely upload files (PDF, DOCX, etc.) using Firebase Functions
  static Future<String?> uploadFile({
    required PlatformFile file,
    void Function(double progress)? onProgress,
  }) async {
    try {
      if (kIsWeb) {
        // Get current user token for authentication
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          debugPrint('User not authenticated');
          return null;
        }

        final idToken = await user.getIdToken();
        
        // For web, convert bytes to base64
        final base64Data = base64Encode(file.bytes!);
        
        final response = await http.post(
          Uri.parse('$_functionsUrl/uploadFile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'fileData': base64Data,
            'fileName': file.name,
            'fileType': file.extension ?? '',
          }),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['success'] == true) {
            return result['url'] as String?;
          } else {
            debugPrint('Upload failed: ${result['error']}');
            return null;
          }
        } else {
          debugPrint('HTTP Error: ${response.statusCode}');
          return null;
        }
      } else {
        // For mobile/desktop, we'd need a different approach
        debugPrint('Secure upload currently only supported on web');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  /// Securely upload profile images using Firebase Functions
  static Future<String?> uploadImage({
    required PlatformFile file,
    void Function(double progress)? onProgress,
  }) async {
    try {
      if (kIsWeb) {
        // Get current user token for authentication
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          debugPrint('User not authenticated');
          return null;
        }

        final idToken = await user.getIdToken();
        
        // For web, convert bytes to base64
        final base64Data = base64Encode(file.bytes!);
        
        final response = await http.post(
          Uri.parse('$_functionsUrl/uploadImage'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'imageData': base64Data,
            'fileName': file.name,
          }),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['success'] == true) {
            return result['url'] as String?;
          } else {
            debugPrint('Image upload failed: ${result['error']}');
            return null;
          }
        } else {
          debugPrint('HTTP Error: ${response.statusCode}');
          return null;
        }
      } else {
        // For mobile/desktop, we'd need a different approach
        debugPrint('Secure image upload currently only supported on web');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
