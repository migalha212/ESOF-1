import 'package:eco_finder/features/authentication/data/auth_service.dart';
import 'package:eco_finder/features/authentication/presentation/widgets/login_form.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  void _handleLogin(String email, String password) async {
    final user = await _authService.loginWithEmail(email, password);
    if (user != null) {
      // Navigate to the next screen
      Navigator.pop(context);
      Navigator.pushNamed(context, NavigationItems.navMap.route);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF3E8E4D),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoginForm(
                onSubmit: _handleLogin,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    NavigationItems.navRegister.route,
                  );
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
