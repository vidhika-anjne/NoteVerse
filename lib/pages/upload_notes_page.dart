// lib/pages/upload_note_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../services/cloudinary_service.dart';
import '../services/database_service.dart';

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

  double _progress = 0.0;
  bool _isUploading = false;

  final DatabaseService _dbService = DatabaseService();
  final CloudinaryService _cloudinary = CloudinaryService();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null) {
      setState(() => _pickedFile = result.files.single);
    }
  }

  Future<Map<String, dynamic>?> _getProfile(String uid) async {
    final snap =
    await FirebaseDatabase.instance.ref("users/$uid").get();

    if (!snap.exists) return null;
    return Map<String, dynamic>.from(snap.value as Map);
  }

  Future<void> _startUpload() async {
    final user = FirebaseAuth.instance.currentUser;

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

    // 🔥 Get uploader profile data
    final profile = await _getProfile(user.uid);

    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile not found')),
      );
      return;
    }

    final uploaderName = profile["name"] ?? "Unknown User";
    final uploaderPhoto = profile["photoUrl"] ?? "";

    setState(() {
      _isUploading = true;
      _progress = 0.0;
    });

    final noteId = const Uuid().v4();

    try {
      // Upload file to Cloudinary
      final fileUrl = await _cloudinary.uploadFile(
        file: _pickedFile!,
        onProgress: (p) => setState(() => _progress = p),
      );

      if (fileUrl == null) throw Exception("Cloudinary upload failed");

      // Save metadata in Firebase Database
      await _dbService.saveNoteMetadata(
        degreeId: widget.degreeId,
        branchId: widget.branchId,
        subjectId: widget.subjectId,
        noteId: noteId,
        title: _titleCtrl.text.trim(),
        downloadUrl: fileUrl,
        uploaderId: user.uid,
        uploaderName: uploaderName,
        uploaderPhoto: uploaderPhoto,
        fileSizeBytes: _pickedFile!.size,
        fileType: _pickedFile!.extension ?? "file",
        tags: _tagsCtrl.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Upload successful")),
      );

      setState(() {
        _pickedFile = null;
        _titleCtrl.clear();
        _tagsCtrl.clear();
        _progress = 0.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
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
            if (_isUploading)
              Column(
                children: [
                  LinearProgressIndicator(value: _progress),
                  const SizedBox(height: 8),
                  Text("${(_progress * 100).toStringAsFixed(0)}%"),
                ],
              ),

            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _startUpload,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
