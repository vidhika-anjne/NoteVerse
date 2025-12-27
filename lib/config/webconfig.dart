// lib/config/web_config.dart
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

String cloudinaryCloudName() {
  if (kIsWeb) {
    try {
      return js.context['CLOUDINARY_CLOUD_NAME'] ?? '';
    } catch (e) {
      debugPrint('Error getting cloudinary cloud name: $e');
      return '';
    }
  }
  return '';
}

String cloudinaryUploadPreset() {
  if (kIsWeb) {
    try {
      return js.context['CLOUDINARY_UPLOAD_PRESET'] ?? '';
    } catch (e) {
      debugPrint('Error getting cloudinary upload preset: $e');
      return '';
    }
  }
  return '';
}
