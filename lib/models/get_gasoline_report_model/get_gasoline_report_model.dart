class GetGasolineReportModel {
  int? status;
  String? success;
  ReportData? data;

  GetGasolineReportModel({this.status, this.success, this.data});

  GetGasolineReportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];

    // ✅ Handle success as String OR validation-error Map
    final successData = json['success'];
    if (successData is String) {
      success = successData;
    } else if (successData is Map) {
      success = successData.entries
          .map((e) => "${e.key}: ${(e.value as List).join(', ')}")
          .join('\n');
    } else {
      success = successData?.toString();
    }

    data = json['data'] != null
        ? ReportData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['status'] = status;
    dataMap['success'] = success;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class ReportData {
  List<MonthlySummary>? monthlySummary;
  GrandTotals? grandTotals;
  ChartData? chartData;

  ReportData({this.monthlySummary, this.grandTotals, this.chartData});

  ReportData.fromJson(Map<String, dynamic> json) {
    if (json['monthly_summary'] != null) {
      monthlySummary = <MonthlySummary>[];
      json['monthly_summary'].forEach((v) {
        monthlySummary!.add(MonthlySummary.fromJson(v));
      });
    }
    grandTotals = json['grand_totals'] != null
        ? GrandTotals.fromJson(json['grand_totals'])
        : null;
    chartData = json['chart_data'] != null
        ? ChartData.fromJson(json['chart_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (monthlySummary != null) {
      data['monthly_summary'] =
          monthlySummary!.map((v) => v.toJson()).toList();
    }
    if (grandTotals != null) {
      data['grand_totals'] = grandTotals!.toJson();
    }
    if (chartData != null) {
      data['chart_data'] = chartData!.toJson();
    }
    return data;
  }
}

class MonthlySummary {
  String? month;
  String? monthShort;
  double? beforeTaxAmount;
  double? gst;
  double? hst;
  double? pst;
  double? qst;
  double? totalAmount;
  double? totalTax;

  MonthlySummary({
    this.month,
    this.monthShort,
    this.beforeTaxAmount,
    this.gst,
    this.hst,
    this.pst,
    this.qst,
    this.totalAmount,
    this.totalTax,
  });

  MonthlySummary.fromJson(Map<String, dynamic> json) {
    month = json['month'];
    monthShort = json['month_short'];
    beforeTaxAmount = _toDouble(json['before_tax_amount']);
    gst = _toDouble(json['gst']);
    hst = _toDouble(json['hst']);
    pst = _toDouble(json['pst']);
    qst = _toDouble(json['qst']);
    totalAmount = _toDouble(json['total_amount']);
    totalTax = _toDouble(json['total_tax']);
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'month_short': monthShort,
      'before_tax_amount': beforeTaxAmount,
      'gst': gst,
      'hst': hst,
      'pst': pst,
      'qst': qst,
      'total_amount': totalAmount,
      'total_tax': totalTax,
    };
  }

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }
}

class GrandTotals {
  double? beforeTax;
  double? gstHst;
  double? pst;
  double? total;
  double? tax;

  GrandTotals({
    this.beforeTax,
    this.gstHst,
    this.pst,
    this.total,
    this.tax,
  });

  GrandTotals.fromJson(Map<String, dynamic> json) {
    beforeTax = _toDouble(json['before_tax']);
    gstHst = _toDouble(json['gst_hst']);
    pst = _toDouble(json['pst']);
    total = _toDouble(json['total']);
    tax = _toDouble(json['tax']);
  }

  Map<String, dynamic> toJson() {
    return {
      'before_tax': beforeTax,
      'gst_hst': gstHst,
      'pst': pst,
      'total': total,
      'tax': tax,
    };
  }

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }
}

class ChartData {
  List<double>? incomeData;
  List<double>? expenseData;
  List<String>? months;

  ChartData({this.incomeData, this.expenseData, this.months});

  ChartData.fromJson(Map<String, dynamic> json) {
    incomeData =
        (json['income_data'] as List).map((e) => _toDouble(e)).toList();
    expenseData =
        (json['expense_data'] as List).map((e) => _toDouble(e)).toList();
    months = (json['months'] as List).map((e) => e.toString()).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'income_data': incomeData,
      'expense_data': expenseData,
      'months': months,
    };
  }

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }
}
