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
    currentPlans = json['current_plans'].cast<int>();
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
  int? sequence;
  String? name;
  String? nameFr;
  String? type;
  String? status;
  int? yearlyPrice;
  int? monthlyPrice;
  String? details;
  String? planFor;
  String? include;
  String? connect;
  int? noOfClients;
  String? createdAt;
  String? updatedAt;
  String? yearlyUsdStripeId;
  String? yearlyUsdPriceId;
  String? yearlyCadStripeId;
  String? yearlyCadPriceId;
  String? stripeProductId;
  String? monthlyUsdStripeId;
  String? monthlyUsdPriceId;
  String? monthlyCadStripeId;
  String? monthlyCadPriceId;
  Null monthlyAppleProductId;
  String? yearlyAppleProductId;
  List<Features>? features;
  bool? isPurchased;
  String? tagline;
  String? taglineFr;

  MorePlans(
      {this.id,
        this.sequence,
        this.name,
        this.nameFr,
        this.type,
        this.status,
        this.yearlyPrice,
        this.monthlyPrice,
        this.details,
        this.planFor,
        this.include,
        this.connect,
        this.noOfClients,
        this.createdAt,
        this.updatedAt,
        this.yearlyUsdStripeId,
        this.yearlyUsdPriceId,
        this.yearlyCadStripeId,
        this.yearlyCadPriceId,
        this.stripeProductId,
        this.monthlyUsdStripeId,
        this.monthlyUsdPriceId,
        this.monthlyCadStripeId,
        this.monthlyCadPriceId,
        this.monthlyAppleProductId,
        this.yearlyAppleProductId,
        this.features,
        this.isPurchased,
        this.tagline,
        this.taglineFr});

  MorePlans.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sequence = json['sequence'];
    name = json['name'];
    nameFr = json['name_fr'];
    type = json['type'];
    status = json['status'];
    yearlyPrice = json['yearly_price'];
    monthlyPrice = json['monthly_price'];
    details = json['details'];
    planFor = json['plan_for'];
    include = json['include'];
    connect = json['connect'];
    noOfClients = json['no_of_clients'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    yearlyUsdStripeId = json['yearly_usd_stripe_id'];
    yearlyUsdPriceId = json['yearly_usd_price_id'];
    yearlyCadStripeId = json['yearly_cad_stripe_id'];
    yearlyCadPriceId = json['yearly_cad_price_id'];
    stripeProductId = json['stripe_product_id'];
    monthlyUsdStripeId = json['monthly_usd_stripe_id'];
    monthlyUsdPriceId = json['monthly_usd_price_id'];
    monthlyCadStripeId = json['monthly_cad_stripe_id'];
    monthlyCadPriceId = json['monthly_cad_price_id'];
    monthlyAppleProductId = json['monthly_apple_product_id'];
    yearlyAppleProductId = json['yearly_apple_product_id'];
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
    data['sequence'] = sequence;
    data['name'] = name;
    data['name_fr'] = nameFr;
    data['type'] = type;
    data['status'] = status;
    data['yearly_price'] = yearlyPrice;
    data['monthly_price'] = monthlyPrice;
    data['details'] = details;
    data['plan_for'] = planFor;
    data['include'] = include;
    data['connect'] = connect;
    data['no_of_clients'] = noOfClients;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['yearly_usd_stripe_id'] = yearlyUsdStripeId;
    data['yearly_usd_price_id'] = yearlyUsdPriceId;
    data['yearly_cad_stripe_id'] = yearlyCadStripeId;
    data['yearly_cad_price_id'] = yearlyCadPriceId;
    data['stripe_product_id'] = stripeProductId;
    data['monthly_usd_stripe_id'] = monthlyUsdStripeId;
    data['monthly_usd_price_id'] = monthlyUsdPriceId;
    data['monthly_cad_stripe_id'] = monthlyCadStripeId;
    data['monthly_cad_price_id'] = monthlyCadPriceId;
    data['monthly_apple_product_id'] = monthlyAppleProductId;
    data['yearly_apple_product_id'] = yearlyAppleProductId;
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
  String? translatedName;
  Null clientsLimit;

  Features({this.name, this.included, this.translatedName, this.clientsLimit});

  Features.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    included = json['included'];
    translatedName = json['translated_name'];
    clientsLimit = json['clients_limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['included'] = included;
    data['translated_name'] = translatedName;
    data['clients_limit'] = clientsLimit;
    return data;
  }
}
