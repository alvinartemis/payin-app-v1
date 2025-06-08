import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import '../core/constants/app_colors.dart';    // Digunakan untuk tema
import '../core/constants/app_strings.dart';   // Digunakan untuk title dan text
import '../core/constants/app_themes.dart';    // Menggunakan tema yang sudah dibuat

class PayInApp extends StatelessWidget {
  const PayInApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Konfigurasi aplikasi menggunakan AppStrings
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      
      // Tema aplikasi menggunakan AppThemes (yang sudah menggunakan AppColors)
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      
      // Lokalisasi
      locale: const Locale('id', 'ID'),
      fallbackLocale: const Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Indonesia
        Locale('en', 'US'), // English
      ],
      
      // Routing
      initialRoute: AppRoutes.DASHBOARD,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      
      // Konfigurasi tambahan
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      
      // Builder untuk konfigurasi global
      builder: (context, child) {
        return MediaQuery(
          // Disable font scaling untuk konsistensi UI
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      
      // Error handling menggunakan AppStrings
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AppStrings.appName),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Halaman Tidak Ditemukan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Halaman yang Anda cari tidak tersedia',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.DASHBOARD),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Kembali ke Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
