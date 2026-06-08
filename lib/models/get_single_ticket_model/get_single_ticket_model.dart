class GetSingleTicketModel {
  int? status;
  bool? success;
  SingleTicketData? data;

  GetSingleTicketModel({this.status, this.success, this.data});

  GetSingleTicketModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    data = json['data'] != null ? SingleTicketData.fromJson(json['data']) : null;
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

class SingleTicketData {
  int? id;
  String? feature;
  String? featureRaw;
  Null featureOther;
  String? description;
  String? status;
  String? assignedTo;
  String? createdAt;
  String? lastReplyAt;
  Null resolvedAt;
  List<Messages>? messages;
  List<Attachments>? attachments;

  SingleTicketData(
      {this.id,
        this.feature,
        this.featureRaw,
        this.featureOther,
        this.description,
        this.status,
        this.assignedTo,
        this.createdAt,
        this.lastReplyAt,
        this.resolvedAt,
        this.messages,
        this.attachments});

  SingleTicketData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    feature = json['feature'];
    featureRaw = json['feature_raw'];
    featureOther = json['feature_other'];
    description = json['description'];
    status = json['status'];
    assignedTo = json['assigned_to'];
    createdAt = json['created_at'];
    lastReplyAt = json['last_reply_at'];
    resolvedAt = json['resolved_at'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(Attachments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['feature'] = feature;
    data['feature_raw'] = featureRaw;
    data['feature_other'] = featureOther;
    data['description'] = description;
    data['status'] = status;
    data['assigned_to'] = assignedTo;
    data['created_at'] = createdAt;
    data['last_reply_at'] = lastReplyAt;
    data['resolved_at'] = resolvedAt;
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    if (attachments != null) {
      data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  int? id;
  int? userId;
  String? userName;
  String? role;
  String? message;
  List<Attachments>? attachments;
  String? createdAt;

  Messages(
      {this.id,
        this.userId,
        this.userName,
        this.role,
        this.message,
        this.attachments,
        this.createdAt});

  Messages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    role = json['role'];
    message = json['message'];
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(Attachments.fromJson(v));
      });
    }
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['role'] = role;
    data['message'] = message;
    if (this.attachments != null) {
      data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    return data;
  }
}

class Attachments {
  int? id;
  String? originalName;
  String? url;
  String? mimeType;
  int? size;

  Attachments({this.id, this.originalName, this.url, this.mimeType, this.size});

  Attachments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    originalName = json['original_name'];
    url = json['url'];
    mimeType = json['mime_type'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['original_name'] = originalName;
    data['url'] = url;
    data['mime_type'] = mimeType;
    data['size'] = size;
    return data;
  }
}
