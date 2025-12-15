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
        SnackBar(
          content: const Text('Please sign in to vote'),
          backgroundColor: const Color(0xFF000000),
        ),
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
        SnackBar(
          content: const Text('Please sign in to vote'),
          backgroundColor: const Color(0xFF000000),
        ),
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
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isMobile) {
            return _buildMobileLayout();
          } else {
            return Row(
              children: [
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
          backgroundColor: const Color(0xFF000000),
          foregroundColor: Colors.white,
          elevation: 4,
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF000000),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF000000),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF000000)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<String?>(
                valueListenable: _summaryTitle,
                builder: (context, title, _) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      title ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000000),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ValueListenableBuilder<String?>(
                  valueListenable: _summary,
                  builder: (context, summaryText, _) {
                    if (summaryText == null) return const SizedBox.shrink();

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E5E0)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          summaryText,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.7,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
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
                          backgroundColor: Color(0xFF000000),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Copy Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
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
      color: Colors.white,
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
                  CircularProgressIndicator(
                    color: const Color(0xFF000000),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading notes...',
                    style: TextStyle(
                      color: const Color(0xFF666666),
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w500,
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
                    width: isMobile ? 100 : 120,
                    height: isMobile ? 100 : 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.note_add_outlined,
                      color: const Color(0xFF000000),
                      size: isMobile ? 40 : 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No notes yet',
                    style: TextStyle(
                      color: const Color(0xFF000000),
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 32 : 48),
                    child: Text(
                      'Be the first to upload notes for this subject!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF666666),
                        fontSize: isMobile ? 14 : 16,
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

          final sortedDates = groupedNotes.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 120,
              vertical: isMobile ? 16 : 40,
            ),
            itemCount: _calculateTotalItemCount(groupedNotes, sortedDates),
            itemBuilder: (context, index) {
              final (dateIndex, noteIndex) = _findItemPosition(
                index,
                groupedNotes,
                sortedDates,
              );

              if (noteIndex == -1) {
                final dateKey = sortedDates[dateIndex];
                return _DateHeader(date: dateKey, isMobile: isMobile);
              } else {
                final dateKey = sortedDates[dateIndex];
                final noteEntry = groupedNotes[dateKey]![noteIndex];

                final noteId = noteEntry.key;
                final value = Map<String, dynamic>.from(noteEntry.value as Map);
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
      count += 1;
      count += groupedNotes[date]!.length;
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

      if (index == currentIndex) {
        return (dateIndex, -1);
      }
      currentIndex++;

      for (int noteIndex = 0; noteIndex < notes.length; noteIndex++) {
        if (index == currentIndex) {
          return (dateIndex, noteIndex);
        }
        currentIndex++;
      }
    }
    return (0, 0);
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
      margin: EdgeInsets.only(
        top: isMobile ? 20 : 32,
        bottom: isMobile ? 12 : 20,
      ),
      child: Row(
        children: [
          Text(
            _formatDateDisplay(dateTime),
            style: TextStyle(
              color: const Color(0xFF000000),
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFFE5E5E0),
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
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
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
  State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard> {
  late Future<Map<String, bool>> _voteStatusFuture;
  bool _isHovered = false;

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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered 
                ? const Color(0xFF000000) 
                : const Color(0xFFE5E5E0),
            width: _isHovered ? 2 : 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF000000).withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: const Color(0xFF000000),
                  fontSize: widget.isMobile ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: widget.isMobile ? 12 : 16),
              Row(
                children: [
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
                    child: Row(
                      children: [
                        Container(
                          width: widget.isMobile ? 32 : 36,
                          height: widget.isMobile ? 32 : 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE5E5E0),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFFF5F5F0),
                            backgroundImage: widget.uploaderPhoto.isNotEmpty
                                ? NetworkImage(widget.uploaderPhoto)
                                : null,
                            child: widget.uploaderPhoto.isEmpty
                                ? Icon(
                                    Icons.person,
                                    color: const Color(0xFF000000),
                                    size: widget.isMobile ? 16 : 18,
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(width: widget.isMobile ? 8 : 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.uploaderName,
                              style: TextStyle(
                                color: const Color(0xFF000000),
                                fontSize: widget.isMobile ? 13 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatTime(widget.timestamp),
                              style: TextStyle(
                                color: const Color(0xFF666666),
                                fontSize: widget.isMobile ? 11 : 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _VotingSection(
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
              SizedBox(height: widget.isMobile ? 12 : 16),
              _ActionButtons(
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

class _ActionButtons extends StatelessWidget {
  final String noteId;
  final String title;
  final String? url;
  final Function(String, String) onGenerateSummary;
  final Function(String, String) onDownloadFile;
  final bool isMobile;

  const _ActionButtons({
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
      spacing: isMobile ? 8 : 12,
      runSpacing: isMobile ? 8 : 12,
      children: [
        _ActionButton(
          icon: Icons.auto_awesome_outlined,
          label: 'AI Summary',
          onPressed: url == null ? null : () => onGenerateSummary(url!, title),
          isMobile: isMobile,
        ),
        _ActionButton(
          icon: Icons.open_in_new,
          label: 'Open',
          onPressed: url == null
              ? null
              : () => launchUrlString(
                    url!,
                    mode: LaunchMode.externalApplication,
                  ),
          isMobile: isMobile,
        ),
        if (kIsWeb)
          _ActionButton(
            icon: Icons.download_outlined,
            label: 'Download',
            onPressed:
                url == null ? null : () => onDownloadFile(url!, '$title.pdf'),
            isMobile: isMobile,
          ),
        _ActionButton(
          icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
          label: isSaved ? 'Saved' : 'Save',
          onPressed: () async {
            final user = auth.firebaseUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please sign in to save notes'),
                  backgroundColor: Color(0xFF000000),
                ),
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
          isMobile: isMobile,
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isMobile;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isMobile,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: Icon(widget.icon, size: widget.isMobile ? 16 : 18),
          label: Text(widget.label),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isHovered && widget.onPressed != null
                ? const Color(0xFF000000)
                : Colors.white,
            foregroundColor: _isHovered && widget.onPressed != null
                ? Colors.white
                : const Color(0xFF000000),
            disabledBackgroundColor: const Color(0xFFF5F5F0),
            disabledForegroundColor: const Color(0xFF999999),
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isMobile ? 12 : 16,
              vertical: widget.isMobile ? 10 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: widget.onPressed != null
                    ? const Color(0xFFE5E5E0)
                    : const Color(0xFFE5E5E0),
              ),
            ),
            textStyle: TextStyle(
              fontSize: widget.isMobile ? 13 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _VotingSection extends StatelessWidget {
  final String noteId;
  final dynamic upvoteCount;
  final dynamic downvoteCount;
  final Future<Map<String, bool>> voteStatusFuture;
  final VoidCallback onToggleUpvote;
  final VoidCallback onToggleDownvote;
  final bool isMobile;

  const _VotingSection({
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

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _VoteButton(
                icon: Icons.thumb_up_outlined,
                count: upCount,
                isActive: hasUp,
                onTap: onToggleUpvote,
                isMobile: isMobile,
              ),
              Container(
                width: 1,
                height: isMobile ? 16 : 20,
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
                color: const Color(0xFFE5E5E0),
              ),
              _VoteButton(
                icon: Icons.thumb_down_outlined,
                count: downCount,
                isActive: hasDown,
                onTap: onToggleDownvote,
                isMobile: isMobile,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VoteButton extends StatefulWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final bool isMobile;

  const _VoteButton({
    required this.icon,
    required this.count,
    required this.isActive,
    required this.onTap,
    required this.isMobile,
  });

  @override
  State<_VoteButton> createState() => _VoteButtonState();
}

class _VoteButtonState extends State<_VoteButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: widget.isActive || _isHovered
                  ? const Color(0xFF000000)
                  : const Color(0xFF666666),
              size: widget.isMobile ? 16 : 18,
            ),
            SizedBox(width: widget.isMobile ? 4 : 6),
            Text(
              '${widget.count}',
              style: TextStyle(
                color: widget.isActive || _isHovered
                    ? const Color(0xFF000000)
                    : const Color(0xFF666666),
                fontSize: widget.isMobile ? 13 : 14,
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
        color: const Color(0xFFF5F5F0),
        border: Border(
          left: BorderSide(color: const Color(0xFFE5E5E0), width: 1),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF000000),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF000000),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF000000)),
                onPressed: onCloseSummary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<String?>(
            valueListenable: summaryTitle,
            builder: (context, title, _) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E5E0)),
                ),
                child: Text(
                  title ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
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
                            CircularProgressIndicator(
                              color: const Color(0xFF000000),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF666666),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E5E0)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          summaryText,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.7,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
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
                      backgroundColor: Color(0xFF000000),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.copy, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Copy Summary',
                      style: TextStyle(
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