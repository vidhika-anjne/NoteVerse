import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes_sharing/pages/branch_subject_selection_page.dart';
import 'package:notes_sharing/pages/notes_list_page.dart';
import 'firebase_options.dart'; // auto-generated from flutterfire configure
import 'auth/login_page.dart'; // we’ll make this next

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: BranchSubjectSelectionPage(),
      home: LoginPage()
    );
  }
}
