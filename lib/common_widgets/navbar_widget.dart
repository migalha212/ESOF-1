import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;

  const NavBar({super.key, required this.selectedIndex});

  void _handleNavigation(BuildContext context, int index) {
    if (index == selectedIndex) return; // Already on this page
    if(selectedIndex != 2) {
    Navigator.pop(context);
    }
    switch (index) {
      case 0:
        Navigator.pushNamed(context, NavigationItems.navSearch.route);
        break;
      case 1:
        Navigator.pushNamed(context, NavigationItems.navNotifications.route);
        break;
      case 2:
        Navigator.pushNamed(context, NavigationItems.navMap.route);
        break;
      case 3:
        Navigator.pushNamed(context, NavigationItems.navAddBusiness.route);
        break;
      case 4:
        Navigator.pushNamed(context, NavigationItems.navLanding.route);
        break;
      default:
        break; // Handle other cases if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3E8E4D), // verde principal
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, -2), // sombra para cima
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.transparent, // já definido no container
          indicatorColor: Colors.white.withOpacity(0.2),
          height: 65, // altura reduzida (default é 80)
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(color: Colors.white, fontSize: 12),
          ),
          iconTheme: MaterialStateProperty.all(
            IconThemeData(color: Colors.white),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            _handleNavigation(context, index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Stores',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
