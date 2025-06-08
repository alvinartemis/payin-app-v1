class SalesAnalytics {
  final double totalSales;
  final int totalInvoices;
  final int paidInvoices;
  final int pendingInvoices;
  final double averageInvoiceValue;
  final String period;

  SalesAnalytics({
    required this.totalSales,
    required this.totalInvoices,
    required this.paidInvoices,
    required this.pendingInvoices,
    required this.averageInvoiceValue,
    required this.period,
  });

  factory SalesAnalytics.empty() => SalesAnalytics(
    totalSales: 0.0,
    totalInvoices: 0,
    paidInvoices: 0,
    pendingInvoices: 0,
    averageInvoiceValue: 0.0,
    period: '',
  );

  // JSON serialization
  Map<String, dynamic> toJson() => {
    'totalSales': totalSales,
    'totalInvoices': totalInvoices,
    'paidInvoices': paidInvoices,
    'pendingInvoices': pendingInvoices,
    'averageInvoiceValue': averageInvoiceValue,
    'period': period,
  };

  factory SalesAnalytics.fromJson(Map<String, dynamic> json) => SalesAnalytics(
    totalSales: (json['totalSales'] ?? 0.0).toDouble(),
    totalInvoices: json['totalInvoices'] ?? 0,
    paidInvoices: json['paidInvoices'] ?? 0,
    pendingInvoices: json['pendingInvoices'] ?? 0,
    averageInvoiceValue: (json['averageInvoiceValue'] ?? 0.0).toDouble(),
    period: json['period'] ?? '',
  );

  // Helper getters
  double get conversionRate => totalInvoices > 0 ? (paidInvoices / totalInvoices) * 100 : 0.0;
  bool get hasData => totalInvoices > 0;
}

class DailySales {
  final String date;
  final double amount;

  DailySales({
    required this.date,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'amount': amount,
  };

  factory DailySales.fromJson(Map<String, dynamic> json) => DailySales(
    date: json['date'] ?? '',
    amount: (json['amount'] ?? 0.0).toDouble(),
  );
}

class ClientAnalytics {
  final String clientName;
  final String clientEmail;
  final double totalRevenue;
  final int invoiceCount;

  ClientAnalytics({
    required this.clientName,
    required this.clientEmail,
    required this.totalRevenue,
    required this.invoiceCount,
  });

  ClientAnalytics copyWith({
    String? clientName,
    String? clientEmail,
    double? totalRevenue,
    int? invoiceCount,
  }) {
    return ClientAnalytics(
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      invoiceCount: invoiceCount ?? this.invoiceCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'clientName': clientName,
    'clientEmail': clientEmail,
    'totalRevenue': totalRevenue,
    'invoiceCount': invoiceCount,
  };

  factory ClientAnalytics.fromJson(Map<String, dynamic> json) => ClientAnalytics(
    clientName: json['clientName'] ?? '',
    clientEmail: json['clientEmail'] ?? '',
    totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
    invoiceCount: json['invoiceCount'] ?? 0,
  );

  // Helper getters
  double get averageInvoiceValue => invoiceCount > 0 ? totalRevenue / invoiceCount : 0.0;
}

class MonthlyRevenue {
  final String month;
  final double revenue;

  MonthlyRevenue({
    required this.month,
    required this.revenue,
  });

  Map<String, dynamic> toJson() => {
    'month': month,
    'revenue': revenue,
  };

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) => MonthlyRevenue(
    month: json['month'] ?? '',
    revenue: (json['revenue'] ?? 0.0).toDouble(),
  );
}

class PaymentPerformance {
  final double onTimePaymentRate;
  final double averageDaysToPayment;
  final int totalPaidInvoices;
  final int onTimePayments;
  final int latePayments;

  PaymentPerformance({
    required this.onTimePaymentRate,
    required this.averageDaysToPayment,
    required this.totalPaidInvoices,
    required this.onTimePayments,
    required this.latePayments,
  });

  factory PaymentPerformance.empty() => PaymentPerformance(
    onTimePaymentRate: 0.0,
    averageDaysToPayment: 0.0,
    totalPaidInvoices: 0,
    onTimePayments: 0,
    latePayments: 0,
  );

  Map<String, dynamic> toJson() => {
    'onTimePaymentRate': onTimePaymentRate,
    'averageDaysToPayment': averageDaysToPayment,
    'totalPaidInvoices': totalPaidInvoices,
    'onTimePayments': onTimePayments,
    'latePayments': latePayments,
  };

  factory PaymentPerformance.fromJson(Map<String, dynamic> json) => PaymentPerformance(
    onTimePaymentRate: (json['onTimePaymentRate'] ?? 0.0).toDouble(),
    averageDaysToPayment: (json['averageDaysToPayment'] ?? 0.0).toDouble(),
    totalPaidInvoices: json['totalPaidInvoices'] ?? 0,
    onTimePayments: json['onTimePayments'] ?? 0,
    latePayments: json['latePayments'] ?? 0,
  );

  // Helper getters
  bool get hasGoodPerformance => onTimePaymentRate >= 80.0;
  String get performanceLevel {
    if (onTimePaymentRate >= 90) return 'Excellent';
    if (onTimePaymentRate >= 80) return 'Good';
    if (onTimePaymentRate >= 60) return 'Fair';
    return 'Poor';
  }
}

class BusinessGrowth {
  final double revenueGrowthRate;
  final double invoiceGrowthRate;
  final double currentMonthRevenue;
  final double lastMonthRevenue;
  final int currentMonthInvoices;
  final int lastMonthInvoices;

