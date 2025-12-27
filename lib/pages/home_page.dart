import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import 'branch_subject_selection_page.dart';
import 'saved_notes.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToBrowse;
  final VoidCallback? onNavigateToUpload;

  const HomePage({
    super.key,
    this.onNavigateToBrowse,
    this.onNavigateToUpload,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

    const backgroundColor = Color(0xFFF5F5F0);
    const textColor = Color(0xFF000000);
    const subtextColor = Color(0xFF666666);
    const borderColor = Color(0xFFE5E5E0);
    const accentColor = Color(0xFF000000);

    if (profileProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: accentColor),
      );
    }

    final profileData = profileProvider.currentProfile;
    final nameValue = profileData?["name"]?.toString().trim();
    final displayName = (nameValue != null && nameValue.isNotEmpty)
        ? nameValue
        : 'there';

    final email = auth.firebaseUser?.email ?? '';
    final savedNotes = profileProvider.savedNotes;
    final recentSaved = savedNotes
        .where((e) => e is Map)
        .cast<Map>()
        .take(3)
        .toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 120,
          vertical: isMobile ? 16 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, $displayName',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jump back into your notes, upload new resources, or review what you saved recently.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: subtextColor,
                          height: 1.5,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Signed in as $email',
                          style: const TextStyle(
                            fontSize: 12,
                            color: subtextColor,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: widget.onNavigateToUpload ?? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BranchSubjectSelectionPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                            label: const Text('Upload notes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 18 : 22,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: widget.onNavigateToBrowse ?? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BranchSubjectSelectionPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.search_rounded, size: 18),
                            label: const Text('Browse notes'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor,
                              side: const BorderSide(color: borderColor),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SavedNotesPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bookmark_border, size: 18),
                            label: const Text('Saved notes'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor,
                              side: const BorderSide(color: borderColor),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 40),
                  SizedBox(
                    width: 220,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: const Border.fromBorderSide(
                          BorderSide(color: borderColor),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.insights_outlined,
                              color: accentColor, size: 20),
                          const SizedBox(height: 12),
                          Text(
                            '${savedNotes.length}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'notes saved',
                            style: TextStyle(
                              fontSize: 13,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 40),

            Text(
              'Recently saved',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            if (recentSaved.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: const Border.fromBorderSide(
                    BorderSide(color: borderColor),
                  ),
                ),
                child: const Text(
                  'You haven\'t saved any notes yet. Browse notes and tap the bookmark icon to save them here.',
                  style: TextStyle(fontSize: 13, color: subtextColor),
                ),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedNotesPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(color: accentColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Column(
                children: recentSaved.map((map) {
                  final data = Map<String, dynamic>.from(map);
                  final title = data['title']?.toString() ?? 'Untitled note';
                  final subject =
                      (data['subject'] ?? data['subjectId'] ?? '').toString();
                  final branch =
                      (data['branch'] ?? data['branchId'] ?? '').toString();
                  final fileUrl = data['fileUrl']?.toString();

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _RecentSavedCard(
                      title: title,
                      subject: subject,
                      branch: branch,
                      fileUrl: fileUrl,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentSavedCard extends StatelessWidget {
  final String title;
  final String subject;
  final String branch;
  final String? fileUrl;

  const _RecentSavedCard({
    required this.title,
    required this.subject,
    required this.branch,
    required this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF000000);
    const subtextColor = Color(0xFF666666);
    const borderColor = Color(0xFFE5E5E0);
    const accentColor = Color(0xFF000000);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: const Border.fromBorderSide(
          BorderSide(color: borderColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.insert_drive_file_outlined,
                color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [branch, subject]
                      .where((s) => s.isNotEmpty)
                      .join(' • '),
                  style: const TextStyle(
                    color: subtextColor,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: (fileUrl == null || fileUrl!.isEmpty)
                ? null
                : () {
                    final url = fileUrl!;
                    launchUrlString(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  },
            style: TextButton.styleFrom(
              foregroundColor: accentColor,
            ),
            child: const Text(
              'Open',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
