import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _authService.userChanges.listen((user) {
      _firebaseUser = user;
      notifyListeners();
    });
  }

  User? _firebaseUser;
  User? get firebaseUser => _firebaseUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<User?> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final user = await _authService.signIn(email, password);
      if (user == null) {
        _error = 'Login failed. Please check your credentials.';
      } else {
        _error = null;
      }
      return user;
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> signUp(String email, String password) async {
    _setLoading(true);
    try {
      final user = await _authService.signUp(email, password);
      if (user == null) {
        _error = 'Signup failed. Please try again.';
      } else {
        _error = null;
      }
      return user;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _error = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}

