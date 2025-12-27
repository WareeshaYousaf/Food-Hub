import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthState {
  static User? get user => FirebaseAuth.instance.currentUser;

  static bool get isLoggedIn => user != null;

  static String? get uid => user?.uid;

  static bool isLoggedInn = false;

  static String? userEmail;
  static String? userId;

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// LOGIN
  static Future<void> login(String email, String password) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    isLoggedInn = true;
    userEmail = credential.user!.email;
    userId = credential.user!.uid;
  }

  /// SIGN UP + SAVE DATA
  /// Signs up the user and saves profile in Firestore.
  /// Returns true if Firestore write succeeded, false if it failed due to permissions.
  static Future<bool> signup(String email, String password, String name) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    userId = credential.user!.uid;
    userEmail = credential.user!.email;
    isLoggedInn = true;

    // update FirebaseAuth displayName so profile can show it even if Firestore write fails
    await credential.user!.updateDisplayName(name);

    // Save user data in Firestore
    try {
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } on FirebaseException catch (e) {
      // permission-denied or other Firestore errors
      if (e.code == 'permission-denied') {
        // Log it and return false so UI can show a helpful message
        print('Firestore write denied: ${e.message}');
        return false;
      }
      rethrow;
    }
  }

  /// LOGOUT
  static Future<void> logout() async {
    await _auth.signOut();
    isLoggedInn = false;
    userEmail = null;
    userId = null;
  }
}
