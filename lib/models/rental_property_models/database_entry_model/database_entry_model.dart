class DatabaseEntriesModel {
  int? status;
  String? success;
  DatabaseEntriesData? data;

  DatabaseEntriesModel({this.status, this.success, this.data});

  DatabaseEntriesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];

    // ✅ Handle success as String or validation-error Map
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
        ? DatabaseEntriesData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['status'] = status;
    dataMap['success'] = success;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}


class DatabaseEntriesData {
  List<AmountByMonth>? amountByMonth;
  double? monthsGrandTotal;
  List<IncomeByType>? incomeByType;
  double? incomeGrandTotal;
  List<ExpenseByCategory>? expenseByCategory;
  double? expenseGrandTotal;
  String? year;
  String? clientCountry;

  DatabaseEntriesData({
    this.amountByMonth,
    this.monthsGrandTotal,
    this.incomeByType,
    this.incomeGrandTotal,
    this.expenseByCategory,
    this.expenseGrandTotal,
    this.year,
    this.clientCountry,
  });

  DatabaseEntriesData.fromJson(Map<String, dynamic> json) {
    if (json['amount_by_month'] != null) {
      amountByMonth = <AmountByMonth>[];
      json['amount_by_month'].forEach((v) {
        amountByMonth!.add(AmountByMonth.fromJson(v));
      });
    }
    monthsGrandTotal = (json['months_grand_total'] ?? 0).toDouble();

    if (json['income_by_type'] != null) {
      incomeByType = <IncomeByType>[];
      json['income_by_type'].forEach((v) {
        incomeByType!.add(IncomeByType.fromJson(v));
      });
    }

    incomeGrandTotal = _parseToDouble(json['income_grand_total']);

    if (json['expense_by_category'] != null) {
      expenseByCategory = <ExpenseByCategory>[];
      json['expense_by_category'].forEach((v) {
        expenseByCategory!.add(ExpenseByCategory.fromJson(v));
      });
    }

    expenseGrandTotal = (json['expense_grand_total'] ?? 0).toDouble();
    year = json['year']?.toString();
    clientCountry = json['client_country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (amountByMonth != null) {
      data['amount_by_month'] = amountByMonth!.map((v) => v.toJson()).toList();
    }
    data['months_grand_total'] = monthsGrandTotal;
    if (incomeByType != null) {
      data['income_by_type'] = incomeByType!.map((v) => v.toJson()).toList();
    }
    data['income_grand_total'] = incomeGrandTotal;
    if (expenseByCategory != null) {
      data['expense_by_category'] =
          expenseByCategory!.map((v) => v.toJson()).toList();
    }
    data['expense_grand_total'] = expenseGrandTotal;
    data['year'] = year;
    data['client_country'] = clientCountry;
    return data;
  }
}

class AmountByMonth {
  String? month;
  double? income;
  double? expense;
  double? total;

  AmountByMonth({this.month, this.income, this.expense, this.total});

  AmountByMonth.fromJson(Map<String, dynamic> json) {
    month = json['month'];
    income = _parseToDouble(json['income']);
    expense = _parseToDouble(json['expense']);
    total = _parseToDouble(json['total']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['month'] = month;
    data['income'] = income;
    data['expense'] = expense;
    data['total'] = total;
    return data;
  }
}

class IncomeByType {
  String? incomeType;
  double? amount;

  IncomeByType({this.incomeType, this.amount});

  IncomeByType.fromJson(Map<String, dynamic> json) {
    incomeType = json['income_type'];

    final amt = json['amount'];
    if (amt is String) {
      amount = double.tryParse(amt) ?? 0.0;
    } else if (amt is num) {
      amount = amt.toDouble();
    } else {
      amount = 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['income_type'] = incomeType;
    data['amount'] = amount;
    return data;
  }
}

class ExpenseByCategory {
  String? expenseCategory;
  double? amount;

  ExpenseByCategory({this.expenseCategory, this.amount});

  ExpenseByCategory.fromJson(Map<String, dynamic> json) {
    expenseCategory = json['expense_category'];

    final amt = json['amount'];
    if (amt is String) {
      amount = double.tryParse(amt) ?? 0.0;
    } else if (amt is num) {
      amount = amt.toDouble();
    } else {
      amount = 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['expense_category'] = expenseCategory;
    data['amount'] = amount;
    return data;
  }
}

double _parseToDouble(dynamic value) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
