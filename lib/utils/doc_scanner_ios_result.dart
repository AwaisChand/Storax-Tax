import 'package:flutter/foundation.dart';

/// Filter console with: `[DocScanner]`
void docScannerLog(String flow, String message) {
  debugPrint('[DocScanner][$flow] $message');
}

String _shortenPathForLog(String p, {int head = 48, int tail = 32}) {
  if (p.length <= head + tail + 3) return p;
  return '${p.substring(0, head)}…${p.substring(p.length - tail)}';
}

/// Normalizes [FlutterDocScanner.getScanDocuments] return values across
/// plugin / iOS versions: sometimes `Map` with `images`, sometimes a bare `List`.
List<String> pathsFromIosDocScannerResult(
  dynamic result, {
  required String flow,
}) {
  void log(String m) => docScannerLog(flow, m);

  if (result == null) {
    log('getScanDocuments returned null');
    return [];
  }

  log('raw result runtimeType=${result.runtimeType}');

  if (result is List) {
    log('shape=List length=${result.length}');
    final take = result.length < 5 ? result.length : 5;
    for (var i = 0; i < take; i++) {
      final e = result[i];
      log(
        '  [$i] elemType=${e.runtimeType} value=${_shortenPathForLog(e.toString())}',
      );
    }
    final paths = result
        .map((e) => e.toString())
        .where((path) => path.isNotEmpty)
        .toList();
    log(
      'resolved from List → ${paths.length} path(s)'
      '${paths.isNotEmpty ? ', first="${_shortenPathForLog(paths.first)}"' : ''}',
    );
    return paths;
  }

  if (result is Map) {
    log('shape=Map keys=${result.keys.toList()}');
    final images = result['images'];
    log(
      'result["images"] runtimeType=${images?.runtimeType ?? "null"}, isList=${images is List}',
    );
    if (images is List) {
      final paths = images
          .map((e) => e.toString())
          .where((path) => path.isNotEmpty)
          .toList();
      log(
        'resolved from Map.images → ${paths.length} path(s)'
        '${paths.isNotEmpty ? ', first="${_shortenPathForLog(paths.first)}"' : ''}',
      );
      return paths;
    }
    log('Map had no usable List at key "images"');
    return [];
  }

  log('unrecognized shape (not List or Map), ignoring');
  return [];
}
