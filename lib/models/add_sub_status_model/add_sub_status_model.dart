class AppleSubscriptionStatusModel {
  final int? status;
  final bool? success;
  final SubscriptionData? data;
  final String? message;

  AppleSubscriptionStatusModel({
    this.status,
    this.success,
    this.data,
    this.message,
  });

  factory AppleSubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    return AppleSubscriptionStatusModel(
      status: json['status'],
      success: json['success'],
      data: json['data'] != null
          ? SubscriptionData.fromJson(json['data'])
          : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class SubscriptionData {
  final bool? hasActiveSubscription;
  final int? planId;
  final String? productId;
  final String? expiryDate;
  final String? subscriptionStatus;

  SubscriptionData({
    this.hasActiveSubscription,
    this.planId,
    this.productId,
    this.expiryDate,
    this.subscriptionStatus,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      hasActiveSubscription: json['has_active_subscription'],
      planId: json['plan_id'],
      productId: json['product_id'],
      expiryDate: json['expiry_date'],
      subscriptionStatus: json['subscription_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_active_subscription': hasActiveSubscription,
      'plan_id': planId,
      'product_id': productId,
      'expiry_date': expiryDate,
      'subscription_status': subscriptionStatus,
    };
  }
}