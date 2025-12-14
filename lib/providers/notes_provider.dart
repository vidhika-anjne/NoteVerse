
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

import '../services/database_service.dart';
import '../services/gemini_service.dart';

class NotesProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
  final GeminiService _geminiService;

  NotesProvider({
    DatabaseService? databaseService,
    GeminiService? geminiService,
  })  : _databaseService = databaseService ?? DatabaseService(),
        _geminiService = geminiService ?? GeminiService();

  Stream<DatabaseEvent> notesStream({
    required String degreeId,
    required String branchId,
    required String subjectId,
  }) {
    final ref = FirebaseDatabase.instance.ref(
      'degrees/$degreeId/branches/$branchId/subjects/$subjectId/notes',
    );
    return ref.onValue;
  }

  Future<String> generateSummary({
    required String url,
    required String title,
  }) async {
    final response = await http.get(Uri.parse(url));
    final rawText = response.body.toString();
    final summaryText = await _geminiService.summarizeText(rawText);
    return summaryText;
  }

  Future<void> toggleUpvote({
    required String degreeId,
    required String branchId,
    required String subjectId,
    required String noteId,
    required String userId,
  }) async {
    await _databaseService.toggleUpvote(
      degreeId: degreeId,
      branchId: branchId,
      subjectId: subjectId,
      noteId: noteId,
      userId: userId,
    );
  }

  Future<void> toggleDownvote({
    required String degreeId,
    required String branchId,
    required String subjectId,
    required String noteId,
    required String userId,
  }) async {
    await _databaseService.toggleDownvote(
      degreeId: degreeId,
      branchId: branchId,
      subjectId: subjectId,
      noteId: noteId,
      userId: userId,
    );
  }

  Future<Map<String, bool>> getVoteStatus({
    required String degreeId,
    required String branchId,
    required String subjectId,
    required String noteId,
    required String userId,
  }) async {
    final noteRef = FirebaseDatabase.instance.ref(
      'degrees/$degreeId/branches/$branchId/subjects/$subjectId/notes/$noteId',
    );

    final upSnap = await noteRef.child('upvotes/$userId').get();
    final downSnap = await noteRef.child('downvotes/$userId').get();

    return {
      'up': upSnap.exists,
      'down': downSnap.exists,
    };
  }

  Future<Map<String, dynamic>> fetchBranches({
    String degreeId = 'btech',
  }) async {
    final ref = FirebaseDatabase.instance.ref('degrees/$degreeId/branches');
    final snapshot = await ref.get();
    if (!snapshot.exists) return {};
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  Future<Map<String, dynamic>> fetchSubjects({
    String degreeId = 'btech',
    required String branchId,
  }) async {
    final ref = FirebaseDatabase.instance
        .ref('degrees/$degreeId/branches/$branchId/subjects');
    final snapshot = await ref.get();
    if (!snapshot.exists) return {};
    return Map<String, dynamic>.from(snapshot.value as Map);
  }
}

