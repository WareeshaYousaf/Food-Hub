import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static bool get isLoggedIn => _auth.currentUser != null;

  static Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
