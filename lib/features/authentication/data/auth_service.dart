import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Sign up error: $e');
      return null;
    }
  }

  User? getCurrentUser(){
    return _auth.currentUser;
  }

  bool createBlankProfile(String email,String password) {
    Map<String, dynamic> blankProfile = {
      'id': getCurrentUser()?.uid,
      'admin': false,
      'business_owner':false,
      'email': email,
      'name': '',
      'username': email.substring(0, email.indexOf('@')),
      'profilePicture': '',
      'password': password,
    };

    final FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      db.collection('profiles').doc(getCurrentUser()?.uid).set(blankProfile);
    } catch (e) {
      throw Exception('Erro ao adicionar negócio: $e');
    }
    return true;
  }
}