import 'package:flutter/material.dart';
import 'package:EcoFinder/pages/landing_page.dart';
import 'package:EcoFinder/pages/search_page.dart';
import 'package:EcoFinder/pages/map_page.dart';
import 'package:EcoFinder/pages/add_bussiness.dart';
import 'package:EcoFinder/pages/work_in_progress.dart';


class NavBar extends StatelessWidget {
  final int selectedIndex;

  const NavBar({
    super.key,
    required this.selectedIndex,
  });

  void _handleNavigation(BuildContext context, int index) {
    if (index == selectedIndex) return; // Already on this page

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WorkInProgressPage(index: 1,)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WorkInProgressPage(index: 3,)),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WorkInProgressPage(index: 4)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (int index) {
        _handleNavigation(context, index);
      },
      indicatorColor: Colors.amber,
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Stores',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          label: '',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_outlined),
          label: 'Map',
        ),
        NavigationDestination(icon: Icon(Icons.favorite_outline), label: ''),
        NavigationDestination(icon: Icon(Icons.person_outline), label: ''),
      ],
    );
  }
}
