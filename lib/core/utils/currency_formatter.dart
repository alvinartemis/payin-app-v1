import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Indonesian Rupiah formatter
  static final NumberFormat _idrFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // US Dollar formatter
  static final NumberFormat _usdFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$ ',
    decimalDigits: 2,
  );

  // Compact formatter for large numbers (1K, 1M, etc.)
  static final NumberFormat _compactFormatter = NumberFormat.compact(
    locale: 'id_ID',
  );

  // Format currency based on locale
  static String formatCurrency(
    double amount, {
    String currency = 'IDR',
    bool showSymbol = true,
    int? decimalDigits,
  }) {
    try {
      switch (currency.toUpperCase()) {
        case 'IDR':
          if (decimalDigits != null) {
            final customFormatter = NumberFormat.currency(
              locale: 'id_ID',
              symbol: showSymbol ? 'Rp ' : '',
              decimalDigits: decimalDigits,
            );
            return customFormatter.format(amount);
          }
          return showSymbol 
              ? _idrFormatter.format(amount)
              : _idrFormatter.format(amount).replaceAll('Rp ', '');
              
        case 'USD':
          if (decimalDigits != null) {
            final customFormatter = NumberFormat.currency(
              locale: 'en_US',
              symbol: showSymbol ? '\$ ' : '',
              decimalDigits: decimalDigits,
            );
            return customFormatter.format(amount);
          }
          return showSymbol 
              ? _usdFormatter.format(amount)
              : _usdFormatter.format(amount).replaceAll('\$ ', '');
              
        default:
          return _idrFormatter.format(amount);
      }
    } catch (e) {
      print('Error formatting currency: $e');
      return showSymbol ? 'Rp ${amount.toStringAsFixed(0)}' : amount.toStringAsFixed(0);
    }
  }

  // Format Indonesian Rupiah (default for pay.in app)
  static String formatIDR(double amount, {bool showSymbol = true}) {
    return formatCurrency(amount, currency: 'IDR', showSymbol: showSymbol);
  }

  // Format compact currency (1K, 1M, 1B)
  static String formatCompact(double amount, {String currency = 'IDR'}) {
    try {
      final compactValue = _compactFormatter.format(amount);
      switch (currency.toUpperCase()) {
        case 'IDR':
          return 'Rp $compactValue';
        case 'USD':
          return '\$ $compactValue';
        default:
          return 'Rp $compactValue';
      }
    } catch (e) {
      print('Error formatting compact currency: $e');
      return formatCurrency(amount, currency: currency);
    }
  }

  // Parse currency string to double
  static double? parseCurrency(String currencyString) {
    try {
      // Remove currency symbols and spaces
      String cleanString = currencyString
          .replaceAll('Rp', '')
          .replaceAll('\$', '')
          .replaceAll(' ', '')
          .replaceAll(',', '')
          .replaceAll('.', '');
      
      return double.tryParse(cleanString);
    } catch (e) {
      print('Error parsing currency: $e');
      return null;
    }
  }

  // Format for input fields (without symbol)
  static String formatForInput(double amount) {
    try {
      final formatter = NumberFormat('#,##0', 'id_ID');
      return formatter.format(amount);
    } catch (e) {
      print('Error formatting for input: $e');
      return amount.toStringAsFixed(0);
    }
  }

  // Format percentage
  static String formatPercentage(double percentage, {int decimalPlaces = 1}) {
    try {
      return '${percentage.toStringAsFixed(decimalPlaces)}%';
    } catch (e) {
      print('Error formatting percentage: $e');
      return '${percentage.toStringAsFixed(1)}%';
    }
  }

  // Format for charts and analytics
  static String formatForChart(double amount) {
    try {
      if (amount >= 1000000000) {
        return '${(amount / 1000000000).toStringAsFixed(1)}B';
      } else if (amount >= 1000000) {
        return '${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return '${(amount / 1000).toStringAsFixed(1)}K';
      } else {
        return amount.toStringAsFixed(0);
      }
    } catch (e) {
      print('Error formatting for chart: $e');
      return amount.toStringAsFixed(0);
    }
  }

  // Validate currency input
  static bool isValidCurrencyInput(String input) {
    try {
      final cleanInput = input.replaceAll(RegExp(r'[^\d.]'), '');
      final parsed = double.tryParse(cleanInput);
      return parsed != null && parsed >= 0;
    } catch (e) {
      return false;
    }
  }

  // Format currency with custom separator
  static String formatWithSeparator(
    double amount, {
    String thousandSeparator = '.',
    String decimalSeparator = ',',
    int decimalPlaces = 0,
  }) {
    try {
      final formatter = NumberFormat('#,##0${decimalPlaces > 0 ? '.${'0' * decimalPlaces}' : ''}', 'id_ID');
      String formatted = formatter.format(amount);
      
      // Replace separators if custom ones are provided
      if (thousandSeparator != ',') {
        formatted = formatted.replaceAll(',', thousandSeparator);
      }
      if (decimalSeparator != '.' && decimalPlaces > 0) {
        formatted = formatted.replaceAll('.', decimalSeparator);
      }
      
      return formatted;
    } catch (e) {
      print('Error formatting with custom separator: $e');
      return amount.toStringAsFixed(decimalPlaces);
    }
  }

  // Get currency symbol
  static String getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'IDR':
        return 'Rp';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return 'Rp';
    }
  }

  // Format for invoice display
  static String formatForInvoice(double amount, {String currency = 'IDR'}) {
    return formatCurrency(
      amount,
      currency: currency,
      showSymbol: true,
      decimalDigits: 0,
    );
  }
}
