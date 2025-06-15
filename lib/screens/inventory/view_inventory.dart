import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import 'add_inventory.dart';
import 'update_inventory.dart';

class ViewInventoryPage extends StatefulWidget {
  const ViewInventoryPage({super.key});

  @override
  State<ViewInventoryPage> createState() => _ViewInventoryPageState();
}

class _ViewInventoryPageState extends State<ViewInventoryPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final inventoryList = Provider.of<InventoryProvider>(context).inventoryList;
    final filteredList =
        inventoryList
            .where(
              (item) =>
                  item.name.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("View Inventory")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(labelText: "Search"),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    "Qty: ${item.quantity} | Price: RM${item.price}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => UpdateInventoryPage(itemToUpdate: item),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddInventoryPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
