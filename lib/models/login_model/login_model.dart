class LoginModel {
  final int status;
  final String success;
  final String accessToken;
  final String tokenType;
  final User user;

  LoginModel({
    this.status = 0,
    this.success = "",
    this.accessToken = "",
    this.tokenType = "",
    User? user,
  }) : user = user ?? User();

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json['status'] ?? 0,
      success: json['success']?.toString() ?? "",
      accessToken: json['access_token']?.toString() ?? "",
      tokenType: json['token_type']?.toString() ?? "",
      user: json['user'] != null ? User.fromJson(json['user']) : User(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'success': success,
      'access_token': accessToken,
      'token_type': tokenType,
      'user': user.toJson(),
    };
  }
}

class User {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String province;
  final int noOfClients;
  final String emailVerifiedAt;
  final String phone;
  final String avatar;
  final String role;
  final String status;
  final String city;
  final String country;
  final String createdAt;
  final String updatedAt;
  final String detachedAt;
  final int planId;
  final String paypalSubscriptionId;
  final String stripeId;
  final String pmType;
  final String pmLastFour;
  final String deletedAt;
  final String businessName;
  final int tutorialCompleted;
  final String twoFactorCode;
  final String twoFactorExpiresAt;
  final String payment;
  final String regCountry;
  final String couponId;
  final String createdBy;
  final String subscriptionId;
  final int gst;
  final String pst;
  final String plan;

  User({
    this.id = 0,
    this.userId = 0,
    this.firstName = "",
    this.lastName = "",
    this.username = "",
    this.email = "",
    this.province = "",
    this.noOfClients = 0,
    this.emailVerifiedAt = "",
    this.phone = "",
    this.avatar = "",
    this.role = "",
    this.status = "",
    this.city = "",
    this.country = "",
    this.createdAt = "",
    this.updatedAt = "",
    this.detachedAt = "",
    this.planId = 0,
    this.paypalSubscriptionId = "",
    this.stripeId = "",
    this.pmType = "",
    this.pmLastFour = "",
    this.deletedAt = "",
    this.businessName = "",
    this.tutorialCompleted = 0,
    this.twoFactorCode = "",
    this.twoFactorExpiresAt = "",
    this.payment = "",
    this.regCountry = "",
    this.couponId = "",
    this.createdBy = "",
    this.subscriptionId = "",
    this.gst = 0,
    this.pst = "",
    this.plan = "",
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      firstName: json['first_name']?.toString() ?? "",
      lastName: json['last_name']?.toString() ?? "",
      username: json['username']?.toString() ?? "",
      email: json['email']?.toString() ?? "",
      province: json['province']?.toString() ?? "",
      noOfClients: json['no_of_clients'] ?? 0,
      emailVerifiedAt: json['email_verified_at']?.toString() ?? "",
      phone: json['phone']?.toString() ?? "",
      avatar: json['avatar']?.toString() ?? "",
      role: json['role']?.toString() ?? "",
      status: json['status']?.toString() ?? "",
      city: json['city']?.toString() ?? "",
      country: json['country']?.toString() ?? "",
      createdAt: json['created_at']?.toString() ?? "",
      updatedAt: json['updated_at']?.toString() ?? "",
      detachedAt: json['detached_at']?.toString() ?? "",
      planId: json['plan_id'] ?? 0,
      paypalSubscriptionId: json['paypal_subscription_id']?.toString() ?? "",
      stripeId: json['stripe_id']?.toString() ?? "",
      pmType: json['pm_type']?.toString() ?? "",
      pmLastFour: json['pm_last_four']?.toString() ?? "",
      deletedAt: json['deleted_at']?.toString() ?? "",
      businessName: json['business_name']?.toString() ?? "",
      tutorialCompleted: json['tutorial_completed'] ?? 0,
      twoFactorCode: json['two_factor_code']?.toString() ?? "",
      twoFactorExpiresAt: json['two_factor_expires_at']?.toString() ?? "",
      payment: json['payment']?.toString() ?? "",
      regCountry: json['reg_country']?.toString() ?? "",
      couponId: json['coupon_id']?.toString() ?? "",
      createdBy: json['created_by']?.toString() ?? "",
      subscriptionId: json['subscription_id']?.toString() ?? "",
      gst: json['gst'] ?? 0,
      pst: json['pst']?.toString() ?? "",
      plan: json['plan']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'province': province,
      'no_of_clients': noOfClients,
      'email_verified_at': emailVerifiedAt,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'status': status,
      'city': city,
      'country': country,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'detached_at': detachedAt,
      'plan_id': planId,
      'paypal_subscription_id': paypalSubscriptionId,
      'stripe_id': stripeId,
      'pm_type': pmType,
      'pm_last_four': pmLastFour,
      'deleted_at': deletedAt,
      'business_name': businessName,
      'tutorial_completed': tutorialCompleted,
      'two_factor_code': twoFactorCode,
      'two_factor_expires_at': twoFactorExpiresAt,
      'payment': payment,
      'reg_country': regCountry,
      'coupon_id': couponId,
      'created_by': createdBy,
      'subscription_id': subscriptionId,
      'gst': gst,
      'pst': pst,
      'plan': plan,
    };
  }
}
