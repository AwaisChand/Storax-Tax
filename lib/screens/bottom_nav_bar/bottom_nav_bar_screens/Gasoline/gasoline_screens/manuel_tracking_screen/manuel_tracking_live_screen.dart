import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../../models/get_trip_detail_model/get_trip_detail_model.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../../view_models/auth_view_model/auth_view_model.dart';
import '../../../../../../view_models/gasoline_view_model/gasoline_view_model.dart';
import '../../../../bottom_nav_bar.dart';

class ManuelTrackingLiveScreen extends StatefulWidget {
  final int tripId;

  const ManuelTrackingLiveScreen({super.key, required this.tripId});

  @override
  State<ManuelTrackingLiveScreen> createState() =>
      _ManuelTrackingLiveScreenState();
}

class _ManuelTrackingLiveScreenState extends State<ManuelTrackingLiveScreen> {
  GoogleMapController? _mapController;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  bool _mapReady = false;
  bool _isCameraLocked = true;

  String routePolyline = "";

  double totalDistanceKm = 0;
  int totalDurationMin = 0;
  String tripStatus = "";

  ManualTripData? tripData;

  StreamSubscription<Position>? _positionSubscription;
  Position? _lastSentPosition;

  final double updateDistance = 10;
  bool _hasStartedMoving = false;
  bool _isEndingTrip = false;

