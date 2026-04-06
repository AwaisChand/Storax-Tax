class GetCategoryModel {
  int? status;
  String? success;
  List<CategoryData>? data;

  GetCategoryModel({this.status, this.success, this.data});

  GetCategoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    if (json['data'] != null) {
      data = <CategoryData>[];
      json['data'].forEach((v) {
        data!.add(CategoryData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryData {
  String? valueEn;
  String? valueFr;
  String? value;
  String? labelEn;
  String? labelFr;
  String? label;

  CategoryData({
    this.valueEn,
    this.valueFr,
    this.value,
    this.labelEn,
    this.labelFr,
    this.label,
  });

  /// 🔹 Backend value (used for API / selected value)
  String? get backendValue => value;

  /// 🔹 Label shown in UI based on language
  String getDisplayLabel(bool isFrench) {
    if (isFrench) {
      return (labelFr ?? labelEn ?? label ?? '').trim();
    }
    return (labelEn ?? labelFr ?? label ?? '').trim();
  }

  CategoryData.fromJson(Map<String, dynamic> json) {
    valueEn = json['value_en'];
    valueFr = json['value_fr'];
    value = json['value'];
    labelEn = json['label_en'];
    labelFr = json['label_fr'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value_en'] = valueEn;
    data['value_fr'] = valueFr;
    data['value'] = value;
    data['label_en'] = labelEn;
    data['label_fr'] = labelFr;
    data['label'] = label;
    return data;
  }
}

