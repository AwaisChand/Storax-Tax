import 'package:intl/intl.dart';

dynamic scanField(Map<String, dynamic> data, List<String> keys) {
  final wanted = keys.map((k) => k.toLowerCase()).toSet();
  for (final entry in data.entries) {
    if (!wanted.contains(entry.key.toString().toLowerCase())) continue;
    final value = entry.value;
    if (value != null && value.toString().trim().isNotEmpty) {
      return value;
    }
  }
  for (final nestedKey in ['extracted', 'fields', 'result', 'data']) {
    for (final entry in data.entries) {
      if (entry.key.toString().toLowerCase() != nestedKey) continue;
      final nested = entry.value;
      if (nested is Map) {
        final found = scanField(Map<String, dynamic>.from(nested), keys);
        if (found != null) return found;
      }
    }
  }
  return null;
}

DateTime? extractScanReceiptDate(Map<String, dynamic>? data) {
  if (data == null || data.isEmpty) return null;

  final parsed = parseScanReceiptDate(
    scanField(data, const [
      'date',
      'invoice_date',
      'receipt_date',
      'document_date',
      'date_received',
      'date_recieved',
      'transaction_date',
      'purchase_date',
    ]),
  );
  if (parsed != null) return parsed;

  final year = _asYear(scanField(data, const ['year']));
  final month = _asMonth(scanField(data, const ['month']));
  if (year == null || month == null) return null;

  final dayRaw = int.tryParse(scanField(data, const ['day'])?.toString() ?? '');
  final day = (dayRaw != null && dayRaw >= 1 && dayRaw <= 31) ? dayRaw : 1;
  return DateTime(year, month, day);
}

DateTime? parseScanReceiptDate(dynamic raw) {
  if (raw == null) return null;
  if (raw is DateTime) {
    return DateTime(raw.year, raw.month, raw.day);
  }
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final year = _asYear(scanField(map, const ['year']));
    final month = _asMonth(scanField(map, const ['month']));
    if (year != null && month != null) {
      final dayRaw = int.tryParse(
        scanField(map, const ['day'])?.toString() ?? '',
      );
      final day = (dayRaw != null && dayRaw >= 1 && dayRaw <= 31) ? dayRaw : 1;
      return DateTime(year, month, day);
    }
    return parseScanReceiptDate(scanField(map, const ['date', 'value']));
  }

  var value = raw.toString().trim();
  if (value.isEmpty) return null;

  final isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
  if (isoDate != null) {
    return DateTime(
      int.parse(isoDate.group(1)!),
      int.parse(isoDate.group(2)!),
      int.parse(isoDate.group(3)!),
    );
  }

  // "27 Sep 2026 8:35:11 PM" → "27 Sep 2026"
  value = value
      .replaceAll(
        RegExp(r'\s+\d{1,2}:\d{2}(?::\d{2})?(?:\s*[AaPp]\.?[Mm]\.?)?$'),
        '',
      )
      .trim();
  value = value.replaceAll('.', '/');

  const formats = [
    'yyyy/MM/dd',
    'dd MMM yyyy',
    'dd MMMM yyyy',
    'd MMM yyyy',
    'd MMMM yyyy',
    'MMM d, yyyy',
    'MMMM d, yyyy',
    'MMM d yyyy',
    'MMMM d yyyy',
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'dd-MM-yyyy',
    'MM-dd-yyyy',
    'dd/MM/yy',
    'MM/dd/yy',
    'dd-MM-yy',
    'MM-dd-yy',
    'MMMM yyyy',
    'MMM yyyy',
    'MM/yyyy',
    'yyyy/MM',
    'yyyy-MM',
  ];

  for (final locale in const ['en_US', 'fr']) {
    for (final format in formats) {
      try {
        return _withCentury(DateFormat(format, locale).parseStrict(value));
      } catch (_) {}
    }
  }

  return null;
}

int? _asYear(dynamic raw) {
  if (raw == null) return null;
  final digits = raw.toString().trim();
  final n = int.tryParse(RegExp(r'\d+').firstMatch(digits)?.group(0) ?? '');
  if (n == null) return null;
  if (n < 100) return 2000 + n;
  return n;
}

int? _asMonth(dynamic raw) {
  if (raw == null) return null;
  if (raw is num) {
    final month = raw.toInt();
    return (month >= 1 && month <= 12) ? month : null;
  }
  final text = raw.toString().trim().toLowerCase().replaceAll('.', '');
  final n = int.tryParse(text);
  if (n != null) return (n >= 1 && n <= 12) ? n : null;

  const months = {
    'jan': 1,
    'january': 1,
    'janv': 1,
    'janvier': 1,
    'feb': 2,
    'february': 2,
    'fev': 2,
    'fév': 2,
    'fevrier': 2,
    'février': 2,
    'mar': 3,
    'march': 3,
    'mars': 3,
    'apr': 4,
    'april': 4,
    'avr': 4,
    'avril': 4,
    'may': 5,
    'mai': 5,
    'jun': 6,
    'june': 6,
    'juin': 6,
    'jul': 7,
    'july': 7,
    'juil': 7,
    'juillet': 7,
    'aug': 8,
    'august': 8,
    'aout': 8,
    'août': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'septembre': 9,
    'oct': 10,
    'october': 10,
    'octobre': 10,
    'nov': 11,
    'november': 11,
    'novembre': 11,
    'dec': 12,
    'december': 12,
    'déc': 12,
    'decembre': 12,
    'décembre': 12,
  };
  return months[text];
}

DateTime _withCentury(DateTime date) {
  final year = date.year < 100 ? 2000 + date.year : date.year;
  return DateTime(year, date.month, date.day);
}
