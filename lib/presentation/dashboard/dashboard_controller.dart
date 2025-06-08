import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/models/invoice_model.dart';
import '../../data/repositories/quotation_repository.dart';
import '../../data/models/quotation_model.dart'; // TAMBAHAN

class DashboardController extends GetxController {
  InvoiceRepository? _invoiceRepository;
  AnalyticsRepository? _analyticsRepository;
  QuotationRepository? _quotationRepository; // PERBAIKAN: Ubah ke nullable
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> statistics = <String, dynamic>{}.obs;
  final RxList<Invoice> recentInvoices = <Invoice>[].obs;
  final RxMap<String, dynamic> salesAnalytics = <String, dynamic>{}.obs;
  final RxMap<String, int> statusDistribution = <String, int>{}.obs;
  final RxList<Quotation> recentQuotations = <Quotation>[].obs; // PERBAIKAN: Type safety
  
  // TAMBAHAN: Observable untuk quotation statistics sesuai memory entries[1]
  final RxMap<String, dynamic> quotationStatistics = <String, dynamic>{}.obs;
  final RxMap<String, int> quotationStatusDistribution = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeRepositories();
    loadDashboardData();
  }

  void _initializeRepositories() {
    try {
      _invoiceRepository = Get.find<InvoiceRepository>();
      _analyticsRepository = Get.find<AnalyticsRepository>();
      _quotationRepository = Get.find<QuotationRepository>(); // PERBAIKAN
    } catch (e) {
      print('❌ Error initializing repositories: $e');
    }
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      
      if (_invoiceRepository != null && _analyticsRepository != null) {
        // Load basic statistics
        statistics.value = _invoiceRepository!.getInvoiceStatistics();
        
        // Load recent invoices
        final allInvoices = _invoiceRepository!.getAllInvoices();
        allInvoices.sort((a, b) => b.createdDate.compareTo(a.createdDate));
        recentInvoices.value = allInvoices.take(5).toList();
          
        // Load sales analytics
        salesAnalytics.value = _analyticsRepository!.getSalesAnalytics();
        
        // Load status distribution
        statusDistribution.value = _analyticsRepository!.getInvoiceStatusDistribution();
      }

      // TAMBAHAN: Load quotation data sesuai memory entries[1]
      if (_quotationRepository != null) {
        final allQuotations = _quotationRepository!.getAllQuotations();
        allQuotations.sort((a, b) => b.createdDate.compareTo(a.createdDate));
        recentQuotations.value = allQuotations.take(5).toList();
        
        // Load quotation statistics
        quotationStatistics.value = _calculateQuotationStatistics(allQuotations);
        quotationStatusDistribution.value = _calculateQuotationStatusDistribution(allQuotations);
      }
      
      print('✅ Dashboard data loaded successfully');
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data dashboard',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // TAMBAHAN: Helper methods untuk quotation statistics sesuai memory entries[1]
  Map<String, dynamic> _calculateQuotationStatistics(List<Quotation> quotations) {
    final totalQuotations = quotations.length;
    final acceptedQuotations = quotations.where((q) => q.status.toLowerCase() == 'accepted').length;
    final sentQuotations = quotations.where((q) => q.status.toLowerCase() == 'sent').length;
    final draftQuotations = quotations.where((q) => q.status.toLowerCase() == 'draft').length;
    final expiredQuotations = quotations.where((q) => q.isExpired).length;
    final totalQuotationValue = quotations.fold(0.0, (sum, q) => sum + q.total);
    
    return {
      'totalQuotations': totalQuotations,
      'acceptedQuotations': acceptedQuotations,
      'sentQuotations': sentQuotations,
      'draftQuotations': draftQuotations,
      'expiredQuotations': expiredQuotations,
      'totalQuotationValue': totalQuotationValue,
      'conversionRate': totalQuotations > 0 ? (acceptedQuotations / totalQuotations) * 100 : 0.0,
    };
  }

  Map<String, int> _calculateQuotationStatusDistribution(List<Quotation> quotations) {
    final distribution = <String, int>{};
    for (final quotation in quotations) {
      final status = quotation.status.toLowerCase();
      distribution[status] = (distribution[status] ?? 0) + 1;
    }
    return distribution;
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // Navigation methods
  void navigateToCreateInvoice() {
    Get.toNamed('/create-invoice');
  }

  void navigateToInvoiceList() {
    Get.toNamed('/invoice-list');
  }

  void navigateToAnalytics() {
    Get.toNamed('/analytics');
  }

  void navigateToSettings() {
    Get.toNamed('/settings');
  }

  void navigateToInvoiceDetail(String invoiceId) {
    Get.toNamed('/invoice-detail', arguments: invoiceId);
  }

  // TAMBAHAN: Navigation methods untuk quotation sesuai memory entries[1]
  void navigateToCreateQuotation() {
    Get.toNamed('/create-quotation');
  }

  void navigateToQuotationList() {
    Get.toNamed('/quotation-list');
  }

  void navigateToQuotationDetail(String quotationId) {
    Get.toNamed('/quotation-detail', arguments: quotationId);
  }

  // Helper methods untuk UI
  String get totalRevenueFormatted {
    final revenue = statistics['totalRevenue'] ?? 0.0;
    return 'Rp ${revenue.toStringAsFixed(0)}';
  }

  String get totalInvoicesText {
    return '${statistics['totalInvoices'] ?? 0}';
  }

  String get paidInvoicesText {
    return '${statistics['paidInvoices'] ?? 0}';
  }

  String get pendingInvoicesText {
    return '${statistics['pendingInvoices'] ?? 0}';
  }

  String get overdueInvoicesText {
    return '${statistics['overdueInvoices'] ?? 0}';
  }

  // TAMBAHAN: Helper methods untuk quotation UI sesuai memory entries[1]
  String get totalQuotationsText {
    return '${quotationStatistics['totalQuotations'] ?? 0}';
  }

  String get acceptedQuotationsText {
    return '${quotationStatistics['acceptedQuotations'] ?? 0}';
  }

  String get sentQuotationsText {
    return '${quotationStatistics['sentQuotations'] ?? 0}';
  }

  String get draftQuotationsText {
    return '${quotationStatistics['draftQuotations'] ?? 0}';
  }

  String get expiredQuotationsText {
    return '${quotationStatistics['expiredQuotations'] ?? 0}';
  }

  String get totalQuotationValueFormatted {
    final value = quotationStatistics['totalQuotationValue'] ?? 0.0;
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  String get conversionRateText {
    final rate = quotationStatistics['conversionRate'] ?? 0.0;
    return '${rate.toStringAsFixed(1)}%';
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'accepted':
        return Colors.green;
      case 'sent':
        return Colors.blue;
      case 'overdue':
      case 'rejected':
        return Colors.red;
      case 'expired':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Lunas';
      case 'sent':
        return 'Terkirim';
      case 'overdue':
        return 'Jatuh Tempo';
      case 'draft':
        return 'Draft';
      case 'accepted':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      case 'expired':
        return 'Kedaluwarsa';
      default:
        return status;
    }
  }

  // Quick actions untuk invoice
  Future<void> markInvoiceAsPaid(String invoiceId) async {
    try {
      if (_invoiceRepository != null) {
        final success = await _invoiceRepository!.updateInvoiceStatus(invoiceId, 'paid');
        if (success) {
          await refreshData();
          Get.snackbar(
            'Berhasil',
            'Invoice berhasil ditandai sebagai lunas',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('❌ Error marking invoice as paid: $e');
      Get.snackbar('Error', 'Gagal mengupdate status invoice');
    }
  }

  Future<void> sendInvoice(String invoiceId) async {
    try {
      if (_invoiceRepository != null) {
        final success = await _invoiceRepository!.updateInvoiceStatus(invoiceId, 'sent');
        if (success) {
          await refreshData();
          Get.snackbar(
            'Berhasil',
            'Invoice berhasil dikirim',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('❌ Error sending invoice: $e');
      Get.snackbar('Error', 'Gagal mengirim invoice');
    }
  }

  // TAMBAHAN: Quick actions untuk quotation sesuai memory entries[1]
  Future<void> markQuotationAsAccepted(String quotationId) async {
    try {
      if (_quotationRepository != null) {
        final success = await _quotationRepository!.updateQuotationStatus(quotationId, 'accepted');
        if (success) {
          await refreshData();
          Get.snackbar(
            'Berhasil',
            'Quotation berhasil ditandai sebagai diterima',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('❌ Error marking quotation as accepted: $e');
      Get.snackbar('Error', 'Gagal mengupdate status quotation');
    }
  }

  Future<void> sendQuotation(String quotationId) async {
    try {
      if (_quotationRepository != null) {
        final success = await _quotationRepository!.updateQuotationStatus(quotationId, 'sent');
        if (success) {
          await refreshData();
          Get.snackbar(
            'Berhasil',
            'Quotation berhasil dikirim',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('❌ Error sending quotation: $e');
      Get.snackbar('Error', 'Gagal mengirim quotation');
    }
  }

  Future<void> convertQuotationToInvoice(String quotationId) async {
    try {
      if (_quotationRepository != null) {
        final invoiceId = await _quotationRepository!.convertQuotationToInvoice(quotationId);
        if (invoiceId != null) {
          await refreshData();
          Get.snackbar(
            'Berhasil',
            'Quotation berhasil dikonversi menjadi invoice',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          navigateToInvoiceDetail(invoiceId);
        }
      }
    } catch (e) {
      print('❌ Error converting quotation to invoice: $e');
      Get.snackbar('Error', 'Gagal mengkonversi quotation ke invoice');
    }
  }

  // TAMBAHAN: Combined dashboard statistics sesuai memory entries[5]
  Map<String, dynamic> get combinedStatistics {
    return {
      'totalInvoices': statistics['totalInvoices'] ?? 0,
      'totalQuotations': quotationStatistics['totalQuotations'] ?? 0,
      'totalRevenue': statistics['totalRevenue'] ?? 0.0,
      'totalQuotationValue': quotationStatistics['totalQuotationValue'] ?? 0.0,
      'conversionRate': quotationStatistics['conversionRate'] ?? 0.0,
      'pendingItems': (statistics['pendingInvoices'] ?? 0) + (quotationStatistics['sentQuotations'] ?? 0),
    };
  }
}
