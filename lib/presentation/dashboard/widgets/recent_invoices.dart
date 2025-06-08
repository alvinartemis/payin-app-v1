import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard_controller.dart';
import '../../invoice/widgets/invoice_status_chip.dart';
import '../../quotations/widgets/quotation_status_chip.dart'; // TAMBAHAN

class RecentInvoices extends StatelessWidget {
  final DashboardController controller;

  const RecentInvoices({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Invoices Section
        _buildRecentInvoicesSection(),
        
        const SizedBox(height: 24),
        
        // TAMBAHAN: Recent Quotations Section sesuai memory entries[2]
        _buildRecentQuotationsSection(),
      ],
    );
  }

  Widget _buildRecentInvoicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Invoice Terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: controller.navigateToInvoiceList,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Lihat Semua'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Obx(() {
            if (controller.recentInvoices.isEmpty) {
              return _buildEmptyState(
                icon: Icons.receipt_long,
                title: 'Belum ada invoice',
                subtitle: 'Buat invoice pertama Anda untuk memulai',
                actionText: 'Buat Invoice',
                onAction: controller.navigateToCreateInvoice,
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentInvoices.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade200,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final invoice = controller.recentInvoices[index];
                return _buildInvoiceItem(invoice);
              },
            );
          }),
        ),
      ],
    );
  }

  // TAMBAHAN: Recent Quotations Section sesuai memory entries[2]
  Widget _buildRecentQuotationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quotation Terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: controller.navigateToQuotationList,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Lihat Semua'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Obx(() {
            if (controller.recentQuotations.isEmpty) {
              return _buildEmptyState(
                icon: Icons.request_quote,
                title: 'Belum ada quotation',
                subtitle: 'Buat quotation pertama Anda untuk memulai',
                actionText: 'Buat Quotation',
                onAction: controller.navigateToCreateQuotation,
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentQuotations.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade200,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final quotation = controller.recentQuotations[index];
                return _buildQuotationItem(quotation);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildInvoiceItem(dynamic invoice) {
    return InkWell(
      onTap: () => controller.navigateToInvoiceDetail(invoice.id),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Invoice Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: controller.getStatusColor(invoice.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt_long,
                color: controller.getStatusColor(invoice.status),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Invoice Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      InvoiceStatusChip(status: invoice.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invoice.clientName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoice.formattedTotal,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '${invoice.dueDate.day}/${invoice.dueDate.month}/${invoice.dueDate.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: invoice.isOverdue ? Colors.red : Colors.grey[600],
                          fontWeight: invoice.isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Menu
            PopupMenuButton<String>(
              onSelected: (value) => _handleInvoiceAction(value, invoice.id),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 16),
                      SizedBox(width: 8),
                      Text('Lihat Detail'),
                    ],
                  ),
                ),
                if (invoice.status.toLowerCase() != 'paid')
                  const PopupMenuItem(
                    value: 'mark_paid',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Tandai Lunas'),
                      ],
                    ),
                  ),
                if (invoice.status.toLowerCase() == 'draft')
                  const PopupMenuItem(
                    value: 'send',
                    child: Row(
                      children: [
                        Icon(Icons.send, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Kirim Invoice'),
                      ],
                    ),
                  ),
              ],
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.more_vert,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAMBAHAN: Build Quotation Item sesuai memory entries[2] dan [6]
  Widget _buildQuotationItem(dynamic quotation) {
    return InkWell(
      onTap: () => controller.navigateToQuotationDetail(quotation.id),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Quotation Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: controller.getStatusColor(quotation.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.request_quote,
                color: controller.getStatusColor(quotation.status),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Quotation Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        quotation.quotationNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      QuotationStatusChip(status: quotation.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quotation.clientName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        quotation.formattedTotal,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Berlaku: ${quotation.validUntil.day}/${quotation.validUntil.month}/${quotation.validUntil.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: quotation.isExpired ? Colors.red : Colors.grey[600],
                          fontWeight: quotation.isExpired ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Menu untuk Quotation
            PopupMenuButton<String>(
              onSelected: (value) => _handleQuotationAction(value, quotation.id),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 16),
                      SizedBox(width: 8),
                      Text('Lihat Detail'),
                    ],
                  ),
                ),
                if (quotation.status.toLowerCase() == 'sent' && !quotation.isExpired)
                  const PopupMenuItem(
                    value: 'mark_accepted',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Tandai Diterima'),
                      ],
                    ),
                  ),
                if (quotation.status.toLowerCase() == 'draft')
                  const PopupMenuItem(
                    value: 'send',
                    child: Row(
                      children: [
                        Icon(Icons.send, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Kirim Quotation'),
                      ],
                    ),
                  ),
                if (quotation.status.toLowerCase() == 'accepted')
                  const PopupMenuItem(
                    value: 'convert_to_invoice',
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long, size: 16, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Buat Invoice'),
                      ],
                    ),
                  ),
              ],
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.more_vert,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add, size: 18),
            label: Text(actionText),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleInvoiceAction(String action, String invoiceId) {
    switch (action) {
      case 'view':
        controller.navigateToInvoiceDetail(invoiceId);
        break;
      case 'mark_paid':
        controller.markInvoiceAsPaid(invoiceId);
        break;
      case 'send':
        controller.sendInvoice(invoiceId);
        break;
    }
  }

  // TAMBAHAN: Handle Quotation Actions sesuai memory entries[2] dan [6]
  void _handleQuotationAction(String action, String quotationId) {
    switch (action) {
      case 'view':
        controller.navigateToQuotationDetail(quotationId);
        break;
      case 'mark_accepted':
        controller.markQuotationAsAccepted(quotationId);
        break;
      case 'send':
        controller.sendQuotation(quotationId);
        break;
      case 'convert_to_invoice':
        controller.convertQuotationToInvoice(quotationId);
        break;
    }
  }
}
