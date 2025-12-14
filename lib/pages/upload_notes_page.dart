// lib/pages/upload_note_page.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/upload_provider.dart';

class UploadNotePage extends StatefulWidget {
  final String degreeId;
  final String branchId;
  final String subjectId;

  const UploadNotePage({
    super.key,
    required this.degreeId,
    required this.branchId,
    required this.subjectId,
  });

  @override
  State<UploadNotePage> createState() => _UploadNotePageState();
}

class _UploadNotePageState extends State<UploadNotePage> {
  final _titleCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  PlatformFile? _pickedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null) {
      setState(() => _pickedFile = result.files.single);
    }
  }

  Future<void> _startUpload() async {
    final auth = context.read<AuthProvider>();
    final user = auth.firebaseUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first')),
      );
      return;
    }

    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a file first')),
      );
      return;
    }

    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title')),
      );
      return;
    }

    final uploadProvider = context.read<UploadProvider>();
    final tags = _tagsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final success = await uploadProvider.uploadNote(
      userId: user.uid,
      degreeId: widget.degreeId,
      branchId: widget.branchId,
      subjectId: widget.subjectId,
      title: _titleCtrl.text.trim(),
      file: _pickedFile!,
      tags: tags,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Upload successful")),
      );

      setState(() {
        _pickedFile = null;
        _titleCtrl.clear();
        _tagsCtrl.clear();
      });
    } else {
      final message = uploadProvider.error ?? 'Upload failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadProvider = context.watch<UploadProvider>();
    final isUploading = uploadProvider.isUploading;
    final progress = uploadProvider.progress;
    final fileName = _pickedFile?.name ?? "No file selected";

    return Scaffold(
      appBar: AppBar(title: const Text("Upload Note")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Branch: ${widget.branchId} • Subject: ${widget.subjectId}"),
            const SizedBox(height: 12),

            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 8),
            TextField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(
                labelText: "Tags (comma separated)",
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Choose file"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            if (isUploading)
              Column(
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text("${(progress * 100).toStringAsFixed(0)}%"),
                ],
              ),

            const Spacer(),
            ElevatedButton.icon(
              onPressed: isUploading ? null : _startUpload,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
