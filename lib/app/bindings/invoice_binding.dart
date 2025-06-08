import 'package:get/get.dart';
import '../../presentation/invoice/invoice_list_controller.dart';
import '../../presentation/invoice/create_invoice_controller.dart';
import '../../presentation/invoice/invoice_detail_controller.dart';
import '../../presentation/invoice/edit_invoice_controller.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../data/services/pdf_service.dart';
import '../../data/services/email_service.dart';

class InvoiceBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan dependencies tersedia
    if (!Get.isRegistered<InvoiceRepository>()) {
      Get.lazyPut<InvoiceRepository>(() => InvoiceRepository());
    }
    
    if (!Get.isRegistered<PdfService>()) {
      Get.lazyPut<PdfService>(() => PdfService());
    }
    
    if (!Get.isRegistered<EmailService>()) {
      Get.lazyPut<EmailService>(() => EmailService());
    }
    
    // Invoice Controllers
    Get.lazyPut<InvoiceListController>(
      () => InvoiceListController(),
      fenix: true,
    );
    
    Get.lazyPut<CreateInvoiceController>(
      () => CreateInvoiceController(),
      fenix: true,
    );
    
    Get.lazyPut<InvoiceDetailController>(
      () => InvoiceDetailController(),
      fenix: true,
    );
    
    Get.lazyPut<EditInvoiceController>(
      () => EditInvoiceController(),
      fenix: true,
    );
    
    print('✅ Invoice bindings registered');
  }
}
