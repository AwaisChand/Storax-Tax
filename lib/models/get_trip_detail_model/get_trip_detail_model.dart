class GetTripDetailModel {
  int? status;
  ManualTripData? data;
  String? message;

  GetTripDetailModel({this.status, this.data, this.message});

  GetTripDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? ManualTripData.fromJson(json['data']) : null;
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

class ManualTripData {
  int? tripId;
  int? userId;
  String? fromLocation;
  double? fromLat;
  double? fromLng;
  List<Stops>? stops;
  String? toLocation;
  double? toLat;
  double? toLng;
  String? routePolyline;
  String? totalDistanceKm;
  int? estimatedDurationMin;
  String? status;
  String? tracking;
  String? startTime;
  String? endTime;

  ManualTripData(
      {this.tripId,
        this.userId,
        this.fromLocation,
        this.fromLat,
        this.fromLng,
        this.stops,
        this.toLocation,
        this.toLat,
        this.toLng,
        this.routePolyline,
        this.totalDistanceKm,
        this.estimatedDurationMin,
        this.status,
        this.tracking,
        this.startTime,
        this.endTime});

  ManualTripData.fromJson(Map<String, dynamic> json) {
    tripId = json['trip_id'];
    userId = json['user_id'];
    fromLocation = json['from_location'];
    fromLat = json['from_lat'];
    fromLng = json['from_lng'];
    if (json['stops'] != null) {
      stops = <Stops>[];
      json['stops'].forEach((v) {
        stops!.add(Stops.fromJson(v));
      });
    }
    toLocation = json['to_location'];
    toLat = json['to_lat'];
    toLng = json['to_lng'];
    routePolyline = json['route_polyline'];
    totalDistanceKm = json['total_distance_km'];
    estimatedDurationMin = json['estimated_duration_min'];
    status = json['status'];
    tracking = json['tracking'];
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['trip_id'] = tripId;
    data['user_id'] = userId;
    data['from_location'] = fromLocation;
    data['from_lat'] = fromLat;
    data['from_lng'] = fromLng;
    if (stops != null) {
      data['stops'] = stops!.map((v) => v.toJson()).toList();
    }
    data['to_location'] = toLocation;
    data['to_lat'] = toLat;
    data['to_lng'] = toLng;
    data['route_polyline'] = routePolyline;
    data['total_distance_km'] = totalDistanceKm;
    data['estimated_duration_min'] = estimatedDurationMin;
    data['status'] = status;
    data['tracking'] = tracking;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    return data;
  }
}

class Stops {
  String? name;
  double? lat;
  double? lng;
  int? order;

  Stops({this.name, this.lat, this.lng, this.order});

  Stops.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    lat = json['lat'];
    lng = json['lng'];
    order = json['order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['lat'] = lat;
    data['lng'] = lng;
    data['order'] = order;
    return data;
  }
}
