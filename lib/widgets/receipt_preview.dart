import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/client.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import 'signature_pad.dart';

/// Professional receipt widget + capture/share helpers.
/// Image share uses RepaintBoundary (no PDF raster) — rock solid on devices.
class ReceiptPreview extends StatelessWidget {
  final Client client;
  final Transaction transaction;
  final String merchantName;
  final String merchantPhone;
  final String merchantAddress;
  final double currentBalance;
  final Uint8List? signaturePng;
  final GlobalKey? boundaryKey;

  const ReceiptPreview({
    super.key,
    required this.client,
    required this.transaction,
    required this.merchantName,
    required this.currentBalance,
    this.merchantPhone = '',
    this.merchantAddress = '',
    this.signaturePng,
    this.boundaryKey,
  });

  static final _dayNames = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  String get _day => _dayNames[transaction.date.weekday - 1];
  String get _date =>
      DateFormat('dd/MM/yyyy  HH:mm').format(transaction.date);
  bool get _isCredit => transaction.type == TxType.credit;

  @override
  Widget build(BuildContext context) {
    final accent = _isCredit ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final accentBg =
        _isCredit ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);

    final child = Container(
      width: 340,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFBBF24),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'H',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Hamo Note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            Center(
              child: Text(
                merchantName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            if (merchantPhone.isNotEmpty)
              Center(
                child: Text(
                  merchantPhone,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ),
            if (merchantAddress.isNotEmpty)
              Center(
                child: Text(
                  merchantAddress,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ),
            const SizedBox(height: 10),
            _dash(),
            const SizedBox(height: 8),
            Center(
              child: Text(
                transaction.isSettlement ? 'وصل تسوية' : 'وصل عملية',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _dash(),
            const SizedBox(height: 10),
            _row('اليوم', _day),
            _row('تاريخ العملية', _date),
            _row('اسم العميل', client.name),
            _row('هاتف العميل', client.phone),
            _row('الفئة', client.category.arName),
            const SizedBox(height: 8),
            _dash(),
            const SizedBox(height: 8),
            _row('نوع العملية', transaction.type.arVerb),
            if (transaction.isSettlement) _row('الحالة', 'تسوية كاملة'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: accentBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent, width: 1.4),
              ),
              child: Column(
                children: [
                  const Text(
                    'المبلغ',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${transaction.amount.toStringAsFixed(2)} ج.م',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
            if (transaction.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              _row('ملاحظة', transaction.note),
            ],
            const SizedBox(height: 10),
            _dash(),
            const SizedBox(height: 8),
            _row(
              'الرصيد بعد العملية',
              '${currentBalance.abs().toStringAsFixed(2)} ج.م (${currentBalance >= 0 ? "له" : "عليه"})',
            ),
            const SizedBox(height: 8),
            _dash(),
            if (signaturePng != null) ...[
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'التوقيع',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Image.memory(
                  signaturePng!,
                  width: 140,
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),
            ] else ...[
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'توقيع التاجر / العميل',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 120,
                  height: 1,
                  color: const Color(0xFFCBD5E1),
                ),
              ),
            ],
            const SizedBox(height: 14),
            const Center(
              child: Text(
                'شكراً لتعاملكم',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Hamo Note • ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );

    if (boundaryKey != null) {
      return RepaintBoundary(key: boundaryKey, child: child);
    }
    return child;
  }

  static Widget _dash() => Container(
        height: 1,
        color: const Color(0xFFE2E8F0),
      );

  static Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              k,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                v,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      );

  /// Capture widget to PNG bytes.
  static Future<Uint8List?> capture(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      // Wait a frame so layout is ready
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// Full share-as-image flow with optional signature pad.
  static Future<void> showAndShare({
    required BuildContext context,
    required Client client,
    required Transaction transaction,
    required String merchantName,
    required double currentBalance,
    String merchantPhone = '',
    String merchantAddress = '',
  }) async {
    final boundaryKey = GlobalKey();
    final sigKey = GlobalKey<SignaturePadState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.appBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'مشاركة الوصل',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: context.appText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${client.name} • ${transaction.amount.toStringAsFixed(2)} ج.م',
                    style: TextStyle(color: context.appTextDim, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  // Live preview (this is what gets captured)
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ReceiptPreview(
                        boundaryKey: boundaryKey,
                        client: client,
                        transaction: transaction,
                        merchantName: merchantName,
                        merchantPhone: merchantPhone,
                        merchantAddress: merchantAddress,
                        currentBalance: currentBalance,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'التوقيع (اختياري)',
                    style: TextStyle(
                      color: context.appTextDim,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SignaturePad(key: sigKey, height: 110),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final sig = await sigKey.currentState?.toPngBytes();
                        Uint8List? png;
                        if (sig != null && sig.isNotEmpty) {
                          png = await _captureWithSignature(
                            context: context,
                            client: client,
                            transaction: transaction,
                            merchantName: merchantName,
                            merchantPhone: merchantPhone,
                            merchantAddress: merchantAddress,
                            currentBalance: currentBalance,
                            signaturePng: sig,
                          );
                        }
                        png ??= await capture(boundaryKey);
                        if (png == null || png.isEmpty) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تعذر التقاط صورة الوصل'),
                              ),
                            );
                          }
                          return;
                        }
                        final dir = await getTemporaryDirectory();
                        final file = File(
                          '${dir.path}/HamoNote_Receipt_${DateTime.now().millisecondsSinceEpoch}.png',
                        );
                        await file.writeAsBytes(png);
                        await Share.shareXFiles(
                          [XFile(file.path)],
                          text:
                              'وصل Hamo Note\nالعميل: ${client.name}\nالمبلغ: ${transaction.amount.toStringAsFixed(2)} ج.م\nالتاريخ: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)}',
                        );
                        try {
                          await file.delete();
                        } catch (_) {}
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('خطأ المشاركة: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.image_rounded),
                    label: const Text('مشاركة كصورة'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('إلغاء'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<Uint8List?> _captureWithSignature({
    required BuildContext context,
    required Client client,
    required Transaction transaction,
    required String merchantName,
    required double currentBalance,
    required Uint8List signaturePng,
    String merchantPhone = '',
    String merchantAddress = '',
  }) async {
    final key = GlobalKey();
    final completerOverlay = OverlayEntry(
      builder: (ctx) => Positioned(
        left: -5000,
        top: 0,
        child: Material(
          color: Colors.transparent,
          child: ReceiptPreview(
            boundaryKey: key,
            client: client,
            transaction: transaction,
            merchantName: merchantName,
            merchantPhone: merchantPhone,
            merchantAddress: merchantAddress,
            currentBalance: currentBalance,
            signaturePng: signaturePng,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(completerOverlay);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final bytes = await capture(key);
    completerOverlay.remove();
    return bytes;
  }
}
