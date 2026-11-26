import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double? _first;
  String? _op;
  bool _resetOnNext = false;

  void _tap(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (key == 'C') {
        _display = '0';
        _expression = '';
        _first = null;
        _op = null;
        _resetOnNext = false;
        return;
      }
      if (key == '⌫') {
        if (_display.length <= 1 || _display == '0') {
          _display = '0';
        } else {
          _display = _display.substring(0, _display.length - 1);
        }
        return;
      }
      if (key == '±') {
        if (_display.startsWith('-')) {
          _display = _display.substring(1);
        } else if (_display != '0') {
          _display = '-$_display';
        }
        return;
      }
      if (key == '%') {
        final v = double.tryParse(_display) ?? 0;
        _display = _fmt(v / 100);
        return;
      }
      if ('+-×÷'.contains(key)) {
        _first = double.tryParse(_display) ?? 0;
        _op = key;
        _expression = '$_display $key';
        _resetOnNext = true;
        return;
      }
      if (key == '=') {
        if (_op == null || _first == null) return;
        final second = double.tryParse(_display) ?? 0;
        double result = 0;
        switch (_op) {
          case '+':
            result = _first! + second;
            break;
          case '-':
            result = _first! - second;
            break;
          case '×':
            result = _first! * second;
            break;
          case '÷':
            if (second == 0) {
              _display = 'خطأ';
              _expression = '';
              _first = null;
              _op = null;
              _resetOnNext = true;
              return;
            }
            result = _first! / second;
            break;
        }
        _expression = '${_fmt(_first!)} $_op ${_fmt(second)} =';
        _display = _fmt(result);
        _first = null;
        _op = null;
        _resetOnNext = true;
        return;
      }
      // digit or dot
      if (_resetOnNext) {
        _display = key == '.' ? '0.' : key;
        _resetOnNext = false;
        return;
      }
      if (key == '.') {
        if (_display.contains('.')) return;
        _display = '$_display.';
        return;
      }
      if (_display == '0') {
        _display = key;
      } else {
        if (_display.replaceAll('-', '').replaceAll('.', '').length >= 12) {
          return;
        }
        _display = '$_display$key';
      }
    });
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    var s = v.toStringAsFixed(6);
    s = s.replaceFirst(RegExp(r'\.?0+$'), '');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['C', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['±', '0', '.', '='],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('الآلة الحاسبة')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.appGold.withOpacity(0.18),
                        context.appCard,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: context.appBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _expression,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: context.appTextDim,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _display,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: context.appText,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 5,
                child: Column(
                  children: keys.map((row) {
                    return Expanded(
                      child: Row(
                        children: row.map((k) {
                          final isOp = '+-×÷='.contains(k);
                          final isFn = 'C⌫%±'.contains(k);
                          Color bg;
                          Color fg;
                          if (k == '=') {
                            bg = context.appGold;
                            fg = Colors.black;
                          } else if (isOp) {
                            bg = context.appGold.withOpacity(0.2);
                            fg = context.appGold;
                          } else if (isFn) {
                            bg = context.appCardLight;
                            fg = context.appTextDim;
                          } else {
                            bg = context.appCard;
                            fg = context.appText;
                          }
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Material(
                                color: bg,
                                borderRadius: BorderRadius.circular(18),
                                elevation: k == '=' ? 3 : 0,
                                shadowColor: context.appGold.withOpacity(0.4),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () => _tap(k),
                                  child: Center(
                                    child: Text(
                                      k,
                                      style: TextStyle(
                                        color: fg,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
