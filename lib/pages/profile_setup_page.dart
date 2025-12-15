import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../providers/user_profile_provider.dart';
import 'main_screen.dart';

class ProfileSetupPage extends StatefulWidget {
  final String userId;
  const ProfileSetupPage({super.key, required this.userId});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  String? _role; // student / teacher
  String? _gender; // male / female / other
  PlatformFile? _pickedFile;

  bool _isSaving = false;

  // ------------------------------ PICK IMAGE ------------------------------
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null) {
      setState(() => _pickedFile = result.files.single);
    }
  }

  // ------------------------------ SAVE PROFILE ------------------------------
  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    final username = _usernameCtrl.text.trim().toLowerCase();
    final linkedin = _linkedinCtrl.text.trim();
    final bio = _bioCtrl.text.trim();

    if (name.isEmpty || username.isEmpty || _role == null || _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final profileProvider = context.read<UserProfileProvider>();

    final error = await profileProvider.saveProfile(
      userId: widget.userId,
      name: name,
      username: username,
      role: _role,
      gender: _gender,
      linkedin: linkedin,
      bio: bio,
      pickedFile: _pickedFile,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  // ------------------------------ UI ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // -------- Profile Photo --------
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage:
                  _pickedFile != null ? MemoryImage(_pickedFile!.bytes!) : null,
                  child:
                  _pickedFile == null ? const Icon(Icons.add_a_photo, size: 40) : null,
                ),
              ),

              const SizedBox(height: 20),

              // -------- Full Name --------
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 15),

              // -------- Username --------
              TextField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(labelText: 'Username (unique)'),
              ),
              const SizedBox(height: 15),

              // -------- Gender --------
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender'),
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (val) => setState(() => _gender = val),
              ),
              const SizedBox(height: 15),

              // -------- Role --------
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                ],
                onChanged: (val) => setState(() => _role = val),
              ),
              const SizedBox(height: 15),

              // -------- LinkedIn --------
              TextField(
                controller: _linkedinCtrl,
                decoration: const InputDecoration(labelText: 'LinkedIn URL'),
              ),
              const SizedBox(height: 15),

              // -------- Bio --------
              TextField(
                controller: _bioCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 25),

              // -------- SAVE BUTTON --------
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Save & Continue"),
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}