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
  Future<void> toggleUpvote({
    required String degreeId,
    required String branchId,
    required String subjectId,
    required String noteId,
    required String userId,
  }) async {
    final noteRef = FirebaseDatabase.instance.ref(
      "degrees/$degreeId/branches/$branchId/subjects/$subjectId/notes/$noteId",
    );

    final upRef = noteRef.child("upvotes/$userId");
    final downRef = noteRef.child("downvotes/$userId");

    final upCountRef = noteRef.child("upvoteCount");
    final downCountRef = noteRef.child("downvoteCount");

    final upSnap = await upRef.get();
    final downSnap = await downRef.get();

    // Read upvote count
    final upCountSnap = await upCountRef.get();
    int upCount = 0;
    if (upCountSnap.exists) {
      if (upCountSnap.value is int) upCount = upCountSnap.value as int;
      else if (upCountSnap.value is String) {
        upCount = int.tryParse(upCountSnap.value as String) ?? 0;
      }
    }

    // Read downvote count
    final downCountSnap = await downCountRef.get();
    int downCount = 0;
    if (downCountSnap.exists) {
      if (downCountSnap.value is int) downCount = downCountSnap.value as int;
      else if (downCountSnap.value is String) {
        downCount = int.tryParse(downCountSnap.value as String) ?? 0;
      }
    }

    if (upSnap.exists) {
      // REMOVE UPVOTE
      upCount = (upCount - 1).clamp(0, 999999);
      await upRef.remove();
    } else {
      // ADD UPVOTE
      upCount += 1;
      await upRef.set(true);

      // If user had downvoted, remove downvote
      if (downSnap.exists) {
        downCount = (downCount - 1).clamp(0, 999999);
        await downRef.remove();
      }
    }

    await upCountRef.set(upCount);
    await downCountRef.set(downCount);
  }


  Future<void> toggleDownvote({
    required String degreeId,
    required String branchId,
    required String subjectId,
    required String noteId,
    required String userId,
  }) async {
    final noteRef = FirebaseDatabase.instance.ref(
      "degrees/$degreeId/branches/$branchId/subjects/$subjectId/notes/$noteId",
    );

    final upRef = noteRef.child("upvotes/$userId");
    final downRef = noteRef.child("downvotes/$userId");

    final upCountRef = noteRef.child("upvoteCount");
    final downCountRef = noteRef.child("downvoteCount");

    final upSnap = await upRef.get();
    final downSnap = await downRef.get();

    // Read upvote count
    final upCountSnap = await upCountRef.get();
    int upCount = 0;
    if (upCountSnap.exists) {
      if (upCountSnap.value is int) upCount = upCountSnap.value as int;
      else if (upCountSnap.value is String) {
        upCount = int.tryParse(upCountSnap.value as String) ?? 0;
      }
    }

    // Read downvote count
    final downCountSnap = await downCountRef.get();
    int downCount = 0;
    if (downCountSnap.exists) {
      if (downCountSnap.value is int) downCount = downCountSnap.value as int;
      else if (downCountSnap.value is String) {
        downCount = int.tryParse(downCountSnap.value as String) ?? 0;
      }
    }

    if (downSnap.exists) {
      // REMOVE DOWNVOTE
      downCount = (downCount - 1).clamp(0, 999999);
      await downRef.remove();
    } else {
      // ADD DOWNVOTE
      downCount += 1;
      await downRef.set(true);

      // If user had upvoted, remove upvote
      if (upSnap.exists) {
        upCount = (upCount - 1).clamp(0, 999999);
        await upRef.remove();
      }
    }

    await upCountRef.set(upCount);
    await downCountRef.set(downCount);
  }





}
