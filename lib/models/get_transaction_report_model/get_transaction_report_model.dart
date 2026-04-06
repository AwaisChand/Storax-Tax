class GetTransactionReportModel {
  int? status;
  String? message;
  Data? data;

  GetTransactionReportModel({this.status, this.message, this.data});

  factory GetTransactionReportModel.fromJson(Map<String, dynamic> json) {
    return GetTransactionReportModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

/* -------------------------------------------------------------------------- */
/*                                    DATA                                    */
/* -------------------------------------------------------------------------- */

class Data {
  Summary? summary;
  KpiStats? kpiStats;
  List<Transactions>? transactions;
  Charts? charts;
  Map<String, GroupedTransactionData>? groupedTransactions;
  Client? client;
  List<dynamic>? teams;
  Filters? filters;

  Data({
    this.summary,
    this.kpiStats,
    this.transactions,
    this.charts,
    this.groupedTransactions,
    this.client,
    this.teams,
    this.filters,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    Map<String, GroupedTransactionData>? groupedTx;

    if (json['grouped_transactions'] is Map<String, dynamic>) {
      groupedTx =
          (json['grouped_transactions'] as Map<String, dynamic>).map(
                (key, value) {
              return MapEntry(
                key,
                GroupedTransactionData.fromJson(value),
              );
            },
          );
    }

    return Data(
      summary:
      json['summary'] != null ? Summary.fromJson(json['summary']) : null,
      kpiStats:
      json['kpi_stats'] != null ? KpiStats.fromJson(json['kpi_stats']) : null,
      transactions: (json['transactions'] as List?)
          ?.map((e) => Transactions.fromJson(e))
          .toList(),
      charts: json['charts'] != null ? Charts.fromJson(json['charts']) : null,
      groupedTransactions: groupedTx,
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
      teams: json['teams'] ?? [],
      filters:
      json['filters'] is Map<String, dynamic>
          ? Filters.fromJson(json['filters'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'summary': summary?.toJson(),
    'kpi_stats': kpiStats != null
        ? {
      'total_transactions': kpiStats?.totalTransactions?.toJson(),
      'total_amount': kpiStats?.totalAmount?.toJson(),
      'total_tax': kpiStats?.totalTax?.toJson(),
      'total_before_tax': kpiStats?.totalBeforeTax?.toJson(),
      'total_gst_hst': kpiStats?.totalGstHst?.toJson(),
      'total_pst': kpiStats?.totalPst?.toJson(),
    }
        : null,
    'transactions': transactions?.map((e) => e.toJson()).toList(),
    'charts': charts?.toJson(),
    'grouped_transactions': groupedTransactions?.map(
          (k, v) => MapEntry(k, v.toJson()),
    ),
    'client': client?.toJson(),
    'teams': teams,
    'filters': filters?.toJson(),
  };
}

/* -------------------------------------------------------------------------- */
/*                                  SUMMARY                                   */
/* -------------------------------------------------------------------------- */

class Summary {
  int? totalTransactions;
  double? totalAmount;
  double? totalTax;
  double? totalBeforeTax;
  double? totalGstHst;
  double? totalPst;

  Summary.fromJson(Map<String, dynamic> json) {
    totalTransactions = json['total_transactions'];
    totalAmount = (json['total_amount'] as num?)?.toDouble();
    totalTax = (json['total_tax'] as num?)?.toDouble();
    totalBeforeTax = (json['total_before_tax'] as num?)?.toDouble();
    totalGstHst = (json['total_gst_hst'] as num?)?.toDouble();
    totalPst = (json['total_pst'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() => {
    'total_transactions': totalTransactions,
    'total_amount': totalAmount,
    'total_tax': totalTax,
    'total_before_tax': totalBeforeTax,
    'total_gst_hst': totalGstHst,
    'total_pst': totalPst,
  };
}

/* -------------------------------------------------------------------------- */
/*                               Kpi Stats                                    */
/* -------------------------------------------------------------------------- */
class KpiStats {
  KpiItem? totalTransactions;
  KpiItem? totalAmount;
  KpiItem? totalTax;
  KpiItem? totalBeforeTax;
  KpiItem? totalGstHst;
  KpiItem? totalPst;

  KpiStats.fromJson(Map<String, dynamic> json) {
    totalTransactions =
        json['total_transactions'] != null
            ? KpiItem.fromJson(json['total_transactions'])
            : null;
    totalAmount =
        json['total_amount'] != null
            ? KpiItem.fromJson(json['total_amount'])
            : null;
    totalTax =
        json['total_tax'] != null ? KpiItem.fromJson(json['total_tax']) : null;
    totalBeforeTax =
        json['total_before_tax'] != null
            ? KpiItem.fromJson(json['total_before_tax'])
            : null;
    totalGstHst =
        json['total_gst_hst'] != null
            ? KpiItem.fromJson(json['total_gst_hst'])
            : null;
    totalPst =
        json['total_pst'] != null ? KpiItem.fromJson(json['total_pst']) : null;
  }
}

class KpiItem {
  double? value;
  String? formattedValue;
  double? progress;

  double? avgPerTransaction;
  String? avgPerTransactionFormatted;

  double? taxPercentage;
  String? taxPercentageFormatted;

  double? effectiveTaxRate;
  String? effectiveTaxRateFormatted;

  String? badgeValue;
  String? badgeLabel;
  String? badgeColor;

  KpiItem.fromJson(Map<String, dynamic> json) {
    value = (json['value'] as num?)?.toDouble();
    formattedValue = json['formatted_value'];
    progress = (json['progress'] as num?)?.toDouble();

    avgPerTransaction = (json['avg_per_transaction'] as num?)?.toDouble();
    avgPerTransactionFormatted = json['avg_per_transaction_formatted'];

    taxPercentage = (json['tax_percentage'] as num?)?.toDouble();
    taxPercentageFormatted = json['tax_percentage_formatted'];

    effectiveTaxRate = (json['effective_tax_rate'] as num?)?.toDouble();
    effectiveTaxRateFormatted = json['effective_tax_rate_formatted'];

    badgeValue = json['badge_value'];
    badgeLabel = json['badge_label'];
    badgeColor = json['badge_color'];
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'formatted_value': formattedValue,
    'progress': progress,
    'avg_per_transaction': avgPerTransaction,
    'avg_per_transaction_formatted': avgPerTransactionFormatted,
    'tax_percentage': taxPercentage,
    'tax_percentage_formatted': taxPercentageFormatted,
    'effective_tax_rate': effectiveTaxRate,
    'effective_tax_rate_formatted': effectiveTaxRateFormatted,
    'badge_value': badgeValue,
    'badge_label': badgeLabel,
    'badge_color': badgeColor,
  };
}

/* -------------------------------------------------------------------------- */
/*                               TRANSACTIONS                                 */
/* -------------------------------------------------------------------------- */

class Transactions {
  int? id;
  dynamic clientId;
  dynamic uploadedBy;
  String? status;
  int? userId;
  String? merchant;

  double? total;
  double? beforeTaxAmount;
  double? tax;

  // ✅ FIXED: tax fields accept int & double
  double? gst;
  double? hst;
  double? pst;
  double? qst;

  double? gstPercent;
  double? hstPercent;
  double? pstPercent;

  String? dateRecieved;
  String? reference;
  String? text;
  dynamic image;
  dynamic capturedImageBase64;
  String? date;
  String? year;
  String? createdAt;
  String? updatedAt;

  Transactions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id'];
    uploadedBy = json['uploaded_by'];
    status = json['status'];
    userId = json['user_id'];
    merchant = json['merchant'];

    total = (json['total'] as num?)?.toDouble();
    beforeTaxAmount = (json['before_tax_amount'] as num?)?.toDouble();
    tax = (json['tax'] as num?)?.toDouble();

    // ✅ SAFE parsing for int OR double
    gst = (json['gst'] as num?)?.toDouble();
    hst = (json['hst'] as num?)?.toDouble();
    pst = (json['pst'] as num?)?.toDouble();
    qst = (json['qst'] as num?)?.toDouble();

    gstPercent = (json['gst_percent'] as num?)?.toDouble();
    hstPercent = (json['hst_percent'] as num?)?.toDouble();
    pstPercent = (json['pst_percent'] as num?)?.toDouble();

    dateRecieved = json['date_recieved'];
    reference = json['reference'];
    text = json['text'];
    image = json['image'];
    capturedImageBase64 = json['captured_image_base64'];
    date = json['date'];
    year = json['year'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'client_id': clientId,
    'uploaded_by': uploadedBy,
    'status': status,
    'user_id': userId,
    'merchant': merchant,
    'total': total,
    'before_tax_amount': beforeTaxAmount,
    'tax': tax,
    'gst': gst,
    'hst': hst,
    'pst': pst,
    'qst': qst,
    'gst_percent': gstPercent,
    'hst_percent': hstPercent,
    'pst_percent': pstPercent,
    'date_recieved': dateRecieved,
    'reference': reference,
    'text': text,
    'image': image,
    'captured_image_base64': capturedImageBase64,
    'date': date,
    'year': year,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

/* -------------------------------------------------------------------------- */
/*                                   CHARTS                                   */
/* -------------------------------------------------------------------------- */

class Charts {
  List<MonthlyTrend>? monthlyTrend;
  List<MerchantDistribution>? merchantDistribution;
  TaxBreakdown? taxBreakdown;
  MonthlyInsights? monthlyInsights;
  TopMerchant? topMerchant;

  Charts.fromJson(Map<String, dynamic> json) {
    monthlyTrend =
        (json['monthly_trend'] as List?)
            ?.map((e) => MonthlyTrend.fromJson(e))
            .toList();
    merchantDistribution =
        (json['merchant_distribution'] as List?)
            ?.map((e) => MerchantDistribution.fromJson(e))
            .toList();
    taxBreakdown =
        json['tax_breakdown'] != null
            ? TaxBreakdown.fromJson(json['tax_breakdown'])
            : null;
    monthlyInsights =
        json['monthly_insights'] != null
            ? MonthlyInsights.fromJson(json['monthly_insights'])
            : null;
    topMerchant =
        json['top_merchant'] != null
            ? TopMerchant.fromJson(json['top_merchant'])
            : null;
  }

  Map<String, dynamic> toJson() => {
    'monthly_trend': monthlyTrend?.map((e) => e.toJson()).toList(),
    'merchant_distribution':
        merchantDistribution?.map((e) => e.toJson()).toList(),
    'tax_breakdown': taxBreakdown?.toJson(),
    'monthly_insights': monthlyInsights?.toJson(),
    'top_merchant': topMerchant?.toJson(),
  };
}

/* ------------------------------ Chart Models ------------------------------ */

class MonthlyTrend {
  double? total;
  double? tax;
  int? count;
  String? month;
  String? monthKey;
  String? dateKey;
  double? totalGstHst;
  double? totalPst;

  MonthlyTrend({
    this.total,
    this.tax,
    this.count,
    this.month,
    this.monthKey,
    this.dateKey,
    this.totalGstHst,
    this.totalPst,
  });

  MonthlyTrend.fromJson(Map<String, dynamic> json) {
    total = (json['total'] as num?)?.toDouble();
    tax = (json['tax'] as num?)?.toDouble();
    count = json['count'];
    month = json['month'];
    monthKey = json['month_key'];
    dateKey = json['date_key'];
    totalGstHst = (json['total_gst_hst'] as num?)?.toDouble();
    totalPst = (json['total_pst'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'tax': tax,
    'count': count,
    'month': month,
    'month_key': monthKey,
    'date_key': dateKey,
    'total_gst_hst': totalGstHst,
    'total_pst': totalPst,
  };
}

class GroupedTransactionData {
  List<Transactions>? transactions;
  Summary? summary;

  GroupedTransactionData({this.transactions, this.summary});

  factory GroupedTransactionData.fromJson(Map<String, dynamic> json) {
    return GroupedTransactionData(
      transactions: (json['transactions'] as List?)
          ?.map((e) => Transactions.fromJson(e))
          .toList(),
      summary:
      json['summary'] != null ? Summary.fromJson(json['summary']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'transactions': transactions?.map((e) => e.toJson()).toList(),
    'summary': summary?.toJson(),
  };
}


class MerchantDistribution {
  String? merchant;
  double? total;
  int? count;

  MerchantDistribution.fromJson(Map<String, dynamic> json) {
    merchant = json['merchant'];
    total = (json['total'] as num?)?.toDouble();
    count = json['count'];
  }

  Map<String, dynamic> toJson() => {
    'merchant': merchant,
    'total': total,
    'count': count,
  };
}

class TaxBreakdown {
  double? totalTax;
  double? gstHst;
  double? pst;
  double? beforeTax;

  TaxBreakdown.fromJson(Map<String, dynamic> json) {
    totalTax = (json['total_tax'] as num?)?.toDouble();
    gstHst = (json['gst_hst'] as num?)?.toDouble();
    pst = (json['pst'] as num?)?.toDouble();
    beforeTax = (json['before_tax'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() => {
    'total_tax': totalTax,
    'gst_hst': gstHst,
    'pst': pst,
    'before_tax': beforeTax,
  };
}

class MonthlyInsights {
  String? highestMonth;
  double? monthlyAverage;
  String? trend;

  MonthlyInsights.fromJson(Map<String, dynamic> json) {
    highestMonth = json['highest_month'];
    monthlyAverage = (json['monthly_average'] as num?)?.toDouble();
    trend = json['trend'];
  }

  Map<String, dynamic> toJson() => {
    'highest_month': highestMonth,
    'monthly_average': monthlyAverage,
    'trend': trend,
  };
}

class TopMerchant {
  String? name;
  int? transactionCount;

  TopMerchant.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    transactionCount = json['transaction_count'];
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'transaction_count': transactionCount,
  };
}

/* -------------------------------------------------------------------------- */
/*                                CLIENT & FILTERS                            */
/* -------------------------------------------------------------------------- */

class Client {
  int? id;
  String? name;
  String? country;

  Client.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'country': country};
}

class Filters {
  String? fromDate;
  String? toDate;
  String? sortBy;
  String? sortOrder;

  Filters.fromJson(Map<String, dynamic> json) {
    fromDate = json['from_date'];
    toDate = json['to_date'];
    sortBy = json['sort_by'];
    sortOrder = json['sort_order'];
  }

  Map<String, dynamic> toJson() => {
    'from_date': fromDate,
    'to_date': toDate,
    'sort_by': sortBy,
    'sort_order': sortOrder,
  };
}
