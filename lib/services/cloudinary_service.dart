
// lib/services/cloudinary_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  final String? cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
  final String? uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

  /// Uploads any file (PDF, DOCX, etc.)
  Future<String?> uploadFile({
    required PlatformFile file,
    required void Function(double progress)? onProgress,
  }) async {
    if (cloudName == null || uploadPreset == null) {
      debugPrint("❌ Cloudinary credentials missing from .env");
      return null;
    }

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset!
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );

    final streamedResponse = await request.send();

    final totalBytes = file.size.toDouble();
    int bytesReceived = 0;
    final responseBytes = <int>[];

    await for (var chunk in streamedResponse.stream) {
      responseBytes.addAll(chunk);
      bytesReceived += chunk.length;
      if (onProgress != null) {
        onProgress(min(1.0, bytesReceived / totalBytes));
      }
    }

    final responseBody = utf8.decode(responseBytes);

    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['secure_url'];
    } else {
      debugPrint('❌ Upload failed: $responseBody');
      return null;
    }
  }

  /// ✅ Uploads profile images (JPEG/PNG) to Cloudinary
  Future<String?> uploadImage({
    required PlatformFile file,
    void Function(double progress)? onProgress,
  }) async {
    if (cloudName == null || uploadPreset == null) {
      debugPrint("❌ Cloudinary credentials missing from .env");
      return null;
    }

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset!
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );

    final streamedResponse = await request.send();

    final totalBytes = file.size.toDouble();
    int bytesReceived = 0;
    final responseBytes = <int>[];

    await for (var chunk in streamedResponse.stream) {
      responseBytes.addAll(chunk);
      bytesReceived += chunk.length;
      if (onProgress != null) {
        onProgress(min(1.0, bytesReceived / totalBytes));
      }
    }

    final responseBody = utf8.decode(responseBytes);

    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(responseBody);
      debugPrint('✅ Image uploaded: ${data['secure_url']}');
      return data['secure_url'];
    } else {
      debugPrint('❌ Image upload failed: $responseBody');
      return null;
    }
  }
}
