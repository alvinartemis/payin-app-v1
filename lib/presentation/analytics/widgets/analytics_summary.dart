import 'package:flutter/material.dart';
import '../analytics_controller.dart';

class AnalyticsSummary extends StatelessWidget {
  final AnalyticsController controller;

  const AnalyticsSummary({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              'Total Penjualan',
              controller.salesAnalytics['totalSales']?.toStringAsFixed(0) ?? '0',
              Icons.attach_money,
              Colors.green,
              'Rp ',
            ),
            _buildSummaryCard(
              'Total Invoice',
              '${controller.salesAnalytics['totalInvoices'] ?? 0}',
              Icons.receipt_long,
              Colors.blue,
              '',
            ),
            _buildSummaryCard(
              'Invoice Lunas',
              '${controller.salesAnalytics['paidInvoices'] ?? 0}',
              Icons.check_circle,
              Colors.teal,
              '',
            ),
            _buildSummaryCard(
              'Invoice Pending',
              '${controller.salesAnalytics['pendingInvoices'] ?? 0}',
              Icons.pending,
              Colors.orange,
              '',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailedSummary(),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String prefix,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(
                Icons.trending_up,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$prefix$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedSummary() {
    final averageInvoice = controller.salesAnalytics['averageInvoiceValue'] ?? 0.0;
    final totalSales = controller.salesAnalytics['totalSales'] ?? 0.0;
    final totalInvoices = controller.salesAnalytics['totalInvoices'] ?? 0;
    final paidInvoices = controller.salesAnalytics['paidInvoices'] ?? 0;
    
    final conversionRate = totalInvoices > 0 ? (paidInvoices / totalInvoices) * 100 : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Performa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Rata-rata Nilai Invoice',
            'Rp ${averageInvoice.toStringAsFixed(0)}',
            Icons.calculate,
            Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Tingkat Konversi',
            '${conversionRate.toStringAsFixed(1)}%',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Revenue per Invoice',
            totalInvoices > 0 ? 'Rp ${(totalSales / totalInvoices).toStringAsFixed(0)}' : 'Rp 0',
            Icons.monetization_on,
            Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
