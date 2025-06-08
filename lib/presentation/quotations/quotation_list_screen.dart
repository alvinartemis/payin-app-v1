import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quotation_list_controller.dart';
import 'widgets/quotation_card.dart';

class QuotationListScreen extends GetView<QuotationListController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Daftar Quotation'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.navigateToCreateQuotation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilter(),
          
          // Quotation List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredQuotations.isEmpty) {
                return _buildEmptyState();
              }
              
              return RefreshIndicator(
                onRefresh: controller.loadQuotations,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredQuotations.length,
                  itemBuilder: (context, index) {
                    final quotation = controller.filteredQuotations[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: QuotationCard(
                        quotation: quotation,
                        onTap: () => controller.navigateToQuotationDetail(quotation.id),
                        onEdit: () => Get.toNamed('/edit-quotation', arguments: quotation.id),
                        onDelete: () => _showDeleteDialog(quotation.id),
                        onDuplicate: () => _duplicateQuotation(quotation.id),
                        onGeneratePdf: () => _generatePdf(quotation.id),
                        onSendEmail: () => _sendEmail(quotation.id),
                        onStatusChange: (newStatus) => _updateStatus(quotation.id, newStatus),
                        onConvertToInvoice: () => _convertToInvoice(quotation.id),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.navigateToCreateQuotation,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Cari quotation...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.searchQuery.value = '';
                        controller.filterQuotations();
                      },
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              controller.searchQuery.value = value;
              controller.filterQuotations();
            },
          ),
          
          const SizedBox(height: 16),
          
          // Status Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
              children: _getStatusOptions().map((status) {
                final isSelected = controller.selectedStatus.value == (status['value'] ?? '');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    // PERBAIKAN: Menggunakan null safety operator sesuai search results
                    label: Text(status['label'] ?? ''),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        // PERBAIKAN: Menggunakan null safety operator sesuai search results
                        controller.selectedStatus.value = status['value'] ?? '';
                        controller.filterQuotations();
                      }
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue,
                  ),
                );
              }).toList(),
            )),
          ),
        ],
      ),
    );
  }

List<Map<String, String>> _getStatusOptions() {
  return [
    {'value': 'all', 'label': 'Semua'},
    {'value': 'draft', 'label': 'Draft'},
    {'value': 'sent', 'label': 'Terkirim'},
    {'value': 'accepted', 'label': 'Diterima'},
    {'value': 'rejected', 'label': 'Ditolak'},
    {'value': 'expired', 'label': 'Kedaluwarsa'},
  ];
}

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.request_quote_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada quotation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat quotation pertama Anda untuk memulai',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.navigateToCreateQuotation,
            icon: const Icon(Icons.add),
            label: const Text('Buat Quotation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _showDeleteDialog(String quotationId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus quotation ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteQuotation(quotationId);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteQuotation(String quotationId) {
    // Implementation will be added when repository methods are ready
    Get.snackbar('Info', 'Fitur hapus quotation sedang dikembangkan');
  }

  void _duplicateQuotation(String quotationId) {
    // Implementation will be added when repository methods are ready
    Get.snackbar('Info', 'Fitur duplikasi quotation sedang dikembangkan');
  }

  void _generatePdf(String quotationId) {
    // Implementation will be added when PDF service is ready
    Get.snackbar('Info', 'Fitur PDF quotation sedang dikembangkan');
  }

  void _sendEmail(String quotationId) {
    // Implementation will be added when email service is ready
    Get.snackbar('Info', 'Fitur kirim email quotation sedang dikembangkan');
  }

  void _updateStatus(String quotationId, String newStatus) {
    // Implementation will be added when repository methods are ready
    Get.snackbar('Info', 'Status quotation berhasil diubah ke $newStatus');
  }

  void _convertToInvoice(String quotationId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konversi ke Invoice'),
        content: const Text('Apakah Anda yakin ingin mengkonversi quotation ini menjadi invoice?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Implementation will be added when repository methods are ready
              Get.snackbar('Info', 'Fitur konversi ke invoice sedang dikembangkan');
            },
            child: const Text('Konversi'),
          ),
        ],
      ),
    );
  }
}
