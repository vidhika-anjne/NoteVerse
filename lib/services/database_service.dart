// lib/services/database_service.dart
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _root = FirebaseDatabase.instance.ref();

  Future<void> saveNoteMetadata({
    // required String universityId,
    required String degreeId,
    required String branchId,
    required String subjectId,
    required String noteId,
    required String title,
    required String downloadUrl,
    required String uploaderId,
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
      'fileSizeBytes': fileSizeBytes,
      'fileType': fileType,
      'tags': tags ?? [],
      'timestamp': ServerValue.timestamp,
    });
  }
}
