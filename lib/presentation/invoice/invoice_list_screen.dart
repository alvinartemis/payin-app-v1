import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'invoice_list_controller.dart';
import 'widgets/invoice_card.dart';

class InvoiceListScreen extends GetView<InvoiceListController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Daftar Invoice'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.navigateToCreateInvoice,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilter(),
          
          // Invoice List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredInvoices.isEmpty) {
                return _buildEmptyState();
              }
              
              return RefreshIndicator(
                onRefresh: controller.loadInvoices,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredInvoices.length,
                  itemBuilder: (context, index) {
                    final invoice = controller.filteredInvoices[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InvoiceCard(
                        invoice: invoice,
                        onTap: () => controller.navigateToInvoiceDetail(invoice.id),
                        onEdit: () => controller.navigateToEditInvoice(invoice.id),
                        onDelete: () => controller.deleteInvoice(invoice.id),
                        onDuplicate: () => controller.duplicateInvoice(invoice.id),
                        onGeneratePdf: () => controller.generatePdf(invoice.id),
                        onSendEmail: () => controller.sendInvoiceEmail(invoice.id),
                        onStatusChange: (newStatus) => 
                            controller.updateInvoiceStatus(invoice.id, newStatus),
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
        onPressed: controller.navigateToCreateInvoice,
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
              hintText: 'Cari invoice...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
              children: controller.statusOptions.map((status) {
                final isSelected = controller.selectedStatus.value == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(controller.getStatusFilterText(status)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        controller.changeStatusFilter(status);
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada invoice',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat invoice pertama Anda untuk memulai',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.navigateToCreateInvoice,
            icon: const Icon(Icons.add),
            label: const Text('Buat Invoice'),
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
}
