class ActiveTripModel {
  int? status;
  ActiveTripData? data;
  String? message;

  ActiveTripModel({this.status, this.data, this.message});

  ActiveTripModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? ActiveTripData.fromJson(json['data']) : null;
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

class ActiveTripData {
  int? tripsToday;
  bool? isTracking;
  String? trackingMode;
  int? tripId;
  String? startTime;
  String? currentDistance;
  String? currentDuration;
  int? trackingInterval;
  int? minDistanceFilter;
  String? pathPolyline;
  double? lastLat;
  double? lastLng;

  ActiveTripData(
      {this.tripsToday,
        this.isTracking,
        this.trackingMode,
        this.tripId,
        this.startTime,
        this.currentDistance,
        this.currentDuration,
        this.trackingInterval,
        this.minDistanceFilter,
        this.pathPolyline,
        this.lastLat,
        this.lastLng});

  ActiveTripData.fromJson(Map<String, dynamic> json) {
    tripsToday = json['trips_today'];
    isTracking = json['is_tracking'];
    trackingMode = json['tracking_mode'];
    tripId = json['trip_id'];
    startTime = json['start_time'];
    currentDistance = json['current_distance'];
    currentDuration = json['current_duration'];
    trackingInterval = json['tracking_interval'];
    minDistanceFilter = json['min_distance_filter'];
    pathPolyline = json['path_polyline'];
    lastLat = json['last_lat'];
    lastLng = json['last_lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['trips_today'] = tripsToday;
    data['is_tracking'] = isTracking;
    data['tracking_mode'] = trackingMode;
    data['trip_id'] = tripId;
    data['start_time'] = startTime;
    data['current_distance'] = currentDistance;
    data['current_duration'] = currentDuration;
    data['tracking_interval'] = trackingInterval;
    data['min_distance_filter'] = minDistanceFilter;
    data['path_polyline'] = pathPolyline;
    data['last_lat'] = lastLat;
    data['last_lng'] = lastLng;
    return data;
  }
}
