class GetReportsModel {
  int? status;
  String? message;
  ReportsData? data;

  GetReportsModel({this.status, this.message, this.data});

  GetReportsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ReportsData.fromJson(json['data']) : null;
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

class ReportsData {
  String? viewUrl;
  String? printUrl;

  ReportsData({this.viewUrl, this.printUrl});

  ReportsData.fromJson(Map<String, dynamic> json) {
    viewUrl = json['view_url'];
    printUrl = json['print_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['view_url'] = viewUrl;
    data['print_url'] = printUrl;
    return data;
  }
}
