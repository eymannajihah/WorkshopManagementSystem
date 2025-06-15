import 'package:flutter/material.dart';
import '../models/inventory.dart';

class InventoryProvider extends ChangeNotifier {
  final List<Inventory> _inventoryList = [];

  List<Inventory> get inventoryList => List.unmodifiable(_inventoryList);

  Future<bool> addInventory(Inventory item) async {
    _inventoryList.add(item);
    notifyListeners();
    return true;
  }

  Future<bool> updateInventory(Inventory updatedItem) async {
    int index = _inventoryList.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _inventoryList[index] = updatedItem;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteInventory(Inventory item) async {
    _inventoryList.removeWhere((inv) => inv.id == item.id);
    notifyListeners();
    return true;
  }
}
