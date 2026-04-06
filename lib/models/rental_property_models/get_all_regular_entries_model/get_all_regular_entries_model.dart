class GetAllRegularEntriesModel {
  int? status;
  String? success;
  List<AllRegularEntriesData>? data;

  GetAllRegularEntriesModel({this.status, this.success, this.data});

  GetAllRegularEntriesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];

    // ✅ Handle success as string or map
    dynamic successData = json['success'];
    if (successData is String) {
      success = successData;
    } else if (successData is Map) {
      // Convert map into human-readable string
      success = successData.entries
          .map((e) => "${e.key}: ${e.value.join(', ')}")
          .join('\n');
    } else {
      success = successData?.toString();
    }

    // Parse data normally
    if (json['data'] != null) {
      data = <AllRegularEntriesData>[];
      json['data'].forEach((v) {
        data!.add(AllRegularEntriesData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['status'] = status;
    dataMap['success'] = success;
    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    return dataMap;
  }
}

class AllRegularEntriesData {
  int? id;
  int? clientPlansId;
  int? userId;
  String? date;
  String? month;
  String? type;
  String? expenseType;
  String? otherExpenseName;
  int? incomeTypeId;
  String? amount;
  String? proof;
  String? onlyForRental;
  String? createdAt;
  String? updatedAt;
  String? incomeTypeName;
  String? expenseTypeFr;

  AllRegularEntriesData(
      {this.id,
        this.clientPlansId,
        this.userId,
        this.date,
        this.month,
        this.type,
        this.expenseType,
        this.otherExpenseName,
        this.incomeTypeId,
        this.amount,
        this.proof,
        this.onlyForRental,
        this.createdAt,
        this.updatedAt,
        this.incomeTypeName,
        this.expenseTypeFr
      });

  AllRegularEntriesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientPlansId = json['client_plans_id'];
    userId = json['user_id'];
    date = json['date'];
    month = json['month'];
    type = json['type'];
    expenseType = json['expense_type'];
    otherExpenseName = json['other_expense_name'];
    incomeTypeId = json['income_type_id'];
    amount = json['amount'];
    proof = json['proof'];
    onlyForRental = json['only_for_rental'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    incomeTypeName = json['income_type_name'];
    expenseTypeFr = json['expense_type_fr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['client_plans_id'] = clientPlansId;
    data['user_id'] = userId;
    data['date'] = date;
    data['month'] = month;
    data['type'] = type;
    data['expense_type'] = expenseType;
    data['other_expense_name'] = otherExpenseName;
    data['income_type_id'] = incomeTypeId;
    data['amount'] = amount;
    data['proof'] = proof;
    data['only_for_rental'] = onlyForRental;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['income_type_name'] = incomeTypeName;
    data['expense_type_fr'] = expenseTypeFr;
    return data;
  }
}
