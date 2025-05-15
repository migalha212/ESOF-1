import 'package:eco_finder/features/authentication/data/auth_service.dart';
import 'package:eco_finder/features/authentication/presentation/pages/signup_page.dart';
import 'package:eco_finder/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';
import 'package:eco_finder/features/profile/presentation/widgets/edit_profile_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/common_widgets/navbar_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _auth = AuthService();
  Map<String, dynamic>? _userData;
  final int _index = 4;

  @override
  void initState(){
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = _auth.getCurrentUser();

    if (user != null) {
      final info = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

    if (info.exists) {
      setState(() {
        _userData = info.data()!;
      });
      }
    }
    else {
      MaterialPageRoute(builder: (context) => const SignUpPage()
      );
    }
  }

  void _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pop(context);
    Navigator.pushNamed(context, NavigationItems.navMap.route);
  }

  void _editProfile(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final profileUrl = _userData!['profileURL'];
    final imageProvider = (profileUrl != null && profileUrl.isNotEmpty)
        ? NetworkImage(profileUrl)
        : const NetworkImage('https://i.pinimg.com/736x/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg');

    return Scaffold(
    bottomNavigationBar: NavBar(selectedIndex: _index),
    appBar: AppBar(
      title: const Text('Profile'),
      backgroundColor: const Color(0xFF3E8E4D),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFF3E8E4D), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: imageProvider,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_userData!['name'] != null && _userData!['name'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          _userData!['name'],
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (_userData!['business_owner'] == true)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          "Business Owner",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E8E4D)),
                        ),
                      ),
                    Text(
                      "@${_userData!['username']}${
                          _userData!['admin'] == true ? ' (ADMIN)' : ''}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _userData!['email'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ]
            ),
          ),
      ElevatedButton(
        onPressed: () => _editProfile(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        ),
        child: const Text(
          'Editar Perfil',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () => _logout(context),
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          ),
          child: const Text(
          'Logout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
  }
}
