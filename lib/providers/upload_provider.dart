
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

import '../services/cloudinary_service.dart';
import '../services/database_service.dart';

class UploadProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  final CloudinaryService _cloudinary;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  double _progress = 0.0;
  double get progress => _progress;

  String? _error;
  String? get error => _error;

  UploadProvider({
    DatabaseService? dbService,
    CloudinaryService? cloudinary,
  })  : _dbService = dbService ?? DatabaseService(),
        _cloudinary = cloudinary ?? CloudinaryService();

  void _setUploading(bool value) {
    if (_isUploading == value) return;
    _isUploading = value;
    notifyListeners();
  }

  void _setProgress(double value) {
    _progress = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> _getProfile(String uid) async {
    final snap = await FirebaseDatabase.instance.ref('users/$uid').get();
    if (!snap.exists) return null;
    return Map<String, dynamic>.from(snap.value as Map);
  }

  Future<bool> uploadNote({
    required String userId,
    required String degreeId,
    required String branchId,
    required String subjectId,
    required String title,
    required PlatformFile file,
    List<String>? tags,
  }) async {
    _error = null;
    _setUploading(true);
    _setProgress(0.0);

    try {
      final profile = await _getProfile(userId);
      if (profile == null) {
        _error = 'Profile not found';
        return false;
      }

      final uploaderName = profile['name'] ?? 'Unknown User';
      final uploaderPhoto = profile['photoUrl'] ?? '';

      final noteId = const Uuid().v4();

      final fileUrl = await _cloudinary.uploadFile(
        file: file,
        onProgress: (p) => _setProgress(p),
      );

      if (fileUrl == null) {
        _error = 'Cloudinary upload failed';
        return false;
      }

      await _dbService.saveNoteMetadata(
        degreeId: degreeId,
        branchId: branchId,
        subjectId: subjectId,
        noteId: noteId,
        title: title.trim(),
        downloadUrl: fileUrl,
        uploaderId: userId,
        uploaderName: uploaderName,
        uploaderPhoto: uploaderPhoto,
        fileSizeBytes: file.size,
        fileType: file.extension ?? 'file',
        tags: tags ?? const [],
      );

      return true;
    } catch (e) {
      _error = 'Upload failed: $e';
      return false;
    } finally {
      _setUploading(false);
    }
  }
}

