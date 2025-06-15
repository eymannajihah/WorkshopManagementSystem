import 'package:flutter/material.dart';
import 'inventory/view_inventory.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ViewInventoryPage()),
            );
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}
