import 'package:get/get.dart';
import '../../presentation/analytics/analytics_controller.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/invoice_repository.dart';

class AnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan repositories tersedia
    if (!Get.isRegistered<InvoiceRepository>()) {
      Get.lazyPut<InvoiceRepository>(() => InvoiceRepository());
    }
    
    if (!Get.isRegistered<AnalyticsRepository>()) {
      Get.lazyPut<AnalyticsRepository>(() => AnalyticsRepository());
    }
    
    // Analytics Controller
    Get.lazyPut<AnalyticsController>(
      () => AnalyticsController(),
      fenix: true,
    );
    
    print('✅ Analytics bindings registered');
  }
}
