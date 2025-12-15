import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/user_profile_provider.dart';
import 'upload_notes_page.dart';
import 'user_public_profile_page.dart';

class NotesListPage extends StatefulWidget {
  final String degreeId;
  final String branchId;
  final String subjectId;
  final VoidCallback? onBack;

  const NotesListPage({
    super.key,
    required this.degreeId,
    required this.branchId,
    required this.subjectId,
    this.onBack,
  });

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);
  final ValueNotifier<String> _loadingText = ValueNotifier<String>('');
  final ValueNotifier<String?> _summary = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _summaryTitle = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final profileProvider = context.read<UserProfileProvider>();
      profileProvider.loadCurrentUserProfile();
    });
  }

  @override
  void dispose() {
    _loading.dispose();
    _loadingText.dispose();
    _summary.dispose();
    _summaryTitle.dispose();
    super.dispose();
  }

  void _downloadFileWeb(String url, String fileName) {
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> _generateSummary(String url, String title) async {
    try {
      _loading.value = true;
      _loadingText.value = 'Generating AI summary for "$title"...';
      _summary.value = null;
      _summaryTitle.value = title;

      final notesProvider = context.read<NotesProvider>();
      final summary = await notesProvider.generateSummary(
        url: url,
        title: title,
      );

      _loading.value = false;
      _summary.value = summary;
    } catch (e) {
      _loading.value = false;
      _summary.value = 'Failed to generate summary: $e';
    }
  }

  void _closeSummary() {
    _summary.value = null;
    _summaryTitle.value = null;
  }

  Future<void> _toggleUpvote(String noteId) async {
    final auth = context.read<AuthProvider>();
    final user = auth.firebaseUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to vote')),
      );
      return;
    }

    final notesProvider = context.read<NotesProvider>();
    await notesProvider.toggleUpvote(
      degreeId: widget.degreeId,
      branchId: widget.branchId,
      subjectId: widget.subjectId,
      noteId: noteId,
      userId: user.uid,
    );
  }

  Future<void> _toggleDownvote(String noteId) async {
    final auth = context.read<AuthProvider>();
    final user = auth.firebaseUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to vote')),
      );
      return;
    }

    final notesProvider = context.read<NotesProvider>();
    await notesProvider.toggleDownvote(
      degreeId: widget.degreeId,
      branchId: widget.branchId,
      subjectId: widget.subjectId,
      noteId: noteId,
      userId: user.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isMobile) {
            return _buildMobileLayout();
          } else {
            return Row(
              children: [
                // Left side: notes list
                Expanded(
                  flex: _summaryTitle.value != null ? (isTablet ? 3 : 2) : 1,
                  child: _NotesListContent(
                    degreeId: widget.degreeId,
                    branchId: widget.branchId,
                    subjectId: widget.subjectId,
                    onGenerateSummary: _generateSummary,
                    onToggleUpvote: _toggleUpvote,
                    onToggleDownvote: _toggleDownvote,
                    onDownloadFile: _downloadFileWeb,
                    onBack: widget.onBack,
                    isMobile: false,
                  ),
                ),
                // Right side: Gemini summary panel
                ValueListenableBuilder<String?>(
                  valueListenable: _summaryTitle,
                  builder: (context, summaryTitle, _) {
                    if (summaryTitle == null) return const SizedBox.shrink();
                    return SizedBox(
                      width: isTablet ? 350 : 450,
                      child: _SummaryPanel(
                        loading: _loading,
                        loadingText: _loadingText,
                        summary: _summary,
                        summaryTitle: _summaryTitle,
                        onCloseSummary: _closeSummary,
                      ),
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UploadNotePage(
                  degreeId: widget.degreeId,
                  branchId: widget.branchId,
                  subjectId: widget.subjectId,
                ),
              ),
            );
          },
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return _NotesListContent(
      degreeId: widget.degreeId,
      branchId: widget.branchId,
      subjectId: widget.subjectId,
      onGenerateSummary: (url, title) async {
        await _generateSummary(url, title);
        // On mobile, show summary in bottom sheet
        if (_summary.value != null) {
          _showSummaryBottomSheet(context);
        }
      },
      onToggleUpvote: _toggleUpvote,
      onToggleDownvote: _toggleDownvote,
      onDownloadFile: _downloadFileWeb,
      onBack: widget.onBack,
      isMobile: true,
    );
  }

  void _showSummaryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF6C63FF).withOpacity(0.9),
                      const Color(0xFF4A44B5).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Lottie.asset(
                        'assets/animations/Blue Gemini.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gemini AI Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Title
              ValueListenableBuilder<String?>(
                valueListenable: _summaryTitle,
                builder: (context, title, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      title ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Content
              Expanded(
                child: ValueListenableBuilder<String?>(
                  valueListenable: _summary,
                  builder: (context, summaryText, _) {
                    if (summaryText == null) return const SizedBox.shrink();

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          summaryText,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Copy button
              ValueListenableBuilder<String?>(
                valueListenable: _summary,
                builder: (context, summaryText, _) {
                  if (summaryText == null) return const SizedBox.shrink();

                  return ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: summaryText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Summary copied to clipboard!'),
                          backgroundColor: Color(0xFF4CAF50),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Copy Summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotesListContent extends StatelessWidget {
  final String degreeId;
  final String branchId;
  final String subjectId;
  final Function(String, String) onGenerateSummary;
  final Function(String) onToggleUpvote;
  final Function(String) onToggleDownvote;
  final Function(String, String) onDownloadFile;
  final VoidCallback? onBack;
  final bool isMobile;

  const _NotesListContent({
    required this.degreeId,
    required this.branchId,
    required this.subjectId,
    required this.onGenerateSummary,
    required this.onToggleUpvote,
    required this.onToggleDownvote,
    required this.onDownloadFile,
    this.onBack,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
        ),
      ),
      child: StreamBuilder(
        stream: notesProvider.notesStream(
          degreeId: degreeId,
          branchId: branchId,
          subjectId: subjectId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/Loading Dots Blue.json',
                    width: isMobile ? 60 : 80,
                    height: isMobile ? 60 : 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading notes...',
                    style: TextStyle(
                      color: Colors.blue.shade300,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data?.snapshot.value;
          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: isMobile ? 90 : 120,
                    height: isMobile ? 90 : 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.note_add_rounded,
                      color: const Color(0xFF6C63FF).withOpacity(0.5),
                      size: isMobile ? 35 : 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 40),
                    child: Text(
                      'Be the first to upload notes for this subject!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final map = Map<String, dynamic>.from(data as Map);
          final items = map.entries.toList()
            ..sort((a, b) {
              final aMap = Map<String, dynamic>.from(a.value);
              final bMap = Map<String, dynamic>.from(b.value);
              final aVotes = (aMap['upvoteCount'] is int)
                  ? aMap['upvoteCount'] as int
                  : int.tryParse('${aMap['upvoteCount'] ?? 0}') ?? 0;
              final bVotes = (bMap['upvoteCount'] is int)
                  ? bMap['upvoteCount'] as int
                  : int.tryParse('${bMap['upvoteCount'] ?? 0}') ?? 0;
              if (bVotes != aVotes) return bVotes.compareTo(aVotes);
              final at = (aMap['timestamp'] ?? 0) as int;
              final bt = (bMap['timestamp'] ?? 0) as int;
              return bt.compareTo(at);
            });

          // Group notes by date
          final Map<String, List<MapEntry<String, dynamic>>> groupedNotes = {};

          for (final item in items) {
            final timestamp = item.value['timestamp'] ?? 0;
            final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final dateKey = _formatDateKey(date);

            if (!groupedNotes.containsKey(dateKey)) {
              groupedNotes[dateKey] = [];
            }
            groupedNotes[dateKey]!.add(item);
          }

          // Sort dates in descending order
          final sortedDates = groupedNotes.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            itemCount: _calculateTotalItemCount(groupedNotes, sortedDates),
            itemBuilder: (context, index) {
              final (dateIndex, noteIndex) = _findItemPosition(
                index,
                groupedNotes,
                sortedDates,
              );

              if (noteIndex == -1) {
                // This is a date header
                final dateKey = sortedDates[dateIndex];
                return _DateHeader(date: dateKey, isMobile: isMobile);
              } else {
                // This is a note card
                final dateKey = sortedDates[dateIndex];
                final noteEntry = groupedNotes[dateKey]![noteIndex];

                final noteId = noteEntry.key;
                final value = Map<String, dynamic>.from(
                  noteEntry.value as Map,
                );
                final title = value['title'] ?? 'Untitled';
                final url = value['fileUrl'];
                final uploaderName = value['uploaderName'] ?? 'Unknown User';
                final uploaderPhoto = value['uploaderPhoto'] ?? value['photo'] ?? '';
                final uploaderId = value['uploadedBy'] ?? '';
                final ts = value['timestamp'] ?? 0;

                return _NoteCard(
                  noteId: noteId,
                  title: title,
                  url: url,
                  uploaderName: uploaderName,
                  uploaderPhoto: uploaderPhoto,
                  uploaderId: uploaderId,
                  timestamp: ts,
                  value: value,
                  onGenerateSummary: onGenerateSummary,
                  onToggleUpvote: onToggleUpvote,
                  onToggleDownvote: onToggleDownvote,
                  onDownloadFile: onDownloadFile,
                  isMobile: isMobile,
                );
              }
            },
          );
        },
      ),
    );
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  int _calculateTotalItemCount(
    Map<String, List<MapEntry<String, dynamic>>> groupedNotes,
    List<String> sortedDates,
  ) {
    int count = 0;
    for (final date in sortedDates) {
      count += 1; // Date header
      count += groupedNotes[date]!.length; // Notes for that date
    }
    return count;
  }

  (int, int) _findItemPosition(
    int index,
    Map<String, List<MapEntry<String, dynamic>>> groupedNotes,
    List<String> sortedDates,
  ) {
    int currentIndex = 0;
    for (int dateIndex = 0; dateIndex < sortedDates.length; dateIndex++) {
      final dateKey = sortedDates[dateIndex];
      final notes = groupedNotes[dateKey]!;

      // Check if this index is the date header
      if (index == currentIndex) {
        return (dateIndex, -1);
      }
      currentIndex++;

      // Check notes for this date
      for (int noteIndex = 0; noteIndex < notes.length; noteIndex++) {
        if (index == currentIndex) {
          return (dateIndex, noteIndex);
        }
        currentIndex++;
      }
    }
    return (0, 0); // Fallback
  }
}

class _DateHeader extends StatelessWidget {
  final String date;
  final bool isMobile;

  const _DateHeader({required this.date, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime(
      int.parse(date.split('-')[0]),
      int.parse(date.split('-')[1]),
      int.parse(date.split('-')[2]),
    );

    return Container(
      margin: EdgeInsets.only(top: isMobile ? 16 : 24, bottom: isMobile ? 12 : 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: isMobile ? 20 : 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF6C63FF), const Color(0xFF4A44B5)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Text(
            _formatDateDisplay(dateTime),
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Today';
    } else if (dateDay == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }
}

class _NoteCard extends StatefulWidget {
  final String noteId;
  final String title;
  final String? url;
  final String uploaderName;
  final String uploaderPhoto;
  final String uploaderId;
  final int timestamp;
  final Map<String, dynamic> value;
  final Function(String, String) onGenerateSummary;
  final Function(String) onToggleUpvote;
  final Function(String) onToggleDownvote;
  final Function(String, String) onDownloadFile;
  final bool isMobile;

  const _NoteCard({
    required this.noteId,
    required this.title,
    required this.url,
    required this.uploaderName,
    required this.uploaderPhoto,
    required this.uploaderId,
    required this.timestamp,
    required this.value,
    required this.onGenerateSummary,
    required this.onToggleUpvote,
    required this.onToggleDownvote,
    required this.onDownloadFile,
    required this.isMobile,
  });

  @override
  State<_NoteCard> createState() => __NoteCardState();
}

class __NoteCardState extends State<_NoteCard> {
  late Future<Map<String, bool>> _voteStatusFuture;

  @override
  void initState() {
    super.initState();
    _voteStatusFuture = _getVoteStatus();
  }

  Future<Map<String, bool>> _getVoteStatus() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.firebaseUser;
    if (user == null) return {"up": false, "down": false};

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    return notesProvider.getVoteStatus(
      degreeId: widget.noteId,
      branchId: widget.noteId,
      subjectId: widget.noteId,
      noteId: widget.noteId,
      userId: user.uid,
    );
  }

  void _refreshVoteStatus() {
    setState(() {
      _voteStatusFuture = _getVoteStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final upvoteCount = (widget.value['upvoteCount'] ?? 0);
    final downvoteCount = (widget.value['downvoteCount'] ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(widget.isMobile ? 10 : 12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Note title - prominent
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: widget.isMobile ? 8 : 12),

                // Uploader info and time
                Row(
                  children: [
                    // Uploader avatar
                    GestureDetector(
                      onTap: widget.uploaderId.isNotEmpty
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserPublicProfilePage(
                                    userId: widget.uploaderId,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        width: widget.isMobile ? 28 : 32,
                        height: widget.isMobile ? 28 : 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6C63FF),
                              const Color(0xFF4A44B5),
                            ],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: widget.isMobile ? 12 : 14,
                          backgroundColor: Colors.transparent,
                          backgroundImage: widget.uploaderPhoto.isNotEmpty
                              ? NetworkImage(widget.uploaderPhoto)
                              : null,
                          child: widget.uploaderPhoto.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: widget.isMobile ? 12 : 16,
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(width: widget.isMobile ? 6 : 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.uploaderName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: widget.isMobile ? 12 : 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: widget.isMobile ? 2 : 4),
                          Text(
                            _formatTime(widget.timestamp),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: widget.isMobile ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: widget.isMobile ? 6 : 8),

                    // Voting section - compact
                    _CompactVotingSection(
                      noteId: widget.noteId,
                      upvoteCount: upvoteCount,
                      downvoteCount: downvoteCount,
                      voteStatusFuture: _voteStatusFuture,
                      onToggleUpvote: () async {
                        await widget.onToggleUpvote(widget.noteId);
                        _refreshVoteStatus();
                      },
                      onToggleDownvote: () async {
                        await widget.onToggleDownvote(widget.noteId);
                        _refreshVoteStatus();
                      },
                      isMobile: widget.isMobile,
                    ),
                  ],
                ),
                SizedBox(height: widget.isMobile ? 8 : 12),

                // Action buttons
                _CompactActionButtons(
                  noteId: widget.noteId,
                  title: widget.title,
                  url: widget.url,
                  onGenerateSummary: widget.onGenerateSummary,
                  onDownloadFile: widget.onDownloadFile,
                  isMobile: widget.isMobile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _CompactActionButtons extends StatelessWidget {
  final String noteId;
  final String title;
  final String? url;
  final Function(String, String) onGenerateSummary;
  final Function(String, String) onDownloadFile;
  final bool isMobile;

  const _CompactActionButtons({
    required this.noteId,
    required this.title,
    required this.url,
    required this.onGenerateSummary,
    required this.onDownloadFile,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final user = auth.firebaseUser;
    final isSaved = user != null && profileProvider.isNoteSaved(noteId);

    return Wrap(
      spacing: isMobile ? 6 : 8,
      runSpacing: isMobile ? 6 : 8,
      children: [
        _CompactActionButton(
          icon: Icons.auto_awesome_rounded,
          label: 'AI Summary',
          onPressed: url == null ? null : () => onGenerateSummary(url!, title),
          color: const Color(0xFF6C63FF),
          isMobile: isMobile,
        ),
        _CompactActionButton(
          icon: Icons.open_in_new_rounded,
          label: 'Open',
          onPressed: url == null
              ? null
              : () => launchUrlString(
                    url!,
                    mode: LaunchMode.externalApplication,
                  ),
          color: const Color(0xFF4FC3F7),
          isMobile: isMobile,
        ),
        if (kIsWeb)
          _CompactActionButton(
            icon: Icons.download_rounded,
            label: 'Download',
            onPressed:
                url == null ? null : () => onDownloadFile(url!, '$title.pdf'),
            color: const Color(0xFF66BB6A),
            isMobile: isMobile,
          ),
        _CompactActionButton(
          icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          label: isSaved ? 'Saved' : 'Save',
          onPressed: () async {
            final user = auth.firebaseUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please sign in to save notes')),
              );
              return;
            }
            await profileProvider.toggleSavedNote(
              userId: user.uid,
              noteId: noteId,
              degreeId: '',
              branchId: '',
              subjectId: '',
              title: title,
              fileUrl: url?.toString(),
            );
          },
          color: const Color(0xFFFFB74D),
          isMobile: isMobile,
        ),
      ],
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool isMobile;

  const _CompactActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 10,
          vertical: isMobile ? 4 : 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: onPressed != null ? color : Colors.grey,
              size: isMobile ? 12 : 14,
            ),
            SizedBox(width: isMobile ? 4 : 5),
            Text(
              label,
              style: TextStyle(
                color: onPressed != null ? color : Colors.grey,
                fontSize: isMobile ? 10 : 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactVotingSection extends StatelessWidget {
  final String noteId;
  final dynamic upvoteCount;
  final dynamic downvoteCount;
  final Future<Map<String, bool>> voteStatusFuture;
  final VoidCallback onToggleUpvote;
  final VoidCallback onToggleDownvote;
  final bool isMobile;

  const _CompactVotingSection({
    required this.noteId,
    required this.upvoteCount,
    required this.downvoteCount,
    required this.voteStatusFuture,
    required this.onToggleUpvote,
    required this.onToggleDownvote,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final upCount = upvoteCount is int ? upvoteCount : int.tryParse('$upvoteCount') ?? 0;
    final downCount = downvoteCount is int ? downvoteCount : int.tryParse('$downvoteCount') ?? 0;

    return FutureBuilder<Map<String, bool>>(
      future: voteStatusFuture,
      builder: (context, snap) {
        final hasUp = snap.data?['up'] ?? false;
        final hasDown = snap.data?['down'] ?? false;

        return Row(
          children: [
            // Upvote
            _CompactVoteButton(
              icon: Icons.thumb_up_rounded,
              count: upCount,
              isActive: hasUp,
              onTap: onToggleUpvote,
              activeColor: const Color(0xFF4CAF50),
              isMobile: isMobile,
            ),
            SizedBox(width: isMobile ? 4 : 6),
            // Downvote
            _CompactVoteButton(
              icon: Icons.thumb_down_rounded,
              count: downCount,
              isActive: hasDown,
              onTap: onToggleDownvote,
              activeColor: const Color(0xFFF44336),
              isMobile: isMobile,
            ),
          ],
        );
      },
    );
  }
}

class _CompactVoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final bool isMobile;

  const _CompactVoteButton({
    required this.icon,
    required this.count,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 5 : 6,
          vertical: isMobile ? 2 : 3,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(isMobile ? 4 : 5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : Colors.white.withOpacity(0.6),
              size: isMobile ? 10 : 12,
            ),
            SizedBox(width: isMobile ? 2 : 3),
            Text(
              '$count',
              style: TextStyle(
                color: isActive ? activeColor : Colors.white.withOpacity(0.6),
                fontSize: isMobile ? 9 : 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final ValueNotifier<bool> loading;
  final ValueNotifier<String> loadingText;
  final ValueNotifier<String?> summary;
  final ValueNotifier<String?> summaryTitle;
  final VoidCallback onCloseSummary;

  const _SummaryPanel({
    required this.loading,
    required this.loadingText,
    required this.summary,
    required this.summaryTitle,
    required this.onCloseSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
            const Color(0xFF0F0F1A),
          ],
        ),
        border: Border(
          left: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.9),
                  const Color(0xFF4A44B5).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Lottie.asset(
                    'assets/animations/Blue Gemini.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gemini AI Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  onPressed: onCloseSummary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Title
          ValueListenableBuilder<String?>(
            valueListenable: summaryTitle,
            builder: (context, title, _) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: loading,
              builder: (context, isLoading, _) {
                if (isLoading) {
                  return ValueListenableBuilder<String>(
                    valueListenable: loadingText,
                    builder: (context, text, _) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Lottie.asset(
                                'assets/animations/Loading Dots Blue.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return ValueListenableBuilder<String?>(
                  valueListenable: summary,
                  builder: (context, summaryText, _) {
                    if (summaryText == null) return const SizedBox.shrink();

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          summaryText,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<String?>(
            valueListenable: summary,
            builder: (context, summaryText, _) {
              if (summaryText == null) return const SizedBox.shrink();

              return ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: summaryText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Summary copied to clipboard!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Copy Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}