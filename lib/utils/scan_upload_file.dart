import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

void _scanUploadLog(String flow, String message) {
  debugPrint('[ScanUpload][$flow] $message');
}

/// Longest edge capped to avoid huge iOS scans tripping PHP/nginx body limits.
const int _kScanUploadMaxDimension = 2800;

Future<File?> _encodeViaImagePackage(
  File source,
  String targetPath,
  String logFlow,
) async {
  try {
    final raw = await source.readAsBytes();
    if (raw.isEmpty) {
      _scanUploadLog(logFlow, 'dart image: empty file bytes');
      return null;
    }

    var decoded = img.decodeImage(raw);
    if (decoded == null) {
      _scanUploadLog(
        logFlow,
        'dart image: decodeImage failed (unsupported/corrupt raster?)',
      );
      return null;
    }

    if (decoded.width > _kScanUploadMaxDimension ||
        decoded.height > _kScanUploadMaxDimension) {
      if (decoded.width >= decoded.height) {
        decoded = img.copyResize(
          decoded,
          width: _kScanUploadMaxDimension,
          interpolation: img.Interpolation.linear,
        );
      } else {
        decoded = img.copyResize(
          decoded,
          height: _kScanUploadMaxDimension,
          interpolation: img.Interpolation.linear,
        );
      }
      _scanUploadLog(
        logFlow,
        'dart image: resized longest edge to <= $_kScanUploadMaxDimension',
      );
    }

    final jpeg = img.encodeJpg(decoded, quality: 88);
    if (jpeg.isEmpty) return null;

    final out = File(targetPath);
    await out.writeAsBytes(jpeg, flush: true);
    final n = await out.length();
    _scanUploadLog(
      logFlow,
      'OK via package:image decode+encodeJpg -> ${out.path} ($n bytes)',
    );
    return out;
  } catch (e, st) {
    _scanUploadLog(logFlow, 'package:image path failed: $e\n$st');
    return null;
  }
}

/// iOS VisionKit / [flutter_doc_scanner] often saves **PNG**. Scan endpoints
/// often validate **`image/jpeg` only** (Laravel `mimes:jpeg,jpg`), returning 422.
///
/// Pipeline (in order):
/// 1. Already `.jpg` / `.jpeg` → return as-is.
/// 2. [FlutterImageCompress] `compressAndGetFile` (native, fast).
/// 3. [FlutterImageCompress] `compressWithFile` (fallback when (2) is null).
/// 4. **`package:image`** decode → optional downscale → JPEG (pure Dart;
///    catches PNGs / color profiles that confuse the native compressor).
///
/// [logFlow] tags logs (e.g. `GasolineBasic`, `TaxManager`, `Quebec`).
Future<File> normalizeScanUploadToJpegIfNeeded(
  File source, {
  String logFlow = 'ScanUpload',
}) async {
  final lower = source.path.toLowerCase();

  try {
    final srcLen = await source.length();
    _scanUploadLog(
      logFlow,
      'normalize begin path=${source.path} ext=${_extOf(source.path)} bytes=$srcLen',
    );
  } catch (_) {}

  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
    _scanUploadLog(logFlow, 'already JPEG, skip re-encode');
    return source;
  }

  Future<File?> tryCompressAndGetFile(String targetPath) async {
    try {
      final out = await FlutterImageCompress.compressAndGetFile(
        source.absolute.path,
        targetPath,
        quality: 88,
        format: CompressFormat.jpeg,
      );
      if (out == null) return null;
      final f = File(out.path);
      if (!await f.exists() || await f.length() == 0) return null;
      return f;
    } catch (e, st) {
      _scanUploadLog(logFlow, 'compressAndGetFile failed: $e\n$st');
      return null;
    }
  }

  Future<File?> tryCompressWithFileBytes(String targetPath) async {
    try {
      final bytes = await FlutterImageCompress.compressWithFile(
        source.absolute.path,
        quality: 88,
        format: CompressFormat.jpeg,
      );
      if (bytes == null || bytes.isEmpty) return null;
      final f = File(targetPath);
      await f.writeAsBytes(bytes, flush: true);
      return f;
    } catch (e, st) {
      _scanUploadLog(logFlow, 'compressWithFile failed: $e\n$st');
      return null;
    }
  }

  try {
    if (!await source.exists()) {
      _scanUploadLog(logFlow, 'source file missing, cannot normalize');
      return source;
    }

    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;

    final pathA = '${dir.path}/scan_upload_${stamp}_a.jpg';
    final jpegA = await tryCompressAndGetFile(pathA);
    if (jpegA != null) {
      final n = await jpegA.length();
      _scanUploadLog(
        logFlow,
        'OK via compressAndGetFile -> ${jpegA.path} ($n bytes)',
      );
      return jpegA;
    }

    _scanUploadLog(
      logFlow,
      'compressAndGetFile empty/null, trying compressWithFile...',
    );

    final pathB = '${dir.path}/scan_upload_${stamp}_b.jpg';
    final jpegB = await tryCompressWithFileBytes(pathB);
    if (jpegB != null && await jpegB.exists() && await jpegB.length() > 0) {
      final n = await jpegB.length();
      _scanUploadLog(
        logFlow,
        'OK via compressWithFile -> ${jpegB.path} ($n bytes)',
      );
      return jpegB;
    }

    _scanUploadLog(
      logFlow,
      'native compress paths failed, trying package:image (PNG/WebP/BMP)...',
    );

    final pathC = '${dir.path}/scan_upload_${stamp}_c.jpg';
    final jpegC = await _encodeViaImagePackage(source, pathC, logFlow);
    if (jpegC != null && await jpegC.exists() && await jpegC.length() > 0) {
      return jpegC;
    }
  } catch (e, st) {
    _scanUploadLog(logFlow, 'normalize error: $e\n$st');
  }

  _scanUploadLog(
    logFlow,
    'ALL JPEG strategies failed — using original (API may return 422): ${source.path}',
  );
  return source;
}

String _extOf(String path) {
  final parts = path.split('.');
  if (parts.length < 2) return '?';
  return parts.last.toLowerCase();
}
