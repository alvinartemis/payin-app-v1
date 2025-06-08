import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  static const String _invoiceCounterKey = 'invoice_counter';
  static const String _quotationCounterKey = 'quotation_counter';
  static const String _taxRateKey = 'tax_rate';
  static const String _businessInfoKey = 'business_info';
  static const String _appSettingsKey = 'app_settings'; // TAMBAHAN
  static const String _currencyKey = 'currency'; // TAMBAHAN

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // PERBAIKAN: Tambahkan method yang hilang sesuai memory entries
  
  // App Settings methods
  Map<String, dynamic> getAppSettings() {
    final jsonString = _preferences?.getString(_appSettingsKey);
    if (jsonString != null) {
      try {
        return Map<String, dynamic>.from(json.decode(jsonString));
      } catch (e) {
        print('Error decoding app settings: $e');
        return _getDefaultAppSettings();
      }
    }
    return _getDefaultAppSettings();
  }

  Future<bool> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final jsonString = json.encode(settings);
      return await _preferences?.setString(_appSettingsKey, jsonString) ?? false;
    } catch (e) {
      print('Error saving app settings: $e');
      return false;
    }
  }

  Map<String, dynamic> _getDefaultAppSettings() {
    return {
      'theme': 'light', // Sesuai memory entries: hanya tema terang
      'language': 'id', // Sesuai memory entries: hanya bahasa Indonesia
      'notifications': true,
      'darkMode': false, // Sesuai memory entries: tidak ada pilihan tema gelap
    };
  }

  // Currency methods
  String getCurrency() {
    return _preferences?.getString(_currencyKey) ?? 'IDR'; // Sesuai memory entries: hanya IDR
  }

  Future<bool> saveCurrency(String currency) async {
    // Sesuai memory entries: hanya IDR yang didukung
    if (currency != 'IDR') {
      print('Only IDR currency is supported');
      return false;
    }
    return await _preferences?.setString(_currencyKey, currency) ?? false;
  }

  // Tax rate methods (update nama method)
  double getTaxRate() {
    return _preferences?.getDouble(_taxRateKey) ?? 11.0;
  }

  Future<bool> saveTaxRate(double rate) async {
    return await _preferences?.setDouble(_taxRateKey, rate) ?? false;
  }

  Future<bool> setTaxRate(double rate) async {
    return saveTaxRate(rate); // Alias untuk kompatibilitas
  }

  // Invoice counter methods (update nama method)
  int getInvoiceCounter() {
    return _preferences?.getInt(_invoiceCounterKey) ?? 1;
  }

  Future<bool> saveInvoiceCounter(int counter) async {
    return await _preferences?.setInt(_invoiceCounterKey, counter) ?? false;
  }

  Future<bool> incrementInvoiceCounter() async {
    final currentCounter = getInvoiceCounter();
    return await saveInvoiceCounter(currentCounter + 1);
  }

  // Quotation counter methods
  int getQuotationCounter() {
    return _preferences?.getInt(_quotationCounterKey) ?? 1;
  }

  Future<bool> incrementQuotationCounter() async {
    final currentCounter = getQuotationCounter();
    return await _preferences?.setInt(_quotationCounterKey, currentCounter + 1) ?? false;
  }

  // Business info methods
  Future<bool> saveBusinessInfo({
    required String businessName,
    required String businessAddress,
    required String businessPhone,
    required String businessEmail,
  }) async {
    try {
      final info = {
        'name': businessName,
        'address': businessAddress,
        'phone': businessPhone,
        'email': businessEmail,
      };
      final jsonString = json.encode(info);
      return await _preferences?.setString(_businessInfoKey, jsonString) ?? false;
    } catch (e) {
      print('Error saving business info: $e');
      return false;
    }
  }

  Map<String, dynamic>? getBusinessInfo() {
    final jsonString = _preferences?.getString(_businessInfoKey);
    if (jsonString != null) {
      try {
        return Map<String, dynamic>.from(json.decode(jsonString));
      } catch (e) {
        print('Error decoding business info: $e');
        return null;
      }
    }
    return null;
  }

  Future<bool> setBusinessInfo(Map<String, dynamic> info) async {
    try {
      final jsonString = json.encode(info);
      return await _preferences?.setString(_businessInfoKey, jsonString) ?? false;
    } catch (e) {
      print('Error encoding business info: $e');
      return false;
    }
  }

  // Clear data method
  Future<bool> clearAllData() async {
    try {
      return await _preferences?.clear() ?? false;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  // String List methods
  List<String>? getStringList(String key) {
    return _preferences?.getStringList(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences?.setStringList(key, value) ?? false;
  }

  // Additional utility methods
  Future<bool> setString(String key, String value) async {
    return await _preferences?.setString(key, value) ?? false;
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _preferences?.setInt(key, value) ?? false;
  }

  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _preferences?.setBool(key, value) ?? false;
  }

  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  Future<bool> setDouble(String key, double value) async {
    return await _preferences?.setDouble(key, value) ?? false;
  }

  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  Future<bool> remove(String key) async {
    return await _preferences?.remove(key) ?? false;
  }

  Future<bool> clear() async {
    return await _preferences?.clear() ?? false;
  }

  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }

  Set<String> getKeys() {
    return _preferences?.getKeys() ?? <String>{};
  }
}
