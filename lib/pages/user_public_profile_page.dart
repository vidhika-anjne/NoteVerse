import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserPublicProfilePage extends StatefulWidget {
  final String userId;
  const UserPublicProfilePage({super.key, required this.userId});

  @override
  State<UserPublicProfilePage> createState() => _UserPublicProfilePageState();
}

class _UserPublicProfilePageState extends State<UserPublicProfilePage> {
  Map<String, dynamic>? userData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final ref = FirebaseDatabase.instance.ref("users/${widget.userId}");
    final snap = await ref.get();

    if (snap.exists) {
      setState(() {
        userData = Map<String, dynamic>.from(snap.value as Map);
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: const Center(child: Text("User not found")),
      );
    }

    final name = userData!["name"] ?? "Unknown";
    final username = userData!["username"] ?? "user";
    final role = userData!["role"] ?? "student";
    final bio = userData!["bio"] ?? "No bio added";
    final gender = userData!["gender"] ?? "Not specified";
    final photoUrl = userData!["photoUrl"] ?? "";
    final rating = (userData!["rating"] ?? 0).toDouble();
    final uploads = userData!["uploads"] ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text("@$username")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child:
              photoUrl.isEmpty ? const Icon(Icons.person, size: 60) : null,
            ),
            const SizedBox(height: 15),

            Text(name,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            Chip(
              label: Text(role.toUpperCase()),
              backgroundColor: Colors.blue.shade100,
            ),

            const SizedBox(height: 20),

            Text(bio,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.grey)),

            const SizedBox(height: 20),

            // ⭐ Rating & uploads
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber.shade600),
                const SizedBox(width: 4),
                Text("$rating / 5.0",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 20),
                Text("Uploads: $uploads",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),

            const SizedBox(height: 30),

            const Text("Uploaded Notes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            const Text("Coming soon...",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
