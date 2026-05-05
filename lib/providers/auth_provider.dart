import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '596014931235-jh17bl9lnk6e0s76ksmm9si32m0ohvcq.apps.googleusercontent.com',
  );
  User? _user;

  AuthProvider() {
    _authService.user.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<String?> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      // This is the most reliable way to login on the Web
      await _auth.signInWithPopup(googleProvider);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      return true;
    } catch (e) {
      print("Guest Login Error: $e");
      return false;
    }
  }





  Future<String?> signInWithGitHub() async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();
      await _auth.signInWithPopup(githubProvider);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signIn(String email, String password) async {
    return await _authService.signIn(email, password);
  }

  Future<String?> register(String email, String password) async {
    return await _authService.register(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
