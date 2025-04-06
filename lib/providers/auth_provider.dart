import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final password = prefs.getString('user_password');

    if (email != null && password != null) {
      try {
        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (userCredential.user != null) {
          _isLoggedIn = true;
          notifyListeners();
        }
      } catch (e) {
        _isLoggedIn = false;
        notifyListeners();
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        _isLoggedIn = true;

        // Save credentials in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_password', password);

        notifyListeners();
      }
    } catch (e) {
      _isLoggedIn = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _isLoggedIn = false;

      // Clear saved credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_password');

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}