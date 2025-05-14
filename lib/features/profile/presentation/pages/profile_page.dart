import 'package:eco_finder/features/authentication/data/auth_service.dart';
import 'package:eco_finder/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';
import 'package:eco_finder/features/profile/presentation/widgets/edit_profile_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _auth = AuthService();
  Map<String, dynamic>? _userData;

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
    if (_userData == null){
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(),
      )
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Profile'),
      backgroundColor: const Color(0xFF3E8E4D),
      ),
      body: Column(
        children: [
        Container(
          width: double.infinity,
          height: 250.0,
          decoration: BoxDecoration(
            image: DecorationImage(
            image: NetworkImage(
            _userData!['profileURL'] ?? 'https://via.placeholder.com/150'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        _userData!['username'] ?? 'Sem username',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      Text(
        _userData!['email'] ?? 'Sem email',
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 24),
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
