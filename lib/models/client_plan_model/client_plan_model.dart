class ClientPlanModel {
  int? status;
  String? success;
  List<Plans>? plans;

  ClientPlanModel({this.status, this.success, this.plans});

  ClientPlanModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    if (json['plans'] != null) {
      plans = <Plans>[];
      json['plans'].forEach((v) {
        plans!.add(Plans.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['success'] = success;
    if (plans != null) {
      data['plans'] = plans!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Plans {
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
  String? tagline;
  String? taglineFr;
  List<Features>? features;

  Plans({
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
    this.tagline,
    this.taglineFr,
    this.features,
  });

  Plans.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameFr = json['name_fr'];
    type = json['type'];
    price = (json['price'] as num?)?.toDouble();
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
    tagline = json['tagline'];
    taglineFr = json['tagline_fr'];
    if (json['features'] != null) {
      features = <Features>[];
      json['features'].forEach((v) {
        features!.add(Features.fromJson(v));
      });
    }
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
    data['tagline'] = tagline;
    data['tagline_fr'] = taglineFr;
    if (features != null) {
      data['features'] = features!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Features {
  String? name;
  bool? included;
  String? translatedName;

  Features({this.name, this.included, this.translatedName});

  Features.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    included = json['included'];
    translatedName = json['translated_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['included'] = included;
    data['translated_name'] = translatedName;
    return data;
  }
}
