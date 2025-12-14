import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import 'profile_setup_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

    if (profileProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.firebaseUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your profile')),
      );
    }

    final profileData = profileProvider.currentProfile;

    if (profileData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: const Center(
          child: Text("No profile found. Please complete setup."),
        ),
      );
    }

    final String name = profileData["name"] ?? "Unknown";
    final String email =
        profileData["email"] ?? auth.firebaseUser?.email ?? "No Email";
    final String role = profileData["role"] ?? "student";
    final String photoUrl = profileData["photoUrl"] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ---------------- Profile Photo ----------------
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
              photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 55)
                  : null,
            ),
            const SizedBox(height: 20),

            // ---------------- Name ----------------
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // ---------------- Email ----------------
            Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),

            const SizedBox(height: 20),

            // ---------------- Role Chip ----------------
            Chip(
              label: Text(role.toUpperCase()),
              backgroundColor: Colors.blue.shade100,
            ),

            const Spacer(),

            // ---------------- Edit Button ----------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final user = auth.firebaseUser;
                  if (user == null) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileSetupPage(userId: user.uid),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
