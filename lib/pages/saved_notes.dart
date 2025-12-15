import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:lottie/lottie.dart';

import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';

class SavedNotesPage extends StatefulWidget {
  const SavedNotesPage({super.key});

  @override
  State<SavedNotesPage> createState() => _SavedNotesPageState();
}

class _SavedNotesPageState extends State<SavedNotesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final profileProvider = context.read<UserProfileProvider>();
      profileProvider.loadCurrentUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<UserProfileProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    // Color palette
    final Color _backgroundColor = const Color(0xFF0F0F1A);
    final Color _cardBackground = const Color(0xFF1A1A2E);
    final Color _accentColor = const Color(0xFF6C63FF);
    final Color _accentColor2 = const Color(0xFF4A44B5);
    final Color _textColor = Colors.white;
    final Color _subtextColor = Colors.white70;

    if (auth.firebaseUser == null) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _accentColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sign In Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Please sign in to view your saved notes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _subtextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (profileProvider.isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/Loading Dots Blue.json',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading your notes...',
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final savedNotes = profileProvider.savedNotes;

    if (savedNotes.isEmpty) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: _cardBackground,
          elevation: 0,
          title: const Text('Saved Notes'),
          centerTitle: true,
          foregroundColor: _textColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                profileProvider.loadCurrentUserProfile();
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _accentColor.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bookmark_outline_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Saved Notes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Save notes by clicking the bookmark icon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _subtextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _cardBackground,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accentColor, _accentColor2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bookmark_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                Text(
                  '${savedNotes.length} items',
                  style: TextStyle(
                    fontSize: 11,
                    color: _subtextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () {
              profileProvider.loadCurrentUserProfile();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getColumnCount(screenWidth),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: _getAspectRatio(screenWidth),
          ),
          itemCount: savedNotes.length,
          itemBuilder: (context, index) {
            final item = savedNotes[index];

            if (item is Map) {
              final map = Map<String, dynamic>.from(item);
              final title = map['title']?.toString() ?? 'Untitled';
              final subject =
                  (map['subject'] ?? map['subjectId'] ?? '').toString();
              final branch =
                  (map['branch'] ?? map['branchId'] ?? '').toString();
              final fileUrl = map['fileUrl']?.toString();
              final noteId = map['noteId']?.toString() ?? '';
              final degreeId = map['degreeId']?.toString() ?? '';
              final branchId = map['branchId']?.toString() ?? '';
              final subjectId = map['subjectId']?.toString() ?? '';

              return _SavedNoteCard(
                title: title,
                subject: subject,
                branch: branch,
                fileUrl: fileUrl,
                noteId: noteId,
                onOpen: fileUrl == null
                    ? null
                    : () => launchUrlString(fileUrl,
                        mode: LaunchMode.externalApplication),
                onRemove: () => _removeNote(
                  context,
                  noteId,
                  title,
                  degreeId,
                  branchId,
                  subjectId,
                  fileUrl,
                  profileProvider,
                ),
                backgroundColor: _cardBackground,
                accentColor: _accentColor,
                accentColor2: _accentColor2,
                textColor: _textColor,
                subtextColor: _subtextColor,
              );
            }

            // Fallback for simple string entries
            return _SavedNoteCard(
              title: item.toString(),
              subject: '',
              branch: '',
              fileUrl: null,
              noteId: '',
              onOpen: null,
              onRemove: null,
              backgroundColor: _cardBackground,
              accentColor: _accentColor,
              accentColor2: _accentColor2,
              textColor: _textColor,
              subtextColor: _subtextColor,
            );
          },
        ),
      ),
    );
  }

  int _getColumnCount(double screenWidth) {
    if (screenWidth < 600) return 2; // Mobile
    if (screenWidth < 900) return 3; // Tablet
    if (screenWidth < 1200) return 4; // Small desktop
    return 5; // Large desktop
  }

  double _getAspectRatio(double screenWidth) {
    if (screenWidth < 600) return 0.65; // Taller cards on mobile
    return 0.7; // Slightly wider on larger screens
  }

  Future<void> _removeNote(
    BuildContext context,
    String noteId,
    String title,
    String degreeId,
    String branchId,
    String subjectId,
    String? fileUrl,
    UserProfileProvider provider,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Remove Note?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Remove "$title" from saved notes?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.toggleSavedNote(
        userId: context.read<AuthProvider>().firebaseUser!.uid,
        noteId: noteId,
        degreeId: degreeId,
        branchId: branchId,
        subjectId: subjectId,
        title: title,
        fileUrl: fileUrl ?? '',
      );
    }
  }
}

class _SavedNoteCard extends StatelessWidget {
  final String title;
  final String subject;
  final String branch;
  final String? fileUrl;
  final String noteId;
  final VoidCallback? onOpen;
  final VoidCallback? onRemove;
  final Color backgroundColor;
  final Color accentColor;
  final Color accentColor2;
  final Color textColor;
  final Color subtextColor;

  const _SavedNoteCard({
    required this.title,
    required this.subject,
    required this.branch,
    required this.fileUrl,
    required this.noteId,
    required this.onOpen,
    required this.onRemove,
    required this.backgroundColor,
    required this.accentColor,
    required this.accentColor2,
    required this.textColor,
    required this.subtextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top section with bookmark and menu
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.bookmark_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const Spacer(),
                    if (onRemove != null)
                      GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.more_vert_rounded,
                            color: subtextColor,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),

                // Note title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Subject and branch
                if (subject.isNotEmpty || branch.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      [branch, subject]
                          .where((s) => s.isNotEmpty)
                          .join(' • '),
                      style: TextStyle(
                        fontSize: 10,
                        color: subtextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // Action buttons
                Row(
                  children: [
                    // Open button - smaller and compact
                    Expanded(
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: onOpen,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    color: accentColor,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Open',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Remove button - smaller
                    if (onRemove != null)
                      GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red.withOpacity(0.8),
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}