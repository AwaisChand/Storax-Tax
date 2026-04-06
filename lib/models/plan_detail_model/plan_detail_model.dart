class PlanDetailModel {
  int? status;
  String? success;
  Plan? plan;

  PlanDetailModel({this.status, this.success, this.plan});

  PlanDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    plan = json['plan'] != null ? Plan.fromJson(json['plan']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['success'] = success;
    if (plan != null) {
      data['plan'] = plan!.toJson();
    }
    return data;
  }
}

class Plan {
  int? id;
  String? name;
  String? nameFr;
  String? type;
  double? price; // always store as double
  String? details;
  String? planFor;
  String? include;
  String? paypalId;
  String? productId;
  String? cadPaypalId;
  String? connect;
  int? noOfClients;
  String? createdAt;
  String? updatedAt;
  String? usdStripeId;
  String? usdPriceId;
  String? cadStripeId;
  String? cadPriceId;

  Plan({
    this.id,
    this.name,
    this.nameFr,
    this.type,
    this.price,
    this.details,
    this.planFor,
    this.include,
    this.paypalId,
    this.productId,
    this.cadPaypalId,
    this.connect,
    this.noOfClients,
    this.createdAt,
    this.updatedAt,
    this.usdStripeId,
    this.usdPriceId,
    this.cadStripeId,
    this.cadPriceId,
  });

  Plan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameFr = json['name_fr'];
    type = json['type'];

    /// ---- PRICE HANDLER (int or double) ----
    var p = json['price'];
    if (p is int) {
      price = p.toDouble();
    } else if (p is double) {
      price = p;
    } else if (p is String) {
      price = double.tryParse(p);
    } else {
      price = null;
    }
    /// ---------------------------------------

    details = json['details'];
    planFor = json['plan_for'];
    include = json['include'];
    paypalId = json['paypal_id'];
    productId = json['product_id'];
    cadPaypalId = json['cad_paypal_id'];
    connect = json['connect'];
    noOfClients = json['no_of_clients'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    usdStripeId = json['usd_stripe_id'];
    usdPriceId = json['usd_price_id'];
    cadStripeId = json['cad_stripe_id'];
    cadPriceId = json['cad_price_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['name_fr'] = nameFr;
    data['type'] = type;
    data['price'] = price; // always sent as double or null
    data['details'] = details;
    data['plan_for'] = planFor;
    data['include'] = include;
    data['paypal_id'] = paypalId;
    data['product_id'] = productId;
    data['cad_paypal_id'] = cadPaypalId;
    data['connect'] = connect;
    data['no_of_clients'] = noOfClients;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['usd_stripe_id'] = usdStripeId;
    data['usd_price_id'] = usdPriceId;
    data['cad_stripe_id'] = cadStripeId;
    data['cad_price_id'] = cadPriceId;
    return data;
  }
}
