import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _initialized = false;

  User? get user => _user;
  bool get initialized => _initialized;
  bool get isEmailVerified => _user?.emailVerified == true;

  Future<void> initializeAuth() async {
    try {
      _user = _auth.currentUser;
      _initialized = true;
      notifyListeners();

      _auth.authStateChanges().listen((user) async {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('❌ [FIREBASE AUTH] initializeAuth error: $e');
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.sendEmailVerification();
      await cred.user?.reload();
      _user = _auth.currentUser;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = _auth.currentUser;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    final u = _auth.currentUser;
    if (u != null && !u.emailVerified) {
      await u.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    final u = _auth.currentUser;
    if (u != null) {
      await u.reload();
      _user = _auth.currentUser;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Exception _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception('Please enter a valid email address.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'user-not-found':
      case 'wrong-password':
        return Exception('Invalid email or password. Please try again.');
      case 'email-already-in-use':
        return Exception('An account with this email already exists.');
      case 'weak-password':
        return Exception('Password must be at least 6 characters long.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      default:
        return Exception(e.message ?? 'Authentication error.');
    }
  }
}
