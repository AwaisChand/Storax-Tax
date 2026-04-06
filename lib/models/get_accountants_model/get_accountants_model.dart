class GetAccountantsModel {
  int? status;
  AccountantPageData? data;
  String? success;

  GetAccountantsModel({this.status, this.data, this.success});

  GetAccountantsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? AccountantPageData.fromJson(json['data']) : null;
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['success'] = success;
    return data;
  }
}

class AccountantPageData {
  int? currentPage;
  List<AccountantData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  AccountantPageData(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.links,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total});

  AccountantPageData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <AccountantData>[];
      json['data'].forEach((v) {
        data!.add(AccountantData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class AccountantData {
  int? id;
  Null userId;
  String? firstName;
  String? lastName;
  Null username;
  String? email;
  Null province;
  int? noOfClients;
  Null emailVerifiedAt;
  String? phone;
  String? avatar;
  String? role;
  String? status;
  String? city;
  String? country;
  String? createdAt;
  String? updatedAt;
  Null detachedAt;
  int? planId;
  Null paypalSubscriptionId;
  Null stripeId;
  Null pmType;
  Null pmLastFour;
  Null deletedAt;
  String? businessName;
  int? tutorialCompleted;
  String? twoFactorCode;
  String? twoFactorExpiresAt;
  String? payment;
  String? regCountry;
  Null couponId;
  int? createdBy;
  String? subscriptionId;
  bool? isConnected;

  AccountantData(
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
        this.isConnected});

  AccountantData.fromJson(Map<String, dynamic> json) {
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
    isConnected = json['isConnected'];
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
    data['isConnected'] = isConnected;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
    return data;
  }
}