  // ✅ Store route points
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTripDetail();
    });
  }

  Future<void> getTripDetail() async {
    final auth = context.read<AuthViewModel>();
    final vm = context.read<GasolineViewModel>();

    await vm.getTripDetailApi(context, auth.user!.id, widget.tripId);

    final data = vm.getTripDetailModel?.data;

    if (data != null) {
      setState(() {
        tripData = data;
        routePolyline = data.routePolyline ?? "";
        totalDistanceKm = double.tryParse(data.totalDistanceKm ?? "0") ?? 0;
        totalDurationMin = data.estimatedDurationMin ?? 0;
        tripStatus = data.status ?? "";
      });

      _addMarkers();
      _drawPolyline();

      startLocationTracking();
    }
  }

  // ✅ START TRACKING (REAL-TIME 3D NAVIGATION VIEW)
  void startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (_isEndingTrip) return;

      LatLng current = LatLng(position.latitude, position.longitude);

      _updateUserMarker(current, position.heading);

      if (_isCameraLocked && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: current,
              zoom: 18.5,
              tilt: 45.0,
              bearing: position.heading,
            ),
          ),
        );
      }

      // ✅ AUTOMATIC END TRIP CHECK: Verify if destination reached
      if (tripData?.toLat != null && tripData?.toLng != null) {
        double distanceToDestination = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          tripData!.toLat!,
          tripData!.toLng!,
        );

        // Standard arrival threshold (e.g., within 50 meters of destination)
        if (distanceToDestination <= 50) {
          stopLocationTracking();
          return;
        }
      }

      double speed = position.speed;

      if (speed > 2) {
        _hasStartedMoving = true;
      }

      if (_routePoints.isNotEmpty && _hasStartedMoving) {
        double remainingKm = _calculateRemainingDistance(current, _routePoints);

        if (remainingKm < 0.05) return;

        double speedKmh = speed > 2 ? speed * 3.6 : 40.0;

        int remainingMin = ((remainingKm / speedKmh) * 60).toInt();

        setState(() {
          totalDistanceKm = remainingKm;
          totalDurationMin = remainingMin < 1 ? 1 : remainingMin;
        });
      }

      /// ✅ FIX: Handle the absolute initial API update payload baseline
      // if (_lastSentPosition == null) {
      //   sendLocationUpdate(position);
      //   return;
      // }

      /// ✅ FIX: Calculate distance against the historical validation benchmark
      double distance = Geolocator.distanceBetween(
        _lastSentPosition!.latitude,
        _lastSentPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      debugPrint(
        "👟 Distance moved since last API update: ${distance.toStringAsFixed(2)} meters",
      );

      /// ✅ FIX: Validate threshold limits before updating state
      // if (distance >= updateDistance) {
      //   sendLocationUpdate(position);
      // }
    });
  }

  Future<void> stopLocationTracking() async {
    if (_isEndingTrip) return;

    setState(() {
      _isEndingTrip = true;
    });

    _positionSubscription?.cancel();
    _positionSubscription = null;

    final auth = context.read<AuthViewModel>();
    final vm = context.read<GasolineViewModel>();

    double endLat = _lastSentPosition?.latitude ?? (tripData?.toLat ?? 0.0);
    double endLng = _lastSentPosition?.longitude ?? (tripData?.toLng ?? 0.0);

    final endTripBody = {
      "trip_id": widget.tripId,
      "user_id": auth.user!.id,
      "end_time": DateTime.now().toUtc().toIso8601String(),
      "final_distance_km": double.parse(totalDistanceKm.toStringAsFixed(1)),
      "final_duration_min": totalDurationMin,
      "end_lat": endLat,
      "end_lng": endLng,
      "tracking": "off",
    };

    final response = await vm.endTripApi(endTripBody);

    if (response != null) {
      vm.activeTripModel?.data?.isTracking = false;
      vm.activeTripModel?.data?.trackingMode = null;
      vm.clearCurrentTrip();
    }

    Utils.selectedMode = '';

    if (response != null && mounted) {
      Future.microtask(() {
        context.goNamed("bottomNavBar");
        BottomNavBar.of(context)?.switchTab(1);
      });
    }
  }

  void _updateUserMarker(LatLng position, double heading) {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == "user_arrow");
      _markers.add(
        Marker(
          markerId: const MarkerId("user_arrow"),
          position: position,
          rotation: heading,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          infoWindow: const InfoWindow(
            title: "Current Location",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  // Future<void> sendLocationUpdate(Position position) async {
  //   final auth = context.read<AuthViewModel>();
  //   final vm = context.read<GasolineViewModel>();
  //
  //   final body = {
  //     "trip_id": widget.tripId,
  //     "user_id": auth.user!.id,
  //     "lat": position.latitude,
  //     "lng": position.longitude,
  //     "speed": position.speed,
  //     "heading": position.heading,
  //     "accuracy": position.accuracy,
  //     "timestamp": DateTime.now().toUtc().toIso8601String(),
  //   };
  //
  //   final response = await vm.updateTrackingApi(body);
  //
  //   if (response != null) {
  //     _lastSentPosition = position;
  //   }
  // }

  double _calculateRemainingDistance(LatLng current, List<LatLng> route) {
    if (route.isEmpty) return 0;

    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < route.length; i++) {
      double d = Geolocator.distanceBetween(
        current.latitude,
        current.longitude,
        route[i].latitude,
        route[i].longitude,
      );
      if (d < minDistance) {
        minDistance = d;
        closestIndex = i;
      }
    }

    double remainingDistanceMeters = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      route[closestIndex].latitude,
      route[closestIndex].longitude,
    );

    for (int i = closestIndex; i < route.length - 1; i++) {
      remainingDistanceMeters += Geolocator.distanceBetween(
        route[i].latitude,
        route[i].longitude,
        route[i + 1].latitude,
        route[i + 1].longitude,
      );
    }

    return remainingDistanceMeters / 1000;
  }

  void _addMarkers() {
    if (tripData == null) return;

    // Preserve user_arrow marker while refreshing trip route markers
    _markers.removeWhere((m) => m.markerId.value != "user_arrow");

    // 1. START POINT MARKER
    if (tripData!.fromLat != null && tripData!.fromLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("from"),
          position: LatLng(tripData!.fromLat!, tripData!.fromLng!),
          infoWindow: InfoWindow(
            title: AppLocalizations.of(context)!.translate("startPointText") ?? "Start Location",
            snippet: tripData!.fromLocation ?? "",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    // 2. INTERMEDIATE STOPS MARKERS
    if (tripData!.stops != null && tripData!.stops!.isNotEmpty) {
      for (int i = 0; i < tripData!.stops!.length; i++) {
        final stop = tripData!.stops![i];
        if (stop.lat != null && stop.lng != null) {
          _markers.add(
            Marker(
              markerId: MarkerId("stop_$i"),
              position: LatLng(stop.lat!, stop.lng!),
              infoWindow: InfoWindow(
                title: "Stop ${stop.order ?? (i + 1)}: ${stop.name ?? 'WayPoint'}",
                snippet: stop.name ?? "",
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          );
        }
      }
    }

    // 3. DESTINATION MARKER
    if (tripData!.toLat != null && tripData!.toLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: LatLng(tripData!.toLat!, tripData!.toLng!),
          infoWindow: InfoWindow(
            title: AppLocalizations.of(context)!.translate("destinationText") ?? "Destination",
            snippet: tripData!.toLocation ?? "",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    setState(() {});
  }

  void _drawPolyline() {
    if (routePolyline.isEmpty) return;

    final decoded = PolylinePoints.decodePolyline(routePolyline);
    final points = decoded.map((e) => LatLng(e.latitude, e.longitude)).toList();

    _routePoints = points;
    _polylines.clear();

    _polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        points: points,
        width: 6,
        color: const Color(0xFF1A73E8),
      ),
    );

    _zoomToRoute(points);
  }

  void _zoomToRoute(List<LatLng> points) {
    if (_mapController == null) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalMinutes) {
    if (totalMinutes <= 0) return "1 min";

    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    if (hours > 0) {
      return "$hours hr ${minutes > 0 ? '$minutes min' : ''}";
    } else {
      return "$minutes min";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        text1:
        AppLocalizations.of(context)!.translate("liveTrackingText") ?? '',
        text2: "",
        onBackTap:
            () => Future.microtask(() {
          context.goNamed("bottomNavBar");
          BottomNavBar.of(context)?.switchTab(1);
        }),
        showBackButton: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(31.4815, 74.3030),
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            onCameraMoveStarted: () {
              setState(() => _isCameraLocked = false);
            },
            onMapCreated: (controller) {
              _mapController = controller;
              _mapReady = true;

              if (routePolyline.isNotEmpty) {
                _drawPolyline();
              }
            },
          ),

          if (!_isCameraLocked)
            Positioned(
              bottom: 30,
              right: 15,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() => _isCameraLocked = true);
                },
                icon: const Icon(Icons.navigation, color: Colors.blue),
                label: Text(
                  AppLocalizations.of(context)!.translate("reCenterText") ?? '',
                  style: GoogleFonts.poppins(color: Colors.blue),
                ),
              ),
            ),

          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${AppLocalizations.of(context)!.translate("statusText")}: $tripStatus",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.translate("remainingDistanceText") ??
                                  '',
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                            Text(
                              "${totalDistanceKm.toStringAsFixed(1)} KM",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.translate("etaDurationText") ??
                                  '',
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                            Text(
                              _formatDuration(totalDurationMin),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}