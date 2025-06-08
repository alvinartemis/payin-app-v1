import 'package:get/get.dart';
import 'dart:convert'; // IMPORT INI YANG HILANG untuk jsonDecode dan jsonEncode
import '../models/quotation_model.dart';
import '../services/hive_service.dart';
import '../services/local_storage_service.dart';

class QuotationRepository extends GetxService {
  HiveService? _hiveService;
  LocalStorageService? _localStorage;
  
  static const String _quotationKey = 'quotations_data';

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      _hiveService = Get.find<HiveService>();
      _localStorage = await LocalStorageService.getInstance();
    } catch (e) {
      print('Error initializing QuotationRepository: $e');
    }
  }

  Future<String> createQuotation(Quotation quotation) async {
    try {
      final quotationWithNumber = quotation.copyWith(
        quotationNumber: quotation.quotationNumber.isEmpty 
            ? await _generateQuotationNumber() 
            : quotation.quotationNumber,
      );

      // Save using SharedPreferences through LocalStorageService
      final quotations = getAllQuotations();
      quotations.add(quotationWithNumber);
      await _saveQuotations(quotations);
      
      return quotationWithNumber.id;
    } catch (e) {
      throw Exception('Gagal membuat quotation: $e');
    }
  }

  List<Quotation> getAllQuotations() {
    try {
      if (_localStorage == null) return [];
      
      // PERBAIKAN: Menggunakan method yang benar
      final quotationsJson = _localStorage!.getStringList(_quotationKey) ?? [];
      return quotationsJson
          .map((jsonString) {
            try {
              // PERBAIKAN: jsonDecode sudah tersedia karena import dart:convert
              return Quotation.fromJson(jsonDecode(jsonString));
            } catch (e) {
              return null;
            }
          })
          .where((quotation) => quotation != null)
          .cast<Quotation>()
          .toList();
    } catch (e) {
      print('Error getting all quotations: $e');
      return [];
    }
  }

  Quotation? getQuotationById(String id) {
    try {
      final quotations = getAllQuotations();
      return quotations.firstWhere(
        (quotation) => quotation.id == id,
        orElse: () => throw Exception('Quotation not found'),
      );
    } catch (e) {
      print('Error getting quotation by ID: $e');
      return null;
    }
  }

  Future<bool> updateQuotation(Quotation quotation) async {
    try {
      final quotations = getAllQuotations();
      final index = quotations.indexWhere((q) => q.id == quotation.id);
      
      if (index != -1) {
        quotations[index] = quotation;
        await _saveQuotations(quotations);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating quotation: $e');
      return false;
    }
  }

  Future<bool> deleteQuotation(String id) async {
    try {
      final quotations = getAllQuotations();
      quotations.removeWhere((quotation) => quotation.id == id);
      await _saveQuotations(quotations);
      return true;
    } catch (e) {
      print('Error deleting quotation: $e');
      return false;
    }
  }

  Future<bool> updateQuotationStatus(String id, String status) async {
    try {
      final quotation = getQuotationById(id);
      if (quotation != null) {
        final updatedQuotation = quotation.copyWith(status: status);
        return await updateQuotation(updatedQuotation);
      }
      return false;
    } catch (e) {
      print('Error updating quotation status: $e');
      return false;
    }
  }

  Future<String> duplicateQuotation(String id) async {
    try {
      final originalQuotation = getQuotationById(id);
      if (originalQuotation == null) {
        throw Exception('Quotation tidak ditemukan');
      }

      final newId = Quotation.generateId();
      final newQuotationNumber = await _generateQuotationNumber();
      
      final duplicatedQuotation = originalQuotation.copyWith(
        id: newId,
        quotationNumber: newQuotationNumber,
        createdDate: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 14)),
        status: 'draft',
      );

      await createQuotation(duplicatedQuotation);
      return newId;
    } catch (e) {
      print('❌ Error duplicating quotation: $e');
      throw Exception('Gagal menduplikasi quotation: $e');
    }
  }

  Future<String?> convertQuotationToInvoice(String quotationId) async {
    try {
      final quotation = getQuotationById(quotationId);
      if (quotation == null) return null;

      // Convert quotation to invoice (implementation depends on your invoice model)
      // This is a placeholder - you'll need to implement based on your invoice structure
      print('Converting quotation ${quotation.quotationNumber} to invoice');
      
      // Return mock invoice ID for now
      return 'inv_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('Error converting quotation to invoice: $e');
      return null;
    }
  }

  Future<void> _saveQuotations(List<Quotation> quotations) async {
    try {
      if (_localStorage == null) return;
      
      final quotationsJson = quotations
          .map((quotation) => jsonEncode(quotation.toJson()))
          .toList();
      
      // PERBAIKAN: Menggunakan method yang benar
      await _localStorage!.setStringList(_quotationKey, quotationsJson);
    } catch (e) {
      print('Error saving quotations: $e');
    }
  }

  Future<String> _generateQuotationNumber() async {
    try {
      // PERBAIKAN: Menggunakan method yang benar
      final counter = _localStorage?.getQuotationCounter() ?? 1;
      final year = DateTime.now().year;
      final month = DateTime.now().month.toString().padLeft(2, '0');
      
      // PERBAIKAN: Menggunakan method yang benar
      await _localStorage?.incrementQuotationCounter();
      return 'QUO-$year$month-${counter.toString().padLeft(4, '0')}';
    } catch (e) {
      return 'QUO-${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}
