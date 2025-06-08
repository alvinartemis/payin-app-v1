import 'package:get/get.dart';
import '../../presentation/dashboard/dashboard_controller.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../data/repositories/analytics_repository.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan repositories tersedia
    if (!Get.isRegistered<InvoiceRepository>()) {
      Get.lazyPut<InvoiceRepository>(() => InvoiceRepository());
    }
    
    if (!Get.isRegistered<AnalyticsRepository>()) {
      Get.lazyPut<AnalyticsRepository>(() => AnalyticsRepository());
    }
    
    // Dashboard Controller
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
      fenix: true,
    );
    
    print('✅ Dashboard bindings registered');
  }
}
