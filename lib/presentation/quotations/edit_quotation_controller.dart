import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/quotation_repository.dart';
import '../../../data/models/quotation_model.dart';
import '../../../data/models/quotation_item_model.dart';
import '../../../data/services/local_storage_service.dart';

class EditQuotationController extends GetxController {
  final QuotationRepository _quotationRepository = Get.find<QuotationRepository>();
  LocalStorageService? _localStorage;
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<QuotationItem> items = <QuotationItem>[].obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble tax = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble total = 0.0.obs;
  final RxDouble taxRate = 11.0.obs;
  final RxString originalStatus = ''.obs;

  // Form controllers
  final clientNameController = TextEditingController();
  final clientEmailController = TextEditingController();
  final clientPhoneController = TextEditingController();
  final clientAddressController = TextEditingController();
  final clientCompanyController = TextEditingController();
  final validUntilController = TextEditingController();
  final notesController = TextEditingController();
  final discountController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();
  
  String? quotationId;
  Quotation? originalQuotation;

  @override
  void onInit() {
    super.onInit();
    quotationId = Get.arguments as String?;
    _initializeLocalStorage();
    if (quotationId != null) {
      loadQuotation();
    }
  }

  @override
  void onClose() {
    clientNameController.dispose();
    clientEmailController.dispose();
    clientPhoneController.dispose();
    clientAddressController.dispose();
    clientCompanyController.dispose();
    validUntilController.dispose();
    notesController.dispose();
    discountController.dispose();
    super.onClose();
  }

  Future<void> _initializeLocalStorage() async {
    try {
      _localStorage = await LocalStorageService.getInstance();
      if (_localStorage != null) {
        taxRate.value = _localStorage!.getTaxRate();
      }
    } catch (e) {
      print('Error initializing LocalStorage: $e');
    }
  }

  void loadQuotation() {
    try {
      isLoading.value = true;
      
      if (quotationId != null) {
        originalQuotation = _quotationRepository.getQuotationById(quotationId!);
        
        if (originalQuotation == null) {
          Get.snackbar('Error', 'Quotation tidak ditemukan');
          Get.back();
          return;
        }

        // Populate form fields
        clientNameController.text = originalQuotation!.clientName;
        clientEmailController.text = originalQuotation!.clientEmail;
        clientPhoneController.text = originalQuotation!.clientPhone;
        clientAddressController.text = originalQuotation!.clientAddress;
        clientCompanyController.text = originalQuotation!.clientCompany ?? '';
        validUntilController.text = '${originalQuotation!.validUntil.day}/${originalQuotation!.validUntil.month}/${originalQuotation!.validUntil.year}';
        notesController.text = originalQuotation!.notes ?? '';
        discountController.text = originalQuotation!.discount.toString();
        
        // Set original status
        originalStatus.value = originalQuotation!.status;
        
        // Load items
        items.value = List<QuotationItem>.from(originalQuotation!.items);
        
        // Calculate totals
        calculateTotals();
        
        print('✅ Quotation loaded for editing: ${originalQuotation!.quotationNumber}');
      }
    } catch (e) {
      print('❌ Error loading quotation: $e');
      Get.snackbar('Error', 'Gagal memuat quotation');
    } finally {
      isLoading.value = false;
    }
  }

  void addItem() {
    Get.dialog(_buildAddItemDialog());
  }

  void editItem(int index) {
    final item = items[index];
    Get.dialog(_buildAddItemDialog(item: item, index: index));
  }

  void removeItem(int index) {
    items.removeAt(index);
    calculateTotals();
  }

  void calculateTotals() {
    subtotal.value = items.fold(0.0, (sum, item) => sum + item.total);
    tax.value = (subtotal.value * taxRate.value) / 100;
    
    final discountValue = double.tryParse(discountController.text) ?? 0.0;
    discount.value = discountValue;
    
    total.value = subtotal.value + tax.value - discount.value;
  }

