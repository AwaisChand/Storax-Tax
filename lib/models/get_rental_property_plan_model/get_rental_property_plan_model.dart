class GetRentalPropertyPlanModel {
  int? status;
  String? success;
  List<Data>? data;

  GetRentalPropertyPlanModel({this.status, this.success, this.data});

  GetRentalPropertyPlanModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  int? id;
  String? displayName;
  String? nameEn;
  String? nameFr;

  Data({this.id, this.displayName, this.nameEn, this.nameFr});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayName = json['display_name'].toString();
    nameEn = json['name_en'];
    nameFr = json['name_fr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['display_name'] = displayName;
    data['name_en'] = nameEn;
    data['name_fr'] = nameFr;
    return data;
  }
}
