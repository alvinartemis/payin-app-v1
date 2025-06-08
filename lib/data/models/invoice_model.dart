import 'invoice_item_model.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final DateTime createdDate;
  final DateTime dueDate;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String clientAddress;
  final String? clientCompany;
  final List<InvoiceItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String status;
  final String? notes;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.createdDate,
    required this.dueDate,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.clientAddress,
    this.clientCompany,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.status,
    this.notes,
  });

  // INI METHOD COPYWITH YANG DIPERLUKAN
  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? createdDate,
    DateTime? dueDate,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? clientAddress,
    String? clientCompany,
    List<InvoiceItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    String? status,
    String? notes,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      createdDate: createdDate ?? this.createdDate,
      dueDate: dueDate ?? this.dueDate,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      clientAddress: clientAddress ?? this.clientAddress,
      clientCompany: clientCompany ?? this.clientCompany,
      items: items ?? List<InvoiceItem>.from(this.items),
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'invoiceNumber': invoiceNumber,
    'createdDate': createdDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'clientName': clientName,
    'clientEmail': clientEmail,
    'clientPhone': clientPhone,
    'clientAddress': clientAddress,
    'clientCompany': clientCompany,
    'items': items.map((item) => item.toJson()).toList(),
    'subtotal': subtotal,
    'tax': tax,
    'discount': discount,
    'total': total,
    'status': status,
    'notes': notes,
  };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: json['id'] ?? '',
    invoiceNumber: json['invoiceNumber'] ?? '',
    createdDate: DateTime.tryParse(json['createdDate'] ?? '') ?? DateTime.now(),
    dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),
    clientName: json['clientName'] ?? '',
    clientEmail: json['clientEmail'] ?? '',
    clientPhone: json['clientPhone'] ?? '',
    clientAddress: json['clientAddress'] ?? '',
    clientCompany: json['clientCompany'],
    items: (json['items'] as List? ?? [])
        .map((item) => InvoiceItem.fromJson(item))
        .toList(),
    subtotal: (json['subtotal'] ?? 0.0).toDouble(),
    tax: (json['tax'] ?? 0.0).toDouble(),
    discount: (json['discount'] ?? 0.0).toDouble(),
    total: (json['total'] ?? 0.0).toDouble(),
    status: json['status'] ?? 'draft',
    notes: json['notes'],
  );

  // Factory constructor untuk membuat invoice baru
  factory Invoice.create({
    required String clientName,
    required String clientEmail,
    required String clientPhone,
    required String clientAddress,
    String? clientCompany,
    required List<InvoiceItem> items,
    double taxRate = 11.0,
    double discount = 0.0,
    String? notes,
  }) {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.total);
    final tax = (subtotal * taxRate) / 100;
    final total = subtotal + tax - discount;

    return Invoice(
      id: generateId(),
      invoiceNumber: '',
      createdDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      clientName: clientName,
      clientEmail: clientEmail,
      clientPhone: clientPhone,
      clientAddress: clientAddress,
      clientCompany: clientCompany,
      items: items,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      status: 'draft',
      notes: notes,
    );
  }

  // Generate ID unik
  static String generateId() {
    return 'inv_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Helper methods
  bool get isValid {
    return id.isNotEmpty &&
           invoiceNumber.isNotEmpty &&
           clientName.isNotEmpty &&
           clientEmail.isNotEmpty &&
           items.isNotEmpty &&
           total >= 0;
  }

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isSent => status.toLowerCase() == 'sent';
  bool get isDraft => status.toLowerCase() == 'draft';
  bool get isOverdue => !isPaid && DateTime.now().isAfter(dueDate);

  String get formattedTotal => 'Rp ${total.toStringAsFixed(0)}';
  String get formattedSubtotal => 'Rp ${subtotal.toStringAsFixed(0)}';

  @override
  String toString() {
    return 'Invoice(id: $id, invoiceNumber: $invoiceNumber, clientName: $clientName, total: $total, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
