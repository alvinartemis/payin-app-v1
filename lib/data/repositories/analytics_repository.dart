import 'package:get/get.dart';
import '../models/invoice_model.dart';
import 'invoice_repository.dart';

class AnalyticsRepository extends GetxService {
  InvoiceRepository? _invoiceRepository;

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      _invoiceRepository = Get.find<InvoiceRepository>();
    } catch (e) {
      print('Error initializing AnalyticsRepository: $e');
    }
  }

  // Get basic sales analytics
  Map<String, dynamic> getSalesAnalytics() {
    try {
      if (_invoiceRepository == null) {
        return _getEmptyAnalytics();
      }

      final invoices = _invoiceRepository!.getAllInvoices();
      final paidInvoices = invoices.where((inv) => inv.status.toLowerCase() == 'paid').toList();
      
      return {
        'totalSales': paidInvoices.fold(0.0, (sum, inv) => sum + inv.total),
        'totalInvoices': invoices.length,
        'paidInvoices': paidInvoices.length,
        'pendingInvoices': invoices.where((inv) => inv.status.toLowerCase() != 'paid').length,
        'averageInvoiceValue': paidInvoices.isNotEmpty 
            ? paidInvoices.fold(0.0, (sum, inv) => sum + inv.total) / paidInvoices.length 
            : 0.0,
      };
    } catch (e) {
      print('Error getting sales analytics: $e');
      return _getEmptyAnalytics();
    }
  }

  // Get invoices by date range
  List<Invoice> getInvoicesByDateRange(DateTime startDate, DateTime endDate) {
    try {
      if (_invoiceRepository == null) return [];
      
      return _invoiceRepository!.getAllInvoices()
          .where((invoice) => 
              invoice.createdDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
              invoice.createdDate.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
    } catch (e) {
      print('Error getting invoices by date range: $e');
      return [];
    }
  }

  // Get daily sales data for charts
  List<Map<String, dynamic>> getDailySalesData({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    try {
      final invoices = getInvoicesByDateRange(startDate, endDate);
      final paidInvoices = invoices.where((inv) => inv.status.toLowerCase() == 'paid').toList();
      
      final Map<String, double> dailySalesMap = {};
      
      for (final invoice in paidInvoices) {
        final dateKey = '${invoice.createdDate.day}/${invoice.createdDate.month}';
        dailySalesMap[dateKey] = (dailySalesMap[dateKey] ?? 0.0) + invoice.total;
      }
      
      return dailySalesMap.entries
          .map((entry) => {
            'date': entry.key,
            'amount': entry.value,
          })
          .toList()
        ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    } catch (e) {
      print('Error getting daily sales data: $e');
      return [];
    }
  }

  // Get top clients by revenue
  List<Map<String, dynamic>> getTopClients({int limit = 10}) {
    try {
      if (_invoiceRepository == null) return [];
      
      final invoices = _invoiceRepository!.getAllInvoices();
      final paidInvoices = invoices.where((inv) => inv.status.toLowerCase() == 'paid').toList();
      
      final Map<String, Map<String, dynamic>> clientMap = {};
      
      for (final invoice in paidInvoices) {
        final clientKey = invoice.clientEmail;
        if (clientMap.containsKey(clientKey)) {
          clientMap[clientKey]!['totalRevenue'] = 
              (clientMap[clientKey]!['totalRevenue'] as double) + invoice.total;
          clientMap[clientKey]!['invoiceCount'] = 
              (clientMap[clientKey]!['invoiceCount'] as int) + 1;
        } else {
          clientMap[clientKey] = {
            'clientName': invoice.clientName,
            'clientEmail': invoice.clientEmail,
            'totalRevenue': invoice.total,
            'invoiceCount': 1,
          };
        }
      }
      
      final sortedClients = clientMap.values.toList()
        ..sort((a, b) => (b['totalRevenue'] as double).compareTo(a['totalRevenue'] as double));
      
      return sortedClients.take(limit).toList();
    } catch (e) {
      print('Error getting top clients: $e');
      return [];
    }
  }

  // Get invoice status distribution
  Map<String, int> getInvoiceStatusDistribution() {
    try {
      if (_invoiceRepository == null) {
        return {'draft': 0, 'sent': 0, 'paid': 0, 'overdue': 0};
      }

      final invoices = _invoiceRepository!.getAllInvoices();
      final Map<String, int> statusMap = {
        'draft': 0,
        'sent': 0,
        'paid': 0,
        'overdue': 0,
      };
      
      final now = DateTime.now();
      
      for (final invoice in invoices) {
        final status = invoice.status.toLowerCase();
        if (status == 'paid') {
          statusMap['paid'] = statusMap['paid']! + 1;
        } else if (status == 'sent') {
          if (invoice.dueDate.isBefore(now)) {
            statusMap['overdue'] = statusMap['overdue']! + 1;
          } else {
            statusMap['sent'] = statusMap['sent']! + 1;
          }
        } else {
          statusMap['draft'] = statusMap['draft']! + 1;
        }
      }
      
      return statusMap;
    } catch (e) {
      print('Error getting invoice status distribution: $e');
      return {'draft': 0, 'sent': 0, 'paid': 0, 'overdue': 0};
    }
  }

  // Get monthly revenue trend
  List<Map<String, dynamic>> getMonthlyRevenueTrend({int months = 12}) {
    try {
      if (_invoiceRepository == null) return [];
      
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - months + 1, 1);
      
      final invoices = getInvoicesByDateRange(startDate, now);
      final paidInvoices = invoices.where((inv) => inv.status.toLowerCase() == 'paid').toList();
      
      final Map<String, double> monthlyMap = {};
      
      for (final invoice in paidInvoices) {
        final monthKey = '${invoice.createdDate.month}/${invoice.createdDate.year}';
        monthlyMap[monthKey] = (monthlyMap[monthKey] ?? 0.0) + invoice.total;
      }
      
      return monthlyMap.entries
          .map((entry) => {
            'month': entry.key,
            'revenue': entry.value,
          })
          .toList()
        ..sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));
    } catch (e) {
      print('Error getting monthly revenue trend: $e');
      return [];
    }
  }

  // Get payment performance metrics
  Map<String, dynamic> getPaymentPerformance() {
    try {
      if (_invoiceRepository == null) return _getEmptyPaymentPerformance();
      
      final invoices = _invoiceRepository!.getAllInvoices();
      final now = DateTime.now();
      
      int onTimePayments = 0;
      int latePayments = 0;
      int totalPaidInvoices = 0;
      double totalDaysToPayment = 0;
      
      for (final invoice in invoices) {
        if (invoice.status.toLowerCase() == 'paid') {
          totalPaidInvoices++;
          
          // Asumsi pembayaran dilakukan pada hari ini untuk demo
          final paymentDate = DateTime.now();
          final daysToPayment = paymentDate.difference(invoice.createdDate).inDays;
          totalDaysToPayment += daysToPayment;
          
          if (paymentDate.isBefore(invoice.dueDate) || 
              paymentDate.isAtSameMomentAs(invoice.dueDate)) {
            onTimePayments++;
          } else {
            latePayments++;
          }
        }
      }
      
      return {
        'onTimePaymentRate': totalPaidInvoices > 0 
            ? (onTimePayments / totalPaidInvoices) * 100 
            : 0.0,
        'averageDaysToPayment': totalPaidInvoices > 0 
            ? totalDaysToPayment / totalPaidInvoices 
            : 0.0,
        'totalPaidInvoices': totalPaidInvoices,
        'onTimePayments': onTimePayments,
        'latePayments': latePayments,
      };
    } catch (e) {
      print('Error getting payment performance: $e');
      return _getEmptyPaymentPerformance();
    }
  }

  // Get business growth metrics
  Map<String, dynamic> getBusinessGrowthMetrics() {
    try {
      if (_invoiceRepository == null) return _getEmptyBusinessGrowth();
      
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      final currentMonthEnd = DateTime(now.year, now.month + 1, 0);
      final lastMonthEnd = DateTime(now.year, now.month, 0);
      
      final currentMonthInvoices = getInvoicesByDateRange(currentMonth, currentMonthEnd);
      final lastMonthInvoices = getInvoicesByDateRange(lastMonth, lastMonthEnd);
      
      final currentMonthRevenue = currentMonthInvoices
          .where((inv) => inv.status.toLowerCase() == 'paid')
          .fold(0.0, (sum, inv) => sum + inv.total);
      
      final lastMonthRevenue = lastMonthInvoices
          .where((inv) => inv.status.toLowerCase() == 'paid')
          .fold(0.0, (sum, inv) => sum + inv.total);
      
      final revenueGrowth = lastMonthRevenue > 0 
          ? ((currentMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100 
          : 0.0;
      
      final invoiceGrowth = lastMonthInvoices.isNotEmpty 
          ? ((currentMonthInvoices.length - lastMonthInvoices.length) / lastMonthInvoices.length) * 100 
          : 0.0;
      
      return {
        'revenueGrowthRate': revenueGrowth,
        'invoiceGrowthRate': invoiceGrowth,
        'currentMonthRevenue': currentMonthRevenue,
        'lastMonthRevenue': lastMonthRevenue,
        'currentMonthInvoices': currentMonthInvoices.length,
        'lastMonthInvoices': lastMonthInvoices.length,
      };
    } catch (e) {
      print('Error getting business growth metrics: $e');
      return _getEmptyBusinessGrowth();
    }
  }

  // Helper methods untuk empty data
  Map<String, dynamic> _getEmptyAnalytics() {
    return {
      'totalSales': 0.0,
      'totalInvoices': 0,
      'paidInvoices': 0,
      'pendingInvoices': 0,
      'averageInvoiceValue': 0.0,
    };
  }

  Map<String, dynamic> _getEmptyPaymentPerformance() {
    return {
      'onTimePaymentRate': 0.0,
      'averageDaysToPayment': 0.0,
      'totalPaidInvoices': 0,
      'onTimePayments': 0,
      'latePayments': 0,
    };
  }

  Map<String, dynamic> _getEmptyBusinessGrowth() {
    return {
      'revenueGrowthRate': 0.0,
      'invoiceGrowthRate': 0.0,
      'currentMonthRevenue': 0.0,
      'lastMonthRevenue': 0.0,
      'currentMonthInvoices': 0,
      'lastMonthInvoices': 0,
    };
  }
}
