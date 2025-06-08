import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/services/pdf_service.dart';
import '../../../data/services/email_service.dart';

class InvoiceListController extends GetxController {
  final InvoiceRepository _invoiceRepository = Get.find<InvoiceRepository>();
  final PdfService _pdfService = Get.find<PdfService>();
  final EmailService _emailService = Get.find<EmailService>();
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<Invoice> invoices = <Invoice>[].obs;
  final RxList<Invoice> filteredInvoices = <Invoice>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'all'.obs;
  
  // Search controller
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterInvoices();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadInvoices() async {
    try {
      isLoading.value = true;
      
      final allInvoices = _invoiceRepository.getAllInvoices();
      allInvoices.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      
      invoices.value = allInvoices;
      filterInvoices();
      
      print('✅ Invoices loaded: ${allInvoices.length}');
    } catch (e) {
      print('❌ Error loading invoices: $e');
      Get.snackbar('Error', 'Gagal memuat daftar invoice');
    } finally {
      isLoading.value = false;
    }
  }

  void filterInvoices() {
    var filtered = invoices.toList();
    
    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((invoice) =>
          invoice.invoiceNumber.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          invoice.clientName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          invoice.clientEmail.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    // Filter by status
    if (selectedStatus.value != 'all') {
      filtered = filtered.where((invoice) => 
          invoice.status.toLowerCase() == selectedStatus.value.toLowerCase()).toList();
    }
    
    filteredInvoices.value = filtered;
  }

  void changeStatusFilter(String status) {
    selectedStatus.value = status;
    filterInvoices();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filterInvoices();
  }

  // Navigation methods
  void navigateToCreateInvoice() {
    Get.toNamed('/create-invoice');
  }

  void navigateToInvoiceDetail(String invoiceId) {
    Get.toNamed('/invoice-detail', arguments: invoiceId);
  }

  void navigateToEditInvoice(String invoiceId) {
    Get.toNamed('/edit-invoice', arguments: invoiceId);
  }

  // Invoice actions
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin menghapus invoice ini?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        final success = await _invoiceRepository.deleteInvoice(invoiceId);
        if (success) {
          await loadInvoices();
          Get.snackbar(
            'Berhasil',
            'Invoice berhasil dihapus',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('❌ Error deleting invoice: $e');
      Get.snackbar('Error', 'Gagal menghapus invoice');
    }
  }

  Future<void> duplicateInvoice(String invoiceId) async {
    try {
      isLoading.value = true;
      
      final newInvoiceId = await _invoiceRepository.duplicateInvoice(invoiceId);
      await loadInvoices();
      
      Get.snackbar(
        'Berhasil',
        'Invoice berhasil diduplikasi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Navigate to edit the duplicated invoice
      navigateToEditInvoice(newInvoiceId);
    } catch (e) {
      print('❌ Error duplicating invoice: $e');
      Get.snackbar('Error', 'Gagal menduplikasi invoice');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateInvoiceStatus(String invoiceId, String newStatus) async {
    try {
      final success = await _invoiceRepository.updateInvoiceStatus(invoiceId, newStatus);
      if (success) {
        await loadInvoices();
        Get.snackbar(
          'Berhasil',
          'Status invoice berhasil diubah',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error updating invoice status: $e');
      Get.snackbar('Error', 'Gagal mengubah status invoice');
    }
  }

  Future<void> generatePdf(String invoiceId) async {
    try {
      isLoading.value = true;
      
      final invoice = _invoiceRepository.getInvoiceById(invoiceId);
      if (invoice == null) {
        Get.snackbar('Error', 'Invoice tidak ditemukan');
        return;
      }
      
      final pdfBytes = await _pdfService.generateInvoicePdf(invoice);
      await _pdfService.sharePdf(pdfBytes, 'Invoice_${invoice.invoiceNumber}');
      
      Get.snackbar(
        'Berhasil',
        'PDF invoice berhasil dibuat',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error generating PDF: $e');
      Get.snackbar('Error', 'Gagal membuat PDF invoice');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendInvoiceEmail(String invoiceId) async {
    try {
      isLoading.value = true;
      
      final invoice = _invoiceRepository.getInvoiceById(invoiceId);
      if (invoice == null) {
        Get.snackbar('Error', 'Invoice tidak ditemukan');
        return;
      }
      
      final pdfBytes = await _pdfService.generateInvoicePdf(invoice);
      final success = await _emailService.sendInvoiceEmail(
        invoice: invoice,
        pdfBytes: pdfBytes,
      );
      
      if (success) {
        await updateInvoiceStatus(invoiceId, 'sent');
        Get.snackbar(
          'Berhasil',
          'Invoice berhasil dikirim via email',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Gagal mengirim email invoice');
      }
    } catch (e) {
      print('❌ Error sending invoice email: $e');
      Get.snackbar('Error', 'Gagal mengirim email invoice');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods
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
      default:
        return status;
    }
  }

  List<String> get statusOptions => ['all', 'draft', 'sent', 'paid', 'overdue'];
  
  String getStatusFilterText(String status) {
    switch (status) {
      case 'all':
        return 'Semua';
      case 'draft':
        return 'Draft';
      case 'sent':
        return 'Terkirim';
      case 'paid':
        return 'Lunas';
      case 'overdue':
        return 'Jatuh Tempo';
      default:
        return status;
    }
  }
}
