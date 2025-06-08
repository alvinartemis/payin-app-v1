import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'data/services/hive_service.dart';

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set orientasi portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inisialisasi services tanpa Hive adapters
  await _initializeServices();
  
  // Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);
  
  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  runApp(const PayInApp());
}

/// Initialize services tanpa menggunakan Hive adapters
Future<void> _initializeServices() async {
  try {
    // Buat instance HiveService (yang sebenarnya menggunakan SharedPreferences)
    final hiveService = HiveService();
    await hiveService.init();
    
    // Register ke GetX dependency injection
    Get.put<HiveService>(hiveService, permanent: true);
    
    print('✅ Services initialized successfully (using SharedPreferences)');
  } catch (e) {
    print('❌ Error initializing services: $e');
    // Aplikasi tetap bisa jalan meski ada error
  }
}
