class ListTicketModel {
  int? status;
  bool? success;
  List<TicketSupport>? data;
  Meta? meta;

  ListTicketModel({this.status, this.success, this.data, this.meta});

  ListTicketModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    if (json['data'] != null) {
      data = <TicketSupport>[];
      json['data'].forEach((v) {
        data!.add(TicketSupport.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class TicketSupport {
  int? id;
  String? featureOther;
  String? status;
  String? lastReplyAt;
  String? createdAt;
  String? feature;
  String? featureFr;
  String? statusLabel;
  String? statusLabelFr;
  String? assignedTo;
  String? description;
  Null resolvedAt;
  List<Messages>? messages;
  List<Attachments>? attachments;

  TicketSupport(
      {this.id,
        this.featureOther,
        this.status,
        this.lastReplyAt,
        this.createdAt,
        this.feature,
        this.featureFr,
        this.statusLabel,
        this.statusLabelFr,
        this.assignedTo,
        this.description,
        this.resolvedAt,
        this.messages,
        this.attachments});

  TicketSupport.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    featureOther = json['feature_other'];
    status = json['status'];
    lastReplyAt = json['last_reply_at'];
    createdAt = json['created_at'];
    feature = json['feature'];
    featureFr = json['feature_fr'];
    statusLabel = json['status_label'];
    statusLabelFr = json['status_label_fr'];
    assignedTo = json['assigned_to'];
    description = json['description'];
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
    data['feature_other'] = featureOther;
    data['status'] = status;
    data['last_reply_at'] = lastReplyAt;
    data['created_at'] = createdAt;
    data['feature'] = feature;
    data['feature_fr'] = featureFr;
    data['status_label'] = statusLabel;
    data['status_label_fr'] = statusLabelFr;
    data['assigned_to'] = assignedTo;
    data['description'] = description;
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
  String? roleLabel;
  String? roleLabelFr;

  Messages(
      {this.id,
        this.userId,
        this.userName,
        this.role,
        this.message,
        this.attachments,
        this.createdAt,
        this.roleLabel,
        this.roleLabelFr});

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
    roleLabel = json['role_label'];
    roleLabelFr = json['role_label_fr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['role'] = role;
    data['message'] = message;
    if (attachments != null) {
      data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['role_label'] = roleLabel;
    data['role_label_fr'] = roleLabelFr;
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

class Meta {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Meta({this.currentPage, this.lastPage, this.perPage, this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['total'] = total;
    return data;
  }
}
