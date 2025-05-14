import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserProfile{
  final String username;
  final String name;
  final String email;
  final String password;
  final String profileURL;
  final bool admin;
  final bool owner;

  UserProfile({
    required this.username,
    this.name = "",
    this.profileURL = "https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg",
    required this.email,
    required this.password,
    this.admin = false,
    this.owner = false
  });

  Map<String, dynamic> toMap(){
    return{
      'username': username,
      'name': name,
      'email': email,
      'password': password,
      'profileURL': profileURL,
      'admin': admin,
      'business_owner': owner
    };
  }
}