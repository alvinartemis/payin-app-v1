import 'package:flutter/material.dart'; // IMPORT INI YANG HILANG
import 'package:get/get.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/email_service.dart';

class SettingsController extends GetxController {
  LocalStorageService? _localStorage;
  EmailService? _emailService;
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> businessInfo = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> appSettings = <String, dynamic>{}.obs;
  final RxDouble taxRate = 11.0.obs;
  final RxString currency = 'IDR'.obs;
  final RxInt invoiceCounter = 1.obs;
  
  // Form controllers
  late final TextEditingController businessNameController;
  late final TextEditingController businessAddressController;
  late final TextEditingController businessPhoneController;
  late final TextEditingController businessEmailController;
  late final TextEditingController taxRateController;

  @override
  void onInit() async {
    super.onInit();
    _initializeControllers();
    await _initializeServices();
    loadSettings();
  }

  @override
  void onClose() {
    businessNameController.dispose();
    businessAddressController.dispose();
    businessPhoneController.dispose();
    businessEmailController.dispose();
    taxRateController.dispose();
    super.onClose();
  }

  void _initializeControllers() {
    businessNameController = TextEditingController();
    businessAddressController = TextEditingController();
    businessPhoneController = TextEditingController();
    businessEmailController = TextEditingController();
    taxRateController = TextEditingController();
  }

  Future<void> _initializeServices() async {
    try {
      _localStorage = await LocalStorageService.getInstance();
      _emailService = Get.find<EmailService>();
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  void loadSettings() {
    try {
      isLoading.value = true;
      
      if (_localStorage != null) {
        // Load business info
        final businessData = _localStorage!.getBusinessInfo();
        if (businessData != null) {
          businessInfo.value = businessData;
          businessNameController.text = businessData['name'] ?? '';
          businessAddressController.text = businessData['address'] ?? '';
          businessPhoneController.text = businessData['phone'] ?? '';
          businessEmailController.text = businessData['email'] ?? '';
        }
        
        // Load app settings
        appSettings.value = _localStorage!.getAppSettings();
        
        // Load other settings
        taxRate.value = _localStorage!.getTaxRate();
        currency.value = _localStorage!.getCurrency();
        invoiceCounter.value = _localStorage!.getInvoiceCounter();
        
        taxRateController.text = taxRate.value.toString();
      }
      
      print('✅ Settings loaded successfully');
    } catch (e) {
      print('❌ Error loading settings: $e');
      Get.snackbar('Error', 'Gagal memuat pengaturan');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveBusinessInfo() async {
    try {
      isLoading.value = true;
      
      if (_localStorage == null) {
        throw Exception('LocalStorage not initialized');
      }
      
      await _localStorage!.saveBusinessInfo(
        businessName: businessNameController.text.trim(),
        businessAddress: businessAddressController.text.trim(),
        businessPhone: businessPhoneController.text.trim(),
        businessEmail: businessEmailController.text.trim(),
      );
      
      // Update observable
      businessInfo.value = {
        'name': businessNameController.text.trim(),
        'address': businessAddressController.text.trim(),
        'phone': businessPhoneController.text.trim(),
        'email': businessEmailController.text.trim(),
      };
      
      Get.snackbar(
        'Berhasil',
        'Informasi bisnis berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      print('✅ Business info saved successfully');
    } catch (e) {
      print('❌ Error saving business info: $e');
      Get.snackbar('Error', 'Gagal menyimpan informasi bisnis');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveTaxRate() async {
    try {
      final newTaxRate = double.tryParse(taxRateController.text) ?? 11.0;
      
      if (newTaxRate < 0 || newTaxRate > 100) {
        Get.snackbar('Error', 'Tarif pajak harus antara 0-100%');
        return;
      }
      
      if (_localStorage != null) {
        await _localStorage!.saveTaxRate(newTaxRate);
        taxRate.value = newTaxRate;
        
        Get.snackbar(
          'Berhasil',
          'Tarif pajak berhasil diubah',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error saving tax rate: $e');
      Get.snackbar('Error', 'Gagal menyimpan tarif pajak');
    }
  }

  Future<void> saveAppSettings({
  bool? darkMode,
  String? language,
  bool? autoBackup,
  bool? emailNotifications,
}) async {
  try {
    if (_localStorage != null) {
      // PERBAIKAN: Sesuai memory entries pengaturan sederhana dengan opsi minimal
      final settings = {
        'theme': 'light', // Hanya tema terang
        'language': 'id', // Hanya bahasa Indonesia
        'notifications': emailNotifications ?? true,
        'darkMode': false, // Tidak ada pilihan tema gelap
        'autoBackup': autoBackup ?? false,
        'emailNotifications': emailNotifications ?? true,
      };
      
      await _localStorage!.saveAppSettings(settings);
      
      // Update observable
      appSettings.value = settings;
      
      Get.snackbar(
        'Berhasil',
        'Pengaturan berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    print('❌ Error saving app settings: $e');
    Get.snackbar('Error', 'Gagal menyimpan pengaturan');
  }
}

  Future<void> testEmailConnection() async {
    try {
      isLoading.value = true;
      
      if (_emailService == null) {
        Get.snackbar('Error', 'Email service tidak tersedia');
        return;
      }
      
      final isConnected = await _emailService!.testEmailConnection();
      
      if (isConnected) {
        Get.snackbar(
          'Berhasil',
          'Koneksi email berhasil',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Koneksi email gagal. Periksa konfigurasi email Anda.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error testing email connection: $e');
      Get.snackbar('Error', 'Gagal menguji koneksi email');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetInvoiceCounter() async {
    try {
      if (_localStorage != null) {
        await _localStorage!.saveInvoiceCounter(1);
        invoiceCounter.value = 1;
        
        Get.snackbar(
          'Berhasil',
          'Counter invoice berhasil direset',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error resetting invoice counter: $e');
      Get.snackbar('Error', 'Gagal mereset counter invoice');
    }
  }

  Future<void> clearAllData() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua data? Tindakan ini tidak dapat dibatalkan.'
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        if (_localStorage != null) {
          await _localStorage!.clearAllData();
          
          // Reset all observables
          businessInfo.clear();
          appSettings.clear();
          taxRate.value = 11.0;
          currency.value = 'IDR';
          invoiceCounter.value = 1;
          
          // Clear form controllers
          businessNameController.clear();
          businessAddressController.clear();
          businessPhoneController.clear();
          businessEmailController.clear();
          taxRateController.text = '11.0';
          
          Get.snackbar(
            'Berhasil',
            'Semua data berhasil dihapus',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('❌ Error clearing all data: $e');
      Get.snackbar('Error', 'Gagal menghapus data');
    }
  }

  void changeCurrency(String newCurrency) {
    try {
      currency.value = newCurrency;
      if (_localStorage != null) {
        _localStorage!.saveCurrency(newCurrency);
      }
      
      Get.snackbar(
        'Berhasil',
        'Mata uang berhasil diubah ke $newCurrency',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error changing currency: $e');
      Get.snackbar('Error', 'Gagal mengubah mata uang');
    }
  }

  void navigateToAbout() {
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
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void navigateToHelp() {
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
            SizedBox(height: 8),
            Text('Untuk bantuan lebih lanjut, hubungi support.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
