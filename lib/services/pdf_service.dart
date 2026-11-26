import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import '../models/client.dart';
import '../models/transaction.dart';

class PdfService {
  static final _dateFmt = DateFormat('yyyy/MM/dd');
  static final _dateTimeFmt = DateFormat('yyyy/MM/dd  HH:mm');
  static final _shortTimeFmt = DateFormat('dd/MM/yyyy  HH:mm');
  static final _dayNames = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static String _dayName(DateTime d) => _dayNames[d.weekday - 1];

  static Future<pw.Font> _reg() async {
    final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  static Future<pw.Font> _bold() async {
    final fontData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
    return pw.Font.ttf(fontData);
  }

  // ───────────────────────── Statement (كشف حساب) ─────────────────────────
  static Future<Uint8List> buildStatement({
    required Client client,
    required String merchantName,
    String merchantPhone = '',
    String merchantAddress = '',
  }) async {
    final font = await _reg();
    final bold = await _bold();
    final doc = pw.Document();
    final theme = pw.ThemeData.withFont(base: font, bold: bold);

    final isCredit = client.balance >= 0;
    final balanceStr = client.balance.abs().toStringAsFixed(2);
    final balanceLabel = isCredit ? 'له' : 'عليه';
    final themeColor =
        isCredit ? PdfColor.fromHex('#16A34A') : PdfColor.fromHex('#DC2626');
    final themeBg =
        isCredit ? PdfColor.fromHex('#F0FDF4') : PdfColor.fromHex('#FEF2F2');
    final invoiceNo =
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final now = DateTime.now();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: theme,
        textDirection: pw.TextDirection.rtl,
        header: (_) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#0B0F1A'),
            borderRadius: pw.BorderRadius.circular(14),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(children: [
                pw.Container(
                  width: 44,
                  height: 44,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FBBF24'),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text('H',
                        style: pw.TextStyle(
                            font: bold,
                            fontSize: 22,
                            color: PdfColors.black)),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Hamo Note',
                        style: pw.TextStyle(
                            font: bold,
                            fontSize: 20,
                            color: PdfColor.fromHex('#FBBF24'))),
                    pw.SizedBox(height: 2),
                    pw.Text('التاجر: $merchantName',
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                            color: PdfColors.white)),
                    if (merchantPhone.isNotEmpty)
                      pw.Text(merchantPhone,
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 9,
                              color: PdfColor.fromHex('#94A3B8'))),
                  ],
                ),
              ]),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('كشف حساب عميل',
                      style: pw.TextStyle(
                          font: bold, fontSize: 14, color: PdfColors.white)),
                  pw.SizedBox(height: 4),
                  pw.Text('رقم: $invoiceNo',
                      style: pw.TextStyle(
                          font: font,
                          fontSize: 9,
                          color: PdfColor.fromHex('#94A3B8'))),
                  pw.Text(
                      '${_dayName(now)}  ${_dateFmt.format(now)}',
                      style: pw.TextStyle(
                          font: font,
                          fontSize: 9,
                          color: PdfColor.fromHex('#94A3B8'))),
                ],
              ),
            ],
          ),
        ),
        build: (ctx) => [
          // Client info card
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8FAFC'),
              borderRadius: pw.BorderRadius.circular(12),
              border:
                  pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('بيانات العميل',
                    style: pw.TextStyle(
                        font: bold,
                        fontSize: 12,
                        color: PdfColor.fromHex('#0F172A'))),
                pw.SizedBox(height: 10),
                pw.Row(children: [
                  pw.Expanded(child: _kv('الاسم', client.name, font, bold)),
                  pw.Expanded(
                      child: _kv('الهاتف', client.phone, font, bold)),
                ]),
                pw.SizedBox(height: 6),
                pw.Row(children: [
                  pw.Expanded(
                      child:
                          _kv('الفئة', client.category.arName, font, bold)),
                  pw.Expanded(
                    child: _kv('عدد المعاملات',
                        '${client.transactions.length}', font, bold),
                  ),
                ]),
                if (client.note != null && client.note!.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  _kv('ملاحظة', client.note!, font, bold),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          // Balance banner
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: themeBg,
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(color: themeColor, width: 1.5),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('الرصيد الحالي',
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 11,
                            color: PdfColor.fromHex('#334155'))),
                    pw.SizedBox(height: 4),
                    pw.Text('$balanceStr ج.م',
                        style: pw.TextStyle(
                            font: bold, fontSize: 26, color: themeColor)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: themeColor,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(balanceLabel,
                      style: pw.TextStyle(
                          font: bold, fontSize: 13, color: PdfColors.white)),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text('سجل المعاملات',
              style: pw.TextStyle(
                  font: bold,
                  fontSize: 13,
                  color: PdfColor.fromHex('#0F172A'))),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
                color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
            columnWidths: const {
              0: pw.FixedColumnWidth(26),
              1: pw.FlexColumnWidth(2.4),
              2: pw.FlexColumnWidth(1.6),
              3: pw.FlexColumnWidth(2),
              4: pw.FlexColumnWidth(2.6),
            },
            children: [
              pw.TableRow(
                decoration:
                    pw.BoxDecoration(color: PdfColor.fromHex('#0B0F1A')),
                children: [
                  _cell('#', bold, header: true),
                  _cell('التاريخ واليوم', bold, header: true),
                  _cell('النوع', bold, header: true),
                  _cell('المبلغ', bold, header: true),
                  _cell('ملاحظة', bold, header: true),
                ],
              ),
              ...client.transactions.reversed.toList().asMap().entries.map(
                (e) {
                  final i = e.key + 1;
                  final t = e.value;
                  final credit = t.type == TxType.credit;
                  final bg = i.isEven
                      ? PdfColors.white
                      : PdfColor.fromHex('#F8FAFC');
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: bg),
                    children: [
                      _cell('$i', font),
                      _cell(
                          '${_dayName(t.date)}\n${_dateTimeFmt.format(t.date)}',
                          font,
                          small: true),
                      _cell(t.type.arName, font,
                          color: credit
                              ? PdfColor.fromHex('#16A34A')
                              : PdfColor.fromHex('#DC2626')),
                      _cell('${t.amount.toStringAsFixed(2)} ج.م', font),
                      _cell(t.note.isEmpty ? '—' : t.note, font, small: true),
                    ],
                  );
                },
              ),
            ],
          ),
          pw.SizedBox(height: 22),
          pw.Container(
            padding: const pw.EdgeInsets.only(top: 12),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                    color: PdfColor.fromHex('#E2E8F0'), width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('توقيع التاجر:',
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                            color: PdfColor.fromHex('#64748B'))),
                    pw.SizedBox(height: 22),
                    pw.Container(
                      width: 110,
                      height: 1,
                      color: PdfColor.fromHex('#94A3B8'),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('تم الإنشاء بواسطة Hamo Note',
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 9,
                            color: PdfColor.fromHex('#64748B'))),
                    pw.Text('شكراً لتعاملكم',
                        style: pw.TextStyle(
                            font: bold,
                            fontSize: 10,
                            color: PdfColor.fromHex('#D97706'))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ───────────────────────── Receipt (وصل) ─────────────────────────
  static Future<Uint8List> buildReceipt({
    required Client client,
    required Transaction transaction,
    required String merchantName,
    required double currentBalance,
    String merchantPhone = '',
    String merchantAddress = '',
    Uint8List? signaturePng,
  }) async {
    final font = await _reg();
    final bold = await _bold();
    final doc = pw.Document();
    final theme = pw.ThemeData.withFont(base: font, bold: bold);
    final isCredit = transaction.type == TxType.credit;
    final themeColor =
        isCredit ? PdfColor.fromHex('#16A34A') : PdfColor.fromHex('#DC2626');
    final themeBg =
        isCredit ? PdfColor.fromHex('#F0FDF4') : PdfColor.fromHex('#FEF2F2');
    final day = _dayName(transaction.date);
    final receiptNo =
        'R-${transaction.id.length > 6 ? transaction.id.substring(transaction.id.length - 6) : transaction.id}';

    // Use a wider thermal-like page that prints reliably
    final pageFormat = PdfPageFormat(
      80 * PdfPageFormat.mm,
      double.infinity,
      marginAll: 6 * PdfPageFormat.mm,
    );

    doc.addPage(pw.Page(
      pageFormat: pageFormat,
      theme: theme,
      textDirection: pw.TextDirection.rtl,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Logo + brand
          pw.Center(
            child: pw.Container(
              width: 40,
              height: 40,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FBBF24'),
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Text('H',
                    style: pw.TextStyle(
                        font: bold, fontSize: 20, color: PdfColors.black)),
              ),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text('Hamo Note',
                style: pw.TextStyle(font: bold, fontSize: 16)),
          ),
          pw.Center(
            child: pw.Text(merchantName,
                style: pw.TextStyle(
                    font: bold,
                    fontSize: 11,
                    color: PdfColor.fromHex('#0F172A'))),
          ),
          if (merchantPhone.isNotEmpty)
            pw.Center(
              child: pw.Text(merchantPhone,
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 9,
                      color: PdfColor.fromHex('#64748B'))),
            ),
          if (merchantAddress.isNotEmpty)
            pw.Center(
              child: pw.Text(merchantAddress,
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 8,
                      color: PdfColor.fromHex('#64748B'))),
            ),
          pw.SizedBox(height: 8),
          _dashed(),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text(
              transaction.isSettlement ? 'وصل تسوية' : 'وصل عملية',
              style: pw.TextStyle(font: bold, fontSize: 13),
            ),
          ),
          pw.Center(
            child: pw.Text('رقم: $receiptNo',
                style: pw.TextStyle(
                    font: font,
                    fontSize: 9,
                    color: PdfColor.fromHex('#64748B'))),
          ),
          pw.SizedBox(height: 6),
          _dashed(),
          pw.SizedBox(height: 8),

          // Details block — full info
          _detailRow('اليوم', day, font, bold),
          _detailRow('تاريخ العملية', _shortTimeFmt.format(transaction.date),
              font, bold),
          _detailRow('اسم العميل', client.name, font, bold),
          _detailRow('هاتف العميل', client.phone, font, bold),
          _detailRow('الفئة', client.category.arName, font, bold),
          pw.SizedBox(height: 6),
          _dashed(),
          pw.SizedBox(height: 6),
          _detailRow('نوع العملية', transaction.type.arVerb, font, bold),
          if (transaction.isSettlement)
            _detailRow('الحالة', 'تسوية كاملة', font, bold),

          pw.SizedBox(height: 8),
          // Amount highlight
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: pw.BoxDecoration(
              color: themeBg,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: themeColor, width: 1.2),
            ),
            child: pw.Column(children: [
              pw.Text('المبلغ',
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 9,
                      color: PdfColor.fromHex('#64748B'))),
              pw.SizedBox(height: 2),
              pw.Text('${transaction.amount.toStringAsFixed(2)} ج.م',
                  style: pw.TextStyle(
                      font: bold, fontSize: 20, color: themeColor)),
            ]),
          ),

          if (transaction.note.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _detailRow('ملاحظة', transaction.note, font, bold),
          ],

          pw.SizedBox(height: 8),
          _dashed(),
          pw.SizedBox(height: 6),
          _detailRow(
            'الرصيد بعد العملية',
            '${currentBalance.abs().toStringAsFixed(2)} ج.م (${currentBalance >= 0 ? "له" : "عليه"})',
            font,
            bold,
          ),
          pw.SizedBox(height: 6),
          _dashed(),

          // Signature area
          if (signaturePng != null) ...[
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text('التوقيع',
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 9,
                      color: PdfColor.fromHex('#64748B'))),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Image(
                pw.MemoryImage(signaturePng),
                width: 120,
                height: 48,
                fit: pw.BoxFit.contain,
              ),
            ),
          ] else ...[
            pw.SizedBox(height: 12),
            pw.Center(
              child: pw.Text('توقيع التاجر / العميل',
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 9,
                      color: PdfColor.fromHex('#94A3B8'))),
            ),
            pw.SizedBox(height: 18),
            pw.Center(
              child: pw.Container(
                width: 100,
                height: 1,
                color: PdfColor.fromHex('#CBD5E1'),
              ),
            ),
          ],

          pw.SizedBox(height: 12),
          pw.Center(
            child: pw.Text('شكراً لتعاملكم',
                style: pw.TextStyle(font: bold, fontSize: 11)),
          ),
          pw.SizedBox(height: 2),
          pw.Center(
            child: pw.Text('Hamo Note • ${_dateFmt.format(DateTime.now())}',
                style: pw.TextStyle(
                    font: font,
                    fontSize: 8,
                    color: PdfColor.fromHex('#94A3B8'))),
          ),
          pw.SizedBox(height: 8),
        ],
      ),
    ));

    return doc.save();
  }

  // ───────────────────────── Share / Print helpers ─────────────────────────
  static Future<void> shareStatement({
    required Client client,
    required String merchantName,
    String merchantPhone = '',
    String merchantAddress = '',
  }) async {
    try {
      final bytes = await buildStatement(
        client: client,
        merchantName: merchantName,
        merchantPhone: merchantPhone,
        merchantAddress: merchantAddress,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'HamoNote_Statement_${client.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> shareReceipt({
    required Client client,
    required Transaction transaction,
    required String merchantName,
    required double currentBalance,
    String merchantPhone = '',
    String merchantAddress = '',
    Uint8List? signaturePng,
  }) async {
    final bytes = await buildReceipt(
      client: client,
      transaction: transaction,
      merchantName: merchantName,
      currentBalance: currentBalance,
      merchantPhone: merchantPhone,
      merchantAddress: merchantAddress,
      signaturePng: signaturePng,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'HamoNote_Receipt_${client.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Convert first page of PDF to high-quality PNG and share as image.
  static Future<void> sharePdfAsImage({
    required Uint8List pdfBytes,
    required String filename,
    String shareText = 'وصل من Hamo Note',
  }) async {
    final tempDir = await getTemporaryDirectory();
    final safeName = filename.replaceAll(RegExp(r'[^\w\-]+'), '_');
    final pdfFile = File('${tempDir.path}/temp_$safeName.pdf');
    await pdfFile.writeAsBytes(pdfBytes);

    try {
      final document = await pdfx.PdfDocument.openFile(pdfFile.path);
      final page = await document.getPage(1);
      // High resolution for clear Arabic text
      final pageImage = await page.render(
        width: page.width * 3.5,
        height: page.height * 3.5,
        format: pdfx.PdfPageImageFormat.png,
      );
      await page.close();
      await document.close();

      if (pageImage != null && pageImage.bytes.isNotEmpty) {
        final imageFile = File('${tempDir.path}/$safeName.png');
        await imageFile.writeAsBytes(pageImage.bytes);
        await Share.shareXFiles(
          [XFile(imageFile.path)],
          text: shareText,
        );
        try {
          await imageFile.delete();
        } catch (_) {}
      }
    } finally {
      try {
        await pdfFile.delete();
      } catch (_) {}
    }
  }

  static Future<void> printPdf(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  // ───────────────────────── Helpers ─────────────────────────
  static pw.Widget _dashed() => pw.Container(
        height: 0.6,
        color: PdfColor.fromHex('#CBD5E1'),
      );

  static pw.Widget _detailRow(
          String k, String v, pw.Font font, pw.Font bold) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(k,
                style: pw.TextStyle(
                    font: font,
                    fontSize: 9,
                    color: PdfColor.fromHex('#64748B'))),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Text(
                v,
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(font: bold, fontSize: 10),
              ),
            ),
          ],
        ),
      );

  static pw.Widget _kv(String k, String v, pw.Font font, pw.Font bold) =>
      pw.Row(children: [
        pw.Text('$k: ',
            style: pw.TextStyle(
                font: font, fontSize: 9, color: PdfColor.fromHex('#64748B'))),
        pw.Expanded(
          child: pw.Text(v, style: pw.TextStyle(font: bold, fontSize: 10)),
        ),
      ]);

  static pw.Widget _cell(
    String text,
    pw.Font font, {
    bool header = false,
    bool small = false,
    PdfColor? color,
  }) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: font,
            fontSize: header ? 9 : (small ? 7.5 : 8.5),
            color: header
                ? PdfColors.white
                : (color ?? PdfColor.fromHex('#0F172A')),
            fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
          textAlign: pw.TextAlign.center,
        ),
      );
}
