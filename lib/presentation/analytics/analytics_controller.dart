import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/invoice_repository.dart';

class AnalyticsController extends GetxController {
  final AnalyticsRepository _analyticsRepository = Get.find<AnalyticsRepository>();
  final InvoiceRepository _invoiceRepository = Get.find<InvoiceRepository>();
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> salesAnalytics = <String, dynamic>{}.obs;
  final RxMap<String, int> statusDistribution = <String, int>{}.obs;
  final RxList<Map<String, dynamic>> topClients = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> monthlyTrend = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> dailySales = <Map<String, dynamic>>[].obs;
  final RxString selectedPeriod = 'thisMonth'.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalyticsData();
  }

  Future<void> loadAnalyticsData() async {
    try {
      isLoading.value = true;
      
      // Load sales analytics
      salesAnalytics.value = _analyticsRepository.getSalesAnalytics();
      
      // Load status distribution
      statusDistribution.value = _analyticsRepository.getInvoiceStatusDistribution();
      
      // Load top clients
      topClients.value = _analyticsRepository.getTopClients(limit: 5);
      
      // Load monthly trend
      monthlyTrend.value = _analyticsRepository.getMonthlyRevenueTrend(months: 6);
      
      // Load daily sales for current period
      final now = DateTime.now();
      final startDate = _getStartDateForPeriod(selectedPeriod.value);
      dailySales.value = _analyticsRepository.getDailySalesData(
        startDate: startDate,
        endDate: now,
      );
      
      print('✅ Analytics data loaded successfully');
    } catch (e) {
      print('❌ Error loading analytics data: $e');
      Get.snackbar('Error', 'Gagal memuat data analytics');
    } finally {
      isLoading.value = false;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadAnalyticsData();
  }

  DateTime _getStartDateForPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'thisWeek':
        return now.subtract(const Duration(days: 7));
      case 'thisMonth':
        return DateTime(now.year, now.month, 1);
      case 'thisQuarter':
        return DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
      case 'thisYear':
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  String get totalRevenueFormatted {
    final revenue = salesAnalytics['totalSales'] ?? 0.0;
    return 'Rp ${revenue.toStringAsFixed(0)}';
  }

  String get averageInvoiceFormatted {
    final average = salesAnalytics['averageInvoiceValue'] ?? 0.0;
    return 'Rp ${average.toStringAsFixed(0)}';
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'sent':
        return Colors.blue;
      case 'overdue':
        return Colors.red;
      case 'draft':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<String> get periodOptions => ['thisWeek', 'thisMonth', 'thisQuarter', 'thisYear'];
  
  String getPeriodText(String period) {
    switch (period) {
      case 'thisWeek':
        return 'Minggu Ini';
      case 'thisMonth':
        return 'Bulan Ini';
      case 'thisQuarter':
        return 'Kuartal Ini';
      case 'thisYear':
        return 'Tahun Ini';
      default:
        return 'Bulan Ini';
    }
  }
}
