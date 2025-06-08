import 'dart:typed_data';
import 'package:emailjs/emailjs.dart' as emailjs;
import '../models/invoice_model.dart';
import '../models/quotation_model.dart';
import 'local_storage_service.dart';

class EmailService {
  LocalStorageService? _localStorage;
  
  // EmailJS configuration sesuai search results
  static const String _serviceId = 'YOUR_SERVICE_ID';
  static const String _publicKey = 'YOUR_PUBLIC_KEY';
  static const String _invoiceTemplateId = 'YOUR_INVOICE_TEMPLATE_ID';
  static const String _quotationTemplateId = 'YOUR_QUOTATION_TEMPLATE_ID'; // TAMBAHAN

  Future<void> _initLocalStorage() async {
    _localStorage ??= await LocalStorageService.getInstance();
  }

  // PERBAIKAN: Tambahkan method sendQuotationEmail sesuai search results
  Future<bool> sendQuotationEmail({
    required Quotation quotation,
    required Uint8List pdfBytes,
  }) async {
    try {
      await _initLocalStorage();
      
      final businessInfo = _localStorage?.getBusinessInfo();
      
      // Template parameters untuk quotation sesuai memory entries
      final templateParams = {
        'to_email': quotation.clientEmail,
        'to_name': quotation.clientName,
        'from_name': businessInfo?['name'] ?? 'pay.in Business',
        'from_email': businessInfo?['email'] ?? 'business@payin.com',
        'quotation_number': quotation.quotationNumber,
        'quotation_total': quotation.formattedTotal,
        'valid_until': '${quotation.validUntil.day}/${quotation.validUntil.month}/${quotation.validUntil.year}',
        'client_company': quotation.clientCompany ?? '',
        'message': _getQuotationEmailMessage(quotation),
        'pdf_attachment': pdfBytes, // PDF sebagai attachment
      };

      // Send email menggunakan EmailJS sesuai search results
      await emailjs.send(
        _serviceId,
        _quotationTemplateId,
        templateParams,
        const emailjs.Options(
          publicKey: _publicKey,
        ),
      );

      print('✅ Quotation email sent successfully');
      return true;
    } catch (error) {
      if (error is emailjs.EmailJSResponseStatus) {
        print('❌ Email error: ${error.status}: ${error.text}');
      } else {
        print('❌ Error sending quotation email: $error');
      }
      return false;
    }
  }

  // Method untuk invoice (existing)
  Future<bool> sendInvoiceEmail({
    required Invoice invoice,
    required Uint8List pdfBytes,
  }) async {
    try {
      await _initLocalStorage();
      
      final businessInfo = _localStorage?.getBusinessInfo();
      
      final templateParams = {
        'to_email': invoice.clientEmail,
        'to_name': invoice.clientName,
        'from_name': businessInfo?['name'] ?? 'pay.in Business',
        'from_email': businessInfo?['email'] ?? 'business@payin.com',
        'invoice_number': invoice.invoiceNumber,
        'invoice_total': invoice.formattedTotal,
        'due_date': '${invoice.dueDate.day}/${invoice.dueDate.month}/${invoice.dueDate.year}',
        'client_company': invoice.clientCompany ?? '',
        'message': _getInvoiceEmailMessage(invoice),
        'pdf_attachment': pdfBytes,
      };

      await emailjs.send(
        _serviceId,
        _invoiceTemplateId,
        templateParams,
        const emailjs.Options(
          publicKey: _publicKey,
        ),
      );

      print('✅ Invoice email sent successfully');
      return true;
    } catch (error) {
      if (error is emailjs.EmailJSResponseStatus) {
        print('❌ Email error: ${error.status}: ${error.text}');
      } else {
        print('❌ Error sending invoice email: $error');
      }
      return false;
    }
  }

  // Helper method untuk quotation email message
  String _getQuotationEmailMessage(Quotation quotation) {
    return '''
Halo ${quotation.clientName},

Terima kasih atas minat Anda terhadap layanan kami. Terlampir adalah quotation ${quotation.quotationNumber} dengan rincian sebagai berikut:

- Nomor Quotation: ${quotation.quotationNumber}
- Total: ${quotation.formattedTotal}
- Berlaku Sampai: ${quotation.validUntil.day}/${quotation.validUntil.month}/${quotation.validUntil.year}

${quotation.notes != null ? '\nCatatan:\n${quotation.notes}' : ''}

Quotation ini berlaku sampai tanggal yang tertera. Jika Anda memiliki pertanyaan atau ingin melanjutkan dengan pesanan, silakan hubungi kami.

Terima kasih,
${_localStorage?.getBusinessInfo()?['name'] ?? 'pay.in Business'}
''';
  }

  // Helper method untuk invoice email message
  String _getInvoiceEmailMessage(Invoice invoice) {
    return '''
Halo ${invoice.clientName},

Terima kasih atas kepercayaan Anda. Terlampir adalah invoice ${invoice.invoiceNumber} dengan rincian sebagai berikut:

- Nomor Invoice: ${invoice.invoiceNumber}
- Total: ${invoice.formattedTotal}
- Jatuh Tempo: ${invoice.dueDate.day}/${invoice.dueDate.month}/${invoice.dueDate.year}

${invoice.notes != null ? '\nCatatan:\n${invoice.notes}' : ''}

Mohon untuk melakukan pembayaran sebelum tanggal jatuh tempo.

Terima kasih,
${_localStorage?.getBusinessInfo()?['name'] ?? 'pay.in Business'}
''';
  }

  // Method untuk test email connection
  Future<bool> testEmailConnection() async {
    try {
      final templateParams = {
        'to_email': 'test@example.com',
        'to_name': 'Test User',
        'from_name': 'pay.in Test',
        'message': 'Test email connection',
      };

      await emailjs.send(
        _serviceId,
        _quotationTemplateId,
        templateParams,
        const emailjs.Options(
          publicKey: _publicKey,
        ),
      );

      return true;
    } catch (error) {
      print('❌ Email connection test failed: $error');
      return false;
    }
  }

  // Method untuk setup email configuration
  Future<bool> setupEmailConfig({
    required String serviceId,
    required String publicKey,
    required String invoiceTemplateId,
    required String quotationTemplateId,
  }) async {
    try {
      await _initLocalStorage();
      
      final emailConfig = {
        'serviceId': serviceId,
        'publicKey': publicKey,
        'invoiceTemplateId': invoiceTemplateId,
        'quotationTemplateId': quotationTemplateId,
      };

      await _localStorage!.setString('email_config', emailConfig.toString());
      return true;
    } catch (e) {
      print('❌ Error saving email config: $e');
      return false;
    }
  }
}
