import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:notes_sharing/pages/profile_setup_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref("users/${user!.uid}");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      setState(() {
        profileData = Map<String, dynamic>.from(snapshot.value as Map);
        isLoading = false;
      });
    } else {
      setState(() {
        profileData = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profileData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: const Center(
          child: Text("No profile found. Please complete setup."),
        ),
      );
    }

    final String name = profileData!["name"] ?? "Unknown";
    final String email = profileData!["email"] ?? user!.email ?? "No Email";
    final String role = profileData!["role"] ?? "student";
    final String photoUrl = profileData!["photoUrl"] ?? "";

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
                  // Navigator.pushNamed(context, "/editProfile");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileSetupPage(userId: user!.uid),
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
