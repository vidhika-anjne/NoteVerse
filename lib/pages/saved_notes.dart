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

    if (auth.firebaseUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view your saved notes'),
        ),
      );
    }

    if (profileProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final savedNotes = profileProvider.savedNotes;

    if (savedNotes.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('📚 No saved notes yet'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Notes')),
      body: ListView.builder(
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

            return ListTile(
              leading: const Icon(Icons.bookmark, color: Colors.amber),
              title: Text(title),
              subtitle: Text(
                [branch, subject].where((s) => s.isNotEmpty).join(' • '),
              ),
              onTap: fileUrl == null
                  ? null
                  : () => launchUrlString(fileUrl,
                      mode: LaunchMode.externalApplication),
              trailing: fileUrl == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.open_in_new),
                      tooltip: 'Open Note',
                      onPressed: () => launchUrlString(fileUrl,
                          mode: LaunchMode.externalApplication),
                    ),
            );
          }

          // Fallback for simple string entries
          return ListTile(
            leading: const Icon(Icons.bookmark, color: Colors.amber),
            title: Text(item.toString()),
          );
        },
      ),
    );
  }
}

