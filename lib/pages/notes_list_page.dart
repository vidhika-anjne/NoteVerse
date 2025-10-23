import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'upload_notes_page.dart';
import 'dart:html' as html;

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

  @override
  void initState() {
    super.initState();
    _notesRef = FirebaseDatabase.instance.ref(
      'degrees/${widget.degreeId}/branches/${widget.branchId}/subjects/${widget.subjectId}/notes',
    );
  }

  // Web-compatible download
  void _downloadFileWeb(String url, String fileName) {
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: StreamBuilder<DatabaseEvent>(
        stream: _notesRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.snapshot.value;
          if (data == null) return const Center(child: Text('No notes yet'));

          final map = Map<String, dynamic>.from(data as Map);
          final items = map.entries.toList()
            ..sort((a, b) {
              final at = (a.value['timestamp'] ?? 0) as int;
              final bt = (b.value['timestamp'] ?? 0) as int;
              return bt.compareTo(at);
            });

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final value = Map<String, dynamic>.from(items[index].value);
              final title = value['title'] ?? 'Untitled';
              final url = value['fileUrl'];
              final uploadedBy = value['uploadedBy'] ?? 'Unknown';
              final ts = value['timestamp'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(
                    'By: $uploadedBy • ${DateTime.fromMillisecondsSinceEpoch(ts)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: 'Open',
                        onPressed: url == null
                            ? null
                            : () => launchUrlString(url, mode: LaunchMode.externalApplication),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        tooltip: 'Download',
                        onPressed: url == null
                            ? null
                            : () {
                          if (kIsWeb) {
                            _downloadFileWeb(url, '$title.pdf');
                          } else {
                            // mobile/desktop download logic (if needed)
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
