class GetPreviousInfoModel {
  int? status;
  String? success;
  Data? data;

  GetPreviousInfoModel({this.status, this.success, this.data});

  GetPreviousInfoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  int? id;
  int? userId;
  String? year;
  bool? noChange;
  String? firstName;
  String? lastName;
  String? homeAddress;
  String? workPhone;
  String? email;
  bool? canadianCitizen;
  String? homePhone;
  String? fax;
  String? languageOfCorrespondence;
  int? ownForeignProperty;
  String? provinceOfResidence;
  String? maritalStatus;
  bool? maritalStatusChanged;
  String? maritalChangeDate;
  String? maritalChangeDetails;
  bool? noSpouse;
  String? spouseName;
  int? ramqMonths;
  int? privateInsuranceMonths;
  bool? rl19;
  String? rl19Amount;
  int? solidaritySpecimen;
  bool? realEstateDisposition;
  bool? principalResidenceDisposition;
  bool? firstTaxReturn;
  List<Dependents>? dependents;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.userId,
        this.year,
        this.noChange,
        this.firstName,
        this.lastName,
        this.homeAddress,
        this.workPhone,
        this.email,
        this.canadianCitizen,
        this.homePhone,
        this.fax,
        this.languageOfCorrespondence,
        this.ownForeignProperty,
        this.provinceOfResidence,
        this.maritalStatus,
        this.maritalStatusChanged,
        this.maritalChangeDate,
        this.maritalChangeDetails,
        this.noSpouse,
        this.spouseName,
        this.ramqMonths,
        this.privateInsuranceMonths,
        this.rl19,
        this.rl19Amount,
        this.solidaritySpecimen,
        this.realEstateDisposition,
        this.principalResidenceDisposition,
        this.firstTaxReturn,
        this.dependents,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    year = json['year'];
    noChange = json['no_change'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    homeAddress = json['home_address'];
    workPhone = json['work_phone'];
    email = json['email'];
    canadianCitizen = json['canadian_citizen'];
    homePhone = json['home_phone'];
    fax = json['fax'];
    languageOfCorrespondence = json['language_of_correspondence'];
    ownForeignProperty = json['own_foreign_property'];
    provinceOfResidence = json['province_of_residence'];
    maritalStatus = json['marital_status'];
    maritalStatusChanged = json['marital_status_changed'];
    maritalChangeDate = json['marital_change_date'];
    maritalChangeDetails = json['marital_change_details'];
    noSpouse = json['no_spouse'];
    spouseName = json['spouse_name'];
    ramqMonths = json['ramq_months'];
    privateInsuranceMonths = json['private_insurance_months'];
    rl19 = json['rl19'];
    rl19Amount = json['rl19_amount'];
    solidaritySpecimen = json['solidarity_specimen'];
    realEstateDisposition = json['real_estate_disposition'];
    principalResidenceDisposition = json['principal_residence_disposition'];
    firstTaxReturn = json['first_tax_return'];
    if (json['dependents'] != null) {
      dependents = <Dependents>[];
      json['dependents'].forEach((v) {
        dependents!.add(Dependents.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['year'] = year;
    data['no_change'] = noChange;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['home_address'] = homeAddress;
    data['work_phone'] = workPhone;
    data['email'] = email;
    data['canadian_citizen'] = canadianCitizen;
    data['home_phone'] = homePhone;
    data['fax'] = fax;
    data['language_of_correspondence'] = languageOfCorrespondence;
    data['own_foreign_property'] = ownForeignProperty;
    data['province_of_residence'] = provinceOfResidence;
    data['marital_status'] = maritalStatus;
    data['marital_status_changed'] = maritalStatusChanged;
    data['marital_change_date'] = maritalChangeDate;
    data['marital_change_details'] = maritalChangeDetails;
    data['no_spouse'] = noSpouse;
    data['spouse_name'] = spouseName;
    data['ramq_months'] = ramqMonths;
    data['private_insurance_months'] = privateInsuranceMonths;
    data['rl19'] = rl19;
    data['rl19_amount'] = rl19Amount;
    data['solidarity_specimen'] = solidaritySpecimen;
    data['real_estate_disposition'] = realEstateDisposition;
    data['principal_residence_disposition'] =
        principalResidenceDisposition;
    data['first_tax_return'] = firstTaxReturn;
    if (dependents != null) {
      data['dependents'] = dependents!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Dependents {
  String? name;
  int? disability;       // 0 or 1
  String? dob;
  String? citizenship;
  int? months;           // numeric
  double? income;        // numeric

  Dependents({
    this.name,
    this.disability,
    this.dob,
    this.citizenship,
    this.months,
    this.income,
  });

  Dependents.fromJson(Map<String, dynamic> json) {
    name = json['name'];

    // disability: int or string
    final disabilityValue = json['disability'];
    disability = disabilityValue is int
        ? disabilityValue
        : int.tryParse(disabilityValue?.toString() ?? '');

    dob = json['dob'];
    citizenship = json['citizenship'];

    // months: int or string
    final monthsValue = json['months'];
    months = monthsValue is int
        ? monthsValue
        : int.tryParse(monthsValue?.toString() ?? '');

    // income: double / int / string
    final incomeValue = json['income'];
    if (incomeValue is num) {
      income = incomeValue.toDouble();
    } else {
      income = double.tryParse(incomeValue?.toString() ?? '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'disability': disability ?? 0,
      'dob': dob,
      'citizenship': citizenship,
      'months': months ?? 0,
      'income': income ?? 0.0,
    };
  }
}
