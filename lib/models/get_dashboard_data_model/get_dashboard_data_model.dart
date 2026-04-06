class GetDashboardDataModel {
  int? status;
  String? success;
  Data? data;

  GetDashboardDataModel({this.status, this.success, this.data});

  GetDashboardDataModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? fileCount;
  int? subscriptionCount;

  Data({this.fileCount, this.subscriptionCount});

  Data.fromJson(Map<String, dynamic> json) {
    fileCount = json['file_count'];
    subscriptionCount = json['subscription_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_count'] = fileCount;
    data['subscription_count'] = subscriptionCount;
    return data;
  }
}
