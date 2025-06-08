import 'quotation_item_model.dart';

class Quotation {
  final String id;
  final String quotationNumber;
  final DateTime createdDate;
  final DateTime validUntil;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String clientAddress;
  final String? clientCompany;
  final List<QuotationItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String status; // draft, sent, accepted, rejected, expired
  final String? notes;

  Quotation({
    required this.id,
    required this.quotationNumber,
    required this.createdDate,
    required this.validUntil,
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

  // copyWith method
  Quotation copyWith({
    String? id,
    String? quotationNumber,
    DateTime? createdDate,
    DateTime? validUntil,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? clientAddress,
    String? clientCompany,
    List<QuotationItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    String? status,
    String? notes,
  }) {
    return Quotation(
      id: id ?? this.id,
      quotationNumber: quotationNumber ?? this.quotationNumber,
      createdDate: createdDate ?? this.createdDate,
      validUntil: validUntil ?? this.validUntil,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      clientAddress: clientAddress ?? this.clientAddress,
      clientCompany: clientCompany ?? this.clientCompany,
      items: items ?? List<QuotationItem>.from(this.items),
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
    'quotationNumber': quotationNumber,
    'createdDate': createdDate.toIso8601String(),
    'validUntil': validUntil.toIso8601String(),
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

  factory Quotation.fromJson(Map<String, dynamic> json) => Quotation(
    id: json['id'] ?? '',
    quotationNumber: json['quotationNumber'] ?? '',
    createdDate: DateTime.tryParse(json['createdDate'] ?? '') ?? DateTime.now(),
    validUntil: DateTime.tryParse(json['validUntil'] ?? '') ?? DateTime.now(),
    clientName: json['clientName'] ?? '',
    clientEmail: json['clientEmail'] ?? '',
    clientPhone: json['clientPhone'] ?? '',
    clientAddress: json['clientAddress'] ?? '',
    clientCompany: json['clientCompany'],
    items: (json['items'] as List? ?? [])
        .map((item) => QuotationItem.fromJson(item))
        .toList(),
    subtotal: (json['subtotal'] ?? 0.0).toDouble(),
    tax: (json['tax'] ?? 0.0).toDouble(),
    discount: (json['discount'] ?? 0.0).toDouble(),
    total: (json['total'] ?? 0.0).toDouble(),
    status: json['status'] ?? 'draft',
    notes: json['notes'],
  );

  // Helper methods
  bool get isExpired => DateTime.now().isAfter(validUntil);
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isDraft => status.toLowerCase() == 'draft';
  String get formattedTotal => 'Rp ${total.toStringAsFixed(0)}';

  static String generateId() {
    return 'quo_${DateTime.now().millisecondsSinceEpoch}';
  }
}
