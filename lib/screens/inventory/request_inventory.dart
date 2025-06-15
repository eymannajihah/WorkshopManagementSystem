import 'package:flutter/material.dart';

class RequestInventoryPage extends StatelessWidget {
  const RequestInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Inventory")),
      body: const Center(child: Text("This is the Request Inventory Page")),
    );
  }
}
