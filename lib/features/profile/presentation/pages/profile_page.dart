import 'package:eco_finder/features/authentication/data/auth_service.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pop(context);
    Navigator.pushNamed(context, NavigationItems.navMap.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF3E8E4D),
      ),
      body: Center(
        child: ElevatedButton(
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
      ),
    );
  }
}
