import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice_model.dart';
import '../models/quotation_model.dart';
import 'local_storage_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';

class PdfService {
  // PERBAIKAN: Menggunakan getInstance() sesuai search results
  LocalStorageService? _localStorage;

  // Initialize dengan singleton pattern
  Future<void> _initLocalStorage() async {
    _localStorage ??= await LocalStorageService.getInstance();
  }

  Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
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
            _buildInvoiceHeader(businessInfo, invoice),
            pw.SizedBox(height: 30),
            
            // Client Info
            _buildClientInfo(invoice),
            pw.SizedBox(height: 30),
            
            // Items Table
            _buildInvoiceItemsTable(invoice),
            pw.SizedBox(height: 30),
            
            // Summary
            _buildInvoiceSummary(invoice),
            pw.SizedBox(height: 40),
            
            // Footer
            _buildInvoiceFooter(invoice),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generateQuotationPdf(Quotation quotation) async {
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
            _buildQuotationHeader(businessInfo, quotation),
            pw.SizedBox(height: 30),
            
            // Client Info
            _buildQuotationClientInfo(quotation),
            pw.SizedBox(height: 30),
            
            // Items Table
            _buildQuotationItemsTable(quotation),
            pw.SizedBox(height: 30),
            
            // Summary
            _buildQuotationSummary(quotation),
            pw.SizedBox(height: 40),
            
            // Footer
            _buildQuotationFooter(quotation),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Invoice PDF Components
  pw.Widget _buildInvoiceHeader(Map<String, dynamic>? businessInfo, Invoice invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
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
            pw.SizedBox(height: 8),
            pw.Text(
              invoice.invoiceNumber,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildClientInfo(Invoice invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
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
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _buildInfoRow('Tanggal:', DateFormatter.formatForInvoice(invoice.createdDate)),
              _buildInfoRow('Jatuh Tempo:', DateFormatter.formatForInvoice(invoice.dueDate)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
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

  pw.Widget _buildInvoiceItemsTable(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 1,
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableHeader('Deskripsi'),
            _buildTableHeader('Qty'),
            _buildTableHeader('Harga'),
            _buildTableHeader('Total'),
          ],
        ),
        
        // Items
        ...invoice.items.map((item) => pw.TableRow(
          children: [
            _buildTableCell('${item.name}\n${item.description}', isDescription: true),
            _buildTableCell('${item.quantity}'),
            _buildTableCell(CurrencyFormatter.formatIDR(item.price)),
            _buildTableCell(CurrencyFormatter.formatIDR(item.total), isBold: true),
          ],
        )).toList(),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
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

  pw.Widget _buildTableCell(String text, {bool isDescription = false, bool isBold = false}) {
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

  pw.Widget _buildInvoiceSummary(Invoice invoice) {
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

  pw.Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
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

  pw.Widget _buildInvoiceFooter(Invoice invoice) {
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

  // Quotation PDF Components (similar structure)
  pw.Widget _buildQuotationHeader(Map<String, dynamic>? businessInfo, Quotation quotation) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              businessInfo?['name'] ?? 'pay.in Business',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.purple800,
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
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'QUOTATION',
              style: pw.TextStyle(
                fontSize: 36,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.purple800,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              quotation.quotationNumber,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildQuotationClientInfo(Quotation quotation) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Quotation Untuk:',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                quotation.clientName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (quotation.clientCompany != null) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  quotation.clientCompany!,
                  style: pw.TextStyle(fontSize: 14),
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Text(
                quotation.clientAddress,
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Tel: ${quotation.clientPhone}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Email: ${quotation.clientEmail}',
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 40),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _buildInfoRow('Tanggal:', DateFormatter.formatForInvoice(quotation.createdDate)),
              _buildInfoRow('Berlaku Sampai:', DateFormatter.formatForInvoice(quotation.validUntil)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildQuotationItemsTable(Quotation quotation) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 1,
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableHeader('Deskripsi'),
            _buildTableHeader('Qty'),
            _buildTableHeader('Harga'),
            _buildTableHeader('Total'),
          ],
        ),
        
        // Items
        ...quotation.items.map((item) => pw.TableRow(
          children: [
            _buildTableCell('${item.name}\n${item.description}', isDescription: true),
            _buildTableCell('${item.quantity}'),
            _buildTableCell(CurrencyFormatter.formatIDR(item.price)),
            _buildTableCell(CurrencyFormatter.formatIDR(item.total), isBold: true),
          ],
        )).toList(),
      ],
    );
  }

  pw.Widget _buildQuotationSummary(Quotation quotation) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 250,
          child: pw.Column(
            children: [
              _buildSummaryRow('Subtotal:', CurrencyFormatter.formatIDR(quotation.subtotal)),
              if (quotation.discount > 0)
                _buildSummaryRow('Diskon:', '- ${CurrencyFormatter.formatIDR(quotation.discount)}'),
              if (quotation.tax > 0)
                _buildSummaryRow('Pajak:', CurrencyFormatter.formatIDR(quotation.tax)),
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 8),
                height: 2,
                color: PdfColors.grey400,
              ),
              _buildSummaryRow(
                'TOTAL:',
                CurrencyFormatter.formatIDR(quotation.total),
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildQuotationFooter(Quotation quotation) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (quotation.notes != null && quotation.notes!.isNotEmpty) ...[
          pw.Text(
            'Catatan:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            quotation.notes!,
            style: pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 20),
        ],
        
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.purple50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Quotation ini berlaku sampai tanggal yang tertera.',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple800,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Quotation ini dibuat menggunakan aplikasi pay.in',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.purple600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Utility methods
  Future<void> sharePdf(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '$fileName.pdf',
    );
  }

  Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}
