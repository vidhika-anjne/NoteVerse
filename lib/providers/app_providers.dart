import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'notes_provider.dart';
import 'upload_provider.dart';
import 'user_profile_provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<NotesProvider>(
          create: (_) => NotesProvider(),
        ),
        ChangeNotifierProvider<UploadProvider>(
          create: (_) => UploadProvider(),
        ),
        ChangeNotifierProvider<UserProfileProvider>(
          create: (_) => UserProfileProvider(),
        ),
        // Other providers (ThemeProvider, UserProfileProvider, NotesProvider, UploadProvider)
        // will be added here as we refactor the rest of the app.
      ],
      child: child,
    );
  }
}

