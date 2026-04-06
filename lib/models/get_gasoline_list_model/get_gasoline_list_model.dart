class GetGasolineListModel {
  int? status;
  String? success;
  List<Data>? data;

  GetGasolineListModel({this.status, this.success, this.data});

  GetGasolineListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];

    // ✅ Handle success as string OR validation-error map
    dynamic successData = json['success'];
    if (successData is String) {
      success = successData;
    } else if (successData is Map) {
      success = successData.entries
          .map((e) => "${e.key}: ${(e.value as List).join(', ')}")
          .join('\n');
    } else {
      success = successData?.toString();
    }

    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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


class Data {
  int? id;
  int? clientId;
  String? uploadedBy;
  String? status;
  int? userId;
  String? merchant;
  num? total;
  num? beforeTaxAmount;
  num? tax;
  num? gst;
  num? hst;
  num? pst;
  num? qst;
  num? gstPercent;
  num? hstPercent;
  num? pstPercent;

  String? dateRecieved;
  String? reference;
  String? text;
  String? image;
  Null capturedImageBase64;
  String? date;
  String? year;
  String? createdAt;
  String? updatedAt;
  Uploadedby? uploadedby;

  Data(
      {this.id,
        this.clientId,
        this.uploadedBy,
        this.status,
        this.userId,
        this.merchant,
        this.total,
        this.beforeTaxAmount,
        this.tax,
        this.gst,
        this.hst,
        this.pst,
        this.qst,
        this.gstPercent,
        this.hstPercent,
        this.pstPercent,
        this.dateRecieved,
        this.reference,
        this.text,
        this.image,
        this.capturedImageBase64,
        this.date,
        this.year,
        this.createdAt,
        this.updatedAt,
        this.uploadedby});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id'];
    uploadedBy = json['uploaded_by'];
    status = json['status'];
    userId = json['user_id'];
    merchant = json['merchant'];
    total = _toNum(json['total']);
    beforeTaxAmount = _toNum(json['before_tax_amount']);
    tax = _toNum(json['tax']);
    gst = _toNum(json['gst']);
    hst = _toNum(json['hst']);
    pst = _toNum(json['pst']);
    qst = _toNum(json['qst']);
    gstPercent = _toNum(json['gst_percent']);
    hstPercent = _toNum(json['hst_percent']);
    pstPercent = _toNum(json['pst_percent']);
    dateRecieved = json['date_recieved'];
    reference = json['reference'];
    text = json['text'];
    image = json['image'];
    capturedImageBase64 = json['captured_image_base64'];
    date = json['date'];
    year = json['year'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    uploadedby = json['uploadedby'] != null
        ? Uploadedby.fromJson(json['uploadedby'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['client_id'] = clientId;
    data['uploaded_by'] = uploadedBy;
    data['status'] = status;
    data['user_id'] = userId;
    data['merchant'] = merchant;
    data['total'] = total;
    data['before_tax_amount'] = beforeTaxAmount;
    data['tax'] = tax;
    data['gst'] = gst;
    data['hst'] = hst;
    data['pst'] = pst;
    data['qst'] = qst;
    data['gst_percent'] = gstPercent;
    data['hst_percent'] = hstPercent;
    data['pst_percent'] = pstPercent;
    data['date_recieved'] = dateRecieved;
    data['reference'] = reference;
    data['text'] = text;
    data['image'] = image;
    data['captured_image_base64'] = capturedImageBase64;
    data['date'] = date;
    data['year'] = year;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (uploadedby != null) {
      data['uploadedby'] = uploadedby!.toJson();
    }
    return data;
  }
}

class Uploadedby {
  int? id;
  Null userId;
  String? firstName;
  String? lastName;
  Null username;
  String? email;
  String? province;
  String? noOfClients;
  String? emailVerifiedAt;
  String? phone;
  String? avatar;
  String? role;
  dynamic teamFor;
  String? status;
  String? city;
  String? country;
  String? createdAt;
  String? updatedAt;
  Null detachedAt;
  int? planId;
  String? paypalSubscriptionId;
  String? stripeId;
  String? pmType;
  String? pmLastFour;
  String? deletedAt;
  String? businessName;
  int? tutorialCompleted;
  String? twoFactorCode;
  String? twoFactorExpiresAt;
  String? payment;
  String? regCountry;
  int? couponId;
  int? createdBy;
  String? subscriptionId;

  Uploadedby(
      {this.id,
        this.userId,
        this.firstName,
        this.lastName,
        this.username,
        this.email,
        this.province,
        this.noOfClients,
        this.emailVerifiedAt,
        this.phone,
        this.avatar,
        this.role,
        this.teamFor,
        this.status,
        this.city,
        this.country,
        this.createdAt,
        this.updatedAt,
        this.detachedAt,
        this.planId,
        this.paypalSubscriptionId,
        this.stripeId,
        this.pmType,
        this.pmLastFour,
        this.deletedAt,
        this.businessName,
        this.tutorialCompleted,
        this.twoFactorCode,
        this.twoFactorExpiresAt,
        this.payment,
        this.regCountry,
        this.couponId,
        this.createdBy,
        this.subscriptionId});

  Uploadedby.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    username = json['username'];
    email = json['email'];
    province = json['province'];
    noOfClients = json['no_of_clients'];
    emailVerifiedAt = json['email_verified_at'];
    phone = json['phone'];
    avatar = json['avatar'];
    role = json['role'];
    teamFor = json['team_for'];
    status = json['status'];
    city = json['city'];
    country = json['country'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    detachedAt = json['detached_at'];
    planId = json['plan_id'];
    paypalSubscriptionId = json['paypal_subscription_id'];
    stripeId = json['stripe_id'];
    pmType = json['pm_type'];
    pmLastFour = json['pm_last_four'];
    deletedAt = json['deleted_at'];
    businessName = json['business_name'];
    tutorialCompleted = json['tutorial_completed'];
    twoFactorCode = json['two_factor_code'];
    twoFactorExpiresAt = json['two_factor_expires_at'];
    payment = json['payment'];
    regCountry = json['reg_country'];
    couponId = json['coupon_id'];
    createdBy = json['created_by'];
    subscriptionId = json['subscription_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['username'] = username;
    data['email'] = email;
    data['province'] = province;
    data['no_of_clients'] = noOfClients;
    data['email_verified_at'] = emailVerifiedAt;
    data['phone'] = phone;
    data['avatar'] = avatar;
    data['role'] = role;
    data['team_for'] = teamFor;
    data['status'] = status;
    data['city'] = city;
    data['country'] = country;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['detached_at'] = detachedAt;
    data['plan_id'] = planId;
    data['paypal_subscription_id'] = paypalSubscriptionId;
    data['stripe_id'] = stripeId;
    data['pm_type'] = pmType;
    data['pm_last_four'] = pmLastFour;
    data['deleted_at'] = deletedAt;
    data['business_name'] = businessName;
    data['tutorial_completed'] = tutorialCompleted;
    data['two_factor_code'] = twoFactorCode;
    data['two_factor_expires_at'] = twoFactorExpiresAt;
    data['payment'] = payment;
    data['reg_country'] = regCountry;
    data['coupon_id'] = couponId;
    data['created_by'] = createdBy;
    data['subscription_id'] = subscriptionId;
    return data;
  }
}

num? _toNum(dynamic value) {
  if (value == null) return null;

  if (value is int || value is double) return value;

  if (value is String) {
    return num.tryParse(value);
  }

  return null;
}
