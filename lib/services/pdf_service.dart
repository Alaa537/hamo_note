import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/client.dart';
import '../models/transaction.dart';

class PdfService {
  static final _dateFmt = DateFormat('yyyy/MM/dd  HH:mm');

  static Future<pw.Font> _arabicFont() => PdfGoogleFonts.cairoRegular();
  static Future<pw.Font> _arabicBold() => PdfGoogleFonts.cairoBold();

  static Future<Uint8List> buildClientStatement({
    required Client client,
    required String merchantName,
  }) async {
    final font = await _arabicFont();
    final bold = await _arabicBold();

    final doc = pw.Document();
    final theme = pw.ThemeData.withFont(base: font, bold: bold);

    final isCredit = client.balance >= 0;
    final balanceStr = client.balance.abs().toStringAsFixed(2);
    final balanceLabel = isCredit ? 'له' : 'عليه';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        textDirection: pw.TextDirection.rtl,
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#0A0E1A'),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Hamo Note',
                        style: pw.TextStyle(
                            font: bold,
                            fontSize: 26,
                            color: PdfColor.fromHex('#00E676'))),
                    pw.SizedBox(height: 4),
                    pw.Text('كشف حساب عميل',
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 14,
                            color: PdfColors.white)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('التاجر: $merchantName',
                        style: pw.TextStyle(
                            font: bold,
                            fontSize: 12,
                            color: PdfColors.white)),
                    pw.Text(_dateFmt.format(DateTime.now()),
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                            color: PdfColor.fromHex('#8A93A8'))),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F5F7FA'),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('بيانات العميل',
                    style: pw.TextStyle(font: bold, fontSize: 14)),
                pw.SizedBox(height: 8),
                _row('الاسم', client.name, font),
                _row('الهاتف', client.phone, font),
                _row('الفئة', client.category.arName, font),
                if (client.note != null && client.note!.isNotEmpty)
                  _row('ملاحظة', client.note!, font),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: isCredit
                  ? PdfColor.fromHex('#00E676')
                  : PdfColor.fromHex('#FF5252'),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('الرصيد الحالي',
                    style: pw.TextStyle(
                        font: bold,
                        fontSize: 16,
                        color: PdfColors.black)),
                pw.Text('$balanceStr ج.م  ($balanceLabel)',
                    style: pw.TextStyle(
                        font: bold,
                        fontSize: 18,
                        color: PdfColors.black)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('سجل المعاملات',
              style: pw.TextStyle(font: bold, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
                font: bold, fontSize: 11, color: PdfColors.white),
            cellStyle: pw.TextStyle(font: font, fontSize: 10),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#141C2E'),
            ),
            cellAlignment: pw.Alignment.centerRight,
            headers: ['التاريخ', 'النوع', 'المبلغ', 'ملاحظة'],
            data: client.transactions.reversed
                .map((t) => [
                      _dateFmt.format(t.date),
                      t.type.arName,
                      '${t.amount.toStringAsFixed(2)} ج.م',
                      t.note,
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Center(
            child: pw.Text('تم الإنشاء بواسطة Hamo Note 💚',
                style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColor.fromHex('#8A93A8'))),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _row(String k, String v, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 70,
            child: pw.Text('$k:',
                style: pw.TextStyle(
                    font: font,
                    fontSize: 11,
                    color: PdfColor.fromHex('#8A93A8'))),
          ),
          pw.Expanded(
            child: pw.Text(v,
                style: pw.TextStyle(font: font, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  static Future<void> shareClientStatement({
    required Client client,
    required String merchantName,
  }) async {
    final bytes = await buildClientStatement(
        client: client, merchantName: merchantName);
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'HamoNote_${client.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}
