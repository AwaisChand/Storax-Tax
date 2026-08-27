import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:storatax/models/trip_report_model/trip_report_model.dart'
    hide Polyline;
import 'package:storatax/utils/app_colors.dart';

import '../../../../../../res/app_assets.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../res/components/app_localization.dart';

class ViewRouteScreen extends StatefulWidget {
  const ViewRouteScreen({super.key, required this.tripsReport});

  final TripsReport tripsReport;

  @override
  State<ViewRouteScreen> createState() => _ViewRouteScreenState();
}

class _ViewRouteScreenState extends State<ViewRouteScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
    _initMapData();
  }

  void _initMapData() {
    final report = widget.tripsReport;

    // 1. Decode polyline string first to ensure we have the precise path
    if (report.routePolyline != null && report.routePolyline!.isNotEmpty) {
      List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(
        report.routePolyline!,
      );
      _polylineCoordinates =
          decodedPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
    }

    // 2. Determine exact Start (From) Coordinate
    LatLng? startLatLng;
    if (report.fromLat != null && report.fromLng != null) {
      startLatLng = LatLng(report.fromLat!, report.fromLng!);
    } else if (_polylineCoordinates.isNotEmpty) {
      startLatLng =
          _polylineCoordinates.first; // Fallback to first polyline point
    }

    // 3. Determine exact End (To) Coordinate
    LatLng? endLatLng;
    if (report.toLat != null && report.toLng != null) {
      endLatLng = LatLng(report.toLat!, report.toLng!);
    } else if (_polylineCoordinates.isNotEmpty) {
      endLatLng = _polylineCoordinates.last; // Fallback to last polyline point
    }

    // 4. Clear and Add Markers with unique IDs
    _markers.clear();

    if (startLatLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId(
            'start_position_unique_id',
          ), // Explicitly unique
          position: startLatLng,
          infoWindow: InfoWindow(
            title: 'Start Location',
            snippet: report.fromLocation,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueCyan,
          ), // Cyan for Start
        ),
      );
    }

    if (endLatLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId(
            'end_position_unique_id',
          ), // Explicitly unique
          position: endLatLng,
          infoWindow: InfoWindow(
            title: 'End Location',
            snippet: report.toLocation,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ), // Green for End
        ),
      );
    }

    // 5. Build Polyline fallback if required
    if (_polylines.isEmpty && _polylineCoordinates.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_path'),
          points: _polylineCoordinates,
          color: const Color(0xFF4A6BE4),
          width: 5,
        ),
      );
    } else if (_polylineCoordinates.isEmpty &&
        startLatLng != null &&
        endLatLng != null) {
      _polylineCoordinates = [startLatLng, endLatLng];
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_path'),
          points: _polylineCoordinates,
          color: const Color(0xFF4A6BE4),
          width: 5,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_polylineCoordinates.isNotEmpty) {
      // Short delay ensuring the controller context registers the viewport safely
      Future.delayed(const Duration(milliseconds: 300), () {
        LatLngBounds bounds = _getBounds(_polylineCoordinates);
        _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      });
    }
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // ✅ Helper method to ensure formatted duration string is strictly positive
  String _getPositiveDuration(String? durationStr) {
    if (durationStr == null || durationStr.isEmpty) return '—';
    // Remove minus signs from the formatted duration string
    return durationStr.replaceAll('-', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.tripsReport;
    final double? distanceNum = double.tryParse(report.totalDistanceKm ?? '');
    final String displayDistance =
    distanceNum != null
        ? "${distanceNum.abs().toStringAsFixed(2)} KM"
        : "0.00 KM";

    final String displayDuration = _getPositiveDuration(report.travelTimeFormatted);

    LatLng defaultCenter = const LatLng(0.0, 0.0);
    if (report.fromLat != null && report.fromLng != null) {
      defaultCenter = LatLng(report.fromLat!, report.fromLng!);
    }

    return Scaffold(
      appBar: CustomAppBar(
        text1: AppLocalizations.of(context)!.translate("tripDetailText") ?? '',
        text2: "",
        onBackTap: () => Navigator.of(context).pop(),
        showBackButton: true,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.backgroundImg),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 25,
                right: 20,
                left: 20,
                bottom: 25,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.translate("tripDetailText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    height: Utils.setHeight(context) * 0.14,
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 22,
                      right: 20,
                      left: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black, width: 0.2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${report.fromLocation ?? ''} - ${report.toLocation ?? ''}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            height: 27,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.black,
                                width: 0.2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                report.trackingMode ?? '',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  _containerWidget("Distance", displayDistance, context),
                  const SizedBox(height: 8),
                  _containerWidget(
                    AppLocalizations.of(context)!.translate("duText") ?? '',
                    displayDuration,
                    context,
                  ),
                  const SizedBox(height: 8),
                  _containerWidget(
                    AppLocalizations.of(context)!.translate("stText") ?? '',
                    report.startedAt ?? '—',
                    context,
                  ),
                  const SizedBox(height: 8),
                  _containerWidget(
                    AppLocalizations.of(context)!.translate("endingText") ?? '',
                    report.endedAt ?? '—',
                    context,
                  ),
                  const SizedBox(height: 8),
                  _containerWidget(
                    AppLocalizations.of(context)!.translate("purposeText") ?? '',
                    report.purpose ?? '—',
                    context,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    AppLocalizations.of(context)!.translate("routeMapText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: double.infinity,
                      height: Utils.setHeight(context) * 0.30,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black, width: 0.2),
                      ),
                      child:
                      (report.fromLat != null && report.fromLng != null)
                          ? GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: defaultCenter,
                          zoom: 13.0,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        mapType: MapType.normal,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                      )
                          : _buildMapFallback(
                        icon: Icons.map_outlined,
                        message:
                        "No geolocation coordinates available for this route.",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapFallback({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _containerWidget(String text1, String text2, BuildContext context) {
    return Container(
      height: Utils.setHeight(context) * 0.08,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 0.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text1,
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Flexible(
            child: Text(
              text2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}