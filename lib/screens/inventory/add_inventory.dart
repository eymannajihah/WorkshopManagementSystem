import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/inventory.dart';
import '../../providers/inventory_provider.dart';
import 'view_inventory.dart';
import 'inventory_dashboard.dart';

class AddInventoryPage extends StatefulWidget {
  const AddInventoryPage({super.key});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController orderDateController = TextEditingController();
  bool isLoading = false;

  Future<void> onSubmit() async {
    setState(() {
      isLoading = true;
    });

    String name = nameController.text.trim();
    int quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    double price = double.tryParse(priceController.text.trim()) ?? 0.0;
    String description = descriptionController.text.trim();
    String orderDate = orderDateController.text.trim();

    if (name.isNotEmpty && quantity > 0) {
      Inventory itemToAdd = Inventory(
        name: name,
        quantity: quantity,
        price: price,
        description: description,
        orderDate: orderDate,
      );

      bool success = await Provider.of<InventoryProvider>(
        context,
        listen: false,
      ).addInventory(itemToAdd);

      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add inventory')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in valid name and quantity')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void onClear() {
    nameController.clear();
    quantityController.clear();
    priceController.clear();
    descriptionController.clear();
    orderDateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Inventory"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ViewInventoryPage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const InventoryDashboard()),
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Item Name",
                        ),
                      ),
                      TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: "Quantity",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: "Description",
                        ),
                      ),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: "Selling Price",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: orderDateController,
                        decoration: const InputDecoration(
                          labelText: "Order Date (YYYY-MM-DD)",
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: onSubmit,
                        child: const Text("Submit"),
                      ),
                      TextButton(
                        onPressed: onClear,
                        child: const Text("Clear"),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