  BusinessGrowth({
    required this.revenueGrowthRate,
    required this.invoiceGrowthRate,
    required this.currentMonthRevenue,
    required this.lastMonthRevenue,
    required this.currentMonthInvoices,
    required this.lastMonthInvoices,
  });

  factory BusinessGrowth.empty() => BusinessGrowth(
    revenueGrowthRate: 0.0,
    invoiceGrowthRate: 0.0,
    currentMonthRevenue: 0.0,
    lastMonthRevenue: 0.0,
    currentMonthInvoices: 0,
    lastMonthInvoices: 0,
  );

  Map<String, dynamic> toJson() => {
    'revenueGrowthRate': revenueGrowthRate,
    'invoiceGrowthRate': invoiceGrowthRate,
    'currentMonthRevenue': currentMonthRevenue,
    'lastMonthRevenue': lastMonthRevenue,
    'currentMonthInvoices': currentMonthInvoices,
    'lastMonthInvoices': lastMonthInvoices,
  };

  factory BusinessGrowth.fromJson(Map<String, dynamic> json) => BusinessGrowth(
    revenueGrowthRate: (json['revenueGrowthRate'] ?? 0.0).toDouble(),
    invoiceGrowthRate: (json['invoiceGrowthRate'] ?? 0.0).toDouble(),
    currentMonthRevenue: (json['currentMonthRevenue'] ?? 0.0).toDouble(),
    lastMonthRevenue: (json['lastMonthRevenue'] ?? 0.0).toDouble(),
    currentMonthInvoices: json['currentMonthInvoices'] ?? 0,
    lastMonthInvoices: json['lastMonthInvoices'] ?? 0,
  );

  // Helper getters
  bool get isGrowing => revenueGrowthRate > 0;
  bool get isDecreasing => revenueGrowthRate < 0;
  String get growthTrend {
    if (revenueGrowthRate > 10) return 'Strong Growth';
    if (revenueGrowthRate > 0) return 'Growing';
    if (revenueGrowthRate == 0) return 'Stable';
    if (revenueGrowthRate > -10) return 'Declining';
    return 'Strong Decline';
  }
}

// Model untuk chart data
class ChartDataPoint {
  final String label;
  final double value;
  final String? category;

  ChartDataPoint({
    required this.label,
    required this.value,
    this.category,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
    'category': category,
  };

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) => ChartDataPoint(
    label: json['label'] ?? '',
    value: (json['value'] ?? 0.0).toDouble(),
    category: json['category'],
  );
}

// Model untuk periode analytics
class AnalyticsPeriod {
  final DateTime startDate;
  final DateTime endDate;
  final String periodType; // daily, weekly, monthly, yearly

  AnalyticsPeriod({
    required this.startDate,
    required this.endDate,
    required this.periodType,
  });

  Map<String, dynamic> toJson() => {
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'periodType': periodType,
  };

  factory AnalyticsPeriod.fromJson(Map<String, dynamic> json) => AnalyticsPeriod(
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    periodType: json['periodType'] ?? 'monthly',
  );

  // Helper getters
  int get durationInDays => endDate.difference(startDate).inDays;
  String get formattedPeriod {
    switch (periodType) {
      case 'daily':
        return '${startDate.day}/${startDate.month}/${startDate.year}';
      case 'weekly':
        return 'Week ${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month}';
      case 'monthly':
        return '${_getMonthName(startDate.month)} ${startDate.year}';
      case 'yearly':
        return '${startDate.year}';
      default:
        return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month];
  }
}

// Model untuk dashboard summary
class DashboardSummary {
  final SalesAnalytics salesAnalytics;
  final PaymentPerformance paymentPerformance;
  final BusinessGrowth businessGrowth;
  final List<ClientAnalytics> topClients;
  final List<MonthlyRevenue> monthlyTrend;

  DashboardSummary({
    required this.salesAnalytics,
    required this.paymentPerformance,
    required this.businessGrowth,
    required this.topClients,
    required this.monthlyTrend,
  });

  factory DashboardSummary.empty() => DashboardSummary(
    salesAnalytics: SalesAnalytics.empty(),
    paymentPerformance: PaymentPerformance.empty(),
    businessGrowth: BusinessGrowth.empty(),
    topClients: [],
    monthlyTrend: [],
  );

  Map<String, dynamic> toJson() => {
    'salesAnalytics': salesAnalytics.toJson(),
    'paymentPerformance': paymentPerformance.toJson(),
    'businessGrowth': businessGrowth.toJson(),
    'topClients': topClients.map((client) => client.toJson()).toList(),
    'monthlyTrend': monthlyTrend.map((trend) => trend.toJson()).toList(),
  };

  factory DashboardSummary.fromJson(Map<String, dynamic> json) => DashboardSummary(
    salesAnalytics: SalesAnalytics.fromJson(json['salesAnalytics'] ?? {}),
    paymentPerformance: PaymentPerformance.fromJson(json['paymentPerformance'] ?? {}),
    businessGrowth: BusinessGrowth.fromJson(json['businessGrowth'] ?? {}),
    topClients: (json['topClients'] as List? ?? [])
        .map((client) => ClientAnalytics.fromJson(client))
        .toList(),
    monthlyTrend: (json['monthlyTrend'] as List? ?? [])
        .map((trend) => MonthlyRevenue.fromJson(trend))
        .toList(),
  );
}
