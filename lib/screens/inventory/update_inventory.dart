import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/inventory.dart';
import '../../providers/inventory_provider.dart';

class UpdateInventoryPage extends StatefulWidget {
  final Inventory itemToUpdate;

  const UpdateInventoryPage({super.key, required this.itemToUpdate});

  @override
  State<UpdateInventoryPage> createState() => _UpdateInventoryPageState();
}

class _UpdateInventoryPageState extends State<UpdateInventoryPage> {
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController priceController;
  bool isLoading = false;
  bool showDeleteConfirmation = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.itemToUpdate.name);
    quantityController = TextEditingController(
      text: widget.itemToUpdate.quantity.toString(),
    );
    priceController = TextEditingController(
      text: widget.itemToUpdate.price.toString(),
    );
  }

  Future<void> onSave() async {
    setState(() {
      isLoading = true;
    });

    String name = nameController.text.trim();
    int quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    double price = double.tryParse(priceController.text.trim()) ?? 0.0;

    if (name.isNotEmpty && quantity > 0) {
      widget.itemToUpdate.name = name;
      widget.itemToUpdate.quantity = quantity;
      widget.itemToUpdate.price = price;

      bool success = await Provider.of<InventoryProvider>(
        context,
        listen: false,
      ).updateInventory(widget.itemToUpdate);

      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Update failed')));
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

  Future<void> onConfirmDelete() async {
    setState(() {
      isLoading = true;
    });

    bool success = await Provider.of<InventoryProvider>(
      context,
      listen: false,
    ).deleteInventory(widget.itemToUpdate);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Delete failed')));
    }

    setState(() {
      isLoading = false;
      showDeleteConfirmation = false;
    });
  }

  void onDelete() {
    setState(() {
      showDeleteConfirmation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Inventory")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: "Quantity"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: "Price"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: onSave,
                      child: const Text("Save"),
                    ),
                    TextButton(
                      onPressed: onDelete,
                      child: const Text("Delete"),
                    ),
                    if (showDeleteConfirmation)
                      AlertDialog(
                        title: const Text("Confirm Deletion"),
                        content: const Text(
                          "Are you sure you want to delete this item?",
                        ),
                        actions: [
                          TextButton(
                            onPressed:
                                () => setState(
                                  () => showDeleteConfirmation = false,
                                ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: onConfirmDelete,
                            child: const Text("Confirm"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }
}