  Future<void> updateQuotation({bool isDraft = true}) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (items.isEmpty) {
      Get.snackbar('Error', 'Tambahkan minimal satu item quotation');
      return;
    }

    if (originalQuotation == null) {
      Get.snackbar('Error', 'Data quotation asli tidak ditemukan');
      return;
    }

    try {
      isLoading.value = true;

      final validUntil = _parseDateFromString(validUntilController.text);
      if (validUntil == null) {
        Get.snackbar('Error', 'Format tanggal berlaku sampai tidak valid');
        return;
      }

      // Determine new status
      String newStatus;
      if (isDraft) {
        newStatus = 'draft';
      } else {
        // Keep original status if not saving as draft, unless it was draft
        newStatus = originalStatus.value == 'draft' ? 'sent' : originalStatus.value;
      }

      final updatedQuotation = originalQuotation!.copyWith(
        clientName: clientNameController.text.trim(),
        clientEmail: clientEmailController.text.trim(),
        clientPhone: clientPhoneController.text.trim(),
        clientAddress: clientAddressController.text.trim(),
        clientCompany: clientCompanyController.text.trim().isEmpty 
            ? null 
            : clientCompanyController.text.trim(),
        validUntil: validUntil,
        items: items.toList(),
        subtotal: subtotal.value,
        tax: tax.value,
        discount: discount.value,
        total: total.value,
        status: newStatus,
        notes: notesController.text.trim().isEmpty 
            ? null 
            : notesController.text.trim(),
      );

      final success = await _quotationRepository.updateQuotation(updatedQuotation);
      
      if (success) {
        Get.snackbar(
          'Berhasil',
          'Quotation berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate back to quotation detail
        Get.offNamed('/quotation-detail', arguments: quotationId);
      } else {
        Get.snackbar('Error', 'Gagal memperbarui quotation');
      }
    } catch (e) {
      print('❌ Error updating quotation: $e');
      Get.snackbar('Error', 'Gagal memperbarui quotation');
    } finally {
      isLoading.value = false;
    }
  }

  DateTime? _parseDateFromString(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return null;
  }

  Widget _buildAddItemDialog({QuotationItem? item, int? index}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descriptionController = TextEditingController(text: item?.description ?? '');
    final quantityController = TextEditingController(text: item?.quantity.toString() ?? '1');
    final priceController = TextEditingController(text: item?.price.toString() ?? '');
    final itemDiscountController = TextEditingController(text: item?.discount.toString() ?? '0');

    return AlertDialog(
      title: Text(item == null ? 'Tambah Item' : 'Edit Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Item',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga Satuan',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: itemDiscountController,
              decoration: const InputDecoration(
                labelText: 'Diskon',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text.trim();
            final description = descriptionController.text.trim();
            final quantity = int.tryParse(quantityController.text) ?? 1;
            final price = double.tryParse(priceController.text) ?? 0.0;
            final itemDiscount = double.tryParse(itemDiscountController.text) ?? 0.0;

            if (name.isEmpty || description.isEmpty || price <= 0) {
              Get.snackbar('Error', 'Lengkapi semua field dengan benar');
              return;
            }

            final newItem = QuotationItem(
              id: QuotationItem.generateId(),
              name: name,
              description: description,
              quantity: quantity,
              price: price,
              discount: itemDiscount,
            );

            if (index != null) {
              items[index] = newItem;
            } else {
              items.add(newItem);
            }

            calculateTotals();
            Get.back();
          },
          child: Text(item == null ? 'Tambah' : 'Update'),
        ),
      ],
    );
  }

  bool get canEdit {
    // Can edit if status is draft or sent (not accepted/rejected)
    return originalStatus.value != 'accepted' && originalStatus.value != 'rejected';
  }

  void showEditRestrictedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Tidak Dapat Mengedit'),
        content: const Text('Quotation yang sudah diterima atau ditolak tidak dapat diedit.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
