class Inventory {
  static int _idCounter = 0;
  final int id;
  String name;
  int quantity;
  double price;
  String? description;
  String? orderDate;

  Inventory({
    required this.name,
    required this.quantity,
    required this.price,
    this.description,
    this.orderDate,
  }) : id = _idCounter++;

  Inventory copyWith({
    String? name,
    int? quantity,
    double? price,
    String? description,
    String? orderDate,
  }) {
    return Inventory(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      description: description ?? this.description,
      orderDate: orderDate ?? this.orderDate,
    );
  }
}
