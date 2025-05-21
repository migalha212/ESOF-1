import 'package:eco_finder/features/authentication/data/auth_service.dart';
import 'package:eco_finder/features/authentication/presentation/pages/signup_page.dart';
import 'package:eco_finder/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> _userBusinesses = [];
  final int _index = 4;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = _auth.getCurrentUser();
    final args = ModalRoute.of(context)?.settings.arguments;

    String? load;

    if (args is String) {
      load = args;
    } else if (user != null) {
      load = user.uid;
    }

    if (load != null) {
      final info =
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(load)
              .get();

      if (info.exists) {
        setState(() {
          _userData = info.data()!;
        });

        if (info['business_owner'] == true) {
          await _loadUserBusinesses(load);
        }
      }
    } else {
      MaterialPageRoute(builder: (context) => const SignUpPage());
    }
  }

  Future<void> _loadUserBusinesses(String uid) async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('businesses')
            .where('uid', isEqualTo: uid)
            .get();

    setState(() {
      _userBusinesses = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  void _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pop(context);
    Navigator.pushNamed(context, NavigationItems.navMap.route);
  }

  void _editProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = _auth.getCurrentUser();

    final profileUrl = _userData!['profileURL'];
    final imageProvider =
        (profileUrl != null && profileUrl.isNotEmpty)
            ? NetworkImage(profileUrl)
            : const NetworkImage(
              'https://i.pinimg.com/736x/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg',
            );

    return Scaffold(
      bottomNavigationBar: NavBar(selectedIndex: _index),
      appBar: AppBar(
        title: const Text('Profile'),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF3E8E4D),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
        ),
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
                    radius: 80,
                    backgroundImage: imageProvider,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_userData!['name'] != null &&
                          _userData!['name'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            _userData!['name'],
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (_userData!['business_owner'] == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            "Business Owner",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E8E4D),
                            ),
                          ),
                        ),
                      Text(
                        "@${_userData!['username']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _userData!['email'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_userData!['business_owner'] == true)
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 8),
              child: Text(
                (_userData!['id'] == _auth.getCurrentUser()!.uid)
                    ? "My Businesses"
                    : "${_userData!['name'] ?? _userData!['username']}'s Businesses",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          if (_userBusinesses.isEmpty)
            const Text("Ainda não tens lojas registadas."),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: _userBusinesses.length,
              itemBuilder: (context, index) {
                final business = _userBusinesses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      business['name'] ?? 'Negócio sem nome',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(business['description'] ?? '', maxLines: 3),
                    trailing: Icon(Icons.energy_savings_leaf),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
          _userData!['id'] == user!.uid
              ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: "editBtn",
                    onPressed: () => _editProfile(context),
                    backgroundColor: const Color(0xFF3E8E4D),
                    tooltip: "Edit Profile",
                    child: const Icon(Icons.edit),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: "businessBtn",
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        NavigationItems.navAddBusiness.route,
                      );
                    },
                    backgroundColor: const Color(0xFF3E8E4D),
                    tooltip: "Add Business",
                    child: const Icon(Icons.store),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: "eventBtn",
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        NavigationItems.navAddEvent.route,
                      );
                    },
                    backgroundColor: const Color(0xFF3E8E4D),
                    tooltip: "Add Event",
                    child: const Icon(Icons.event),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: "logoutBtn",
                    onPressed: () => _logout(context),
                    backgroundColor: Colors.red,
                    tooltip: "Logout",
                    child: const Icon(Icons.logout),
                  ),
                ],
              )
              : null,
    );
  }
}
