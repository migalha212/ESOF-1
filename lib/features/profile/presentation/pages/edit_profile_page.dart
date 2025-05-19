import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/features/authentication/data/auth_service.dart';
import 'package:eco_finder/features/profile/model/profile.dart';
import 'package:eco_finder/features/profile/presentation/widgets/edit_profile_form.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _profileURLController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = _auth.getCurrentUser();

    if (user != null){
      final info = await FirebaseFirestore.instance.collection('profiles').doc(user.uid).get();
      if (info.exists){
        final data = info.data()!;
        _usernameController.text = data['username'] ?? '';
        _nameController.text = data['name'] ?? '';
        _profileURLController.text = data['profileURL'] ?? '';
        _emailController.text = data['email'];
        _passwordController.text = data['password'];

      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.getCurrentUser();
    if (user == null) return;

    final info = await FirebaseFirestore.instance.collection('profiles').doc(user.uid).get();

    try {
      final profile = UserProfile(
        username: _usernameController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        profileURL: _profileURLController.text.trim(),
        owner: info.data()?['business_owner'],
        admin: info.data()?['admin']
      );
      await FirebaseFirestore.instance.
        collection('profiles').
        doc(user.uid).
        set(profile.toMap(), SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile Updated')),
      );

      Navigator.pushNamed(
          context,
          NavigationItems.navProfile.route,
      );
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error! Could not update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EditProfileForm(
          formKey: _formKey,
          usernameController: _usernameController,
          nameController: _nameController,
          profileURLController: _profileURLController,
          emailController: _emailController,
          passwordController: _passwordController,
          onSave: _saveProfile,
        ),
      ),
    );
  }
}

