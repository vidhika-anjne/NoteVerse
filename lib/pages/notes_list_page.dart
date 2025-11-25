// lib/pages/notes_list_page.dart
import 'dart:html' as html; // web download
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../services/database_service.dart';
import 'upload_notes_page.dart';
import '../services/gemini_service.dart';
import 'user_public_profile_page.dart';

class NotesListPage extends StatefulWidget {
  final String degreeId;
  final String branchId;
  final String subjectId;

  const NotesListPage({
    super.key,
    required this.degreeId,
    required this.branchId,
    required this.subjectId,
  });

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  late final DatabaseReference _notesRef;
  final GeminiService _geminiService = GeminiService();

  bool _loading = false;
  String _loadingText = '';
  String? _summary;
  String? _summaryTitle;

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _notesRef = FirebaseDatabase.instance.ref(
      'degrees/${widget.degreeId}/branches/${widget.branchId}/subjects/${widget.subjectId}/notes',
    );
  }

  void _downloadFileWeb(String url, String fileName) {
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> _generateSummary(String url, String title) async {
    try {
      setState(() {
        _loading = true;
        _loadingText = 'Generating AI summary for "$title"...';
        _summary = null;
        _summaryTitle = title;
      });

      final response = await http.get(Uri.parse(url));
      final rawText = response.body.toString();

      final summary = await _geminiService.summarizeText(rawText);

      setState(() {
        _loading = false;
        _summary = summary;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _summary = 'Failed to generate summary: $e';
      });
    }
  }

  void _closeSummary() {
    setState(() {
      _summary = null;
      _summaryTitle = null;
    });
  }

  // Toggle like (upvote) for a note (per-user). This will:
  // 1) check if current user has already liked (votes/$noteId/$uid)
  // 2) set/remove that node and update note.voteCount atomically (using transaction)
  Future<void> _toggleVote(String noteId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to vote')),
      );
      return;
    }

    final voteNode = FirebaseDatabase.instance.ref('votes/$noteId/${user.uid}');
    final noteVoteCountRef = FirebaseDatabase.instance
        .ref('degrees/${widget.degreeId}/branches/${widget.branchId}/subjects/${widget.subjectId}/notes/$noteId/voteCount');

    try {
      final voteSnap = await voteNode.get();
      final alreadyVoted = voteSnap.exists;

      // Update voteCount transactionally
      // await noteVoteCountRef.runTransaction((transaction) async {
      //   final currentValue = transaction.dataSnapshot.value;
      //
      //   int currentVal = 0;
      //
      //   if (currentValue is int) {
      //     currentVal = currentValue;
      //   } else if (currentValue is String) {
      //     currentVal = int.tryParse(currentValue) ?? 0;
      //   }
      //
      //   final newVal = alreadyVoted ? currentVal - 1 : currentVal + 1;
      //
      //   // Never go negative as TransactionHandler
      //   final safeVal = newVal < 0 ? 0 : newVal;
      //
      //   transaction.update(safeVal);
      //   return transaction;
      // } as TransactionHandler);
      await noteVoteCountRef.runTransaction((currentValue) {
        int current = 0;

        if (currentValue is int) {
          current = currentValue;
        } else if (currentValue is String) {
          current = int.tryParse(currentValue) ?? 0;
        }

        final newValue = alreadyVoted ? current - 1 : current + 1;

        return Transaction.success(newValue < 0 ? 0 : newValue);
      });

      // Set or remove user's vote record
      if (alreadyVoted) {
        await voteNode.remove();
      } else {
        await voteNode.set({'votedAt': ServerValue.timestamp});
      }
    } catch (e) {
      debugPrint('Vote toggle failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update vote: $e')),
      );
    }
  }

  // Check if current user has voted for a given noteId
  Future<bool> _hasVoted(String noteId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final voteNode = FirebaseDatabase.instance.ref('votes/$noteId/${user.uid}');
    final snap = await voteNode.get();
    return snap.exists;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: isDark ? const Color(0xFF1A365D) : null,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Left side: notes list
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F1B2D), Color(0xFF1A365D)],
                )
                    : null,
              ),
              child: StreamBuilder<DatabaseEvent>(
                stream: _notesRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.blue.shade300 : Colors.blue),
                      ),
                    );
                  }

                  final data = snapshot.data?.snapshot.value;
                  if (data == null) {
                    return Center(
                      child: Text(
                        'No notes yet',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  final map = Map<String, dynamic>.from(data as Map);
                  final items = map.entries.toList()
                    ..sort((a, b) {
                      // Prefer sorting by voteCount (desc), then by timestamp (desc)
                      final aMap = Map<String, dynamic>.from(a.value);
                      final bMap = Map<String, dynamic>.from(b.value);
                      final aVotes = (aMap['voteCount'] is int) ? aMap['voteCount'] as int : int.tryParse('${aMap['voteCount'] ?? 0}') ?? 0;
                      final bVotes = (bMap['voteCount'] is int) ? bMap['voteCount'] as int : int.tryParse('${bMap['voteCount'] ?? 0}') ?? 0;
                      if (bVotes != aVotes) return bVotes.compareTo(aVotes);
                      final at = (aMap['timestamp'] ?? 0) as int;
                      final bt = (bMap['timestamp'] ?? 0) as int;
                      return bt.compareTo(at);
                    });

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final noteId = items[index].key;
                      final value = Map<String, dynamic>.from(items[index].value);
                      final title = value['title'] ?? 'Untitled';
                      final url = value['fileUrl'];
                      final uploaderName = value['uploaderName'] ?? 'Unknown User';
                      final uploaderPhoto = value['uploaderPhoto'] ?? value['photo'] ?? '';
                      final uploaderId = value['uploadedBy'] ?? '';
                      final ts = value['timestamp'] ?? 0;
                      final voteCount = (value['voteCount'] is int) ? value['voteCount'] as int : int.tryParse('${value['voteCount'] ?? 0}') ?? 0;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Card(
                          elevation: 4,
                          shadowColor: isDark ? Colors.blue.shade800.withOpacity(0.5) : null,
                          color: isDark ? const Color(0xFF1E3A5C) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                            // Avatar (tap to public profile)
                            leading: GestureDetector(
                              onTap: () {
                                if (uploaderId.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UserPublicProfilePage(userId: uploaderId),
                                    ),
                                  );
                                }
                              },
                              child: CircleAvatar(
                                radius: 22,
                                backgroundImage: uploaderPhoto.isNotEmpty
                                    ? NetworkImage(uploaderPhoto)
                                    : null,
                                backgroundColor: Colors.grey.shade300,
                                child: uploaderPhoto.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                              ),
                            ),

                            title: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'By: $uploaderName',
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${DateTime.fromMillisecondsSinceEpoch(ts)}',
                                  style: TextStyle(
                                    color: isDark ? Colors.white60 : Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildIconButton(
                                  icon: Icons.auto_awesome,
                                  tooltip: 'Generate Summary (AI)',
                                  onPressed: url == null ? null : () => _generateSummary(url, title),
                                  isDark: isDark,
                                  color: Colors.purple,
                                ),
                                _buildIconButton(
                                  icon: Icons.open_in_new,
                                  tooltip: 'Open',
                                  onPressed: url == null
                                      ? null
                                      : () => launchUrlString(url, mode: LaunchMode.externalApplication),
                                  isDark: isDark,
                                  color: Colors.green,
                                ),
                                _buildIconButton(
                                  icon: Icons.download,
                                  tooltip: 'Download',
                                  onPressed: url == null
                                      ? null
                                      : () {
                                    if (kIsWeb) {
                                      _downloadFileWeb(url, '$title.pdf');
                                    }
                                  },
                                  isDark: isDark,
                                  color: Colors.blue,
                                ),

                                // ----------------- Upvote + Downvote -----------------
                                FutureBuilder<Map<String, bool>>(
                                  future: _getVoteStatus(noteId),
                                  builder: (context, snap) {
                                    final hasUp = snap.data?['up'] ?? false;
                                    final hasDown = snap.data?['down'] ?? false;

                                    final upvoteCount = (value['upvoteCount'] ?? 0);
                                    final downvoteCount = (value['downvoteCount'] ?? 0);

                                    return Row(
                                      children: [
                                        // ---- UPVOTE BUTTON ----
                                        IconButton(
                                          icon: Icon(
                                            Icons.thumb_up,
                                            color: hasUp
                                                ? Colors.orange
                                                : (isDark ? Colors.white70 : Colors.grey[700]),
                                          ),
                                          tooltip: hasUp ? "Remove Upvote" : "Upvote",
                                          onPressed: () async {
                                            await _toggleUpvote(noteId);
                                            setState(() {}); // refresh UI
                                          },
                                        ),
                                        Text(
                                          "$upvoteCount",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color:
                                            isDark ? Colors.white70 : Colors.grey[700],
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        // ---- DOWNVOTE BUTTON ----
                                        IconButton(
                                          icon: Icon(
                                            // Icons.thumb_down,
                                            Icons.thumb_down,
                                            color: hasDown
                                                ? Colors.red
                                                : (isDark ? Colors.white70 : Colors.grey[700]),
                                          ),
                                          tooltip: hasDown ? "Remove Downvote" : "Downvote",
                                          onPressed: () async {
                                            await _toggleDownvote(noteId);
                                            setState(() {}); // refresh UI
                                          },
                                        ),
                                        Text(
                                          "$downvoteCount",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color:
                                            isDark ? Colors.white70 : Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),

                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Right side: Gemini summary panel
          if (_summaryTitle != null)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [const Color(0xFF0F1B2D), const Color(0xFF1A365D), const Color(0xFF2D3748)]
                        : [const Color(0xFFE8F0FE), const Color(0xFFF1F8FF), Colors.white],
                  ),
                  border: Border(left: BorderSide(color: isDark ? Colors.blue.shade800 : Colors.blue.shade200, width: 1)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.blue.shade700 : Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(4),
                            child: Lottie.asset('assets/animations/Blue Gemini.json', fit: BoxFit.contain),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Gemini AI Summary',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.blue.shade200 : Colors.blue.shade800),
                            ),
                          ),
                          IconButton(icon: Icon(Icons.close, color: isDark ? Colors.blue.shade200 : Colors.blue.shade600), onPressed: _closeSummary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _summaryTitle!,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey[700], fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    if (_loading)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 80, height: 80, child: Lottie.asset('assets/animations/Loading Dots Blue.json', fit: BoxFit.contain)),
                              const SizedBox(height: 20),
                              Text(_loadingText, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: isDark ? Colors.blue.shade200 : Colors.blue.shade600)),
                              const SizedBox(height: 16),
                              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.blue.shade300 : Colors.blue), strokeWidth: 2),
                            ],
                          ),
                        ),
                      ),
                    if (!_loading && _summary != null)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withOpacity(0.2) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.blue.shade800 : Colors.blue.shade200),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(child: SelectableText(_summary!, style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? Colors.white : Colors.grey[800]))),
                        ),
                      ),
                    if (!_loading && _summary != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.purple.shade600], begin: Alignment.centerLeft, end: Alignment.centerRight),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _summary!));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Summary copied to clipboard!'), backgroundColor: Colors.green));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), padding: const EdgeInsets.symmetric(vertical: 12)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.copy, color: Colors.white, size: 20), SizedBox(width: 8), Text('Copy Summary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => UploadNotePage(degreeId: widget.degreeId, branchId: widget.branchId, subjectId: widget.subjectId)));
        },
        backgroundColor: isDark ? Colors.blue.shade600 : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required bool isDark,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1), shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, size: 20), color: isDark ? color.withOpacity(0.8) : color, tooltip: tooltip, onPressed: onPressed, iconSize: 20, padding: const EdgeInsets.all(6)),
    );

  }

  Future<Map<String, bool>> _getVoteStatus(String noteId) async {
    final user = _currentUser;
    if (user == null) return {"up": false, "down": false};

    final noteRef = FirebaseDatabase.instance.ref(
      "degrees/${widget.degreeId}/branches/${widget.branchId}/subjects/${widget.subjectId}/notes/$noteId",
    );

    final upSnap = await noteRef.child("upvotes/${user.uid}").get();
    final downSnap = await noteRef.child("downvotes/${user.uid}").get();

    return {
      "up": upSnap.exists,
      "down": downSnap.exists,
    };
  }
  Future<void> _toggleUpvote(String noteId) async {
    final user = _currentUser;
    if (user == null) return;

    final noteRef = FirebaseDatabase.instance.ref(
      "degrees/${widget.degreeId}/branches/${widget.branchId}/subjects/${widget.subjectId}/notes/$noteId",
    );

    final upRef = noteRef.child("upvotes/${user.uid}");
    final downRef = noteRef.child("downvotes/${user.uid}");

    final upCountRef = noteRef.child("upvoteCount");
    final downCountRef = noteRef.child("downvoteCount");

    final upSnap = await upRef.get();
    final downSnap = await downRef.get();

    int upCount = await _readVoteInt(upCountRef);
    int downCount = await _readVoteInt(downCountRef);

    if (upSnap.exists) {
      // remove upvote
      upCount = (upCount - 1).clamp(0, 999999);
      await upRef.remove();
    } else {
      // add upvote
      upCount += 1;
      await upRef.set(true);

      // remove previous downvote
      if (downSnap.exists) {
        downCount = (downCount - 1).clamp(0, 999999);
        await downRef.remove();
      }
    }

    await upCountRef.set(upCount);
    await downCountRef.set(downCount);
  }
  Future<void> _toggleDownvote(String noteId) async {
    final user = _currentUser;
    if (user == null) return;

    final noteRef = FirebaseDatabase.instance.ref(
      "degrees/${widget.degreeId}/branches/${widget.branchId}/subjects/${widget.subjectId}/notes/$noteId",
    );

    final upRef = noteRef.child("upvotes/${user.uid}");
    final downRef = noteRef.child("downvotes/${user.uid}");

    final upCountRef = noteRef.child("upvoteCount");
    final downCountRef = noteRef.child("downvoteCount");

    final upSnap = await upRef.get();
    final downSnap = await downRef.get();

    int upCount = await _readVoteInt(upCountRef);
    int downCount = await _readVoteInt(downCountRef);

    if (downSnap.exists) {
      // remove downvote
      downCount = (downCount - 1).clamp(0, 999999);
      await downRef.remove();
    } else {
      // add downvote
      downCount += 1;
      await downRef.set(true);

      // remove previous upvote
      if (upSnap.exists) {
        upCount = (upCount - 1).clamp(0, 999999);
        await upRef.remove();
      }
    }

    await upCountRef.set(upCount);
    await downCountRef.set(downCount);
  }

  Future<int> _readVoteInt(DatabaseReference ref) async {
    final snap = await ref.get();
    if (!snap.exists) return 0;

    if (snap.value is int) return snap.value as int;
    if (snap.value is String) return int.tryParse(snap.value as String) ?? 0;

    return 0;
  }


}
