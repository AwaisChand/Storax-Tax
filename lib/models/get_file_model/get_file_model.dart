class GetFileModel {
  int? status;
  String? success;
  List<FileData>? data;

  GetFileModel({this.status, this.success, this.data});

  GetFileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    if (json['data'] != null) {
      data = <FileData>[];
      json['data'].forEach((v) {
        data!.add(FileData.fromJson(v));
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

class FileData {
  int? id;
  int? clientId;
  String? uploadedBy;
  String? fileName;
  String? category;
  String? comments;
  String? date;
  String? year;
  String? status;
  String? createdAt;
  String? updatedAt;
  List<Uploads>? uploads;
  Uploadedby? uploadedby;

  FileData({
    this.id,
    this.clientId,
    this.uploadedBy,
    this.fileName,
    this.category,
    this.comments,
    this.date,
    this.year,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.uploads,
    this.uploadedby,
  });

  FileData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id'];
    uploadedBy = json['uploaded_by'];
    fileName = json['file_name'];
    category = json['category'];
    comments = json['comments'];
    date = json['date'];
    year = json['year'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['uploads'] != null) {
      uploads = <Uploads>[];
      json['uploads'].forEach((v) {
        uploads!.add(Uploads.fromJson(v));
      });
    }
    uploadedby =
        json['uploadedby'] != null
            ? Uploadedby.fromJson(json['uploadedby'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['client_id'] = clientId;
    data['uploaded_by'] = uploadedBy;
    data['file_name'] = fileName;
    data['category'] = category;
    data['comments'] = comments;
    data['date'] = date;
    data['year'] = year;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (uploads != null) {
      data['uploads'] = uploads!.map((v) => v.toJson()).toList();
    }
    if (uploadedby != null) {
      data['uploadedby'] = uploadedby!.toJson();
    }
    return data;
  }
}

class Uploads {
  int? id;
  int? fileId;
  String? filePath;
  String? createdAt;
  String? updatedAt;

  Uploads({
    this.id,
    this.fileId,
    this.filePath,
    this.createdAt,
    this.updatedAt,
  });

  Uploads.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fileId = json['file_id'];
    filePath = json['file_path'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['file_id'] = fileId;
    data['file_path'] = filePath;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Uploadedby {
  int? id;
  String? userId;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  String? province;
  int? noOfClients;
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
  String? detachedAt;
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

  Uploadedby({
    this.id,
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
    this.subscriptionId,
  });

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
