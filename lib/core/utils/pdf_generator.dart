import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../data/models/invoice_model.dart';
import '../../data/services/local_storage_service.dart';
import 'currency_formatter.dart';
import 'date_formatter.dart';

class PdfGenerator {
  static LocalStorageService? _localStorage;

  // Initialize local storage
  static Future<void> _initLocalStorage() async {
    _localStorage ??= await LocalStorageService.getInstance();
  }

  // Generate invoice PDF
  static Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
    await _initLocalStorage();
    
    final pdf = pw.Document();
    final businessInfo = _localStorage?.getBusinessInfo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(businessInfo),
            pw.SizedBox(height: 30),
            
            // Invoice Info and Client
            _buildInvoiceInfo(invoice),
            pw.SizedBox(height: 30),
            
            // Items Table
            _buildItemsTable(invoice),
            pw.SizedBox(height: 30),
            
            // Summary
            _buildSummary(invoice),
            pw.SizedBox(height: 40),
            
            // Footer
            _buildFooter(invoice),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Build PDF header
  static pw.Widget _buildHeader(Map<String, dynamic>? businessInfo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Business Info
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              businessInfo?['name'] ?? 'pay.in Business',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              businessInfo?['address'] ?? 'Alamat Bisnis',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'Tel: ${businessInfo?['phone'] ?? 'Nomor Telepon'}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'Email: ${businessInfo?['email'] ?? 'email@business.com'}',
              style: pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
        
        // Invoice Title
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 36,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build invoice info section
  static pw.Widget _buildInvoiceInfo(Invoice invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Client Info
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Tagihan Kepada:',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                invoice.clientName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (invoice.clientCompany != null) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  invoice.clientCompany!,
                  style: pw.TextStyle(fontSize: 14),
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Text(
                invoice.clientAddress,
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Tel: ${invoice.clientPhone}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Email: ${invoice.clientEmail}',
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        
        pw.SizedBox(width: 40),
        
        // Invoice Details
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _buildInfoRow('No. Invoice:', invoice.invoiceNumber),
              _buildInfoRow('Tanggal:', DateFormatter.formatForInvoice(invoice.createdDate)),
              _buildInfoRow('Jatuh Tempo:', DateFormatter.formatForInvoice(invoice.dueDate)),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _getStatusColor(invoice.status),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  _getStatusText(invoice.status),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build info row
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Build items table
  static pw.Widget _buildItemsTable(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 1,
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(1.5),
        4: pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableHeader('Deskripsi'),
            _buildTableHeader('Qty'),
            _buildTableHeader('Harga Satuan'),
            _buildTableHeader('Diskon'),
            _buildTableHeader('Total'),
          ],
        ),
        
        // Items
        ...invoice.items.map((item) => pw.TableRow(
          children: [
            _buildTableCell('${item.name}\n${item.description}', isDescription: true),
            _buildTableCell('${item.quantity}'),
            _buildTableCell(CurrencyFormatter.formatIDR(item.price)),
            _buildTableCell(CurrencyFormatter.formatIDR(item.discount)),
            _buildTableCell(
              CurrencyFormatter.formatIDR(item.total),
              isBold: true,
            ),
          ],
        )).toList(),
      ],
    );
  }

  // Build table header
  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Build table cell
  static pw.Widget _buildTableCell(
    String text, {
    bool isDescription = false,
    bool isBold = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isDescription ? 10 : 11,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isDescription ? pw.TextAlign.left : pw.TextAlign.center,
      ),
    );
  }

  // Build summary section
  static pw.Widget _buildSummary(Invoice invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 250,
          child: pw.Column(
            children: [
              _buildSummaryRow('Subtotal:', CurrencyFormatter.formatIDR(invoice.subtotal)),
              if (invoice.discount > 0)
                _buildSummaryRow('Diskon:', '- ${CurrencyFormatter.formatIDR(invoice.discount)}'),
              if (invoice.tax > 0)
                _buildSummaryRow('Pajak:', CurrencyFormatter.formatIDR(invoice.tax)),
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 8),
                height: 2,
                color: PdfColors.grey400,
              ),
              _buildSummaryRow(
                'TOTAL:',
                CurrencyFormatter.formatIDR(invoice.total),
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build summary row
  static pw.Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? PdfColors.green700 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Build footer
  static pw.Widget _buildFooter(Invoice invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
          pw.Text(
            'Catatan:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            invoice.notes!,
            style: pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 20),
        ],
        
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Terima kasih atas kepercayaan Anda!',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Invoice ini dibuat menggunakan aplikasi pay.in',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.blue600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods
  static PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PdfColors.green;
      case 'sent':
        return PdfColors.blue;
      case 'overdue':
        return PdfColors.red;
      case 'draft':
        return PdfColors.orange;
      default:
        return PdfColors.grey;
    }
  }

  static String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'LUNAS';
      case 'sent':
        return 'TERKIRIM';
      case 'overdue':
        return 'JATUH TEMPO';
      case 'draft':
        return 'DRAFT';
      default:
        return status.toUpperCase();
    }
  }

  // Save PDF to file
  static Future<File> savePdfToFile(Uint8List pdfBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes);
    return file;
  }

  // Share PDF
  static Future<void> sharePdf(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '$fileName.pdf',
    );
  }

  // Preview PDF
  static Future<void> previewPdf(Uint8List pdfBytes, String title) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
    );
  }
}
