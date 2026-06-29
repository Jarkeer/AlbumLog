import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
  bool _isGoogleInitialized = false;

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _auth.authStateChanges().listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      
      if (!_isGoogleInitialized) {
        await _googleSignIn.initialize(
          
          serverClientId: '699008715686-fqtrugli1dpl5qoskjc66qlijbvv0te5.apps.googleusercontent.com',
          clientId: '699008715686-fqtrugli1dpl5qoskjc66qlijbvv0te5.apps.googleusercontent.com', 
        );
        _isGoogleInitialized = true;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

    } catch (e) {
      debugPrint("Error en Google Sign-In: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}