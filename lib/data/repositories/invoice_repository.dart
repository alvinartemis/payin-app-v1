import 'package:get/get.dart';
import '../models/invoice_model.dart';
import '../services/hive_service.dart';
import '../services/local_storage_service.dart';

class InvoiceRepository extends GetxService {
  HiveService? _hiveService;
  LocalStorageService? _localStorage;

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      _hiveService = Get.find<HiveService>();
      _localStorage = await LocalStorageService.getInstance();
    } catch (e) {
      print('Error initializing InvoiceRepository: $e');
    }
  }

  Future<String> createInvoice(Invoice invoice) async {
    try {
      if (_hiveService == null) {
        throw Exception('HiveService not initialized');
      }

      final invoiceWithNumber = invoice.copyWith(
        invoiceNumber: invoice.invoiceNumber.isEmpty 
            ? await _generateInvoiceNumber() 
            : invoice.invoiceNumber,
      );

      await _hiveService!.createInvoice(invoiceWithNumber);
      
      if (_localStorage != null) {
        await _localStorage!.incrementInvoiceCounter();
      }

      return invoiceWithNumber.id;
    } catch (e) {
      throw Exception('Gagal membuat invoice: $e');
    }
  }

  List<Invoice> getAllInvoices() {
    try {
      if (_hiveService == null) return [];
      return _hiveService!.getAllInvoices();
    } catch (e) {
      print('Error getting all invoices: $e');
      return [];
    }
  }

  Invoice? getInvoiceById(String id) {
    try {
      if (_hiveService == null) return null;
      return _hiveService!.getInvoice(id);
    } catch (e) {
      print('Error getting invoice by ID: $e');
      return null;
    }
  }

  Future<bool> updateInvoice(Invoice invoice) async {
    try {
      if (_hiveService == null) return false;
      
      final invoices = getAllInvoices();
      final index = invoices.indexWhere((inv) => inv.id == invoice.id);
      
      if (index != -1) {
        await _hiveService!.updateInvoice(index, invoice);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating invoice: $e');
      return false;
    }
  }

  Future<bool> deleteInvoice(String id) async {
    try {
      if (_hiveService == null) return false;
      
      final invoices = getAllInvoices();
      final index = invoices.indexWhere((inv) => inv.id == id);
      
      if (index != -1) {
        await _hiveService!.deleteInvoice(index);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting invoice: $e');
      return false;
    }
  }

  // METHOD DUPLICATEINVOICE YANG HILANG
  Future<String> duplicateInvoice(String id) async {
    try {
      final originalInvoice = getInvoiceById(id);
      if (originalInvoice == null) {
        throw Exception('Invoice tidak ditemukan');
      }

      // Generate ID baru dan invoice number baru
      final newId = Invoice.generateId();
      final newInvoiceNumber = await _generateInvoiceNumber();
      
      // Buat salinan invoice dengan data baru
      final duplicatedInvoice = originalInvoice.copyWith(
        id: newId,
        invoiceNumber: newInvoiceNumber,
        createdDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        status: 'draft', // Reset status ke draft
      );

      // Simpan invoice yang diduplikasi
      await createInvoice(duplicatedInvoice);
      
      print('✅ Invoice duplicated successfully: $newId');
      return newId;
    } catch (e) {
      print('❌ Error duplicating invoice: $e');
      throw Exception('Gagal menduplikasi invoice: $e');
    }
  }

  Future<bool> updateInvoiceStatus(String id, String status) async {
    try {
      final invoice = getInvoiceById(id);
      if (invoice != null) {
        final updatedInvoice = invoice.copyWith(status: status);
        return await updateInvoice(updatedInvoice);
      }
      return false;
    } catch (e) {
      print('Error updating invoice status: $e');
      return false;
    }
  }

  double getTotalRevenue() {
    try {
      return getAllInvoices()
          .where((invoice) => invoice.status.toLowerCase() == 'paid')
          .fold(0.0, (sum, invoice) => sum + invoice.total);
    } catch (e) {
      print('Error calculating total revenue: $e');
      return 0.0;
    }
  }

  Future<String> _generateInvoiceNumber() async {
    try {
      final counter = _localStorage?.getInvoiceCounter() ?? 1;
      final year = DateTime.now().year;
      final month = DateTime.now().month.toString().padLeft(2, '0');
      
      return 'INV-$year$month-${counter.toString().padLeft(4, '0')}';
    } catch (e) {
      return 'INV-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Map<String, dynamic> getInvoiceStatistics() {
    try {
      final invoices = getAllInvoices();
      final totalInvoices = invoices.length;
      final paidInvoices = invoices.where((inv) => inv.status.toLowerCase() == 'paid').length;
      final pendingInvoices = invoices.where((inv) => inv.status.toLowerCase() != 'paid').length;
      final overdueInvoices = invoices.where((inv) => 
          inv.dueDate.isBefore(DateTime.now()) && 
          inv.status.toLowerCase() != 'paid').length;
      
      return {
        'totalInvoices': totalInvoices,
        'paidInvoices': paidInvoices,
        'pendingInvoices': pendingInvoices,
        'overdueInvoices': overdueInvoices,
        'totalRevenue': getTotalRevenue(),
      };
    } catch (e) {
      print('Error getting invoice statistics: $e');
      return {
        'totalInvoices': 0,
        'paidInvoices': 0,
        'pendingInvoices': 0,
        'overdueInvoices': 0,
        'totalRevenue': 0.0,
      };
    }
  }

  // Helper methods untuk invoice management
  List<Invoice> getInvoicesByStatus(String status) {
    try {
      return getAllInvoices()
          .where((invoice) => invoice.status.toLowerCase() == status.toLowerCase())
          .toList();
    } catch (e) {
      print('Error getting invoices by status: $e');
      return [];
    }
  }

  List<Invoice> getOverdueInvoices() {
    try {
      final now = DateTime.now();
      return getAllInvoices()
          .where((invoice) => 
              invoice.dueDate.isBefore(now) && 
              invoice.status.toLowerCase() != 'paid')
          .toList();
    } catch (e) {
      print('Error getting overdue invoices: $e');
      return [];
    }
  }

  List<Invoice> searchInvoices(String query) {
    try {
      final lowercaseQuery = query.toLowerCase();
      return getAllInvoices()
          .where((invoice) =>
              invoice.invoiceNumber.toLowerCase().contains(lowercaseQuery) ||
              invoice.clientName.toLowerCase().contains(lowercaseQuery) ||
              invoice.clientEmail.toLowerCase().contains(lowercaseQuery))
          .toList();
    } catch (e) {
      print('Error searching invoices: $e');
      return [];
    }
  }

  List<Invoice> getInvoicesByDateRange(DateTime startDate, DateTime endDate) {
    try {
      return getAllInvoices()
          .where((invoice) => 
              invoice.createdDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
              invoice.createdDate.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
    } catch (e) {
      print('Error getting invoices by date range: $e');
      return [];
    }
  }

  // Export dan import data
  List<Map<String, dynamic>> exportInvoicesData() {
    try {
      return getAllInvoices().map((invoice) => invoice.toJson()).toList();
    } catch (e) {
      print('Error exporting invoices data: $e');
      return [];
    }
  }

  Future<bool> clearAllInvoices() async {
    try {
      if (_hiveService == null) return false;
      
      final invoices = getAllInvoices();
      for (int i = invoices.length - 1; i >= 0; i--) {
        await _hiveService!.deleteInvoice(i);
      }
      return true;
    } catch (e) {
      print('Error clearing all invoices: $e');
      return false;
    }
  }
}
