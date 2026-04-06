class PropertyOwnerModel {
  int? status;
  String? success;
  PropertyOwnerData? data;

  PropertyOwnerModel({this.status, this.success, this.data});

  PropertyOwnerModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    data = json['data'] != null ? PropertyOwnerData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class PropertyOwnerData {
  int? id;
  int? clientId;
  int? clientPlansId;
  String? firstName;
  String? lastName;
  String? address;
  String? streetPoBox;
  String? city;
  String? province;
  String? postalCode;
  String? appartmentOrSuit;
  String? createdAt;
  String? updatedAt;

  PropertyOwnerData(
      {this.id,
        this.clientId,
        this.clientPlansId,
        this.firstName,
        this.lastName,
        this.address,
        this.streetPoBox,
        this.city,
        this.province,
        this.postalCode,
        this.appartmentOrSuit,
        this.createdAt,
        this.updatedAt});

  PropertyOwnerData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id'];
    clientPlansId = json['client_plans_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    address = json['address'];
    streetPoBox = json['street_po_box'];
    city = json['city'];
    province = json['province'];
    postalCode = json['postal_code'];
    appartmentOrSuit = json['appartment_or_suit'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['client_id'] = clientId;
    data['client_plans_id'] = clientPlansId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['address'] = address;
    data['street_po_box'] = streetPoBox;
    data['city'] = city;
    data['province'] = province;
    data['postal_code'] = postalCode;
    data['appartment_or_suit'] = appartmentOrSuit;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
