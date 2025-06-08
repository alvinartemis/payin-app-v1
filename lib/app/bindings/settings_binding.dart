import 'package:get/get.dart';
import '../../presentation/settings/settings_controller.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/email_service.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan services tersedia
    if (!Get.isRegistered<LocalStorageService>()) {
      Get.putAsync<LocalStorageService>(() => LocalStorageService.getInstance());
    }
    
    if (!Get.isRegistered<EmailService>()) {
      Get.lazyPut<EmailService>(() => EmailService());
    }
    
    // Settings Controller
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
      fenix: true,
    );
    
    print('✅ Settings bindings registered');
  }
}
