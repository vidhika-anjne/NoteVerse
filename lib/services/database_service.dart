// lib/services/database_service.dart
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _root = FirebaseDatabase.instance.ref();

  Future<void> saveNoteMetadata({
    required String degreeId,
    required String branchId,
    required String subjectId,
    required String noteId,
    required String title,
    required String downloadUrl,
    required String uploaderId,
    required String uploaderName,
    required String uploaderPhoto,
    required int fileSizeBytes,
    required String fileType,
    List<String>? tags,
  }) async {

    final path =
        'degrees/$degreeId/branches/$branchId/subjects/$subjectId/notes/$noteId';

    final noteRef = _root.child(path);

    await noteRef.set({
      'title': title,
      'fileUrl': downloadUrl,
      'uploadedBy': uploaderId,
      'uploaderName': uploaderName,
      'uploaderPhoto': uploaderPhoto,
      'fileSizeBytes': fileSizeBytes,
      'fileType': fileType,
      'tags': tags ?? [],
      'timestamp': ServerValue.timestamp,

      // ⭐ Rating fields (new)
      'rating': 0.0,
      'ratingCount': 0,
      'totalRating': 0,
    });
  }
}
