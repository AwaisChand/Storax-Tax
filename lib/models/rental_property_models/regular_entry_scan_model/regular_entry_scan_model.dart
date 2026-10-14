class RegularEntryScanModel {
  final bool success;
  final RegularEntryScanData? data;
  final String? message;

  RegularEntryScanModel({required this.success, this.data, this.message});

  bool get isSuccess => success && data != null;

  factory RegularEntryScanModel.fromJson(Map<dynamic, dynamic> json) {
    final rawSuccess = json['success'];
    final status = json['status'];
    final success =
        rawSuccess == true ||
        rawSuccess == 1 ||
        rawSuccess?.toString() == '1' ||
        status?.toString() == '1';

    RegularEntryScanData? data;
    final rawData = json['data'];
    if (rawData is Map) {
      data = RegularEntryScanData.fromJson(Map<String, dynamic>.from(rawData));
    }

    final rawMessage = json['message'];
    String? message;
    if (rawMessage != null) {
      message = rawMessage.toString();
    } else if (json['success'] is String) {
      message = json['success'] as String;
    }

    return RegularEntryScanModel(
      success: success,
      data: data,
      message: message,
    );
  }
}

class RegularEntryScanData {
  final String? date;
  final double? amount;
  final String? expenseType;

  RegularEntryScanData({this.date, this.amount, this.expenseType});

  factory RegularEntryScanData.fromJson(Map<String, dynamic> json) {
    return RegularEntryScanData(
      date: json['date']?.toString(),
      amount: _parseAmount(json['amount']),
      expenseType: json['expense_type']?.toString(),
    );
  }

  static double? _parseAmount(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    final cleaned = raw.toString().replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned);
  }
}
