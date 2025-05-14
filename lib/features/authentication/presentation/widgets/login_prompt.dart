import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';

class LoginPromptDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text(
            'You need to be logged in to access this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushNamed(context, NavigationItems.navLogin.route);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E8E4D),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
