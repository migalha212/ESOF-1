import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  // This class will handle authentication logic
  bool isAuthenticated = false;
  String? userId;

  AuthService() {
    // Initialize Firebase Auth
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        isAuthenticated = true;
        userId = user.uid;
      } else {
        isAuthenticated = false;
        userId = null;
      }
    });
  }

  bool isLoggedIn() {
    return isAuthenticated;
  }
}