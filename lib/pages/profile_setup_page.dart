import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../services/cloudinary_service.dart'; // for uploading image
import 'branch_subject_selection_page.dart';

class ProfileSetupPage extends StatefulWidget {
  final String userId;
  const ProfileSetupPage({super.key, required this.userId});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nameCtrl = TextEditingController();
  String? _role; // student or teacher
  PlatformFile? _pickedFile;
  bool _isSaving = false;

  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final CloudinaryService _cloudinary = CloudinaryService(); // we’ll define next

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _pickedFile = result.files.single);
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _role == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isSaving = true);

    String? photoUrl;
    if (_pickedFile != null) {
      photoUrl = await _cloudinary.uploadImage(file : _pickedFile!);
    }

    final user = FirebaseAuth.instance.currentUser!;
    await _usersRef.child(widget.userId).set({
      'name': name,
      'email': user.email,
      'role': _role,
      'photoUrl': photoUrl ?? '',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });

    setState(() => _isSaving = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BranchSubjectSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _pickedFile != null
                      ? MemoryImage(_pickedFile!.bytes!)
                      : null,
                  child: _pickedFile == null
                      ? const Icon(Icons.add_a_photo, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                ],
                onChanged: (val) => setState(() => _role = val),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: _isSaving
                    ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save & Continue'),
                onPressed: _isSaving ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
