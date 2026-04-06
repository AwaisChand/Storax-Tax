class GetMorePlansModel {
  int? status;
  bool? success;
  Data? data;
  String? message;

  GetMorePlansModel({this.status, this.success, this.data, this.message});

  GetMorePlansModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  List<MorePlans>? plans;
  String? country;
  List<int>? currentPlans;

  Data({this.plans, this.country, this.currentPlans});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['plans'] != null) {
      plans = <MorePlans>[];
      json['plans'].forEach((v) {
        plans!.add(MorePlans.fromJson(v));
      });
    }
    country = json['country'];
    currentPlans =
        json['current_plans'] != null
            ? List<int>.from(json['current_plans'])
            : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (plans != null) {
      data['plans'] = plans!.map((v) => v.toJson()).toList();
    }
    data['country'] = country;
    data['current_plans'] = currentPlans;
    return data;
  }
}

class MorePlans {
  int? id;
  String? name;
  String? nameFr;
  String? type;
  double? price;
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
  List<Features>? features;
  bool? isPurchased;
  String? tagline;
  String? taglineFr;

  MorePlans({
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
    this.features,
    this.isPurchased,
    this.tagline,
    this.taglineFr,
  });

  MorePlans.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameFr = json['name_fr'];
    type = json['type'];
    price =
        (json['price'] != null)
            ? double.tryParse(json['price'].toString())
            : 0.0; // ✅ Handles int/double safely
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

    if (json['features'] != null) {
      features = <Features>[];
      json['features'].forEach((v) {
        features!.add(Features.fromJson(v));
      });
    }
    isPurchased = json['isPurchased'];
    tagline = json['tagline'];
    taglineFr = json['tagline_fr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['name_fr'] = nameFr;
    data['type'] = type;
    data['price'] = price;
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
    if (features != null) {
      data['features'] = features!.map((v) => v.toJson()).toList();
    }
    data['isPurchased'] = isPurchased;
    data['tagline'] = tagline;
    data['tagline_fr'] = taglineFr;
    return data;
  }
}

class Features {
  String? name;
  bool? included;
  String? translationName;
  dynamic clientsLimit;

  Features({this.name, this.included, this.translationName, this.clientsLimit});

  Features.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    included = json['included'];
    translationName = json['translated_name'];
    clientsLimit = json['clients_limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['included'] = included;
    data['translated_name'] = translationName;
    data['clients_limit'] = clientsLimit;
    return data;
  }
}
