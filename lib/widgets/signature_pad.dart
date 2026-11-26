import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../theme/app_theme.dart';

/// Simple freehand signature / pen pad.
class SignaturePad extends StatefulWidget {
  final double height;
  final Color penColor;
  final double strokeWidth;

  const SignaturePad({
    super.key,
    this.height = 160,
    this.penColor = Colors.black,
    this.strokeWidth = 2.4,
  });

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _current = [];
  final GlobalKey _repaintKey = GlobalKey();

  bool get hasStrokes => _strokes.isNotEmpty || _current.isNotEmpty;

  void clear() {
    setState(() {
      _strokes.clear();
      _current = [];
    });
  }

  Future<Uint8List?> toPngBytes() async {
    if (!hasStrokes) return null;
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: context.isDark
                ? const Color(0xFFF8FAFC)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appBorder, width: 1.2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: RepaintBoundary(
              key: _repaintKey,
              child: GestureDetector(
                onPanStart: (d) {
                  setState(() {
                    _current = [d.localPosition];
                  });
                },
                onPanUpdate: (d) {
                  setState(() {
                    _current = [..._current, d.localPosition];
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    if (_current.isNotEmpty) {
                      _strokes.add(List.from(_current));
                    }
                    _current = [];
                  });
                },
                child: CustomPaint(
                  painter: _SignaturePainter(
                    strokes: [
                      ..._strokes,
                      if (_current.isNotEmpty) _current,
                    ],
                    color: widget.penColor,
                    strokeWidth: widget.strokeWidth,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'ارسم التوقيع بالقلم',
              style: TextStyle(color: context.appTextDim, fontSize: 12),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: hasStrokes ? clear : null,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('مسح'),
              style: TextButton.styleFrom(
                foregroundColor: context.appRed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;
  final double strokeWidth;

  _SignaturePainter({
    required this.strokes,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) {
        if (stroke.isNotEmpty) {
          canvas.drawCircle(stroke.first, strokeWidth / 2, paint..style = PaintingStyle.fill);
          paint.style = PaintingStyle.stroke;
        }
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
