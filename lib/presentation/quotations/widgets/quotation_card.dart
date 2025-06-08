import 'package:flutter/material.dart';
import '../../../data/models/quotation_model.dart';
import 'quotation_status_chip.dart';

class QuotationCard extends StatelessWidget {
  final Quotation quotation;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onGeneratePdf;
  final VoidCallback? onSendEmail;
  final Function(String)? onStatusChange;
  final VoidCallback? onConvertToInvoice;

  const QuotationCard({
    Key? key,
    required this.quotation,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.onGeneratePdf,
    this.onSendEmail,
    this.onStatusChange,
    this.onConvertToInvoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quotation.quotationNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quotation.clientName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  QuotationStatusChip(status: quotation.status),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Amount and Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        quotation.formattedTotal,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Berlaku Sampai',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${quotation.validUntil.day}/${quotation.validUntil.month}/${quotation.validUntil.year}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: quotation.isExpired ? Colors.red : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Expiry warning
              if (quotation.isExpired || _isExpiringSoon()) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: quotation.isExpired ? Colors.red.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        quotation.isExpired ? Icons.error : Icons.warning,
                        size: 16,
                        color: quotation.isExpired ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        quotation.isExpired ? 'Kedaluwarsa' : 'Akan kedaluwarsa',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: quotation.isExpired ? Colors.red : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.edit,
                      label: 'Edit',
                      onPressed: onEdit,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.picture_as_pdf,
                      label: 'PDF',
                      onPressed: onGeneratePdf,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.email,
                      label: 'Email',
                      onPressed: onSendEmail,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value),
                    itemBuilder: (context) => _buildMenuItems(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.more_vert, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    final items = <PopupMenuEntry<String>>[];
    
    // Convert to Invoice (only for sent status and not expired)
    if (quotation.status.toLowerCase() == 'sent' && !quotation.isExpired) {
      items.add(
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
      );
    }
    
    // Duplicate
    items.add(
      const PopupMenuItem(
        value: 'duplicate',
        child: Row(
          children: [
            Icon(Icons.copy, size: 16),
            SizedBox(width: 8),
            Text('Duplikasi'),
          ],
        ),
      ),
    );
    
    // Status actions
    if (quotation.status.toLowerCase() == 'sent' && !quotation.isExpired) {
      items.add(
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
      );
      
      items.add(
        const PopupMenuItem(
          value: 'mark_rejected',
          child: Row(
            children: [
              Icon(Icons.cancel, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Tandai Ditolak'),
            ],
          ),
        ),
      );
    }
    
    // Delete (only for draft)
    if (quotation.status.toLowerCase() == 'draft') {
      items.add(
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus'),
            ],
          ),
        ),
      );
    }
    
    return items;
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'convert_to_invoice':
        onConvertToInvoice?.call();
        break;
      case 'duplicate':
        onDuplicate?.call();
        break;
      case 'mark_accepted':
        onStatusChange?.call('accepted');
        break;
      case 'mark_rejected':
        onStatusChange?.call('rejected');
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  bool _isExpiringSoon() {
    final daysUntilExpiry = quotation.validUntil.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }
}
