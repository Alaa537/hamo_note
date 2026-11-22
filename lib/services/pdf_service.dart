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
  static final _dateTimeFmt = DateFormat('yyyy/MM/dd HH:mm');
  static final _shortTimeFmt = DateFormat('dd/MM  HH:mm');

  static Future<pw.Font> _reg() async {
    final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    return pw.Font.ttf(fontData);
  }

  static Future<pw.Font> _bold() async {
    final fontData = await rootBundle.load("assets/fonts/Cairo-Bold.ttf");
    return pw.Font.ttf(fontData);
  }

  static Future<Uint8List> buildStatement({
    required Client client,
    required String merchantName,
  }) async {
    final font = await _reg();
    final bold = await _bold();
    final doc = pw.Document();
    final theme = pw.ThemeData.withFont(base: font, bold: bold);

    final isCredit = client.balance >= 0;
    final balanceStr = client.balance.abs().toStringAsFixed(2);
    final balanceLabel = isCredit ? 'له' : 'عليه';
    final themeColor = isCredit
        ? PdfColor.fromHex('#00A650')
        : PdfColor.fromHex('#E53935');
    final themeBg = isCredit
        ? PdfColor.fromHex('#E8F8EE')
        : PdfColor.fromHex('#FFEBEB');
    final invoiceNo =
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: theme,
        textDirection: pw.TextDirection.rtl,
        header: (_) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 18),
          padding: const pw.EdgeInsets.all(18),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#0A0E1A'),
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
                    color: PdfColor.fromHex('#00E676'),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text('H',
                        style: pw.TextStyle(
                            font: bold,
                            fontSize: 24,
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
                            fontSize: 22,
                            color: PdfColor.fromHex('#00E676'))),
                    pw.SizedBox(height: 2),
                    pw.Text('اسم التاجر: $merchantName',
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                            color: PdfColors.white)),
                  ],
                ),
              ]),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('كشف حساب عميل',
                      style: pw.TextStyle(
                          font: bold,
                          fontSize: 15,
                          color: PdfColors.white)),
                  pw.SizedBox(height: 4),
                  pw.Text('رقم: $invoiceNo',
                      style: pw.TextStyle(
                          font: font,
                          fontSize: 9,
                          color: PdfColor.fromHex('#8A93A8'))),
                  pw.Text('تاريخ: ${_dateFmt.format(DateTime.now())}',
                      style: pw.TextStyle(
                          font: font,
                          fontSize: 9,
                          color: PdfColor.fromHex('#8A93A8'))),
                ],
              ),
            ],
          ),
        ),
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F5F7FA'),
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(
                  color: PdfColor.fromHex('#E3E8EF'), width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('بيانات العميل',
                    style: pw.TextStyle(
                        font: bold,
                        fontSize: 13,
                        color: PdfColor.fromHex('#1A1F2E'))),
                pw.SizedBox(height: 10),
                pw.Row(children: [
                  pw.Expanded(child: _kv('الاسم', client.name, font, bold)),
                  pw.Expanded(
                      child: _kv('الهاتف', client.phone, font, bold)),
                ]),
                pw.SizedBox(height: 6),
                pw.Row(children: [
                  pw.Expanded(
                      child: _kv('الفئة', client.category.arName, font, bold)),
                  pw.Expanded(
                    child: _kv(
                        'عدد المعاملات',
                        '${client.transactions.length}',
                        font,
                        bold),
                  ),
                ]),
                if (client.note != null && client.note!.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  _kv('ملاحظة', client.note!, font, bold),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            padding: const pw.EdgeInsets.all(18),
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
                            fontSize: 12,
                            color: PdfColor.fromHex('#1A1F2E'))),
                    pw.SizedBox(height: 4),
                    pw.Text('$balanceStr ج.م',
                        style: pw.TextStyle(
                            font: bold,
                            fontSize: 28,
                            color: themeColor)),
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
                          font: bold,
                          fontSize: 13,
                          color: PdfColors.white)),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text('سجل المعاملات',
              style: pw.TextStyle(
                  font: bold, fontSize: 14, color: PdfColor.fromHex('#1A1F2E'))),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
                color: PdfColor.fromHex('#E3E8EF'), width: 0.5),
            columnWidths: const {
              0: pw.FixedColumnWidth(28),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
              4: pw.FlexColumnWidth(3),
            },
            children: [
              pw.TableRow(
                decoration:
                    pw.BoxDecoration(color: PdfColor.fromHex('#141C2E')),
                children: [
                  _cell('#', bold, header: true),
                  _cell('التاريخ', bold, header: true),
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
                      _cell(_dateTimeFmt.format(t.date), font, small: true),
                      _cell(t.type.arName, font,
                          color: credit
                              ? PdfColor.fromHex('#00A650')
                              : PdfColor.fromHex('#E53935')),
                      _cell('${t.amount.toStringAsFixed(2)} ج.م', font),
                      _cell(t.note.isEmpty ? '—' : t.note, font, small: true),
                    ],
                  );
                },
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.only(top: 14),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                    color: PdfColor.fromHex('#E3E8EF'), width: 1),
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
                            color: PdfColor.fromHex('#6B7280'))),
                    pw.SizedBox(height: 20),
                    pw.Container(
                      width: 100,
                      height: 1,
                      color: PdfColor.fromHex('#6B7280'),
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
                            color: PdfColor.fromHex('#6B7280'))),
                    pw.Text('شكراً لتعاملكم 💚',
                        style: pw.TextStyle(
                            font: bold,
                            fontSize: 10,
                            color: PdfColor.fromHex('#00A650'))),
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

  static Future<Uint8List> buildReceipt({
    required Client client,
    required Transaction transaction,
    required String merchantName,
    required double currentBalance,
  }) async {
    final font = await _reg();
    final bold = await _bold();
    final doc = pw.Document();
    final theme = pw.ThemeData.withFont(base: font, bold: bold);
    final isCredit = transaction.type == TxType.credit;
    final themeColor = isCredit
        ? PdfColor.fromHex('#00A650')
        : PdfColor.fromHex('#E53935');
    final themeBg = isCredit
        ? PdfColor.fromHex('#E8F8EE')
        : PdfColor.fromHex('#FFEBEB');

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.roll80,
      theme: theme,
      textDirection: pw.TextDirection.rtl,
      build: (ctx) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Container(
                width: 36,
                height: 36,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#00E676'),
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text('H',
                      style: pw.TextStyle(
                          font: bold,
                          fontSize: 20,
                          color: PdfColors.black)),
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text('Hamo Note',
                  style: pw.TextStyle(font: bold, fontSize: 15)),
            ),
            pw.Center(
              child: pw.Text(merchantName,
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColor.fromHex('#6B7280'))),
            ),
            pw.SizedBox(height: 8),
            _dashed(),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                transaction.isSettlement ? 'وصل تسوية' : 'وصل استلام',
                style: pw.TextStyle(font: bold, fontSize: 12),
              ),
            ),
            pw.SizedBox(height: 6),
            _dashed(),
            pw.SizedBox(height: 6),
            _row('العميل', client.name, font, bold),
            _row('الهاتف', client.phone, font, bold),
            _row('التاريخ', _shortTimeFmt.format(transaction.date), font, bold),
            pw.SizedBox(height: 6),
            _dashed(),
            pw.SizedBox(height: 6),
            _row('النوع', transaction.type.arVerb, font, bold),
            pw.SizedBox(height: 8),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: pw.BoxDecoration(
                color: themeBg,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: themeColor, width: 1),
              ),
              child: pw.Column(children: [
                pw.Text('المبلغ',
                    style: pw.TextStyle(
                        font: font,
                        fontSize: 9,
                        color: PdfColor.fromHex('#6B7280'))),
                pw.SizedBox(height: 2),
                pw.Text('${transaction.amount.toStringAsFixed(2)} ج.م',
                    style: pw.TextStyle(
                        font: bold, fontSize: 20, color: themeColor)),
              ]),
            ),
            if (transaction.note.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              _row('ملاحظة', transaction.note, font, bold),
            ],
            pw.SizedBox(height: 8),
            _dashed(),
            pw.SizedBox(height: 4),
            _row(
              'الرصيد الحالي',
              '${currentBalance.abs().toStringAsFixed(2)} ج.م (${currentBalance >= 0 ? "له" : "عليه"})',
              font,
              bold,
            ),
            pw.SizedBox(height: 6),
            _dashed(),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text('شكراً لتعاملكم 💚',
                  style: pw.TextStyle(font: font, fontSize: 10)),
            ),
            pw.SizedBox(height: 2),
            pw.Center(
              child: pw.Text('Hamo Note',
                  style: pw.TextStyle(
                      font: bold,
                      fontSize: 9,
                      color: PdfColor.fromHex('#6B7280'))),
            ),
            pw.SizedBox(height: 8),
          ],
        ),
      ),
    ));

    return doc.save();
  }

  static Future<void> shareStatement({
    required Client client,
    required String merchantName,
  }) async {
    final bytes =
        await buildStatement(client: client, merchantName: merchantName);
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'HamoNote_Statement_${client.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static Future<void> shareReceipt({
    required Client client,
    required Transaction transaction,
    required String merchantName,
    required double currentBalance,
  }) async {
    final bytes = await buildReceipt(
      client: client,
      transaction: transaction,
      merchantName: merchantName,
      currentBalance: currentBalance,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'HamoNote_Receipt_${client.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static Future<void> sharePdfAsImage({
    required Uint8List pdfBytes,
    required String filename,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final pdfFile = File('${tempDir.path}/temp_$filename.pdf');
    await pdfFile.writeAsBytes(pdfBytes);

    final document = await pdfx.PdfDocument.openFile(pdfFile.path);
    final page = await document.getPage(1);
    final pageImage = await page.render(
      width: page.width * 3,
      height: page.height * 3,
      format: pdfx.PdfPageImageFormat.png,
    );
    await page.close();
    await document.close();

    if (pageImage != null) {
      final imageFile = File('${tempDir.path}/$filename.png');
      await imageFile.writeAsBytes(pageImage.bytes);
      await Share.shareXFiles([XFile(imageFile.path)], text: 'وصل من Hamo Note');
      await imageFile.delete();
    }
    await pdfFile.delete();
  }

  static pw.Widget _dashed() => pw.Container(
        height: 0.5,
        color: PdfColor.fromHex('#BFC7D2'),
      );

  static pw.Widget _row(String k, String v, pw.Font font, pw.Font bold) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(k,
                style: pw.TextStyle(
                    font: font,
                    fontSize: 9,
                    color: PdfColor.fromHex('#6B7280'))),
            pw.Text(v, style: pw.TextStyle(font: bold, fontSize: 9)),
          ],
        ),
      );

  static pw.Widget _kv(String k, String v, pw.Font font, pw.Font bold) =>
      pw.Row(children: [
        pw.Text('$k: ',
            style: pw.TextStyle(
                font: font, fontSize: 9, color: PdfColor.fromHex('#6B7280'))),
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
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: font,
            fontSize: small ? 8 : 9,
            color: color ??
                (header ? PdfColors.white : PdfColor.fromHex('#1A1F2E')),
          ),
        ),
      );
}
