class QuotationItem {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final double discount;
  final String unit;

  QuotationItem({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    this.discount = 0.0,
    this.unit = 'pcs',
  });

  QuotationItem copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    double? price,
    double? discount,
    String? unit,
  }) {
    return QuotationItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      unit: unit ?? this.unit,
    );
  }

  double get subtotal => quantity * price;
  double get total => subtotal - discount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'quantity': quantity,
    'price': price,
    'discount': discount,
    'unit': unit,
  };

  factory QuotationItem.fromJson(Map<String, dynamic> json) => QuotationItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    quantity: json['quantity'] ?? 1,
    price: (json['price'] ?? 0.0).toDouble(),
    discount: (json['discount'] ?? 0.0).toDouble(),
    unit: json['unit'] ?? 'pcs',
  );

  static String generateId() {
    return 'item_${DateTime.now().millisecondsSinceEpoch}';
  }
}
