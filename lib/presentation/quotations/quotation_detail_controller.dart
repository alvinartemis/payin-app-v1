import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/quotation_repository.dart';
import '../../../data/models/quotation_model.dart';
import '../../../data/services/pdf_service.dart';
import '../../../data/services/email_service.dart';

class QuotationDetailController extends GetxController {
  final QuotationRepository _quotationRepository = Get.find<QuotationRepository>();
  final PdfService _pdfService = Get.find<PdfService>();
  final EmailService _emailService = Get.find<EmailService>();
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final Rx<Quotation?> quotation = Rx<Quotation?>(null);
  
  String? quotationId;

  @override
  void onInit() {
    super.onInit();
    quotationId = Get.arguments as String?;
    if (quotationId != null) {
      loadQuotation();
    }
  }

  void loadQuotation() {
    try {
      isLoading.value = true;
      
      if (quotationId != null) {
        final loadedQuotation = _quotationRepository.getQuotationById(quotationId!);
        quotation.value = loadedQuotation;
        
        if (loadedQuotation == null) {
          Get.snackbar('Error', 'Quotation tidak ditemukan');
          Get.back();
        }
      }
    } catch (e) {
      print('❌ Error loading quotation: $e');
      Get.snackbar('Error', 'Gagal memuat quotation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String newStatus) async {
    try {
      if (quotationId == null) return;
      
      isLoading.value = true;
      
      final success = await _quotationRepository.updateQuotationStatus(quotationId!, newStatus);
      if (success) {
        loadQuotation(); // Reload to get updated data
        Get.snackbar(
          'Berhasil',
          'Status quotation berhasil diubah',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error updating status: $e');
      Get.snackbar('Error', 'Gagal mengubah status quotation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generatePdf() async {
    try {
      if (quotation.value == null) return;
      
      isLoading.value = true;
      
      final pdfBytes = await _pdfService.generateQuotationPdf(quotation.value!);
      await _pdfService.sharePdf(pdfBytes, 'Quotation_${quotation.value!.quotationNumber}');
      
      Get.snackbar(
        'Berhasil',
        'PDF quotation berhasil dibuat',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error generating PDF: $e');
      Get.snackbar('Error', 'Gagal membuat PDF quotation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendEmail() async {
    try {
      if (quotation.value == null) return;
      
      isLoading.value = true;
      
      final pdfBytes = await _pdfService.generateQuotationPdf(quotation.value!);
      final success = await _emailService.sendQuotationEmail(
        quotation: quotation.value!,
        pdfBytes: pdfBytes,
      );
      
      if (success) {
        await updateStatus('sent');
        Get.snackbar(
          'Berhasil',
          'Quotation berhasil dikirim via email',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Gagal mengirim email quotation');
      }
    } catch (e) {
      print('❌ Error sending email: $e');
      Get.snackbar('Error', 'Gagal mengirim email quotation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> convertToInvoice() async {
    try {
      if (quotation.value == null) return;
      
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Konversi ke Invoice'),
          content: const Text('Apakah Anda yakin ingin mengkonversi quotation ini menjadi invoice?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Konversi'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        isLoading.value = true;
        
        // Create invoice from quotation
        final invoiceId = await _quotationRepository.convertQuotationToInvoice(quotationId!);
        
        if (invoiceId != null) {
          // Update quotation status to accepted
          await updateStatus('accepted');
          
          Get.snackbar(
            'Berhasil',
            'Quotation berhasil dikonversi menjadi invoice',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          
          // Navigate to invoice detail
          Get.offNamed('/invoice-detail', arguments: invoiceId);
        }
      }
    } catch (e) {
      print('❌ Error converting to invoice: $e');
      Get.snackbar('Error', 'Gagal mengkonversi quotation ke invoice');
    } finally {
      isLoading.value = false;
    }
  }

  void editQuotation() {
    if (quotationId != null && canEdit) {
      Get.toNamed('/edit-quotation', arguments: quotationId);
    } else {
      showEditRestrictedDialog();
    }
  }

  Future<void> deleteQuotation() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin menghapus quotation ini?'),
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
      
      if (confirmed == true && quotationId != null) {
        isLoading.value = true;
        
        final success = await _quotationRepository.deleteQuotation(quotationId!);
        if (success) {
          Get.snackbar(
            'Berhasil',
            'Quotation berhasil dihapus',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.offAllNamed('/quotation-list');
        }
      }
    } catch (e) {
      print('❌ Error deleting quotation: $e');
      Get.snackbar('Error', 'Gagal menghapus quotation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> duplicateQuotation() async {
    try {
      if (quotationId == null) return;
      
      isLoading.value = true;
      
      final newQuotationId = await _quotationRepository.duplicateQuotation(quotationId!);
      
      Get.snackbar(
        'Berhasil',
        'Quotation berhasil diduplikasi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Navigate to edit the duplicated quotation
      Get.toNamed('/edit-quotation', arguments: newQuotationId);
    } catch (e) {
      print('❌ Error duplicating quotation: $e');
      Get.snackbar('Error', 'Gagal menduplikasi quotation');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'sent':
        return Colors.blue;
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
      case 'accepted':
        return 'Diterima';
      case 'sent':
        return 'Terkirim';
      case 'rejected':
        return 'Ditolak';
      case 'expired':
        return 'Kedaluwarsa';
      case 'draft':
        return 'Draft';
      default:
        return status;
    }
  }

  bool get canEdit {
    if (quotation.value == null) return false;
    // Can edit if status is draft or sent (not accepted/rejected/expired)
    final status = quotation.value!.status.toLowerCase();
    return status == 'draft' || status == 'sent';
  }

  bool get canConvertToInvoice {
    if (quotation.value == null) return false;
    // Can convert if status is sent and not expired
    final status = quotation.value!.status.toLowerCase();
    return status == 'sent' && !quotation.value!.isExpired;
  }

  bool get isExpired {
    if (quotation.value == null) return false;
    return quotation.value!.isExpired;
  }

  void showEditRestrictedDialog() {
    String message = 'Quotation ini tidak dapat diedit.';
    
    if (quotation.value != null) {
      final status = quotation.value!.status.toLowerCase();
      if (status == 'accepted') {
        message = 'Quotation yang sudah diterima tidak dapat diedit.';
      } else if (status == 'rejected') {
        message = 'Quotation yang sudah ditolak tidak dapat diedit.';
      } else if (status == 'expired') {
        message = 'Quotation yang sudah kedaluwarsa tidak dapat diedit.';
      }
    }
    
    Get.dialog(
      AlertDialog(
        title: const Text('Tidak Dapat Mengedit'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Quick actions for different statuses
  void markAsAccepted() {
    updateStatus('accepted');
  }

  void markAsRejected() {
    updateStatus('rejected');
  }

  void markAsSent() {
    updateStatus('sent');
  }

  // Get available actions based on current status
  List<Map<String, dynamic>> getAvailableActions() {
    if (quotation.value == null) return [];
    
    final status = quotation.value!.status.toLowerCase();
    final actions = <Map<String, dynamic>>[];
    
    // Edit action
    if (canEdit) {
      actions.add({
        'title': 'Edit',
        'icon': Icons.edit,
        'color': Colors.blue,
        'action': editQuotation,
      });
    }
    
    // Send action
    if (status == 'draft') {
      actions.add({
        'title': 'Kirim',
        'icon': Icons.send,
        'color': Colors.green,
        'action': sendEmail,
      });
    }
    
    // Convert to invoice action
    if (canConvertToInvoice) {
      actions.add({
        'title': 'Buat Invoice',
        'icon': Icons.receipt_long,
        'color': Colors.purple,
        'action': convertToInvoice,
      });
    }
    
    // PDF action
    actions.add({
      'title': 'PDF',
      'icon': Icons.picture_as_pdf,
      'color': Colors.red,
      'action': generatePdf,
    });
    
    // Duplicate action
    actions.add({
      'title': 'Duplikasi',
      'icon': Icons.copy,
      'color': Colors.orange,
      'action': duplicateQuotation,
    });
    
    // Status actions
    if (status == 'sent' && !isExpired) {
      actions.add({
        'title': 'Tandai Diterima',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'action': markAsAccepted,
      });
      
      actions.add({
        'title': 'Tandai Ditolak',
        'icon': Icons.cancel,
        'color': Colors.red,
        'action': markAsRejected,
      });
    }
    
    // Delete action (only for draft)
    if (status == 'draft') {
      actions.add({
        'title': 'Hapus',
        'icon': Icons.delete,
        'color': Colors.red,
        'action': deleteQuotation,
      });
    }
    
    return actions;
  }

  // Get days until expiry
  int get daysUntilExpiry {
    if (quotation.value == null) return 0;
    return quotation.value!.validUntil.difference(DateTime.now()).inDays;
  }

  // Get expiry status text
  String get expiryStatusText {
    if (quotation.value == null) return '';
    
    final days = daysUntilExpiry;
    if (days < 0) {
      return 'Kedaluwarsa ${days.abs()} hari yang lalu';
    } else if (days == 0) {
      return 'Kedaluwarsa hari ini';
    } else if (days == 1) {
      return 'Kedaluwarsa besok';
    } else {
      return 'Berlaku $days hari lagi';
    }
  }
}
