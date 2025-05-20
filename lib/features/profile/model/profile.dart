import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserProfile{
  final String id;
  final String username;
  final String name;
  final String email;
  final String password;
  final String profileURL;
  final bool admin;
  final bool owner;

  UserProfile({
    required this.id,
    required this.username,
    this.name = "",
    this.profileURL = "",
    required this.email,
    required this.password,
    this.admin = false,
    this.owner = false
  });

  Map<String, dynamic> toMap(){
    return{
      'id': id,
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