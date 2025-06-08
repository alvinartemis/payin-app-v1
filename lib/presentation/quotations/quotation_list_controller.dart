import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/quotation_repository.dart';
import '../../../data/models/quotation_model.dart';

class QuotationListController extends GetxController {
  final QuotationRepository _quotationRepository = Get.find<QuotationRepository>();
  
  final RxBool isLoading = false.obs;
  final RxList<Quotation> quotations = <Quotation>[].obs;
  final RxList<Quotation> filteredQuotations = <Quotation>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'all'.obs;
  
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadQuotations();
  }

  Future<void> loadQuotations() async {
    try {
      isLoading.value = true;
      
      final allQuotations = _quotationRepository.getAllQuotations();
      allQuotations.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      
      quotations.value = allQuotations;
      filterQuotations();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar quotation');
    } finally {
      isLoading.value = false;
    }
  }

  void filterQuotations() {
    var filtered = quotations.toList();
    
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((quotation) =>
          quotation.quotationNumber.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          quotation.clientName.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    if (selectedStatus.value != 'all') {
      filtered = filtered.where((quotation) => 
          quotation.status.toLowerCase() == selectedStatus.value.toLowerCase()).toList();
    }
    
    filteredQuotations.value = filtered;
  }

  void navigateToCreateQuotation() {
    Get.toNamed('/create-quotation');
  }

  void navigateToQuotationDetail(String quotationId) {
    Get.toNamed('/quotation-detail', arguments: quotationId);
  }
}
