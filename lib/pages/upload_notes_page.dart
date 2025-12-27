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
        const SnackBar(
          content: Text('Please sign in first'),
          backgroundColor: Color(0xFF000000),
        ),
      );
      return;
    }

    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick a file first'),
          backgroundColor: Color(0xFF000000),
        ),
      );
      return;
    }

    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a title'),
          backgroundColor: Color(0xFF000000),
        ),
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
        const SnackBar(
          content: Text("✅ Upload successful"),
          backgroundColor: Colors.white,
        ),
      );

      setState(() {
        _pickedFile = null;
        _titleCtrl.clear();
        _tagsCtrl.clear();
      });
    } else {
      final message = uploadProvider.error ?? 'Upload failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF000000),
        ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000000)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Upload Note",
          style: TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E5E0),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 120,
            vertical: isMobile ? 24 : 48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              const Text(
                'Share Your Knowledge',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload notes to help your peers succeed',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 32),

              // Course Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E5E0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF000000),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Uploading to:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.branchId} • ${widget.subjectId}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Form Section
              const Text(
                'Note Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 20),

              // Title Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Title *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF000000),
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g., Data Structures - Lecture 5 Notes',
                      hintStyle: TextStyle(
                        color: const Color(0xFF999999),
                        fontSize: 15,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E5E0),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E5E0),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF000000),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Tags Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tags (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tagsCtrl,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF000000),
                    ),
                    decoration: InputDecoration(
                      hintText: 'algorithms, sorting, trees (comma separated)',
                      hintStyle: TextStyle(
                        color: const Color(0xFF999999),
                        fontSize: 15,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E5E0),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E5E0),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF000000),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // File Upload Section
              const Text(
                'Upload File',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 20),

              // File Picker
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: _pickedFile != null
                        ? const Color(0xFFF5F5F0)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _pickedFile != null
                          ? const Color(0xFF000000)
                          : const Color(0xFFE5E5E0),
                      width: _pickedFile != null ? 2 : 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _pickedFile != null
                              ? const Color(0xFF000000)
                              : const Color(0xFFF5F5F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _pickedFile != null
                              ? Icons.check_circle
                              : Icons.cloud_upload_outlined,
                          color: _pickedFile != null
                              ? Colors.white
                              : const Color(0xFF666666),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _pickedFile != null
                            ? _pickedFile!.name
                            : 'Click to choose file',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _pickedFile != null
                              ? const Color(0xFF000000)
                              : const Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _pickedFile != null
                            ? 'Click to change file'
                            : 'PDF, DOC, DOCX, TXT (Max 10MB)',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF999999),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              if (isUploading) ...[
                const SizedBox(height: 24),
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFE5E5E0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF000000),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Uploading...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 48),

              // Upload Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isUploading ? null : _startUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000000),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE5E5E0),
                    disabledForegroundColor: const Color(0xFF999999),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isUploading ? Icons.hourglass_empty : Icons.upload,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isUploading ? 'Uploading...' : 'Upload Note',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF666666),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}