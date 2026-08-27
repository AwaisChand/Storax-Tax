// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
//
// import 'package:storatax/utils/utils.dart';
// import '../models/trip_details_model.dart';
// import '../view_models/gasoline_view_model/gasoline_view_model.dart';
//
// class MapTrackingScreen extends StatefulWidget {
//   final TripDetailsModel? tripModel;
//
//   const MapTrackingScreen({super.key, this.tripModel});
//
//   @override
//   State<MapTrackingScreen> createState() => _MapTrackingScreenState();
// }
//
// class _MapTrackingScreenState extends State<MapTrackingScreen> {
//   GoogleMapController? mapController;
//   StreamSubscription<Position>? positionStream;
//
//   Set<Marker> markers = {};
//   Set<Polyline> polylines = {};
//
//   TripDetailData? trip;
//
//   LatLng? lastPosition;
//   LatLng? lastApiPosition;
//   DateTime? lastApiTime;
//
//   LatLng currentPosition = const LatLng(0, 0);
//
//   double totalDistance = 0;
//   double coveredDistance = 0;
//
//   // Track if initial rendering and camera view setting are done
//   bool isCameraCentered = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     trip = widget.tripModel?.data;
//
//     if (trip == null) {
//       Future.microtask(() {
//         Utils.toastMessage("Trip data missing");
//         Navigator.pop(context);
//       });
//       return;
//     }
//
//     totalDistance = (trip!.plannedDistanceMeters ?? 0).toDouble();
//
//     setupMarkers();
//     initLocation();
//   }
//
//   @override
//   void dispose() {
//     positionStream?.cancel();
//     super.dispose();
//   }
//
//   // ---------------- MARKERS ----------------
//   void setupMarkers() {
//     markers.add(Marker(
//       markerId: const MarkerId("from"),
//       position: LatLng(trip!.fromLat ?? 0, trip!.fromLng ?? 0),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//     ));
//
//     markers.add(Marker(
//       markerId: const MarkerId("to"),
//       position: LatLng(trip!.toLat ?? 0, trip!.toLng ?? 0),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//     ));
//   }
//
//   // ---------------- ROUTE ----------------
//   void drawRouteFromBackend() {
//     if (trip?.plannedPolyline == null || trip!.plannedPolyline!.isEmpty) {
//       print("❌ No polyline received");
//       return;
//     }
//
//     final points = decodePolyline(trip!.plannedPolyline!);
//
//     setState(() {
//       polylines.clear();
//       polylines.add(Polyline(
//         polylineId: const PolylineId("route"),
//         points: points,
//         width: 5,
//         color: Colors.blue,
//       ));
//     });
//
//     if (points.isNotEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) async {
//         try {
//           // 1. Move camera to view the entire journey path on startup
//           await mapController?.animateCamera(
//             CameraUpdate.newLatLngBounds(getBounds(points), 60),
//           );
//
//           // 2. Buffer time to let engine finish viewport transitions smoothly
//           await Future.delayed(const Duration(seconds: 2));
//
//           if (!mounted) return;
//           setState(() {
//             isCameraCentered = true;
//           });
//         } catch (e) {
//           print("Camera adjustment error: $e");
//           if (mounted) setState(() => isCameraCentered = true);
//         }
//       });
//     }
//   }
//
//   // ---------------- LOCATION ----------------
//   Future<void> initLocation() async {
//     if (!await Geolocator.isLocationServiceEnabled()) {
//       Utils.toastMessage("Enable location services");
//       return;
//     }
//
//     var permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return;
//     }
//
//     final pos = await Geolocator.getCurrentPosition();
//     lastPosition = LatLng(pos.latitude, pos.longitude);
//
//     startTracking();
//   }
//
//   // ---------------- GPS STREAM ----------------
//   void startTracking() {
//     positionStream = Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.bestForNavigation,
//         distanceFilter: 5,
//       ),
//     ).listen((position) async {
//       if (position.accuracy > 25) return;
//
//       final current = LatLng(position.latitude, position.longitude);
//       updateCoveredDistance(current);
//
//       if (lastPosition != null) {
//         await animateMarker(lastPosition!, current, position.heading);
//       } else {
//         updateMarker(current, position.heading);
//       }
//
//       // 🔥 Real Live Tracking Dynamic View Bounds Adjustment (Uber Style)
//       if (isCameraCentered && mapController != null) {
//         LatLng destination = LatLng(trip!.toLat ?? 0, trip!.toLng ?? 0);
//
//         LatLngBounds trackingBounds = LatLngBounds(
//           southwest: LatLng(
//             current.latitude < destination.latitude ? current.latitude : destination.latitude,
//             current.longitude < destination.longitude ? current.longitude : destination.longitude,
//           ),
//           northeast: LatLng(
//             current.latitude > destination.latitude ? current.latitude : destination.latitude,
//             current.longitude > destination.longitude ? current.longitude : destination.longitude,
//           ),
//         );
//
//         mapController!.animateCamera(
//           CameraUpdate.newLatLngBounds(trackingBounds, 80), // 80px frame padding
//         );
//       }
//
//       handleLiveApi(position, current);
//       lastPosition = current;
//     });
//   }
//
//   // ---------------- MARKER UPDATE ----------------
//   void updateMarker(LatLng position, double heading) {
//     if (!mounted) return;
//     setState(() {
//       markers.removeWhere((m) => m.markerId.value == "current");
//       markers.add(
//         Marker(
//           markerId: const MarkerId("current"),
//           position: position,
//           rotation: heading,
//           flat: true,
//           anchor: const Offset(0.5, 0.5),
//         ),
//       );
//     });
//   }
//
//   // ---------------- SMOOTH ANIMATION ----------------
//   Future<void> animateMarker(LatLng from, LatLng to, double heading) async {
//     const int steps = 25;
//     final latStep = (to.latitude - from.latitude) / steps;
//     final lngStep = (to.longitude - from.longitude) / steps;
//
//     for (int i = 0; i < steps; i++) {
//       if (!mounted) return;
//       final lat = from.latitude + (latStep * i);
//       final lng = from.longitude + (lngStep * i);
//
//       updateMarker(LatLng(lat, lng), heading);
//       await Future.delayed(const Duration(milliseconds: 20));
//     }
//   }
//
//   // ---------------- API CONTROL ----------------
//   void handleLiveApi(Position position, LatLng current) {
//     final now = DateTime.now();
//
//     final shouldSendByTime =
//         lastApiTime == null || now.difference(lastApiTime!).inSeconds >= 10;
//
//     final shouldSendByDistance = lastApiPosition == null ||
//         Geolocator.distanceBetween(
//           lastApiPosition!.latitude,
//           lastApiPosition!.longitude,
//           current.latitude,
//           current.longitude,
//         ) >= 30;
//
//     if (shouldSendByTime || shouldSendByDistance) {
//       lastApiTime = now;
//       lastApiPosition = current;
//       sendLiveLocation(position, current);
//     }
//   }
//
//   // ---------------- DISTANCE ----------------
//   void updateCoveredDistance(LatLng current) {
//     if (lastPosition == null) return;
//
//     final distance = Geolocator.distanceBetween(
//       lastPosition!.latitude,
//       lastPosition!.longitude,
//       current.latitude,
//       current.longitude,
//     );
//
//     if (distance > 5 && distance < 100) {
//       coveredDistance += distance;
//     }
//   }
//
//   // ---------------- API ----------------
//   Future<void> sendLiveLocation(Position position, LatLng current) async {
//     final data = {
//       "trip_id": trip!.tripId,
//       "user_id": trip!.userId,
//       "lat": current.latitude,
//       "lng": current.longitude,
//       "speed": position.speed,
//       "accuracy": position.accuracy,
//       "heading": position.heading,
//       "distance_from_last_point": coveredDistance,
//       "is_moving": position.speed > 1.5,
//       "timestamp": DateTime.now().toIso8601String(),
//     };
//
//     await context
//         .read<GasolineViewModel>()
//         .liveLocationUpdateApi(context, data);
//   }
//
//   // ---------------- POLYLINE DECODER ----------------
//   List<LatLng> decodePolyline(String encoded) {
//     List<LatLng> points = [];
//     int index = 0, lat = 0, lng = 0;
//
//     while (index < encoded.length) {
//       int shift = 0, result = 0, b;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//
//       lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//
//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//
//       lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       points.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//     return points;
//   }
//
//   LatLngBounds getBounds(List<LatLng> points) {
//     double minLat = points.first.latitude;
//     double maxLat = points.first.latitude;
//     double minLng = points.first.longitude;
//     double maxLng = points.first.longitude;
//
//     for (var p in points) {
//       if (p.latitude < minLat) minLat = p.latitude;
//       if (p.latitude > maxLat) maxLat = p.latitude;
//       if (p.longitude < minLng) minLng = p.longitude;
//       if (p.longitude > maxLng) maxLng = p.longitude;
//     }
//
//     return LatLngBounds(
//       southwest: LatLng(minLat, minLng),
//       northeast: LatLng(maxLat, maxLng),
//     );
//   }
//
//   String formatDistance(double meters) {
//     return meters < 1000
//         ? "${meters.toStringAsFixed(0)} m"
//         : "${(meters / 1000).toStringAsFixed(2)} km";
//   }
//
//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Trip Tracking")),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: LatLng(trip!.fromLat ?? 0, trip!.fromLng ?? 0),
//               zoom: 10,
//             ),
//             onMapCreated: (c) {
//               mapController = c;
//               drawRouteFromBackend();
//             },
//             markers: markers,
//             polylines: polylines,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//           ),
//           Positioned(
//             bottom: 20,
//             left: 15,
//             right: 15,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: const [
//                   BoxShadow(color: Colors.black12, blurRadius: 4)
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "Covered: ${formatDistance(coveredDistance)}",
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                   ),
//                   Text(
//                     "Total: ${formatDistance(totalDistance)}",
//                     style: const TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }