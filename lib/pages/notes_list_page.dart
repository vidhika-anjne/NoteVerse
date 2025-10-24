import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart'; // Add this package for animations

import 'upload_notes_page.dart';
import '../services/gemini_service.dart';

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

  // 🔹 Generate AI Summary using Gemini
  Future<void> _generateSummary(String url, String title) async {
    try {
      setState(() {
        _loading = true;
        _loadingText = 'Generating AI summary for "$title"...';
        _summary = null;
        _summaryTitle = title;
      });

      // Download file text
      final response = await http.get(Uri.parse(url));
      final rawText = response.body.toString();

      // Get summary from Gemini
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

  // Close the summary panel
  void _closeSummary() {
    setState(() {
      _summary = null;
      _summaryTitle = null;
    });
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
                  colors: [
                    Color(0xFF0F1B2D),
                    Color(0xFF1A365D),
                  ],
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
                          isDark ? Colors.blue.shade300 : Colors.blue,
                        ),
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

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Card(
                          elevation: 4,
                          shadowColor: isDark ? Colors.blue.shade800.withOpacity(0.5) : null,
                          color: isDark ? const Color(0xFF1E3A5C) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.blue.shade800 : Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.description,
                                color: isDark ? Colors.blue.shade200 : Colors.blue.shade600,
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
                                  'By: $uploadedBy',
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
                                  icon: Icons.summarize_outlined,
                                  tooltip: 'Generate Summary (AI)',
                                  onPressed: url == null ? null : () => _generateSummary(url, title),
                                  isDark: isDark,
                                  color: Colors.purple,
                                ),
                                _buildIconButton(
                                  icon: Icons.open_in_new,
                                  tooltip: 'Open',
                                  onPressed: url == null ? null : () => launchUrlString(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  ),
                                  isDark: isDark,
                                  color: Colors.green,
                                ),
                                _buildIconButton(
                                  icon: Icons.download,
                                  tooltip: 'Download',
                                  onPressed: url == null ? null : () {
                                    if (kIsWeb) {
                                      _downloadFileWeb(url, '$title.pdf');
                                    }
                                  },
                                  isDark: isDark,
                                  color: Colors.blue,
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

          // Right side: Gemini-styled summary panel
          if (_summaryTitle != null)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                      const Color(0xFF0F1B2D), // Dark blue-gray
                      const Color(0xFF1A365D), // Dark blue
                      const Color(0xFF2D3748), // Dark gray-blue
                    ]
                        : [
                      const Color(0xFFE8F0FE), // Light blue
                      const Color(0xFFF1F8FF), // Very light blue
                      Colors.white,
                    ],
                  ),
                  border: Border(
                    left: BorderSide(
                      color: isDark ? Colors.blue.shade800 : Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Gemini Header with animated icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.blue.shade700 : Colors.blue.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Animated Gemini Icon
                          Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(4),
                            child: Lottie.asset(
                              'assets/animations/Blue Gemini.json', // You'll need to add this file
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Gemini AI Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.blue.shade200 : Colors.blue.shade800,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.blue.shade200 : Colors.blue.shade600,
                            ),
                            onPressed: _closeSummary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Document title
                    Text(
                      _summaryTitle!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    // Loading indicator with Gemini styling
                    if (_loading)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated Gemini thinking animation
                              Container(
                                width: 80,
                                height: 80,
                                child: Lottie.asset(
                                  'assets/animations/Loading Dots Blue.json', // You'll need to add this file
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _loadingText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.blue.shade200 : Colors.blue.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? Colors.blue.shade300 : Colors.blue,
                                ),
                                strokeWidth: 2,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Summary content
                    if (!_loading && _summary != null)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withOpacity(0.2) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.blue.shade800 : Colors.blue.shade200,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Gemini response header
                                Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      color: isDark ? Colors.blue.shade300 : Colors.blue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'AI Summary',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.blue.shade300 : Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SelectableText(
                                  _summary!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: isDark ? Colors.white : Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Copy button with Gemini styling
                    if (!_loading && _summary != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade600,
                              Colors.purple.shade600,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _summary!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Summary copied to clipboard!'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.copy, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
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
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: isDark ? color.withOpacity(0.8) : color,
        tooltip: tooltip,
        onPressed: onPressed,
        iconSize: 20,
        padding: const EdgeInsets.all(6),
      ),
    );
  }
}