import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Normalized (0–1) overlay box on a tax document.
class SensitiveBox {
  SensitiveBox({
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.visible = true,
    this.userDrawn = false,
  });

  final String id;
  double left;
  double top;
  double width;
  double height;
  bool visible;
  bool userDrawn;

  SensitiveBox copy() => SensitiveBox(
        id: id,
        left: left,
        top: top,
        width: width,
        height: height,
        visible: visible,
        userDrawn: userDrawn,
      );
}

class SensitiveDataDetector {
  SensitiveDataDetector._();

  static final _sin = RegExp(r'\b\d{3}[\s\-]?\d{3}[\s\-]?\d{3}\b');
  static final _ssn = RegExp(r'\b\d{3}-\d{2}-\d{4}\b');
  static final _postal = RegExp(
    r'\b[ABCEGHJ-NPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][ ]?\d[ABCEGHJ-NPRSTV-Z]\d\b',
    caseSensitive: false,
  );
  static final _phone = RegExp(r'\b(?:\+?1[\s\-]?)?\(?\d{3}\)?[\s\-]?\d{3}[\s\-]?\d{4}\b');
  static final _email = RegExp(r'\b[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}\b', caseSensitive: false);
  static final _longAccount = RegExp(r'\b\d{7,12}\b');

  static const _labelHints = [
    'sin',
    'nas',
    'social insurance',
    "numero d'assurance",
    "numéro d'assurance",
    'assurance sociale',
    'old age security number',
    'numero de la vieillesse',
    'nom et adresse',
    'name and address',
    'recipient',
    'beneficiaire',
    'bénéficiaire',
  ];

  static Future<({double width, double height})> imageSize(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final size = (width: image.width.toDouble(), height: image.height.toDouble());
    image.dispose();
    return size;
  }

  static Future<List<SensitiveBox>> detect(File file) async {
    final size = await imageSize(file);
    if (size.width <= 0 || size.height <= 0) return [];

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFilePath(file.absolute.path);
      final result = await recognizer.processImage(input);
      final boxes = <SensitiveBox>[];
      var i = 0;

      for (final block in result.blocks) {
        for (final line in block.lines) {
          final text = line.text.trim();
          if (text.isEmpty) continue;
          if (_isSensitive(text)) {
            boxes.add(_fromRect(line.boundingBox, size.width, size.height, 'd${i++}'));
          }
        }
      }

      return _dedupe(boxes);
    } catch (e, st) {
      debugPrint('SensitiveDataDetector error: $e\n$st');
      return [];
    } finally {
      await recognizer.close();
    }
  }

  static bool _isSensitive(String text) {
    final lower = text.toLowerCase();
    if (_labelHints.any(lower.contains)) return true;
    if (_email.hasMatch(text) || _phone.hasMatch(text) || _postal.hasMatch(text)) {
      return true;
    }
    if (_ssn.hasMatch(text)) return true;

    for (final match in _sin.allMatches(text)) {
      final digits = match.group(0)!.replaceAll(RegExp(r'[\s\-]'), '');
      if (digits.length == 9 && !_looksLikeMoney(text)) return true;
    }

    if (_longAccount.hasMatch(text) && !_looksLikeMoney(text) && !_looksLikeYearLine(text)) {
      return true;
    }

    if (_looksLikePersonName(text) || _looksLikeStreet(text)) return true;
    return false;
  }

  static bool _looksLikeMoney(String text) =>
      RegExp(r'\d+[.,]\d{2}').hasMatch(text);

  static bool _looksLikeYearLine(String text) =>
      RegExp(r'\b(19|20)\d{2}\b').hasMatch(text) && text.length < 12;

  static bool _looksLikePersonName(String text) {
    final t = text.trim();
    if (t.length < 6) return false;
    return RegExp(
      r'^(M\.|MME|MR\.?|MS\.?|MRS\.?|MISS)\s+[A-ZÀ-Ü]',
      caseSensitive: false,
    ).hasMatch(t);
  }

  static bool _looksLikeStreet(String text) {
    final lower = text.toLowerCase();
    return RegExp(
      r'\b(rue|avenue|av\.|blvd|boulevard|street|st\.|road|rd\.|drive|dr\.|chemin|ch\.|place)\b',
    ).hasMatch(lower);
  }

  static SensitiveBox _fromRect(
    ui.Rect rect,
    double imgW,
    double imgH,
    String id,
  ) {
    const pad = 0.006;
    var left = (rect.left / imgW) - pad;
    var top = (rect.top / imgH) - pad;
    var width = (rect.width / imgW) + pad * 2;
    var height = (rect.height / imgH) + pad * 2;
    left = left.clamp(0.0, 1.0);
    top = top.clamp(0.0, 1.0);
    if (left + width > 1) width = 1 - left;
    if (top + height > 1) height = 1 - top;
    return SensitiveBox(
      id: id,
      left: left,
      top: top,
      width: width.clamp(0.01, 1.0),
      height: height.clamp(0.012, 1.0),
    );
  }

  static List<SensitiveBox> _dedupe(List<SensitiveBox> input) {
    final out = <SensitiveBox>[];
    for (final box in input) {
      final overlap = out.any((e) => _iou(e, box) > 0.55);
      if (!overlap) out.add(box);
    }
    return out;
  }

  static double _iou(SensitiveBox a, SensitiveBox b) {
    final x1 = a.left > b.left ? a.left : b.left;
    final y1 = a.top > b.top ? a.top : b.top;
    final x2 = (a.left + a.width) < (b.left + b.width)
        ? a.left + a.width
        : b.left + b.width;
    final y2 = (a.top + a.height) < (b.top + b.height)
        ? a.top + a.height
        : b.top + b.height;
    final inter = (x2 - x1).clamp(0, 1) * (y2 - y1).clamp(0, 1);
    final union = a.width * a.height + b.width * b.height - inter;
    if (union <= 0) return 0;
    return inter / union;
  }
}
