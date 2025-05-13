import 'package:eco_finder/features/authentication/data/auth_service.dart';
import 'package:eco_finder/features/authentication/presentation/widgets/signup_form.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleSignUp(String email, String password) async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signUpWithEmail(email, password);
      if (user != null) {
        Navigator.pop(context);
        Navigator.pushNamed(context, NavigationItems.navMap.route);
      } else {
        _showError('Sign up failed. Please try again.');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: const Color(0xFF3E8E4D),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SignUpForm(
                onSubmit: _handleSignUp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    NavigationItems.navLogin.route,
                  );
                },
                child: const Text(
                  'Already have an account? Log In',
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
