import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice_model.dart';

class HiveService {
  static const String _invoiceKey = 'invoices_data';
  static const String _settingsKey = 'settings_data';
  
  SharedPreferences? _prefs;

  // Initialize service menggunakan SharedPreferences
  Future<HiveService> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print('✅ HiveService initialized with SharedPreferences');
      return this;
    } catch (e) {
      print('❌ Error initializing HiveService: $e');
      rethrow;
    }
  }

  // Create new invoice
  Future<void> createInvoice(Invoice invoice) async {
    try {
      final invoices = getAllInvoices();
      invoices.add(invoice);
      await _saveInvoices(invoices);
      print('✅ Invoice created: ${invoice.id}');
    } catch (e) {
      print('❌ Error creating invoice: $e');
      throw Exception('Gagal membuat invoice: $e');
    }
  }

  // Get all invoices
  List<Invoice> getAllInvoices() {
    try {
      if (_prefs == null) {
        print('⚠️ SharedPreferences not initialized');
        return [];
      }
      
      final invoicesJson = _prefs!.getStringList(_invoiceKey) ?? [];
      final invoices = invoicesJson
          .map((jsonString) {
            try {
              return Invoice.fromJson(jsonDecode(jsonString));
            } catch (e) {
              print('❌ Error parsing invoice JSON: $e');
              return null;
            }
          })
          .where((invoice) => invoice != null)
          .cast<Invoice>()
          .toList();
      
      print('📋 Retrieved ${invoices.length} invoices');
      return invoices;
    } catch (e) {
      print('❌ Error getting all invoices: $e');
      return [];
    }
  }

  // Get invoice by ID
  Invoice? getInvoice(String id) {
    try {
      final invoices = getAllInvoices();
      for (final invoice in invoices) {
        if (invoice.id == id) {
          return invoice;
        }
      }
      print('⚠️ Invoice not found: $id');
      return null;
    } catch (e) {
      print('❌ Error getting invoice: $e');
      return null;
    }
  }

  // Update invoice
  Future<void> updateInvoice(int index, Invoice invoice) async {
    try {
      final invoices = getAllInvoices();
      if (index >= 0 && index < invoices.length) {
        invoices[index] = invoice;
        await _saveInvoices(invoices);
        print('✅ Invoice updated at index $index');
      } else {
        throw Exception('Invalid index: $index');
      }
    } catch (e) {
      print('❌ Error updating invoice: $e');
      throw Exception('Gagal mengupdate invoice: $e');
    }
  }

  // Delete invoice
  Future<void> deleteInvoice(int index) async {
    try {
      final invoices = getAllInvoices();
      if (index >= 0 && index < invoices.length) {
        final deletedInvoice = invoices.removeAt(index);
        await _saveInvoices(invoices);
        print('✅ Invoice deleted: ${deletedInvoice.id}');
      } else {
        throw Exception('Invalid index: $index');
      }
    } catch (e) {
      print('❌ Error deleting invoice: $e');
      throw Exception('Gagal menghapus invoice: $e');
    }
  }

  // Save invoices to SharedPreferences
  Future<void> _saveInvoices(List<Invoice> invoices) async {
    try {
      if (_prefs == null) {
        throw Exception('SharedPreferences not initialized');
      }
      
      final invoicesJson = invoices
          .map((invoice) => jsonEncode(invoice.toJson()))
          .toList();
      
      await _prefs!.setStringList(_invoiceKey, invoicesJson);
      print('💾 Saved ${invoices.length} invoices to storage');
    } catch (e) {
      print('❌ Error saving invoices: $e');
      throw Exception('Gagal menyimpan data invoice: $e');
    }
  }

  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      if (_prefs == null) {
        throw Exception('SharedPreferences not initialized');
      }
      
      final settings = getSettings();
      settings[key] = value;
      
      await _prefs!.setString(_settingsKey, jsonEncode(settings));
      print('⚙️ Setting saved: $key');
    } catch (e) {
      print('❌ Error saving setting: $e');
    }
  }

  T? getSetting<T>(String key) {
    try {
      final settings = getSettings();
      return settings[key] as T?;
    } catch (e) {
      print('❌ Error getting setting: $e');
      return null;
    }
  }

  Map<String, dynamic> getSettings() {
    try {
      if (_prefs == null) return {};
      
      final settingsJson = _prefs!.getString(_settingsKey);
      if (settingsJson == null) return {};
      
      return jsonDecode(settingsJson) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error getting settings: $e');
      return {};
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      if (_prefs == null) return;
      
      await _prefs!.remove(_invoiceKey);
      await _prefs!.remove(_settingsKey);
      print('🗑️ All data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }

  // Check if service is ready
  bool get isReady => _prefs != null;
}
