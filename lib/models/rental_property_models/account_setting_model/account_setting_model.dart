class AccountSettingModel {
  int? status;
  String? success;
  RentalAddressData? data;

  AccountSettingModel({this.status, this.success, this.data});

  AccountSettingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    data = json['data'] != null ? RentalAddressData.fromJson(json['data']) : null;
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

class RentalAddressData {
  int? id;
  int? clientPlansId;
  int? clientId;
  String? address;
  String? streetPoBox;
  String? city;
  String? province;
  String? postalCode;
  String? appartmentOrSuit;
  String? yourPercentage;
  String? personalUsePercentage;
  int? numberOfUnits;
  String? typeOfProperty;
  String? otherDescribe;
  int? fairRentalDays;
  int? personalUseDays;
  String? createdAt;
  String? updatedAt;

  RentalAddressData(
      {this.id,
        this.clientPlansId,
        this.clientId,
        this.address,
        this.streetPoBox,
        this.city,
        this.province,
        this.postalCode,
        this.appartmentOrSuit,
        this.yourPercentage,
        this.personalUsePercentage,
        this.numberOfUnits,
        this.typeOfProperty,
        this.otherDescribe,
        this.fairRentalDays,
        this.personalUseDays,
        this.createdAt,
        this.updatedAt});

  RentalAddressData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientPlansId = json['client_plans_id'];
    clientId = json['client_id'];
    address = json['address'];
    streetPoBox = json['street_po_box'];
    city = json['city'];
    province = json['province'];
    postalCode = json['postal_code'];
    appartmentOrSuit = json['appartment_or_suit'];
    yourPercentage = json['your_percentage'];
    personalUsePercentage = json['personal_use_percentage'];
    numberOfUnits = json['number_of_units'];
    typeOfProperty = json['type_of_property'];
    otherDescribe = json['other_describe'];
    fairRentalDays = json['fair_rental_days'];
    personalUseDays = json['personal_use_days'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['client_plans_id'] = clientPlansId;
    data['client_id'] = clientId;
    data['address'] = address;
    data['street_po_box'] = streetPoBox;
    data['city'] = city;
    data['province'] = province;
    data['postal_code'] = postalCode;
    data['appartment_or_suit'] = appartmentOrSuit;
    data['your_percentage'] = yourPercentage;
    data['personal_use_percentage'] = personalUsePercentage;
    data['number_of_units'] = numberOfUnits;
    data['type_of_property'] = typeOfProperty;
    data['other_describe'] = otherDescribe;
    data['fair_rental_days'] = fairRentalDays;
    data['personal_use_days'] = personalUseDays;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
