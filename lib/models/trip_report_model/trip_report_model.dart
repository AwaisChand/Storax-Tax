class TripReportModel {
  int? status;
  String? message;
  TripReportData? data;

  TripReportModel({this.status, this.message, this.data});

  TripReportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? TripReportData.fromJson(json['data']) : null;
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

class TripReportData {
  String? filter;
  Period? period;
  Stats? stats;
  Chart? chart;
  List<TripsReport>? trips;

  TripReportData({this.filter, this.period, this.stats, this.chart, this.trips});

  TripReportData.fromJson(Map<String, dynamic> json) {
    filter = json['filter'];
    period =
    json['period'] != null ? Period.fromJson(json['period']) : null;
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;
    chart = json['chart'] != null ? Chart.fromJson(json['chart']) : null;
    if (json['trips'] != null) {
      trips = <TripsReport>[];
      json['trips'].forEach((v) {
        trips!.add(TripsReport.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['filter'] = filter;
    if (period != null) {
      data['period'] = period!.toJson();
    }
    if (stats != null) {
      data['stats'] = stats!.toJson();
    }
    if (chart != null) {
      data['chart'] = chart!.toJson();
    }
    if (trips != null) {
      data['trips'] = trips!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Period {
  String? from;
  String? to;
  String? label;

  Period({this.from, this.to, this.label});

  Period.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from'] = from;
    data['to'] = to;
    data['label'] = label;
    return data;
  }
}

class Stats {
  int? totalTrips;
  double? totalKm;
  String? totalTravelTime;
  int? totalTravelSeconds;
  double? avgKmPerTrip;
  String? avgDurationPerTrip;

  Stats(
      {this.totalTrips,
        this.totalKm,
        this.totalTravelTime,
        this.totalTravelSeconds,
        this.avgKmPerTrip,
        this.avgDurationPerTrip});

  Stats.fromJson(Map<String, dynamic> json) {
    totalTrips = json['total_trips'];

    totalKm = (json['total_km'] as num?)?.toDouble();

    totalTravelTime = json['total_travel_time'];
    totalTravelSeconds = json['total_travel_seconds'];

    // Applying the same fix here to protect average calculations
    avgKmPerTrip = (json['avg_km_per_trip'] as num?)?.toDouble();

    avgDurationPerTrip = json['avg_duration_per_trip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_trips'] = totalTrips;
    data['total_km'] = totalKm;
    data['total_travel_time'] = totalTravelTime;
    data['total_travel_seconds'] = totalTravelSeconds;
    data['avg_km_per_trip'] = avgKmPerTrip;
    data['avg_duration_per_trip'] = avgDurationPerTrip;
    return data;
  }
}

class Chart {
  List<String>? categories;
  List<double>? trips;
  List<double>? km;

  Chart({this.categories, this.trips, this.km});

  Chart.fromJson(Map<String, dynamic> json) {
    categories = (json['categories'] as List?)
        ?.map((e) => e.toString())
        .toList();

    trips = (json['trips'] as List?)
        ?.map((e) => (e as num).toDouble())
        .toList();

    km = (json['km'] as List?)
        ?.map((e) => (e as num).toDouble())
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'trips': trips,
      'km': km,
    };
  }
}

class TripsReport {
  int? id;
  int? tripId;
  String? trackingMode;
  String? tripType;
  String? fromLocation;
  String? toLocation;
  String? purpose;
  String? startedAt;
  String? startDateFormatted;
  String? startedAtSort;
  String? startTime;
  String? endedAt;
  String? endTime;
  String? totalDistanceKm;
  int? estimatedDurationMin;
  int? plannedDistanceKm;
  String? travelTimeFormatted;
  String? status;
  double? fromLat;
  double? fromLng;
  double? toLat;
  double? toLng;
  String? routePolyline;
  List<Polyline>? polyline;
  Polyline? from;
  Polyline? to;

  TripsReport(
      {this.id,
        this.tripId,
        this.trackingMode,
        this.tripType,
        this.fromLocation,
        this.toLocation,
        this.purpose,
        this.startedAt,
        this.startDateFormatted,
        this.startedAtSort,
        this.startTime,
        this.endedAt,
        this.endTime,
        this.totalDistanceKm,
        this.estimatedDurationMin,
        this.plannedDistanceKm,
        this.travelTimeFormatted,
        this.status,
        this.fromLat,
        this.fromLng,
        this.toLat,
        this.toLng,
        this.routePolyline,
        this.polyline,
        this.from,
        this.to});

  TripsReport.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tripId = json['trip_id'];
    trackingMode = json['tracking_mode'];
    tripType = json['trip_type'];
    fromLocation = json['from_location'];
    toLocation = json['to_location'];
    purpose = json['purpose'];
    startedAt = json['started_at'];
    startDateFormatted = json['start_date_formatted'];
    startedAtSort = json['started_at_sort'];
    startTime = json['start_time'];
    endedAt = json['ended_at'];
    endTime = json['end_time'];
    totalDistanceKm = json['total_distance_km'];
    estimatedDurationMin = json['estimated_duration_min'];
    plannedDistanceKm = json['planned_distance_km'];
    travelTimeFormatted = json['travel_time_formatted'];
    status = json['status'];
    fromLat = json['from_lat'];
    fromLng = json['from_lng'];
    toLat = json['to_lat'];
    toLng = json['to_lng'];
    routePolyline = json['route_polyline'];
    if (json['polyline'] != null) {
      polyline = <Polyline>[];
      json['polyline'].forEach((v) {
        polyline!.add(Polyline.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['trip_id'] = tripId;
    data['tracking_mode'] = trackingMode;
    data['trip_type'] = tripType;
    data['from_location'] = fromLocation;
    data['to_location'] = toLocation;
    data['purpose'] = purpose;
    data['started_at'] = startedAt;
    data['start_date_formatted'] = startDateFormatted;
    data['started_at_sort'] = startedAtSort;
    data['start_time'] = startTime;
    data['ended_at'] = endedAt;
    data['end_time'] = endTime;
    data['total_distance_km'] = totalDistanceKm;
    data['estimated_duration_min'] = estimatedDurationMin;
    data['planned_distance_km'] = plannedDistanceKm;
    data['travel_time_formatted'] = travelTimeFormatted;
    data['status'] = status;
    data['from_lat'] = fromLat;
    data['from_lng'] = fromLng;
    data['to_lat'] = toLat;
    data['to_lng'] = toLng;
    data['route_polyline'] = routePolyline;
    if (polyline != null) {
      data['polyline'] = polyline!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Polyline {
  double? lat;
  double? lng;

  Polyline({this.lat, this.lng});

  Polyline.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}
