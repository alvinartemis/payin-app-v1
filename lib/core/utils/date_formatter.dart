import 'package:intl/intl.dart';

class DateFormatter {
  // Indonesian date formatters
  static final DateFormat _ddMMyyyy = DateFormat('dd/MM/yyyy', 'id_ID');
  static final DateFormat _ddMMMyyyy = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _ddMMMMyyyy = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _eeeDdMMMyyyy = DateFormat('EEE, dd MMM yyyy', 'id_ID');
  static final DateFormat _yyyyMMdd = DateFormat('yyyy-MM-dd', 'id_ID');
  static final DateFormat _HHmm = DateFormat('HH:mm', 'id_ID');
  static final DateFormat _ddMMMHHmm = DateFormat('dd MMM, HH:mm', 'id_ID');

  // Format date for display (default Indonesian format)
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    try {
      switch (format.toLowerCase()) {
        case 'dd/mm/yyyy':
          return _ddMMyyyy.format(date);
        case 'dd mmm yyyy':
          return _ddMMMyyyy.format(date);
        case 'dd mmmm yyyy':
          return _ddMMMMyyyy.format(date);
        case 'eee, dd mmm yyyy':
          return _eeeDdMMMyyyy.format(date);
        case 'yyyy-mm-dd':
          return _yyyyMMdd.format(date);
        default:
          return _ddMMyyyy.format(date);
      }
    } catch (e) {
      print('Error formatting date: $e');
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Format for invoice display
  static String formatForInvoice(DateTime date) {
    return formatDate(date, format: 'dd MMMM yyyy');
  }

  // Format for invoice due date
  static String formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return 'Jatuh tempo ${difference.abs()} hari yang lalu';
    } else if (difference == 0) {
      return 'Jatuh tempo hari ini';
    } else if (difference == 1) {
      return 'Jatuh tempo besok';
    } else {
      return 'Jatuh tempo dalam $difference hari';
    }
  }

  // Format time
  static String formatTime(DateTime dateTime) {
    try {
      return _HHmm.format(dateTime);
    } catch (e) {
      print('Error formatting time: $e');
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    try {
      return _ddMMMHHmm.format(dateTime);
    } catch (e) {
      print('Error formatting datetime: $e');
      return '${formatDate(dateTime)}, ${formatTime(dateTime)}';
    }
  }

  // Format relative time (ago)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years tahun yang lalu';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan yang lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  // Parse date from string (dd/MM/yyyy format)
  static DateTime? parseDate(String dateString) {
    try {
      // Try different formats
      final formats = [
        'dd/MM/yyyy',
        'dd-MM-yyyy',
        'yyyy-MM-dd',
        'dd MMM yyyy',
        'dd MMMM yyyy',
      ];

      for (final format in formats) {
        try {
          final formatter = DateFormat(format, 'id_ID');
          return formatter.parse(dateString);
        } catch (e) {
          continue;
        }
      }
      
      // Fallback to DateTime.parse
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  // Format for analytics charts
  static String formatForChart(DateTime date, {String period = 'daily'}) {
    try {
      switch (period.toLowerCase()) {
        case 'daily':
          return DateFormat('dd/MM', 'id_ID').format(date);
        case 'weekly':
          return DateFormat('dd MMM', 'id_ID').format(date);
        case 'monthly':
          return DateFormat('MMM yyyy', 'id_ID').format(date);
        case 'yearly':
          return DateFormat('yyyy', 'id_ID').format(date);
        default:
          return DateFormat('dd/MM', 'id_ID').format(date);
      }
    } catch (e) {
      print('Error formatting for chart: $e');
      return '${date.day}/${date.month}';
    }
  }

  // Get month name in Indonesian
  static String getMonthName(int month) {
    const monthNames = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    if (month >= 1 && month <= 12) {
      return monthNames[month];
    }
    return 'Bulan Tidak Valid';
  }

  // Get day name in Indonesian
  static String getDayName(int weekday) {
    const dayNames = [
      '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    
    if (weekday >= 1 && weekday <= 7) {
      return dayNames[weekday];
    }
    return 'Hari Tidak Valid';
  }

  // Check if date is overdue
  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  // Get days until due date
  static int daysUntilDue(DateTime dueDate) {
    return dueDate.difference(DateTime.now()).inDays;
  }

  // Format date range
  static String formatDateRange(DateTime startDate, DateTime endDate) {
    try {
      if (startDate.year == endDate.year && startDate.month == endDate.month) {
        // Same month
        return '${startDate.day} - ${formatDate(endDate, format: 'dd MMM yyyy')}';
      } else if (startDate.year == endDate.year) {
        // Same year
        return '${formatDate(startDate, format: 'dd MMM')} - ${formatDate(endDate, format: 'dd MMM yyyy')}';
      } else {
        // Different years
        return '${formatDate(startDate, format: 'dd MMM yyyy')} - ${formatDate(endDate, format: 'dd MMM yyyy')}';
      }
    } catch (e) {
      print('Error formatting date range: $e');
      return '${formatDate(startDate)} - ${formatDate(endDate)}';
    }
  }

  // Validate date string
  static bool isValidDate(String dateString) {
    return parseDate(dateString) != null;
  }

  // Get current date formatted
  static String getCurrentDate({String format = 'dd/MM/yyyy'}) {
    return formatDate(DateTime.now(), format: format);
  }

  // Get current time formatted
  static String getCurrentTime() {
    return formatTime(DateTime.now());
  }

  // Format for file naming (safe characters only)
  static String formatForFileName(DateTime date) {
    return DateFormat('yyyy-MM-dd_HH-mm-ss').format(date);
  }
}
