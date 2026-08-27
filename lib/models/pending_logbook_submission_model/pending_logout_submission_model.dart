class PendingLogBookSubmissionsModel {
  int? status;
  String? message;
  List<PendingSubmission>? data;

  PendingLogBookSubmissionsModel({this.status, this.message, this.data});

  PendingLogBookSubmissionsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PendingSubmission>[];
      json['data'].forEach((v) {
        data!.add(PendingSubmission.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PendingSubmission {
  int? id;
  int? year;
  double? kmStart;
  double? kmEnd;
  double? totalKmDriven;
  String? approvalStatus;
  int? createdBy;
  String? creatorName;
  String? createdAt;

  PendingSubmission({
    this.id,
    this.year,
    this.kmStart,
    this.kmEnd,
    this.totalKmDriven,
    this.approvalStatus,
    this.createdBy,
    this.creatorName,
    this.createdAt,
  });

  PendingSubmission.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    year = json['year'];
    kmStart = _toDouble(json['km_start']);
    kmEnd = _toDouble(json['km_end']);
    totalKmDriven = _toDouble(json['total_km_driven']);
    approvalStatus = json['approval_status'];
    createdBy = json['created_by'];
    creatorName = json['creator_name'];
    createdAt = json['created_at'];
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['year'] = year;
    data['km_start'] = kmStart;
    data['km_end'] = kmEnd;
    data['total_km_driven'] = totalKmDriven;
    data['approval_status'] = approvalStatus;
    data['created_by'] = createdBy;
    data['creator_name'] = creatorName;
    data['created_at'] = createdAt;
    return data;
  }
}