// more_plans.dart
import 'package:storatax/models/base_plan_models.dart';

class MoreFeatures implements BaseFeature {
  @override
  final String? name;

  @override
  final int? included;

  MoreFeatures({this.name, this.included});

  factory MoreFeatures.fromJson(Map<String, dynamic> json) {
    return MoreFeatures(
      name: json['name'],
      included: json['included'],
    );
  }
}




class MorePlans implements BasePlan {
  @override
  final String name;

  @override
  final String price;

  @override
  final List<MoreFeatures>? features;

  @override
  final int id;

  MorePlans({
    required this.name,
    required this.price,
    required this.features,
    required this.id,
  });

  factory MorePlans.fromJson(Map<String, dynamic> json) {
    return MorePlans(
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      features: (json['features'] as List?)
          ?.map((f) => MoreFeatures.fromJson(f))
          .toList(),
      id: json['id'] ?? 0,
    );
  }
}
