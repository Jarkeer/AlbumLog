import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  AuthViewModel() {
    
    _user = _auth.currentUser;
    
    _auth.authStateChanges().listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Inicialización de Google Sign-In
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
        return; // El usuario canceló el inicio de sesión
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      
      await _auth.signInWithCredential(credential);

      // Crear o actualizar el perfil público en Cloud Firestore
      if (_auth.currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .set({
          'uid': _auth.currentUser!.uid,
          'displayName': _auth.currentUser!.displayName ?? 'Usuario de AlbumLog',
          'photoURL': _auth.currentUser!.photoURL ?? '',
          'email': _auth.currentUser!.email ?? '', 
          'lastSeen': FieldValue.serverTimestamp(), 
        }, SetOptions(merge: true)); 
      }

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