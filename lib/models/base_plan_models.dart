abstract class BaseFeature {
  String? get name;
  dynamic get included; // use `bool?`, `int?`, or `dynamic` based on model
}

abstract class BasePlan {
  String get name;
  String get price;
  List<dynamic>? get features;
  int get id;
}
