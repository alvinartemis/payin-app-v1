import 'package:get/get.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/pdf_service.dart';
import '../../data/services/email_service.dart';
//import '../../data/services/hive_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services - Lazy loading untuk optimasi performa
    Get.putAsync<LocalStorageService>(() => LocalStorageService.getInstance());
    
    Get.lazyPut<PdfService>(
      () => PdfService(),
      fenix: true,
    );
    
    Get.lazyPut<EmailService>(
      () => EmailService(),
      fenix: true,
    );
    
    // HiveService sudah di-register di main.dart, jadi tidak perlu di sini
    
    // Repositories - Lazy loading
    Get.lazyPut<InvoiceRepository>(
      () => InvoiceRepository(),
      fenix: true,
    );
    
    Get.lazyPut<AnalyticsRepository>(
      () => AnalyticsRepository(),
      fenix: true,
    );
    
    print('✅ Initial bindings registered successfully');
  }
}
