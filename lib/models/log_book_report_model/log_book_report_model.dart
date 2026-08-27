class LogBookReportModel {
  int? status;
  String? message;
  LogReportData? data;

  LogBookReportModel({this.status, this.message, this.data});

  LogBookReportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? LogReportData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class LogReportData {
  int? year;
  Report? report;
  List<int>? yearOptions;
  List<Submission>? submissions;

  LogReportData({
    this.year,
    this.report,
    this.yearOptions,
    this.submissions,
  });

  LogReportData.fromJson(Map<String, dynamic> json) {
    year = json['year'];
    report = json['report'] != null ? Report.fromJson(json['report']) : null;
    if (json['year_options'] != null) {
      yearOptions = json['year_options'].cast<int>();
    }
    if (json['submissions'] != null) {
      submissions = <Submission>[];
      json['submissions'].forEach((v) {
        submissions!.add(Submission.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['year'] = year;
    if (report != null) {
      data['report'] = report!.toJson();
    }
    data['year_options'] = yearOptions;
    if (submissions != null) {
      data['submissions'] = submissions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Report {
  double? kmStart;
  double? kmEnd;
  double? totalKmDriven;
  double? totalKmBusiness;

  Report({
    this.kmStart,
    this.kmEnd,
    this.totalKmDriven,
    this.totalKmBusiness,
  });

  Report.fromJson(Map<String, dynamic> json) {
    kmStart = _toDouble(json['km_start']);
    kmEnd = _toDouble(json['km_end']);
    totalKmDriven = _toDouble(json['total_km_driven']);
    totalKmBusiness = _toDouble(json['total_km_business']);
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['km_start'] = kmStart;
    data['km_end'] = kmEnd;
    data['total_km_driven'] = totalKmDriven;
    data['total_km_business'] = totalKmBusiness;
    return data;
  }
}

class Submission {
  int? id;
  int? year;
  double? kmStart;
  double? kmEnd;
  double? totalKmDriven;
  String? approvalStatus;
  int? createdBy;
  String? creatorName;
  String? createdAt;

  Submission({
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

  Submission.fromJson(Map<String, dynamic> json) {
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