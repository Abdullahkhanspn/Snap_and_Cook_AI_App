import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthService {
  Stream<User?> get authStateChanges;
  Future<UserCredential> signIn(String email, String password);
  Future<UserCredential> signUp(String email, String password, String name);
  Future<UserCredential> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  User? get currentUser;
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signUp(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google Sign-In was cancelled.';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}

class MockAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  
  @override
  Stream<User?> get authStateChanges async* {
    yield null;
    yield* _controller.stream;
  }

  @override
  User? get currentUser => null;

  @override
  Future<UserCredential> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockCredential();
  }

  @override
  Future<UserCredential> signUp(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockCredential();
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockCredential();
  }

  @override
  Future<void> signOut() async {
    _controller.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<UserCredential> _mockCredential() async {
    // This is just a placeholder as UserCredential cannot be easily instantiated
    throw UnimplementedError('Mock user credential not fully implemented');
  }
}
