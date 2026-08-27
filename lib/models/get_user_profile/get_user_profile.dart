import 'dart:convert';

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
      status: _parseInt(json['status']),
      data: json['data'] != null ? Data.fromJson(json['data']) : Data(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'data': data.toJson(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
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
  List<String> teamFor; // Added: handles stringified JSON array
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
    this.teamFor = const [],
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
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      firstName: json['first_name']?.toString() ?? "",
      lastName: json['last_name']?.toString() ?? "",
      username: json['username']?.toString() ?? "",
      email: json['email']?.toString() ?? "",
      province: json['province']?.toString() ?? "",
      noOfClients: _parseInt(json['no_of_clients']),
      phone: json['phone']?.toString() ?? "",
      avatar: json['avatar']?.toString() ?? "",
      role: json['role']?.toString() ?? "",
      teamFor: _parseStringList(json['team_for']),
      status: json['status']?.toString() ?? "",
      city: json['city']?.toString() ?? "",
      country: json['country']?.toString() ?? "",
      createdAt: json['created_at']?.toString() ?? "",
      updatedAt: json['updated_at']?.toString() ?? "",
      planId: _parseInt(json['plan_id']),
      businessName: json['business_name']?.toString() ?? "",
      tutorialCompleted: _parseInt(json['tutorial_completed']),
      twoFactorCode: json['two_factor_code']?.toString() ?? "",
      twoFactorExpiresAt: json['two_factor_expires_at']?.toString() ?? "",
      payment: json['payment']?.toString() ?? "",
      regCountry: json['reg_country']?.toString() ?? "",
      subscriptionId: json['subscription_id']?.toString() ?? "",

      // Taxes
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
      'team_for': jsonEncode(teamFor),
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

  // Safe integer parser
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  // Safe double parser
  static double? _parseDouble(dynamic value) {
    if (value == null || value == "" || value == "N/A") return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  // Safe decoder for stringified arrays like "[\"Business Tax Manager\"]"
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return List<String>.from(value.map((e) => e.toString()));
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return List<String>.from(decoded.map((e) => e.toString()));
        }
      } catch (_) {
        return [];
      }
    }
    return [];
  }
}