import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Information Section
            _buildSection(
              title: 'Informasi Bisnis',
              children: [
                _buildSettingsTile(
                  icon: Icons.business,
                  title: 'Nama Bisnis',
                  subtitle: 'pay.in Business',
                  onTap: () => _showEditDialog('Nama Bisnis', 'pay.in Business'),
                ),
                _buildSettingsTile(
                  icon: Icons.email,
                  title: 'Email Bisnis',
                  subtitle: 'business@payin.com',
                  onTap: () => _showEditDialog('Email Bisnis', 'business@payin.com'),
                ),
                _buildSettingsTile(
                  icon: Icons.phone,
                  title: 'Nomor Telepon',
                  subtitle: '+62 812 3456 7890',
                  onTap: () => _showEditDialog('Nomor Telepon', '+62 812 3456 7890'),
                ),
                _buildSettingsTile(
                  icon: Icons.location_on,
                  title: 'Alamat',
                  subtitle: 'Jakarta, Indonesia',
                  onTap: () => _showEditDialog('Alamat', 'Jakarta, Indonesia'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Invoice Settings Section
            _buildSection(
              title: 'Pengaturan Invoice',
              children: [
                _buildSettingsTile(
                  icon: Icons.percent,
                  title: 'Tarif Pajak',
                  subtitle: '11%',
                  onTap: () => _showTaxDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.attach_money,
                  title: 'Mata Uang',
                  subtitle: 'Rupiah (IDR)',
                  onTap: () => _showCurrencyDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.format_list_numbered,
                  title: 'Format Nomor Invoice',
                  subtitle: 'INV-YYYYMM-XXXX',
                  onTap: () => _showInvoiceFormatDialog(),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // App Settings Section - PERBAIKAN: Hanya tema terang
            _buildSection(
              title: 'Pengaturan Aplikasi',
              children: [
                _buildInfoTile(
                  icon: Icons.light_mode,
                  title: 'Tema',
                  subtitle: 'Tema Terang (Default)',
                ),
                _buildInfoTile(
                  icon: Icons.language,
                  title: 'Bahasa',
                  subtitle: 'Bahasa Indonesia',
                ),
                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: 'Notifikasi',
                  subtitle: 'Terima notifikasi aplikasi',
                  value: true,
                  onChanged: (value) {
                    // Toggle notifications
                    Get.snackbar('Info', value ? 'Notifikasi diaktifkan' : 'Notifikasi dinonaktifkan');
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // About Section
            _buildSection(
              title: 'Tentang',
              children: [
                _buildSettingsTile(
                  icon: Icons.info,
                  title: 'Tentang pay.in',
                  subtitle: 'Versi 1.0.0',
                  onTap: () => _showAboutDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.help,
                  title: 'Bantuan',
                  subtitle: 'Panduan penggunaan',
                  onTap: () => _showHelpDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.privacy_tip,
                  title: 'Kebijakan Privasi',
                  subtitle: 'Lihat kebijakan privasi',
                  onTap: () => _showPrivacyDialog(),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // PERBAIKAN: Tombol keluar dihilangkan sesuai permintaan
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // PERBAIKAN: Widget baru untuk info tile (tidak bisa diklik)
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.grey[600]),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  // Dialog methods
  void _showEditDialog(String title, String currentValue) {
    Get.dialog(
      AlertDialog(
        title: Text('Edit $title'),
        content: TextFormField(
          initialValue: currentValue,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Berhasil', '$title berhasil diperbarui');
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showTaxDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Tarif Pajak'),
        content: const Text('Pilih tarif pajak yang akan digunakan:'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Berhasil', 'Tarif pajak berhasil diperbarui');
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // PERBAIKAN: Currency dialog hanya IDR
  void _showCurrencyDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Mata Uang'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Rupiah (IDR)'),
              leading: Icon(Icons.radio_button_checked, color: Colors.blue),
            ),
            SizedBox(height: 8),
            Text(
              'Hanya mata uang Rupiah yang didukung.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInvoiceFormatDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Format Nomor Invoice'),
        content: const Text('Format saat ini: INV-YYYYMM-XXXX\n\nContoh: INV-202506-0001'),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Tentang pay.in'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('pay.in - Aplikasi Invoice untuk Freelancer'),
            SizedBox(height: 8),
            Text('Versi: 1.0.0'),
            SizedBox(height: 8),
            Text('Dikembangkan dengan Flutter & Dart'),
            SizedBox(height: 8),
            Text('© 2025 pay.in'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Bantuan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cara menggunakan pay.in:'),
            SizedBox(height: 8),
            Text('1. Atur informasi bisnis di pengaturan'),
            Text('2. Buat invoice baru dari dashboard'),
            Text('3. Kirim invoice via email atau PDF'),
            Text('4. Pantau status pembayaran'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Kebijakan Privasi'),
        content: const Text('Data Anda aman dan hanya disimpan secara lokal di perangkat Anda. Kami tidak mengumpulkan atau membagikan informasi pribadi Anda.'),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}
