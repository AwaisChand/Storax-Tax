class AllTripsModel {
  int? status;
  Data? data;
  String? message;

  AllTripsModel({this.status, this.data, this.message});

  AllTripsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  List<Trips>? trips;
  Pagination? pagination;

  Data({this.trips, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['trips'] != null) {
      trips = <Trips>[];
      json['trips'].forEach((v) {
        trips!.add(Trips.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (trips != null) {
      data['trips'] = trips!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Trips {
  int? tripId;
  String? trackingMode;
  String? tripType;
  String? purpose;
  String? status;
  String? fromLocation;
  double? fromLat;
  double? fromLng;
  String? toLocation;
  double? toLat;
  double? toLng;
  String? startedAt;
  String? startDateFormatted;
  String? endedAt;
  String? totalDistance;
  String? totalDuration;
  int? createdBy;
  String? creatorName;
  String? approvalStatus;

  Trips(
      {this.tripId,
        this.trackingMode,
        this.tripType,
        this.purpose,
        this.status,
        this.fromLocation,
        this.fromLat,
        this.fromLng,
        this.toLocation,
        this.toLat,
        this.toLng,
        this.startedAt,
        this.startDateFormatted,
        this.endedAt,
        this.totalDistance,
        this.totalDuration,
        this.createdBy,
        this.creatorName,
        this.approvalStatus});

  Trips.fromJson(Map<String, dynamic> json) {
    tripId = json['trip_id'];
    trackingMode = json['tracking_mode'];
    tripType = json['trip_type'];
    purpose = json['purpose'];
    status = json['status'];
    fromLocation = json['from_location'];
    fromLat = json['from_lat'];
    fromLng = json['from_lng'];
    toLocation = json['to_location'];
    toLat = json['to_lat'];
    toLng = json['to_lng'];
    startedAt = json['started_at'];
    startDateFormatted = json['start_date_formatted'];
    endedAt = json['ended_at'];
    totalDistance = json['total_distance'];
    totalDuration = json['total_duration'];
    createdBy = json['created_by'];
    creatorName = json['creator_name'];
    approvalStatus = json['approval_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['trip_id'] = tripId;
    data['tracking_mode'] = trackingMode;
    data['trip_type'] = tripType;
    data['purpose'] = purpose;
    data['status'] = status;
    data['from_location'] = fromLocation;
    data['from_lat'] = fromLat;
    data['from_lng'] = fromLng;
    data['to_location'] = toLocation;
    data['to_lat'] = toLat;
    data['to_lng'] = toLng;
    data['started_at'] = startedAt;
    data['start_date_formatted'] = startDateFormatted;
    data['ended_at'] = endedAt;
    data['total_distance'] = totalDistance;
    data['total_duration'] = totalDuration;
    data['created_by'] = createdBy;
    data['creator_name'] = creatorName;
    data['approval_status'] = approvalStatus;
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? total;
  int? lastPage;

  Pagination({this.currentPage, this.perPage, this.total, this.lastPage});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    perPage = json['per_page'];
    total = json['total'];
    lastPage = json['last_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['per_page'] = perPage;
    data['total'] = total;
    data['last_page'] = lastPage;
    return data;
  }
}
