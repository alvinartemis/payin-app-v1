class InvoiceItem {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final double discount;
  final String unit;

  InvoiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    this.discount = 0.0,
    this.unit = 'pcs',
  });

  // copyWith method untuk InvoiceItem
  InvoiceItem copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    double? price,
    double? discount,
    String? unit,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      unit: unit ?? this.unit,
    );
  }

  // Calculated properties
  double get subtotal => quantity * price;
  double get total => subtotal - discount;

  // JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'quantity': quantity,
    'price': price,
    'discount': discount,
    'unit': unit,
  };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    quantity: json['quantity'] ?? 1,
    price: (json['price'] ?? 0.0).toDouble(),
    discount: (json['discount'] ?? 0.0).toDouble(),
    unit: json['unit'] ?? 'pcs',
  );

  // Factory constructor
  factory InvoiceItem.create({
    required String name,
    required String description,
    required int quantity,
    required double price,
    double discount = 0.0,
    String unit = 'pcs',
  }) {
    return InvoiceItem(
      id: generateId(),
      name: name,
      description: description,
      quantity: quantity,
      price: price,
      discount: discount,
      unit: unit,
    );
  }

  static String generateId() {
    return 'item_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  String toString() {
    return 'InvoiceItem(id: $id, name: $name, quantity: $quantity, price: $price, total: $total)';
  }
}
