import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  

  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, NavigationItems.navSearch.route);
      },
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF3E8E4D),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.manage_search, color: Colors.white, size: 30),
            SizedBox(width: 8),
            Text(
              'Search Stores',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
