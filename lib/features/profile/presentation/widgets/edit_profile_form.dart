import 'package:flutter/material.dart';

class EditProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController nameController;
  final TextEditingController profileURLController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSave;

  const EditProfileForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.nameController,
    required this.profileURLController,
    required this.emailController,
    required this.passwordController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: profileURLController,
              decoration: const InputDecoration(
                labelText: 'Profile picture URL',
              ),
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onSave, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
