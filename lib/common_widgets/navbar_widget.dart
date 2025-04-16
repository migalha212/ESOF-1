import 'package:eco_finder/pages/navigation_items.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;

  const NavBar({super.key, required this.selectedIndex});

  void _handleNavigation(BuildContext context, int index) {
    if (index == selectedIndex) return; // Already on this page

    switch (index) {
      case 0:
        Navigator.pushNamed(context, NavigationItems.navSearch.route);
        break;
      case 1:
        Navigator.pushNamed(context, NavigationItems.navLanding.route);
        break;
      case 2:
        Navigator.pushNamed(context, NavigationItems.navMap.route);
        break;
      case 3:
        Navigator.pushNamed(context, NavigationItems.navAddBusiness.route);
        break;
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
