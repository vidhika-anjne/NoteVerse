// lib/pages/upload_note_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _progress = 0.0;
    });

    final noteId = const Uuid().v4();

    try {
      final fileUrl = await _cloudinary.uploadFile(
        file: _pickedFile!,
        onProgress: (p) => setState(() => _progress = p),
      );

      if (fileUrl == null) throw Exception('Cloudinary upload failed');

      await _dbService.saveNoteMetadata(
        degreeId: widget.degreeId,
        branchId: widget.branchId,
        subjectId: widget.subjectId,
        noteId: noteId,
        title: title,
        downloadUrl: fileUrl,
        uploaderId: user.uid,
        fileSizeBytes: _pickedFile!.size,
        fileType: _pickedFile!.extension ?? 'file',
        tags: _tagsCtrl.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Upload successful')),
      );

      setState(() {
        _pickedFile = null;
        _titleCtrl.clear();
        _tagsCtrl.clear();
        _progress = 0.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
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
    final fileName = _pickedFile?.name ?? 'No file selected';

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Branch: ${widget.branchId} • Subject: ${widget.subjectId}'),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Choose file'),
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
                  Text('${(_progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _startUpload,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';


// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:uuid/uuid.dart';
// import '../services/database_service.dart';
//
// class UploadNotePage extends StatefulWidget {
//   // final String universityId;
//   final String degreeId;
//   final String branchId;
//   final String subjectId;
//
//   const UploadNotePage({
//     super.key,
//     // required this.universityId,
//     required this.degreeId,
//     required this.branchId,
//     required this.subjectId,
//   });
//
//   @override
//   State<UploadNotePage> createState() => _UploadNotePageState();
// }
//
// class _UploadNotePageState extends State<UploadNotePage> {
//   final _titleCtrl = TextEditingController();
//   final _tagsCtrl = TextEditingController();
//   PlatformFile? _pickedFile;
//   double _progress = 0.0;
//   bool _isUploading = false;
//
//   final DatabaseService _dbService = DatabaseService();
//
//   // ✅ Replace with your own Cloudinary info
//   final String cloudName = 'do1gabeqw';
//   final String uploadPreset = 'notes_upload';
//
//   Future<void> _pickFile() async {
//     final result = await FilePicker.platform.pickFiles(withData: true);
//     if (result == null) return;
//     setState(() {
//       _pickedFile = result.files.single;
//     });
//   }
//
//   Future<String?> _uploadToCloudinary(PlatformFile file) async {
//     final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');
//
//     final request = http.MultipartRequest('POST', uri)
//       ..fields['upload_preset'] = uploadPreset
//       ..files.add(
//         http.MultipartFile.fromBytes(
//           'file',
//           file.bytes!,
//           filename: file.name,
//         ),
//       );
//
//     final streamedResponse = await request.send();
//
//     final totalBytes = file.size.toDouble();
//     int bytesReceived = 0;
//     final responseBytes = <int>[];
//
//     await for (var chunk in streamedResponse.stream) {
//       responseBytes.addAll(chunk);
//       bytesReceived += chunk.length;
//       setState(() {
//         _progress = min(1.0, bytesReceived / totalBytes);
//       });
//     }
//
//     final responseBody = utf8.decode(responseBytes);
//
//     if (streamedResponse.statusCode == 200) {
//       final data = jsonDecode(responseBody);
//       print(data['secure_url']);
//       return data['secure_url'];
//     } else {
//       debugPrint('Upload failed: $responseBody');
//       return null;
//     }
//
//   }
//
//   Future<void> _startUpload() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please sign in first')),
//       );
//       return;
//     }
//
//     if (_pickedFile == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Pick a file first')),
//       );
//       return;
//     }
//
//     final title = _titleCtrl.text.trim();
//     if (title.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Enter a title')),
//       );
//       return;
//     }
//
//     setState(() {
//       _isUploading = true;
//       _progress = 0.0;
//     });
//
//     final noteId = const Uuid().v4();
//
//     try {
//       final fileUrl = await _uploadToCloudinary(_pickedFile!);
//       if (fileUrl == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Upload failed')),
//         );
//         setState(() => _isUploading = false);
//         return;
//       }
//
//       await _dbService.saveNoteMetadata(
//         // universityId: widget.universityId,
//         degreeId: widget.degreeId,
//         branchId: widget.branchId,
//         subjectId: widget.subjectId,
//         noteId: noteId,
//         title: title,
//         downloadUrl: fileUrl,
//         uploaderId: user.uid,
//         fileSizeBytes: _pickedFile!.size,
//         fileType: _pickedFile!.extension ?? 'file',
//         tags: _tagsCtrl.text
//             .split(',')
//             .map((s) => s.trim())
//             .where((s) => s.isNotEmpty)
//             .toList(),
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Upload successful')),
//       );
//
//       setState(() {
//         _pickedFile = null;
//         _titleCtrl.clear();
//         _tagsCtrl.clear();
//         _progress = 0.0;
//       });
//     } catch (e, st) {
//       debugPrint('Upload failed: $e\n$st');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload failed: $e')),
//       );
//     } finally {
//       setState(() => _isUploading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _tagsCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final fileName = _pickedFile?.name ?? 'No file selected';
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Upload Note')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text('Branch: ${widget.branchId} • Subject: ${widget.subjectId}'),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _titleCtrl,
//               decoration: const InputDecoration(labelText: 'Title'),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _tagsCtrl,
//               decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _pickFile,
//                   icon: const Icon(Icons.attach_file),
//                   label: const Text('Choose file'),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     fileName,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             if (_isUploading)
//               Column(
//                 children: [
//                   LinearProgressIndicator(value: _progress),
//                   const SizedBox(height: 8),
//                   Text('${(_progress * 100).toStringAsFixed(0)}%'),
//                 ],
//               ),
//             const Spacer(),
//             ElevatedButton.icon(
//               onPressed: _isUploading ? null : _startUpload,
//               icon: const Icon(Icons.cloud_upload),
//               label: const Text('Upload'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
