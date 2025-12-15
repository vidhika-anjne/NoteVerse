import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

    // Responsive values
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    // Dynamic padding based on screen size
    final double horizontalPadding = isMobile ? 16 : isTablet ? 32 : 120;
    final double verticalPadding = isMobile ? 24 : 40;
    
    // Grid columns based on screen size
    final int crossAxisCount = isMobile ? 2 : isTablet ? 3 : 4;
    
    // Card aspect ratio based on screen size
    final double cardAspectRatio = isMobile ? 0.8 : isTablet ? 0.75 : 0.7;

    // Color palette matching profile page
    final Color _backgroundColor = Colors.white;
    final Color _cardBackground = Colors.white;
    final Color _accentColor = const Color(0xFF000000);
    final Color _textColor = const Color(0xFF000000);
    final Color _subtextColor = const Color(0xFF666666);
    final Color _borderColor = const Color(0xFFE5E5E0);

    if (auth.firebaseUser == null) {
      return Container(
        color: _backgroundColor,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _borderColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: _accentColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sign In Required',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please sign in to view saved notes',
                  style: TextStyle(
                    color: _subtextColor,
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (profileProvider.isLoading) {
      return Container(
        color: _backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _accentColor),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  color: _subtextColor,
                  fontSize: isMobile ? 13 : 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final savedNotes = profileProvider.savedNotes;

    if (savedNotes.isEmpty) {
      return Container(
        color: _backgroundColor,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: isMobile ? 80 : 100,
                  height: isMobile ? 80 : 100,
                  decoration: BoxDecoration(
                    color: _cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _borderColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.bookmark_border,
                    color: _accentColor,
                    size: isMobile ? 32 : 40,
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),
                Text(
                  'No Saved Notes',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save notes by clicking the bookmark icon',
                  style: TextStyle(
                    color: _subtextColor,
                    fontSize: isMobile ? 12 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: _backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: verticalPadding,
              bottom: isMobile ? 16 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Notes',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 8),
                Text(
                  '${savedNotes.length} ${savedNotes.length == 1 ? 'note' : 'notes'} saved',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: _subtextColor,
                  ),
                ),
              ],
            ),
          ),

          // Grid with proper scrolling
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isMobile ? 12 : 20,
                  mainAxisSpacing: isMobile ? 12 : 20,
                  childAspectRatio: cardAspectRatio,
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
                      isMobile: isMobile,
                    );
                  }

                  return _SavedNoteCard(
                    title: item.toString(),
                    subject: '',
                    branch: '',
                    fileUrl: null,
                    noteId: '',
                    onOpen: null,
                    onRemove: null,
                    isMobile: isMobile,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Remove Note?',
          style: TextStyle(
            color: const Color(0xFF000000),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Remove "$title" from saved notes?',
          style: TextStyle(
            color: const Color(0xFF666666),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF666666),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000000),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
  final bool isMobile;

  const _SavedNoteCard({
    required this.title,
    required this.subject,
    required this.branch,
    required this.fileUrl,
    required this.noteId,
    required this.onOpen,
    required this.onRemove,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final Color _cardBackground = Colors.white;
    final Color _accentColor = const Color(0xFF000000);
    final Color _textColor = const Color(0xFF000000);
    final Color _subtextColor = const Color(0xFF666666);
    final Color _borderColor = const Color(0xFFE5E5E0);

    return Container(
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with bookmark icon
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bookmark,
                  color: _accentColor,
                  size: isMobile ? 18 : 20,
                ),
                SizedBox(width: isMobile ? 8 : 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 13 : 15,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      size: isMobile ? 16 : 18,
                      color: _subtextColor,
                    ),
                    onPressed: onRemove,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

          // Subject and branch info
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (branch.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 10,
                        vertical: isMobile ? 3 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        branch,
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  if (branch.isNotEmpty) SizedBox(height: isMobile ? 6 : 8),
                  if (subject.isNotEmpty)
                    Expanded(
                      child: Text(
                        subject,
                        style: TextStyle(
                          color: _subtextColor,
                          fontSize: isMobile ? 12 : 13,
                        ),
                        maxLines: isMobile ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Open button
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: SizedBox(
              width: double.infinity,
              height: isMobile ? 36 : 40,
              child: ElevatedButton(
                onPressed: onOpen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: onOpen != null
                      ? _accentColor
                      : const Color(0xFFE5E5E0),
                  foregroundColor: onOpen != null 
                      ? Colors.white 
                      : _subtextColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.open_in_new,
                      size: isMobile ? 14 : 16,
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Text(
                      'Open Note',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}