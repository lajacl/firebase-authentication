import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream to listen to authentication state changes
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges();
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication errors
      debugPrint(e.message);
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // Sign out
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
