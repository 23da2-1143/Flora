import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up and save user profile to Firestore
  static Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await credential.user?.updateDisplayName(name.trim());

      // Save user profile to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null; // no error
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    }
  }

  /// Sign in with email/password
  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // no error
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    }
  }

  /// Send password reset email
  static Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password. Please try again.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'invalid-email': return 'Please enter a valid email address.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      case 'too-many-requests': return 'Too many attempts. Please try again later.';
      default: return 'Something went wrong. Please try again.';
    }
  }
}
