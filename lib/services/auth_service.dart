import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static User? get currentUser =>
      _auth.currentUser;

  static Stream<User?>
      get authStateChanges =>
          _auth.authStateChanges();

  static Future<String?> register({

    required String email,

    required String password,

  }) async {

    try {

      await _auth
          .createUserWithEmailAndPassword(

        email: email,

        password: password,
      );

      return null;

    } on FirebaseAuthException catch (e) {

      return e.message;
    }
  }

  static Future<String?> login({

    required String email,

    required String password,

  }) async {

    try {

      await _auth
          .signInWithEmailAndPassword(

        email: email,

        password: password,
      );

      return null;

    } on FirebaseAuthException catch (e) {

      return e.message;
    }
  }

  // =========================
  // RESET PASSWORD
  // =========================

  static Future<String?> resetPassword(
    String email,
  ) async {

    try {

      await _auth
          .sendPasswordResetEmail(
        email: email,
      );

      return null;

    } on FirebaseAuthException catch (e) {

      return e.message;
    }
  }

  static Future<void> logout()
      async {

    await _auth.signOut();
  }
}