class GetUserProfileModel {
  String message;
  int status;
  Data data;

  GetUserProfileModel({
    this.message = "",
    this.status = 0,
    required this.data,
  });

  factory GetUserProfileModel.fromJson(Map<String, dynamic> json) {
    return GetUserProfileModel(
      message: json['message']?.toString() ?? "",
      status: json['status'] ?? 0,
      data: json['data'] != null
          ? Data.fromJson(json['data'])
          : Data(), // fallback empty data
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'data': data.toJson(),
    };
  }
}

class Data {
  int id;
  int userId;
  String firstName;
  String lastName;
  String username;
  String email;
  String province;
  int noOfClients;
  String phone;
  String avatar;
  String role;
  String status;
  String city;
  String country;
  String createdAt;
  String updatedAt;
  int planId;
  String businessName;
  int tutorialCompleted;
  String twoFactorCode;
  String twoFactorExpiresAt;
  String payment;
  String regCountry;
  String subscriptionId;

  double? gst;
  double? hst;
  double? pst;

  Data({
    this.id = 0,
    this.userId = 0,
    this.firstName = "",
    this.lastName = "",
    this.username = "",
    this.email = "",
    this.province = "",
    this.noOfClients = 0,
    this.phone = "",
    this.avatar = "",
    this.role = "",
    this.status = "",
    this.city = "",
    this.country = "",
    this.createdAt = "",
    this.updatedAt = "",
    this.planId = 0,
    this.businessName = "",
    this.tutorialCompleted = 0,
    this.twoFactorCode = "",
    this.twoFactorExpiresAt = "",
    this.payment = "",
    this.regCountry = "",
    this.subscriptionId = "",
    this.gst,
    this.hst,
    this.pst,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      firstName: json['first_name']?.toString() ?? "",
      lastName: json['last_name']?.toString() ?? "",
      username: json['username']?.toString() ?? "",
      email: json['email']?.toString() ?? "",
      province: json['province']?.toString() ?? "",
      noOfClients: json['no_of_clients'] ?? 0,
      phone: json['phone']?.toString() ?? "",
      avatar: json['avatar']?.toString() ?? "",
      role: json['role']?.toString() ?? "",
      status: json['status']?.toString() ?? "",
      city: json['city']?.toString() ?? "",
      country: json['country']?.toString() ?? "",
      createdAt: json['created_at']?.toString() ?? "",
      updatedAt: json['updated_at']?.toString() ?? "",
      planId: json['plan_id'] ?? 0,
      businessName: json['business_name']?.toString() ?? "",
      tutorialCompleted: json['tutorial_completed'] ?? 0,
      twoFactorCode: json['two_factor_code']?.toString() ?? "",
      twoFactorExpiresAt: json['two_factor_expires_at']?.toString() ?? "",
      payment: json['payment']?.toString() ?? "",
      regCountry: json['reg_country']?.toString() ?? "",
      subscriptionId: json['subscription_id']?.toString() ?? "",

      // Handle GST / HST / PST safely
      gst: _parseDouble(json['gst']),
      hst: _parseDouble(json['hst']),
      pst: _parseDouble(json['pst']),
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
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'status': status,
      'city': city,
      'country': country,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'plan_id': planId,
      'business_name': businessName,
      'tutorial_completed': tutorialCompleted,
      'two_factor_code': twoFactorCode,
      'two_factor_expires_at': twoFactorExpiresAt,
      'payment': payment,
      'reg_country': regCountry,
      'subscription_id': subscriptionId,
      'gst': gst,
      'hst': hst,
      'pst': pst,
    };
  }

  /// Safely convert any value to double? (supports null, "N/A", "", int, double)
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value == "" || value == "N/A") return null;
    return double.tryParse(value.toString());
  }
}
