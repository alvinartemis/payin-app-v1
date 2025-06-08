import 'package:get/get.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email harus diisi';
    }
    
    if (!GetUtils.isEmail(value.trim())) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }

  // Phone number validation (Indonesian format)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon harus diisi';
    }

    // Remove all non-digit characters
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Indonesian phone number
    if (cleanPhone.length < 10 || cleanPhone.length > 15) {
      return 'Nomor telepon harus 10-15 digit';
    }

    // Check if it starts with valid Indonesian prefixes
    final validPrefixes = ['08', '62', '+62'];
    bool hasValidPrefix = false;
    
    for (final prefix in validPrefixes) {
      if (value.startsWith(prefix)) {
        hasValidPrefix = true;
        break;
      }
    }

    if (!hasValidPrefix && !cleanPhone.startsWith('08')) {
      return 'Nomor telepon harus dimulai dengan 08, 62, atau +62';
    }

    return null;
  }

  // Currency/amount validation
  static String? validateAmount(String? value, {double minAmount = 0}) {
    if (value == null || value.trim().isEmpty) {
      return 'Jumlah harus diisi';
    }

    // Remove currency symbols and formatting
    final cleanValue = value
        .replaceAll('Rp', '')
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll('.', '');

    final amount = double.tryParse(cleanValue);
    
    if (amount == null) {
      return 'Format jumlah tidak valid';
    }

    if (amount < minAmount) {
      return 'Jumlah minimal Rp ${minAmount.toStringAsFixed(0)}';
    }

    if (amount > 999999999999) {
      return 'Jumlah terlalu besar';
    }

    return null;
  }

  // Quantity validation
  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity harus diisi';
    }

    final quantity = int.tryParse(value);
    
    if (quantity == null) {
      return 'Quantity harus berupa angka';
    }

    if (quantity <= 0) {
      return 'Quantity harus lebih dari 0';
    }

    if (quantity > 99999) {
      return 'Quantity maksimal 99,999';
    }

    return null;
  }

  // Date validation
  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tanggal harus diisi';
    }

    try {
      // Try to parse the date
      final parts = value.split('/');
      if (parts.length != 3) {
        return 'Format tanggal harus DD/MM/YYYY';
      }

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final date = DateTime(year, month, day);
      
      // Check if the parsed date is valid
      if (date.day != day || date.month != month || date.year != year) {
        return 'Tanggal tidak valid';
      }

      return null;
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }

  // Due date validation (must be future date)
  static String? validateDueDate(String? value) {
    final dateValidation = validateDate(value);
    if (dateValidation != null) {
      return dateValidation;
    }

    try {
      final parts = value!.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      if (date.isBefore(today)) {
        return 'Tanggal jatuh tempo tidak boleh di masa lalu';
      }

      return null;
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }

  // Invoice number validation
  static String? validateInvoiceNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor invoice harus diisi';
    }

    if (value.length < 3) {
      return 'Nomor invoice minimal 3 karakter';
    }

    if (value.length > 50) {
      return 'Nomor invoice maksimal 50 karakter';
    }

    // Check for valid characters (alphanumeric, dash, underscore)
    final validPattern = RegExp(r'^[a-zA-Z0-9\-_]+$');
    if (!validPattern.hasMatch(value)) {
      return 'Nomor invoice hanya boleh mengandung huruf, angka, dash (-), dan underscore (_)';
    }

    return null;
  }

  // Name validation - PERBAIKAN REGEX
  static String? validateName(String? value, {String fieldName = 'Nama'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }

    if (value.trim().length < 2) {
      return '$fieldName minimal 2 karakter';
    }

    if (value.trim().length > 100) {
      return '$fieldName maksimal 100 karakter';
    }

    // PERBAIKAN: Regex yang benar sesuai search results
    final validPattern = RegExp(r'^[a-zA-Z\s.,-]+$');
    if (!validPattern.hasMatch(value.trim())) {
      return '$fieldName hanya boleh mengandung huruf dan tanda baca umum';
    }

    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alamat harus diisi';
    }

    if (value.trim().length < 10) {
      return 'Alamat minimal 10 karakter';
    }

    if (value.trim().length > 500) {
      return 'Alamat maksimal 500 karakter';
    }

    return null;
  }

  // Tax rate validation
  static String? validateTaxRate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tarif pajak harus diisi';
    }

    final taxRate = double.tryParse(value);
    
    if (taxRate == null) {
      return 'Tarif pajak harus berupa angka';
    }

    if (taxRate < 0) {
      return 'Tarif pajak tidak boleh negatif';
    }

    if (taxRate > 100) {
      return 'Tarif pajak maksimal 100%';
    }

    return null;
  }

  // Discount validation
  static String? validateDiscount(String? value, {double maxDiscount = double.infinity}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Discount is optional
    }

    final cleanValue = value.replaceAll('Rp', '').replaceAll(' ', '').replaceAll(',', '');
    final discount = double.tryParse(cleanValue);
    
    if (discount == null) {
      return 'Format diskon tidak valid';
    }

    if (discount < 0) {
      return 'Diskon tidak boleh negatif';
    }

    if (discount > maxDiscount) {
      return 'Diskon tidak boleh lebih dari subtotal';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    if (value.length > 50) {
      return 'Password maksimal 50 karakter';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }

    if (value != password) {
      return 'Konfirmasi password tidak cocok';
    }

    return null;
  }

  // Business name validation
  static String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama bisnis harus diisi';
    }

    if (value.trim().length < 2) {
      return 'Nama bisnis minimal 2 karakter';
    }

    if (value.trim().length > 100) {
      return 'Nama bisnis maksimal 100 karakter';
    }

    return null;
  }

  // Notes validation (optional field)
  static String? validateNotes(String? value) {
    if (value != null && value.length > 1000) {
      return 'Catatan maksimal 1000 karakter';
    }
    return null;
  }

  // Multiple email validation (separated by comma or semicolon)
  static String? validateMultipleEmails(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final emails = value.split(RegExp(r'[,;]')).map((e) => e.trim()).toList();
    
    for (final email in emails) {
      if (email.isNotEmpty && !GetUtils.isEmail(email)) {
        return 'Email "$email" tidak valid';
      }
    }

    return null;
  }

  // Custom validation for specific business rules
  static String? validateInvoiceItems(List items) {
    if (items.isEmpty) {
      return 'Invoice harus memiliki minimal 1 item';
    }

    if (items.length > 50) {
      return 'Invoice maksimal 50 item';
    }

    return null;
  }

  // Item name validation
  static String? validateItemName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama item harus diisi';
    }

    if (value.trim().length < 2) {
      return 'Nama item minimal 2 karakter';
    }

    if (value.trim().length > 100) {
      return 'Nama item maksimal 100 karakter';
    }

    // Allow alphanumeric, spaces, and common punctuation
    final validPattern = RegExp(r'^[a-zA-Z0-9\s.,-]+$');
    if (!validPattern.hasMatch(value.trim())) {
      return 'Nama item hanya boleh mengandung huruf, angka, dan tanda baca umum';
    }

    return null;
  }

  // Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi harus diisi';
    }

    if (value.trim().length < 5) {
      return 'Deskripsi minimal 5 karakter';
    }

    if (value.trim().length > 500) {
      return 'Deskripsi maksimal 500 karakter';
    }

    return null;
  }
}
