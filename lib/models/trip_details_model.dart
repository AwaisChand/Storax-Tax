class TripDetailsModel {
  int? status;
  TripDetailData? data;
  String? message;

  TripDetailsModel({this.status, this.data, this.message});

  TripDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? TripDetailData.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap['status'] = status;
    if (data != null) {
      jsonMap['data'] = data!.toJson();
    }
    jsonMap['message'] = message;
    return jsonMap;
  }
}

class TripDetailData {
  int? tripId;
  int? userId;
  int? planId;
  String? tripType;
  String? purpose;
  String? fromLocation;
  double? fromLat;
  double? fromLng;
  String? toLocation;
  double? toLat;
  double? toLng;
  String? status;
  String? startedAt;
  int? plannedDistanceMeters;
  double? plannedDistanceKm;
  int? plannedDurationMinutes;
  String? plannedPolyline;
  int? activeDistanceMeters;
  String? activePolyline;
  int? remainingDistanceMeters;
  String? endedAt;
  dynamic totalDistanceKm; // Kept dynamic to handle null or future updates safely
  dynamic travelTimeSeconds;
  dynamic travelTimeFormatted;

  TripDetailData({
    this.tripId,
    this.userId,
    this.planId,
    this.tripType,
    this.purpose,
    this.fromLocation,
    this.fromLat,
    this.fromLng,
    this.toLocation,
    this.toLat,
    this.toLng,
    this.status,
    this.startedAt,
    this.plannedDistanceMeters,
    this.plannedDistanceKm,
    this.plannedDurationMinutes,
    this.plannedPolyline,
    this.activeDistanceMeters,
    this.activePolyline,
    this.remainingDistanceMeters,
    this.endedAt,
    this.totalDistanceKm,
    this.travelTimeSeconds,
    this.travelTimeFormatted,
  });

  TripDetailData.fromJson(Map<String, dynamic> json) {
    tripId = json['trip_id'];
    userId = json['user_id'];
    planId = json['plan_id'];
    tripType = json['trip_type'];
    purpose = json['purpose'];
    fromLocation = json['from_location'];

    // Safe coordinate conversions
    fromLat = _parseDouble(json['from_lat']);
    fromLng = _parseDouble(json['from_lng']);

    toLocation = json['to_location'];
    toLat = _parseDouble(json['to_lat']);
    toLng = _parseDouble(json['to_lng']);

    status = json['status'];
    startedAt = json['started_at'];
    plannedDistanceMeters = json['planned_distance_meters'];
    plannedDistanceKm = _parseDouble(json['planned_distance_km']);
    plannedDurationMinutes = json['planned_duration_minutes'];
    plannedPolyline = json['planned_polyline'];
    activeDistanceMeters = json['active_distance_meters'];
    activePolyline = json['active_polyline'];
    remainingDistanceMeters = json['remaining_distance_meters'];
    endedAt = json['ended_at'];
    totalDistanceKm = json['total_distance_km'];
    travelTimeSeconds = json['travel_time_seconds'];
    travelTimeFormatted = json['travel_time_formatted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap['trip_id'] = tripId;
    jsonMap['user_id'] = userId;
    jsonMap['plan_id'] = planId;
    jsonMap['trip_type'] = tripType;
    jsonMap['purpose'] = purpose;
    jsonMap['from_location'] = fromLocation;
    jsonMap['from_lat'] = fromLat;
    jsonMap['from_lng'] = fromLng;
    jsonMap['to_location'] = toLocation;
    jsonMap['to_lat'] = toLat;
    jsonMap['to_lng'] = toLng;
    jsonMap['status'] = status;
    jsonMap['started_at'] = startedAt;
    jsonMap['planned_distance_meters'] = plannedDistanceMeters;
    jsonMap['planned_distance_km'] = plannedDistanceKm;
    jsonMap['planned_duration_minutes'] = plannedDurationMinutes;
    jsonMap['planned_polyline'] = plannedPolyline;
    jsonMap['active_distance_meters'] = activeDistanceMeters;
    jsonMap['active_polyline'] = activePolyline;
    jsonMap['remaining_distance_meters'] = remainingDistanceMeters;
    jsonMap['ended_at'] = endedAt;
    jsonMap['total_distance_km'] = totalDistanceKm;
    jsonMap['travel_time_seconds'] = travelTimeSeconds;
    jsonMap['travel_time_formatted'] = travelTimeFormatted;
    return jsonMap;
  }

  // Helper method to completely eliminate silent Null pointer parsing crashes
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}