import 'package:get/get.dart';
import '../../presentation/quotations/quotation_list_controller.dart';
import '../../presentation/quotations/create_quotation_controller.dart';
import '../../presentation/quotations/quotation_detail_controller.dart';
import '../../presentation/quotations/edit_quotation_controller.dart';
import '../../data/repositories/quotation_repository.dart';

class QuotationBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    if (!Get.isRegistered<QuotationRepository>()) {
      Get.lazyPut<QuotationRepository>(() => QuotationRepository());
    }
    
    // Controllers
    Get.lazyPut<QuotationListController>(() => QuotationListController());
    Get.lazyPut<CreateQuotationController>(() => CreateQuotationController());
    Get.lazyPut<QuotationDetailController>(() => QuotationDetailController());
    Get.lazyPut<EditQuotationController>(() => EditQuotationController());
  }
}
