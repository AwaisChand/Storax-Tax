import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/manuel_tracking_screen/show_map_screen.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../../../../../res/components/app_drawer.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../../view_models/gasoline_view_model/gasoline_view_model.dart';
import '../places_search_screen/places_search_screen.dart';

class ManuelTrackingScreen extends StatefulWidget {
  const ManuelTrackingScreen({super.key});

  @override
  State<ManuelTrackingScreen> createState() => _ManuelTrackingScreenState();
}

class _ManuelTrackingScreenState extends State<ManuelTrackingScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  String routePolyline = "";
  bool _mapReady = false;
  bool tripCreated = false;
  int? createdTripId;
  List<int> createdIds = [];
  DateTime selectedDateTime = DateTime.now();

  static const LatLng _defaultCenter = LatLng(31.4815, 74.3030);

  bool _isLoadingLocation = true;

  List<Map<String, dynamic>> routePoints = [
    {
      'id': 'start_point',
      'name': "Fetching current location...",
      'lat': _defaultCenter.latitude,
      'lng': _defaultCenter.longitude,
    },
    {'id': 'initial_dest', 'name': null, 'lat': null, 'lng': null},
  ];

  double totalDistanceKm = 0;
  int totalDurationMin = 0;

  List<Map<String, dynamic>> routeLegsData = [];

  final String apiKey = "AIzaSyBx7X2S83I4ei7X51AOUOiqiaj-e7gHO0E";

  @override
  void initState() {
    super.initState();
    _determineAndSetUserPosition();
  }

  Future<void> _determineAndSetUserPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services disabled';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition();
      LatLng userCoordinates = LatLng(position.latitude, position.longitude);
      String address = await _getReadableAddressFromLatLng(userCoordinates);

      setState(() {
        routePoints[0] = {
          ...routePoints[0],
          'name': address,
          'lat': userCoordinates.latitude,
          'lng': userCoordinates.longitude,
        };
        _isLoadingLocation = false;
      });

      _updateMapElements();

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(userCoordinates, 14),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<String> _getReadableAddressFromLatLng(LatLng coords) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${coords.latitude},${coords.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      return data['results'][0]['formatted_address'];
    }
    return "Current Location";
  }

  void _updateMapElements() {
    final Set<Marker> localMarkers = {};

    final validPoints = routePoints.where((p) => p["lat"] != null).toList();
    if (validPoints.isEmpty) {
      setState(() {
        _markers.clear();
        _polylines.clear();
        totalDistanceKm = 0;
        totalDurationMin = 0;
        routeLegsData.clear();
      });
      return;
    }

    for (int i = 0; i < routePoints.length; i++) {
      final point = routePoints[i];

      if (point["lat"] != null) {
        bool isFirst = (point['id'] == validPoints.first['id']);
        bool isLast = (point['id'] == validPoints.last['id']);

        localMarkers.add(
          Marker(
            markerId: MarkerId('marker_position_$i'),
            position: LatLng(point['lat'], point['lng']),
            infoWindow: InfoWindow(title: point['name'] ?? ''),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isFirst
                  ? BitmapDescriptor.hueGreen
                  : (isLast
                      ? BitmapDescriptor.hueRed
                      : BitmapDescriptor.hueAzure),
            ),
          ),
        );
      }
    }

    setState(() {
      _markers.clear();
      _markers.addAll(localMarkers);
    });

    calculateDistanceAndDuration();
  }

  void _drawPolyline() {
    if (!_mapReady || routePolyline.isEmpty) return;

    final List<PointLatLng> decoded = PolylinePoints.decodePolyline(
      routePolyline,
    );
    if (decoded.isEmpty) return;

    final List<LatLng> visualPoints =
        decoded
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("google_route"),
          points: visualPoints,
          width: 6,
          color: Colors.blue,
          geodesic: true,
        ),
      );
    });

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        visualPoints.map((e) => e.latitude).reduce((a, b) => a < b ? a : b),
        visualPoints.map((e) => e.longitude).reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        visualPoints.map((e) => e.latitude).reduce((a, b) => a > b ? a : b),
        visualPoints.map((e) => e.longitude).reduce((a, b) => a > b ? a : b),
      ),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  Future<void> calculateDistanceAndDuration() async {
    final validPoints = routePoints.where((p) => p["lat"] != null).toList();
    if (validPoints.length < 2) {
      setState(() {
        _polylines.clear();
        routePolyline = "";
        totalDistanceKm = 0;
        totalDurationMin = 0;
        routeLegsData.clear();
      });
      return;
    }

    final origin = validPoints.first;
    final destination = validPoints.last;

    String waypoints = "";
    if (validPoints.length > 2) {
      waypoints = validPoints
          .sublist(1, validPoints.length - 1)
          .map((s) => "${s["lat"]},${s["lng"]}")
          .join('|');
    }

    String url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${origin["lat"]},${origin["lng"]}"
        "&destination=${destination["lat"]},${destination["lng"]}"
        "&mode=driving"
        "&key=$apiKey";

    if (waypoints.isNotEmpty) {
      url += "&waypoints=$waypoints";
    }

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data["status"] == "OK") {
      int distance = 0;
      int duration = 0;
      List<Map<String, dynamic>> extractedLegs = [];

      // 🔹 Extract actual leg-by-leg metrics
      for (var leg in data["routes"][0]["legs"]) {
        int legDistMeters = leg["distance"]["value"] as int;
        int legDurSeconds = leg["duration"]["value"] as int;

        distance += legDistMeters;
        duration += legDurSeconds;

        extractedLegs.add({
          "distance_km": legDistMeters / 1000,
          "duration_min": (legDurSeconds / 60).round(),
        });
      }

      setState(() {
        totalDistanceKm = distance / 1000;
        totalDurationMin = (duration / 60).round();
        routeLegsData = extractedLegs;
        routePolyline = data["routes"][0]["overview_polyline"]["points"];
      });

      _drawPolyline();
    }
  }

  Future<void> _navigateToPlaceSearch({required int index}) async {
    if (tripCreated) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlaceSearchScreen(isFrom: true),
      ),
    );

    if (result != null) {
      setState(() {
        routePoints[index] = {
          ...routePoints[index],
          'name': result['name'],
          'lat': result['lat'],
          'lng': result['lng'],
        };
      });
      _updateMapElements();
    }
  }

  List<Map<String, dynamic>> buildSegmentedTripRequests(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final validPoints = routePoints.where((p) => p["lat"] != null).toList();

    // Use the manually picked date/time
    final String deviceTime = selectedDateTime.toIso8601String();

    if (validPoints.length < 2) return [];

    List<Map<String, dynamic>> tripPayloads = [];
    int segmentCount = validPoints.length - 1;

    final int? userId =
        (auth.user?.role == 'team') ? auth.user?.userId : auth.user?.id;

    for (int i = 0; i < segmentCount; i++) {
      final fromPoint = validPoints[i];
      final toPoint = validPoints[i + 1];

      double segmentDistance =
          (i < routeLegsData.length)
              ? routeLegsData[i]["distance_km"]
              : totalDistanceKm / segmentCount;

      int segmentDuration =
          (i < routeLegsData.length)
              ? routeLegsData[i]["duration_min"]
              : (totalDurationMin / segmentCount).round();

      tripPayloads.add({
        "user_id": userId,
        "trip_type": "manual",
        "from_location": fromPoint["name"] ?? "",
        "from_lat": fromPoint["lat"],
        "from_lng": fromPoint["lng"],
        "stops": [],
        "to_location": toPoint["name"] ?? "",
        "to_lat": toPoint["lat"],
        "to_lng": toPoint["lng"],
        "total_distance_km": segmentDistance,
        "estimated_duration_min": segmentDuration,
        "route_polyline": routePolyline,
        "start_time": deviceTime,
        "tracking": "on",
      });
    }

    return tripPayloads;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    if (tripCreated) return;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();

    final double safeLat = routePoints[0]["lat"] ?? _defaultCenter.latitude;
    final double safeLng = routePoints[0]["lng"] ?? _defaultCenter.longitude;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
      appBar: CustomAppBar(
        text1:
            AppLocalizations.of(context)!.translate("manualTrackingText") ?? '',
        text2: "",
        onBackTap: () => Navigator.of(context).pop(),
        showBackButton: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(safeLat, safeLng),
              zoom: 13,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (c) {
              _mapController = c;
              _mapReady = true;
              if (routePolyline.isNotEmpty) _drawPolyline();

              // Force iOS platform view to render tiles
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.zoomBy(0.0),
                  );
                }
              });
            },
            myLocationEnabled: true,
          ),

          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 340),
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: routePoints.length,
                        buildDefaultDragHandles: false,
                        onReorder: (oldIndex, newIndex) {
                          if (tripCreated) return;

                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final item = routePoints.removeAt(oldIndex);
                            routePoints.insert(newIndex, item);

                            routePolyline = "";
                            _polylines.clear();
                          });

                          _updateMapElements();
                        },
                        itemBuilder: (context, i) {
                          final item = routePoints[i];
                          bool isFirst = (i == 0);
                          bool isLast = (i == routePoints.length - 1);

                          String placeholderText =
                              isFirst
                                  ? "Choose starting point"
                                  : isLast
                                  ? (AppLocalizations.of(
                                        context,
                                      )!.translate("enterDestinationText") ??
                                      'Choose destination')
                                  : "${AppLocalizations.of(context)!.translate("enterStopText") ?? 'Stop'} ${String.fromCharCode(64 + i)}";

                          Widget leadingIcon =
                              isFirst
                                  ? const Icon(
                                    Icons.radio_button_unchecked,
                                    color: Colors.green,
                                    size: 22,
                                  )
                                  : isLast
                                  ? const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 24,
                                  )
                                  : Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blueGrey,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      String.fromCharCode(64 + i),
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  );

                          return Container(
                            key: ValueKey(item['id']),
                            child: _buildRouteField(
                              text: item['name'] ?? placeholderText,
                              onTap: () => _navigateToPlaceSearch(index: i),
                              leading: leadingIcon,
                              showLine: !isLast,
                              isPlaceholder: item['name'] == null,
                              index: i,
                              isDraggable: !tripCreated,
                              onTrailingCloseTap:
                                  (!tripCreated && routePoints.length > 2)
                                      ? () {
                                        setState(() {
                                          routePoints.removeAt(i);
                                          _updateMapElements();
                                        });
                                      }
                                      : null,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    InkWell(
                      onTap: () => _selectDateTime(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} at ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            if (!tripCreated)
                              const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.grey,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (totalDistanceKm > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "$totalDurationMin min (${totalDistanceKm.toStringAsFixed(1)} km)",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),

                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            tripCreated ? Icons.arrow_back : Icons.add,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            if (tripCreated) {
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                routePoints.insert(routePoints.length - 1, {
                                  'id':
                                      DateTime.now().microsecondsSinceEpoch
                                          .toString(),
                                  'name': null,
                                  'lat': null,
                                  'lng': null,
                                });
                              });
                            }
                          },
                        ),
                        const Spacer(),
                        if (!tripCreated)
                          TextButton(
                            onPressed: () async {
                              final tripPayloads = buildSegmentedTripRequests(
                                context,
                              );

                              final int? userId =
                                  (auth.user?.role == 'team')
                                      ? auth.user?.userId
                                      : auth.user?.id;

                              if (tripPayloads.isEmpty) {
                                Utils.toastMessage(
                                  "Please select valid origin and destination points.",
                                );
                                return;
                              }

                              final vm = context.read<GasolineViewModel>();
                              List<int> tempCreatedIds = [];

                              for (int i = 0; i < tripPayloads.length; i++) {
                                try {
                                  final response = await vm.createTripApi(
                                    tripPayloads[i],
                                  );

                                  if (response != null &&
                                      response["data"] != null) {
                                    tempCreatedIds.add(
                                      response["data"]["trip_id"],
                                    );
                                  }

                                  await Future.delayed(
                                    const Duration(milliseconds: 500),
                                  );
                                } catch (e) {
                                  debugPrint(
                                    "Error creating trip segment $i: $e",
                                  );
                                }
                              }

                              if (context.mounted && auth.user != null) {
                                await vm.activeTripApi(context, userId!);
                              }

                              if (tempCreatedIds.isNotEmpty) {
                                setState(() {
                                  tripCreated = true;
                                  createdIds = tempCreatedIds;
                                  createdTripId = tempCreatedIds.last;
                                });

                                Utils.toastMessage(
                                  "${tempCreatedIds.length} of ${tripPayloads.length} trips created!",
                                );
                              }
                            },
                            child: Text(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("saveText") ??
                                  'Save',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (tripCreated)
                          TextButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          showMapScreen(tripIds: createdIds),
                                ),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("showMapText") ??
                                  'Show Map',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
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

  Widget _buildRouteField({
    required String text,
    required VoidCallback onTap,
    required Widget leading,
    required bool showLine,
    required int index,
    required bool isDraggable,
    VoidCallback? onTrailingCloseTap,
    bool isPlaceholder = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              const SizedBox(height: 12),
              leading,
              if (showLine)
                Expanded(
                  child: Container(
                    width: 0,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CustomPaint(painter: _DottedLinePainter()),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: isDraggable ? onTap : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color:
                                  isPlaceholder
                                      ? Colors.black38
                                      : Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isDraggable) ...[
                      ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Icon(
                            Icons.menu,
                            color: Colors.black45,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    SizedBox(
                      width: 24,
                      child:
                          (isDraggable && onTrailingCloseTap != null)
                              ? InkWell(
                                onTap: onTrailingCloseTap,
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.black54,
                                  size: 20,
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
                if (showLine)
                  const Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Colors.black12,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 3, dashSpace = 3, startY = 0;
    final paint =
        Paint()
          ..color = Colors.black38
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
