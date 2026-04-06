class GetIncomeTypesModel {
  int? status;
  String? success;
  List<IncomeTypesData>? data;

  GetIncomeTypesModel({this.status, this.success, this.data});

  GetIncomeTypesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    if (json['data'] != null) {
      data = <IncomeTypesData>[];
      json['data'].forEach((v) {
        data!.add(IncomeTypesData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class IncomeTypesData {
  int? id;
  int? clientPlansId;
  int? userId;
  String? name;
  String? createdAt;
  String? updatedAt;
  List<Information>? information;

  IncomeTypesData(
      {this.id,
        this.clientPlansId,
        this.userId,
        this.name,
        this.createdAt,
        this.updatedAt,
        this.information});

  IncomeTypesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientPlansId = json['client_plans_id'];
    userId = json['user_id'];
    name = json['name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['information'] != null) {
      information = <Information>[];
      json['information'].forEach((v) {
        information!.add(Information.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['client_plans_id'] = clientPlansId;
    data['user_id'] = userId;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (information != null) {
      data['information'] = information!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Information {
  int? incomeTypeId;
  String? email;
  String? firstName;
  String? lastName;
  int? isPrimary;
  String? createdAt;
  String? updatedAt;

  Information(
      {this.incomeTypeId,
        this.email,
        this.firstName,
        this.lastName,
        this.isPrimary,
        this.createdAt,
        this.updatedAt});

  Information.fromJson(Map<String, dynamic> json) {
    incomeTypeId = json['income_type_id'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    isPrimary = json['is_primary'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['income_type_id'] = incomeTypeId;
    data['email'] = email;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['is_primary'] = isPrimary;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class IncomeTypeOption {
  final int id;
  final String name;
  final dynamic rawEntry;

  IncomeTypeOption({
    required this.id,
    required this.name,
    this.rawEntry,
  });
}



