import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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

class showMapScreen extends StatefulWidget {
  final List<int> tripIds;

  const showMapScreen({super.key, required this.tripIds});

  @override
  State<showMapScreen> createState() => _showMapScreenState();
}

class _showMapScreenState extends State<showMapScreen> {
  GoogleMapController? _mapController;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  bool _mapReady = false;
  bool _isLoading = true;

  double totalDistanceKm = 0.0;
  int totalDurationMin = 0;

  List<ManualTripData> tripDataList = [];
  List<LatLng> _allRoutePoints = [];

  @override
  void initState() {
    super.initState();
    fetchAllTripDetails();
  }

  Future<void> fetchAllTripDetails() async {
    final auth = context.read<AuthViewModel>().user;
    final vm = context.read<GasolineViewModel>();

    final int? userId =
    (auth?.role == 'team')
        ? auth?.userId
        : auth?.id;
    if (auth == null) return;

    List<LatLng> allPoints = [];
    double accumulatedDistance = 0.0;
    int accumulatedDuration = 0;

    for (int i = 0; i < widget.tripIds.length; i++) {
      int id = widget.tripIds[i];
      await vm.getTripDetailApi(context, userId!, id);

      final data = vm.getTripDetailModel?.data;
      if (data != null) {
        tripDataList.add(data);

        // 🔹 FIX: Sum up each segment's distance and duration
        double segDist = double.tryParse(data.totalDistanceKm ?? "0") ?? 0.0;
        int segDur = data.estimatedDurationMin ?? 0;

        accumulatedDistance += segDist;
        accumulatedDuration += segDur;

        // Decode Polyline for map display
        if (data.routePolyline != null && data.routePolyline!.isNotEmpty) {
          final List<PointLatLng> decoded = PolylinePoints.decodePolyline(
            data.routePolyline!,
          );
          final List<LatLng> segmentPoints =
          decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();

          allPoints.addAll(segmentPoints);

          _polylines.add(
            Polyline(
              polylineId: PolylineId('segment_$id'),
              points: segmentPoints,
              width: 5,
              color: i % 2 == 0 ? Colors.blue : Colors.indigo,
            ),
          );
        }

        // Add Start Marker
        if (data.fromLat != null && data.fromLng != null) {
          _markers.add(
            Marker(
              markerId: MarkerId('start_$id'),
              position: LatLng(data.fromLat!, data.fromLng!),
              infoWindow: InfoWindow(
                title: "Segment ${i + 1} Start",
                snippet: data.fromLocation ?? '',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                i == 0 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
              ),
            ),
          );
        }

        // Add Stop / Destination Marker
        if (data.toLat != null && data.toLng != null) {
          bool isFinalDest = (i == widget.tripIds.length - 1);
          _markers.add(
            Marker(
              markerId: MarkerId('end_$id'),
              position: LatLng(data.toLat!, data.toLng!),
              infoWindow: InfoWindow(
                title: isFinalDest ? "Final Destination" : "Stop ${i + 1}",
                snippet: data.toLocation ?? '',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                isFinalDest
                    ? BitmapDescriptor.hueRed
                    : BitmapDescriptor.hueOrange,
              ),
            ),
          );
        }
      }
    }

    setState(() {
      totalDistanceKm = accumulatedDistance;
      totalDurationMin = accumulatedDuration;
      _allRoutePoints = allPoints;
      _isLoading = false;
    });

    _fitMapToRoute();
  }

  void _fitMapToRoute() {
    if (!_mapReady || _allRoutePoints.isEmpty || _mapController == null) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _allRoutePoints.map((e) => e.latitude).reduce((a, b) => a < b ? a : b),
        _allRoutePoints.map((e) => e.longitude).reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        _allRoutePoints.map((e) => e.latitude).reduce((a, b) => a > b ? a : b),
        _allRoutePoints.map((e) => e.longitude).reduce((a, b) => a > b ? a : b),
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialTarget =
    _allRoutePoints.isNotEmpty
        ? _allRoutePoints.first
        : const LatLng(31.4815, 74.3030);

    return Scaffold(
      appBar: CustomAppBar(
        text1: AppLocalizations.of(context)!.translate("showMapText") ?? '',
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
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              _mapReady = true;
              if (_allRoutePoints.isNotEmpty) {
                _fitMapToRoute();
              }
            },
            myLocationEnabled: true,
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Total Distance",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${totalDistanceKm.toStringAsFixed(1)} km",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: Colors.grey[300]),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Estimated Duration",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$totalDurationMin min",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
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