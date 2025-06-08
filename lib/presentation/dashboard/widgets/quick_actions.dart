import 'package:flutter/material.dart';
import '../dashboard_controller.dart';

class QuickActions extends StatelessWidget {
  final DashboardController controller;

  const QuickActions({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // PERBAIKAN: Menggunakan 3 kolom untuk menampung 6 aksi sesuai memory entries[6]
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9, // Aspect ratio disesuaikan untuk 3 kolom
          children: [
            _buildQuickActionCard(
              'Buat Invoice',
              Icons.add_circle_outline,
              Colors.green,
              controller.navigateToCreateInvoice,
              'Invoice baru',
            ),
            // TAMBAHAN: Quotation actions sesuai memory entries[1]
            _buildQuickActionCard(
              'Buat Quotation',
              Icons.request_quote,
              Colors.purple,
              controller.navigateToCreateQuotation,
              'Quotation baru',
            ),
            _buildQuickActionCard(
              'Lihat Invoice',
              Icons.receipt_long,
              Colors.blue,
              controller.navigateToInvoiceList,
              'Kelola invoice',
            ),
            _buildQuickActionCard(
              'Lihat Quotation',
              Icons.format_quote,
              Colors.indigo,
              controller.navigateToQuotationList,
              'Kelola quotation',
            ),
            _buildQuickActionCard(
              'Analytics',
              Icons.analytics,
              Colors.orange,
              controller.navigateToAnalytics,
              'Lihat laporan',
            ),
            // Sesuai memory entries[4]: pengaturan sederhana dengan opsi minimal
            _buildQuickActionCard(
              'Pengaturan',
              Icons.settings,
              Colors.grey,
              controller.navigateToSettings,
              'Atur aplikasi',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    String subtitle,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8), // Reduced padding untuk 3 kolom
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Smaller radius untuk compact design
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8), // Smaller icon container
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color), // Smaller icon
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11, // Smaller font untuk 3 kolom
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Allow 2 lines untuk title yang lebih panjang
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9, // Smaller subtitle
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
