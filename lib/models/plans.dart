import 'package:storatax/models/base_plan_models.dart';



class Features implements BaseFeature {
  @override
  final String? name;

  @override
  final bool? included;

  Features({this.name, this.included});

  factory Features.fromJson(Map<String, dynamic> json) {
    return Features(
      name: json['name'],
      included: json['included'],
    );
  }
}


class Plans implements BasePlan {
  @override
  final String name;

  @override
  final String price;

  @override
  final List<Features>? features;

  @override
  final int id;

  Plans({
    required this.name,
    required this.price,
    required this.features,
    required this.id,
  });

  factory Plans.fromJson(Map<String, dynamic> json) {
    return Plans(
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      features: (json['features'] as List?)
          ?.map((f) => Features.fromJson(f))
          .toList(),
      id: json['id'] ?? 0,
    );
  }
}
