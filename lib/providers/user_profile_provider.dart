
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';

import '../services/cloudinary_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final CloudinaryService _cloudinary = CloudinaryService();

  Map<String, dynamic>? _currentProfile;
  Map<String, dynamic>? get currentProfile => _currentProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _currentProfile = null;
      _error = 'Not signed in';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final snap = await _usersRef.child(user.uid).get();
      if (snap.exists) {
        _currentProfile = Map<String, dynamic>.from(snap.value as Map);
        _error = null;
      } else {
        _currentProfile = null;
        _error = null;
      }
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final snap = await _usersRef.child(userId).get();
      if (!snap.exists) return null;
      return Map<String, dynamic>.from(snap.value as Map);
    } catch (_) {
      return null;
    }
  }

  Future<String?> saveProfile({
    required String userId,
    required String name,
    required String username,
    required String? role,
    required String? gender,
    required String linkedin,
    required String bio,
    PlatformFile? pickedFile,
  }) async {
    try {
      // Check if username is already taken
      final existing = await _usersRef
          .orderByChild('username')
          .equalTo(username)
          .get();
      bool takenByOther = false;
      if (existing.exists) {
        for (final child in existing.children) {
          if (child.key != userId) {
            takenByOther = true;
            break;
          }
        }
      }
      if (takenByOther) {
        return 'Username already taken! Choose another.';
      }

      // Upload profile image if provided
      String? photoUrl;
      if (pickedFile != null) {
        photoUrl = await _cloudinary.uploadImage(file: pickedFile);
      }

      final user = FirebaseAuth.instance.currentUser;

      final data = <String, dynamic>{
        'name': name,
        'username': username,
        'email': user?.email ?? '',
        'role': role,
        'gender': gender,
        'linkedin': linkedin,
        'bio': bio,
        'photoUrl': photoUrl ?? _currentProfile?['photoUrl'] ?? '',
        // Preserve existing savedNotes if present
        'savedNotes': _currentProfile?['savedNotes'] ?? [],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _usersRef.child(userId).set(data);

      _currentProfile = Map<String, dynamic>.from(data);
      _error = null;
      notifyListeners();

      return null; // success
    } catch (e) {
      _error = 'Failed to save profile: $e';
      notifyListeners();
      return _error;
    }
  }

  bool isNoteSaved(String noteId) {
    for (final item in savedNotes) {
      if (item is Map && item['noteId'] == noteId) {
        return true;
      }
      if (item is String && item == noteId) {
        return true;
      }
    }
    return false;
  }

  Future<void> toggleSavedNote({
    required String userId,
    required String noteId,
    required String degreeId,
    required String branchId,
    required String subjectId,
    required String title,
    String? fileUrl,
  }) async {
    final List<dynamic> updated = List<dynamic>.from(_currentProfile?['savedNotes'] ?? []);

    int existingIndex = -1;
    for (var i = 0; i < updated.length; i++) {
      final item = updated[i];
      if (item is Map && item['noteId'] == noteId) {
        existingIndex = i;
        break;
      }
      if (item is String && item == noteId) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex >= 0) {
      // Remove existing saved note
      updated.removeAt(existingIndex);
    } else {
      // Add new saved note entry
      updated.add({
        'noteId': noteId,
        'degreeId': degreeId,
        'branchId': branchId,
        'subjectId': subjectId,
        'title': title,
        'fileUrl': fileUrl,
        'savedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }

    await _usersRef.child(userId).update({'savedNotes': updated});

    _currentProfile = {
      ...?_currentProfile,
      'savedNotes': updated,
    };

    notifyListeners();
  }

  List<dynamic> get savedNotes {
    final value = _currentProfile?['savedNotes'];
    if (value is List) return value;
    return const [];
  }
}

