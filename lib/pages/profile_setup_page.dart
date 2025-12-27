import 'dart:io';

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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    final username = _usernameCtrl.text.trim().toLowerCase();
    final linkedin = _linkedinCtrl.text.trim();
    final bio = _bioCtrl.text.trim();

    if (name.isEmpty || username.isEmpty || _role == null || _gender == null) {
      _showSnackBar('Please fill all required fields');
      return;
    }

    setState(() => _isSaving = true);

    final profileProvider = context.read<UserProfileProvider>();

    final error = await profileProvider.saveProfile(
      userId: widget.userId,
      name: name,
      username: username,
      role: _role!,
      gender: _gender!,
      linkedin: linkedin,
      bio: bio,
      pickedFile: _pickedFile,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (error != null) {
      _showSnackBar(error);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF000000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _linkedinCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;

    final double horizontalPadding = isMobile ? 20 : isTablet ? 80 : 200;
    final double maxFormWidth = isMobile ? double.infinity : 500;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isMobile ? 20 : 32),

                // Header
                Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: isMobile ? 26 : 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in your details to get started',
                  style: TextStyle(
                    color: const Color(0xFF666666),
                    fontSize: isMobile ? 14 : 15,
                  ),
                ),

                const SizedBox(height: 32),

                // Profile Setup Card
                Center(
                  child: Container(
                    width: maxFormWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E5E0), width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Profile Photo
                          Column(
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF9F9F9),
                                    border: Border.all(
                                      color: const Color(0xFFE5E5E0),
                                      width: 3,
                                    ),
                                  ),
                                  child: _pickedFile != null
                                      ? ClipOval(
                                    child: Image.file(
                                      File(_pickedFile!.path!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Color(0xFF999999),
                                        );
                                      },
                                    ),
                                  )
                                      : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 32,
                                        color: const Color(0xFF999999),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(
                                          color: const Color(0xFF999999),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Profile Picture',
                                style: TextStyle(
                                  color: const Color(0xFF666666),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Full Name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Full Name',
                                style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Enter your full name',
                                  hintStyle: const TextStyle(color: Color(0xFF999999)),
                                  filled: true,
                                  fillColor: const Color(0xFFF9F9F9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E5E0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E5E0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF000000)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Username
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Username',
                                style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _usernameCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Choose a unique username',
                                  hintStyle: const TextStyle(color: Color(0xFF999999)),
                                  filled: true,
                                  fillColor: const Color(0xFFF9F9F9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E5E0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E5E0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF000000)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Gender Dropdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gender',
                                style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE5E5E0)),
                                ),
                                child: DropdownButton<String>(
                                  value: _gender,
                                  hint: Text(
                                    'Select gender',
                                    style: TextStyle(
                                      color: const Color(0xFF999999),
                                      fontSize: 15,
                                    ),
                                  ),
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: const Color(0xFF666666),
                                  ),
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  menuMaxHeight: 200,
                                  items: [
                                    DropdownMenuItem(
                                      value: 'male',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text('Male'),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'female',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text('Female'),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'other',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text('Other'),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) => setState(() => _gender = val),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Role Dropdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Role',
                                style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE5E5E0)),
                                ),
                                child: DropdownButton<String>(
                                  value: _role,
                                  hint: Text(
                                    'Select your role',
                                    style: TextStyle(
                                      color: const Color(0xFF999999),
                                      fontSize: 15,
                                    ),
                                  ),
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: const Color(0xFF666666),
                                  ),
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  menuMaxHeight: 200,
                                  items: [
                                    DropdownMenuItem(
                                      value: 'student',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text('Student'),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'teacher',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text('Teacher'),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) => setState(() => _role = val),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // LinkedIn URL
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'LinkedIn URL (Optional)',
                                style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _linkedinCtrl,
                                decoration: InputDecoration(
                                  hintText: 'https://linkedin.com/in/yourprofile',
                                  hintStyle: const TextStyle(color: Color(0xFF999999)),
                                  filled: true,
                                  fillColor: const Color(0xFFF9F9F9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E5E0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E5E0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF000000)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Bio
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bio (Optional)',
                                style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _bioCtrl,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Tell us about yourself...',
                                  hintStyle: const TextStyle(color: Color(0xFF999999)),
                                  filled: true,
                                  fillColor: const Color(0xFFF9F9F9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E5E0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E5E0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF000000)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF000000),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSaving
                                  ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Saving...',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.save, size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                    'Save & Continue',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isMobile ? 20 : 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}