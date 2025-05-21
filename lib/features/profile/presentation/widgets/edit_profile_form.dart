import 'package:flutter/material.dart';

class EditProfileForm extends StatefulWidget {
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
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  @override
  void initState() {
    super.initState();
    widget.usernameController.addListener(_update);
    widget.emailController.addListener(_update);
    widget.nameController.addListener(_update);
    widget.profileURLController.addListener(_update);
  }

  void _update() => setState(() {});



  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: widget.formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: widget.profileURLController.text.isNotEmpty
                        ? NetworkImage(widget.profileURLController.text)
                        : null,
                    child: widget.profileURLController.text.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  title: Text(widget.nameController.text.isNotEmpty
                        ? widget.nameController.text
                        : ''),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('@${widget.usernameController.text.isNotEmpty ? widget.usernameController.text : 'username'}'),
                        Text(widget.emailController.text.isNotEmpty ? widget.emailController.text : 'sem email'),
                      ],
                    ),
                  ),
                ),
                TextFormField(
                  controller: widget.usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator:
                      (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: widget.nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: widget.profileURLController,
                  decoration: const InputDecoration(
                    labelText: 'Profile picture URL',
                  ),
                ),
                TextFormField(
                  controller: widget.emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: widget.passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: widget.onSave, child: const Text('Save')),
              ],
            ),
        ),
      )

    );
  }
}

