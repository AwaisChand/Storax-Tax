import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storatax/models/get_gasoline_list_model/get_gasoline_list_model.dart'
    as list;
import 'package:storatax/models/get_gasoline_report_model/get_gasoline_report_model.dart';
import 'package:storatax/models/get_transaction_report_model/get_transaction_report_model.dart';
import 'package:storatax/models/list_auto_trips_model/list_auto_trips_model.dart';
import 'package:storatax/repository/gasoline_repository/gasoline_repository.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/gasoline_list_screen/gasoline_list_screen/gasoline_list_screen.dart';
import 'package:storatax/utils/scan_flow_log.dart';

import '../../models/active_trip_model(auto)/active_trip_model.dart';
import '../../models/get_trip_detail_model/get_trip_detail_model.dart';
import '../../models/trip_report_model/trip_report_model.dart';
import '../../utils/utils.dart';

class GasolineViewModel extends ChangeNotifier {
  final GasolineRepository gasolineRepository = GasolineRepository();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _tripLoading = false;

  bool get tripLoading => _tripLoading;

  set trip(bool setLoading) {
    _tripLoading = setLoading;
    notifyListeners();
  }

  bool _endTripLoading = false;

  bool get endTripLoading => _endTripLoading;

  set endTrip(bool setLoading) {
    _endTripLoading = setLoading;
    notifyListeners();
  }

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  bool _tripReportLoading = false;

  bool get tripReportLoading => _tripReportLoading;

  set tripReport(bool reportLoading) {
    _tripReportLoading = reportLoading;
    notifyListeners();
  }


  bool _printTripLoading = false;

  bool get printTripLoading => _printTripLoading;

  set printTrip(bool setLoading) {
    _printTripLoading = setLoading;
    notifyListeners();
  }

  bool _isTrackingRunning = false;

  bool get isTrackingRunning => _isTrackingRunning;

  void setTrackingRunning(bool value) {
    _isTrackingRunning = value;
    notifyListeners();
  }

  List<list.Data> _gasolineList = [];

  List<list.Data> get gasolineList => _gasolineList;

  List<MonthlySummary> _monthlySummary = [];

  List<MonthlySummary> get monthlySummary => _monthlySummary;

  GetGasolineReportModel? _gasolineReportModel;

  GetGasolineReportModel? get gasolineReportModel => _gasolineReportModel;

  GetTransactionReportModel? _getTransactionReportModel;

  GetTransactionReportModel? get getTransactionReportModel =>
      _getTransactionReportModel;

  GetTripDetailModel? _getTripDetailModel;

  GetTripDetailModel? get getTripDetailModel => _getTripDetailModel;

  ActiveTripModel? _activeTripModel;
  ActiveTripModel? get activeTripModel => _activeTripModel;

  List<Trips> _trips = [];
  List<Trips> get trips => _trips;

  TripReportModel? _tripReportModel;
  TripReportModel? get tripReportModel => _tripReportModel;

  DateTime? fromDate;
  DateTime? toDate;
  DateTime? selectedMonth;
  String? selectedYear;
  String? sortBy;
  String? sortOrder;
  Timer? _timer;
  Position? lastPosition;
  StreamSubscription<Position>? _positionStream;

  ///Graph Entry
  DateTime? fromGraphDate;
  DateTime? toGraphDate;
  DateTime? selectedGraphMonth;
  String? selectedGraphYear;

  /// For Transaction
  DateTime? fromTransDate;
  DateTime? toTransDate;
  DateTime? selectedTransMonth;
  String? selectedTransYear;
  int? currentTripId;

  void clearFilters() {
    fromDate = null;
    toDate = null;
    selectedMonth = null;
    selectedYear = null;
    notifyListeners();
  }

  void clearGraphFilters() {
    fromGraphDate = null;
    toGraphDate = null;
    selectedGraphMonth = null;
    selectedGraphYear = null;
    notifyListeners();
  }

  void clearTransactionFilters() {
    fromDate = null;
    toDate = null;
    selectedMonth = null;
    selectedYear = null;
    sortBy = null;
    sortOrder = null;

    notifyListeners();
  }

  void clearActiveTrip() {
    _activeTripModel = null;
    notifyListeners();
  }

  void clearCurrentTrip() {
    currentTripId = null;
    notifyListeners();
  }

  void setTrackingLocally() {
    _activeTripModel ??= ActiveTripModel();

    activeTripModel!.data ??= ActiveTripData();

    activeTripModel!.data!.isTracking = true;
    activeTripModel!.data!.trackingMode = "auto";

    notifyListeners();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }
  }

  // 🔹 Top of GasolineViewModel:
  final List<Map<String, dynamic>> _offlineLocationBuffer = [];

// 🔹 Safe Buffer Helper Method:
  Future<dynamic> _sendOrBufferLocation(Map<String, dynamic> data) async {
    try {
      // 1. Flush offline queue if network returned
      if (_offlineLocationBuffer.isNotEmpty) {
        debugPrint("📦 Flushing ${_offlineLocationBuffer.length} buffered location updates...");
        final copy = List<Map<String, dynamic>>.from(_offlineLocationBuffer);
        _offlineLocationBuffer.clear();
        for (var bufferedData in copy) {
          await liveLocationUpdateApi(bufferedData);
        }
      }

      // 2. Send current position update
      final response = await liveLocationUpdateApi(data);
      return response;
    } catch (e) {
      debugPrint("⚠️ Network error / switch: $e. Buffering update locally.");
      _offlineLocationBuffer.add(data);
      return null; // Return null so the main listener knows API call was buffered
    }
  }

// 🔹 Fixed startLiveTracking Method:
  Future<void> startLiveTracking(int tripId) async {
    if (_isTrackingRunning) return;

    _isTrackingRunning = true;
    notifyListeners();

    await _initLocation();
    await _positionStream?.cancel();

    DateTime? lastSentTime;

    // 🔹 Remove intervalDuration so the stream starts IMMEDIATELY on Android
    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        // ❌ Removed intervalDuration: const Duration(seconds: 10) to avoid double throttling
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "Auto Tracking Active",
          notificationText: "Storatax is tracking your trip location in background.",
          notificationIcon: AndroidResource(name: 'ic_launcher'),
          enableWakeLock: true,
        ),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }

    debugPrint("🚀 Starting Position Stream...");

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) async {
      try {
        final now = DateTime.now();

        // ✅ 1. Manual 10-Second Throttling (Applies AFTER the first immediate fix)
        if (lastSentTime != null && now.difference(lastSentTime!).inSeconds < 10) {
          debugPrint("⏳ Skipped update: Less than 10 seconds passed.");
          return;
        }

        double speedKmH = (position.speed >= 0 ? position.speed : 0) * 3.6;

        // ✅ 2. GPS Jitter Check (< 2 meters)
        if (lastPosition != null) {
          final distance = Geolocator.distanceBetween(
            lastPosition!.latitude,
            lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          if (distance < 2 && speedKmH < 1) {
            debugPrint("⚠️ Minor GPS jitter ignored (<2m)");
            return;
          }
        }

        // Update timer and last position IMMEDIATELY
        lastSentTime = now;
        lastPosition = position;

        // final rawTime = position.timestamp;
        // final karachiTime = rawTime.toUtc().add(const Duration(hours: 5));
        //
        // final formattedTime =
        //     "${karachiTime.year.toString().padLeft(4, '0')}-"
        //     "${karachiTime.month.toString().padLeft(2, '0')}-"
        //     "${karachiTime.day.toString().padLeft(2, '0')}T"
        //     "${karachiTime.hour.toString().padLeft(2, '0')}:"
        //     "${karachiTime.minute.toString().padLeft(2, '0')}:"
        //     "${karachiTime.second.toString().padLeft(2, '0')}";

        final String deviceTime = now.toIso8601String();

        String currentAddress = "";
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            currentAddress =
                "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}"
                    .replaceAll(RegExp(r'^,\s*|\s*,\s*$'), '')
                    .replaceAll(RegExp(r'(,\s*)+'), ', ');
          }
        } catch (e) {
          debugPrint("⚠️ Geocoding address error: $e");
        }

        final data = {
          "trip_id": currentTripId ?? tripId,
          "lat": position.latitude,
          "lng": position.longitude,
          "speed": speedKmH,
          "accuracy": position.accuracy,
          "timestamp": deviceTime,
          "address": currentAddress,
        };

        debugPrint("📡 Hitting API with data: Lat ${position.latitude}, Lng ${position.longitude}");

        final response = await _sendOrBufferLocation(data);

        if (response != null) {
          final responseData = response["data"];

          if (responseData != null && responseData["ignored"] == true) {
            debugPrint("⚠️ Backend ignored location: ${responseData["reason"]}");
          }

          // 🔥 AUTO TRIP SWITCH
          final int? backendTripId =
              responseData?["trip_id"] ?? responseData?["new_trip_id"];

          if (backendTripId != null && backendTripId != currentTripId) {
            debugPrint("🔄 Backend auto-started new trip ID: $backendTripId");

            currentTripId = backendTripId;
            _activeTripModel = ActiveTripModel.fromJson(responseData);
            _activeTripModel!.data?.isTracking = true;
            _activeTripModel!.data?.trackingMode = "auto";

            Utils.toastMessage("Previous trip auto-completed. New trip started!");
          } else if (responseData != null) {
            if (_activeTripModel == null) {
              _activeTripModel = ActiveTripModel.fromJson(responseData);
              _activeTripModel!.data?.isTracking = true;
              _activeTripModel!.data?.trackingMode = "auto";
            } else {
              _activeTripModel!.data?.currentDistance =
                  responseData["current_distance"] ??
                      _activeTripModel!.data?.currentDistance;

              _activeTripModel!.data?.currentDuration =
                  responseData["current_duration"] ??
                      _activeTripModel!.data?.currentDuration;

              _activeTripModel!.data?.lastLat =
                  responseData["last_lat"] ??
                      _activeTripModel!.data?.lastLat;

              _activeTripModel!.data?.lastLng =
                  responseData["last_lng"] ??
                      _activeTripModel!.data?.lastLng;

              _activeTripModel!.data?.pathPolyline =
                  responseData["path_polyline"] ??
                      _activeTripModel!.data?.pathPolyline;
            }
          }

          notifyListeners();
        } else {
          debugPrint("⚠️ Response was null (Buffered or API Exception).");
        }
      } catch (e) {
        debugPrint("🔥 Stream error inside listener: $e");
      }
    });
  }

  ///Get Gasoline Api Model

  Future<void> getGasolineApi(
    BuildContext context, {
    String? year,
    DateTime? month,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.getGasolineRepo(
        year: year,
        month: month,
        fromDate: fromDate,
        toDate: toDate,
      );

      if (response.status == 1 && response.data != null) {
        _gasolineList = response.data!;
      } else {
        Utils.toastMessage(response.success ?? "Failed to fetch gasoline data");
      }

      if (kDebugMode) {
        debugPrint("Get gasoline Data API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get gasoline data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  ///Scan file api

  Future<Map<String, dynamic>?> scanFileApi(File? avatarFile) async {
    loading = true;
    notifyListeners();

    try {
      if (avatarFile != null && await avatarFile.exists()) {
        gasolineScanLog(
          'scanFileApi VM: dispatch path=${avatarFile.path} bytes=${await avatarFile.length()}',
        );
      } else {
        gasolineScanLog(
          'scanFileApi VM: file missing or null path=${avatarFile?.path}',
        );
      }

      final response = await gasolineRepository.scanFile(filesPath: avatarFile);

      if (response == null) {
        gasolineScanLog(
          'scanFileApi VM: response null (check [ScanUpload][GasolineBasic] and multipart errors)',
        );
      } else if (response is Map) {
        gasolineScanLog(
          'scanFileApi VM: status=${response["status"]} keys=${response.keys.toList()}',
        );
      } else {
        gasolineScanLog(
          'scanFileApi VM: unexpected type ${response.runtimeType}',
        );
      }

      if (kDebugMode) {
        debugPrint("Scan File API Response: $response");
      }

      return response;
    } catch (e, st) {
      gasolineScanLog('scanFileApi VM ERROR: $e');
      debugPrintStack(stackTrace: st);
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  ///Create Gasoline Api

  Future<void> createGasolineApi(
    BuildContext context,
    Map<String, dynamic> fields,
    File? avatarFile,
  ) async {
    loading = true;
    try {
      debugPrint("Gasoline Creation data: $fields");

      final response = await gasolineRepository.gasolineCreateRepo(
        fields: fields,
        avatarFile: avatarFile,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GasolineListScreen()),
        );
      } else {
        Utils.toastMessage(response["success"]);
      }
      if (kDebugMode) {
        debugPrint("Gasoline Creation API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Gasoline Creation error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Delete Gasoline Api

  Future<bool> deleteGasolineApi(BuildContext context, int id) async {
    loading = true;
    try {
      final response = await gasolineRepository.deleteGasolineRepo(id);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        if (kDebugMode) {
          debugPrint("Delete Gasoline API Response: $response");
        }
        return true;
      } else {
        Utils.toastMessage(response["success"]);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("Delete Gasoline Api error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      return false; // ✅ error case
    } finally {
      loading = false;
    }
  }

  ///Update Gasoline Api

  Future<void> updateGasolineApi({
    required BuildContext context,
    Map<String, dynamic>? fields,
    required int id,
    File? avatarFile,
  }) async {
    loading = true;
    try {
      debugPrint("Gasoline Update data: $fields");

      final response = await gasolineRepository.updateGasolineRepo(
        fields: fields!,
        id: id,
        avatarFile: avatarFile,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GasolineListScreen()),
        );
      } else {
        Utils.toastMessage(response["success"]);
      }
      if (kDebugMode) {
        debugPrint("Gasoline Update API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Gasoline Update error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Forward multiple gasoline

  Future<void> forwardMultipleGasolineFileApi(
    BuildContext context,
    dynamic data,
    String language,
  ) async {
    loading = true;

    try {
      debugPrint("Forward gasoline data: $data");

      final response = await gasolineRepository.forwardMultipleGasolineRepo(
        data: data,
        language: language,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Forward multiple gasoline API Response: $response");
      }
    } catch (e) {
      debugPrint("forward multiple gasoline error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Get Gasoline Report

  Future<void> getGasolineReportApi(
    BuildContext context, {
    String? year,
    DateTime? month,
    DateTime? fromDate,
    DateTime? toDate,
    String? language,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.gasolineReportRepo(
        year: year,
        month: month,
        fromDate: fromDate,
        toDate: toDate,
        language: language,
      );

      if (response.status == 1) {
        _gasolineReportModel = response;
        _monthlySummary = response.data!.monthlySummary!;
        Utils.toastMessage(response.success!);
      } else {
        Utils.toastMessage(response.success!);
      }

      if (kDebugMode) {
        debugPrint("Get gasoline Report API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get gasoline Report error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Report forward api

  Future<void> reportForwardApi(
    BuildContext context,
    dynamic data,
    String language,
  ) async {
    loading = true;

    try {
      debugPrint("Forward gasoline data: $data");

      final response = await gasolineRepository.reportForwardRepo(
        data,
        language, // ✅ forwarded
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Forward gasoline report API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("forward gasoline report error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  /// print report api

  Future<String?> printReportApi({
    String? year,
    String? month,
    String? fromDate,
    String? toDate,
    required String language,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final result = await gasolineRepository.printReportRepo(
        year: year,
        month: month,
        fromDate: fromDate,
        toDate: toDate,
        language: language, // ✅ forwarded
      );

      if (result["status"] == 1 && result["fileBytes"] != null) {
        final bytes = result["fileBytes"] as List<int>;

        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        debugPrint("✅ PDF saved at: $filePath");
        return filePath;
      } else {
        final message =
            (result["success"] is String)
                ? result["success"] as String
                : "Please update your account settings to proceed";

        Utils.toastMessage(message);
        return null;
      }
    } catch (e, stack) {
      debugPrint("❌ printReportApi error: $e $stack");
      Utils.toastMessage("Something went wrong");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<int> getMonthlyReceiptCount() async {
    final now = DateTime.now();

    final monthReceipts =
        _gasolineList.where((r) {
          if (r.date == null) return false; // ✅ skip null dates
          try {
            // ✅ convert string date to DateTime
            final date = DateTime.parse(r.date!);
            return date.month == now.month && date.year == now.year;
          } catch (e) {
            debugPrint("Date parse error for ${r.date}: $e");
            return false;
          }
        }).toList();

    return monthReceipts.length;
  }

  ///Get Transaction report api

  Future<void> getTransactionReportApi(
    BuildContext context, {
    String? language, // 👈 add this
    String? year,
    String? month,
    String? fromDate,
    String? toDate,
    String? sortBy,
    String? sortOrder,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.getTransactionReportRepo(
        language: language,
        // 👈 pass it
        year: year,
        month: month,
        fromDate: fromDate,
        toDate: toDate,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (response.status == 1 && response.data != null) {
        _getTransactionReportModel = response;
      } else {
        Utils.toastMessage(
          response.message ?? "Failed to fetch transaction report data",
        );
      }

      debugPrint("Get transaction report Data API Response: $response");
    } catch (e, stackTrace) {
      debugPrint("Get transaction report data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Get transaction report api

  Future<String?> getTransactionPdfReportApi(String? language) async {
    loading = true;
    notifyListeners();

    try {
      String? yearParam;
      String? monthParam;
      String? fromParam;
      String? toParam;

      // 🔥 Priority 1: Date range
      if (fromTransDate != null && toTransDate != null) {
        fromParam = DateFormat('yyyy-MM-dd').format(fromTransDate!);
        toParam = DateFormat('yyyy-MM-dd').format(toTransDate!);
      }
      // 🔥 Priority 2: Year
      else if (selectedTransYear != null && selectedTransYear!.isNotEmpty) {
        yearParam = selectedTransYear;
      }

      // Optional: Month in YYYY-MM format
      if (selectedTransMonth != null) {
        monthParam = DateFormat('yyyy-MM').format(selectedTransMonth!);
      }

      final result = await gasolineRepository.printTransactionReportRepo(
        year: yearParam,
        month: monthParam,
        fromDate: fromParam,
        toDate: toParam,
        sortBy: sortBy,
        sortOrder: sortOrder,
        language: language,
      );

      if (result["status"] == 1 && result["fileBytes"] != null) {
        final bytes = result["fileBytes"] as List<int>;
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';

        final file = File(filePath);
        await file.writeAsBytes(bytes);

        return filePath;
      }

      Utils.toastMessage(result["success"] ?? "Failed to generate PDF");
      return null;
    } catch (e) {
      Utils.toastMessage("Something went wrong");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  ///forward email report api
  Future<void> forwardEmailReportApi(
    BuildContext context,
    dynamic data,
    String language,
  ) async {
    loading = true;

    try {
      debugPrint("Forward email report data: $data");

      final response = await gasolineRepository.forwardEmailReportRepo(
        data,
        language,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);
      } else {
        Utils.toastMessage(response["message"]);
      }

      if (kDebugMode) {
        debugPrint("Forward email report API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("forward email report error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  /// Start Trip Api

  Future<Map<String, dynamic>?> startTripApi(
    BuildContext context,
    dynamic data,
  ) async {
    trip = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.startTripRepo(data: data);

      debugPrint("🔥 START TRIP RESPONSE: $response");

      final status = response["status"];

      if (status == 1 || status == "1") {
        currentTripId = response["data"]?["trip_id"];

        debugPrint("✅ Saved Trip ID: $currentTripId");

        Utils.toastMessage(response["message"] ?? "Trip started");

        if (currentTripId != null) {
          startLiveTracking(currentTripId!);
        }

        return response;
      } else {
        Utils.toastMessage(response["message"] ?? "Something went wrong");
        return null;
      }
    } catch (e, st) {
      debugPrint("🔥 ERROR: $e\n$st");
      Utils.toastMessage("Error: $e");
      return null;
    } finally {
      trip = false;
      notifyListeners();
    }
  }

  /// Trip Detail Api

  Future<void> activeTripApi(BuildContext context, int userId) async {
    trip = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.activeTripRepo(userId);

      if (response.status == 1) {
        _activeTripModel = response;

        currentTripId = response.data?.tripId;

        debugPrint("🔁 Restored Trip ID: $currentTripId");
      } else {
        debugPrint(response.message!);
      }

      debugPrint("Get trip detail API Response: $response");
    } catch (e, stackTrace) {
      debugPrint("Get trip detail data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      trip = false;
      notifyListeners();
    }
  }

  /// Live location update api

  Future<Map<String, dynamic>?> liveLocationUpdateApi(dynamic data) async {
    trip = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.liveLocationUpdateRepo(
        data: data,
      );

      debugPrint("🔥 Live Location RESPONSE: $response");

      final status = response["status"];

      if (status == 1 || status == "1") {
        Utils.toastMessage(response["message"] ?? "Trip started");

        return response;
      } else {
        Utils.toastMessage(response["message"] ?? "Something went wrong");
        return null;
      }
    } catch (e, st) {
      debugPrint("🔥 ERROR: $e\n$st");
      Utils.toastMessage("Error: $e");
      return null;
    } finally {
      trip = false;
      notifyListeners();
    }
  }

  // Future<void> startLiveTracking(int tripId) async {
  //   if (_isTrackingRunning) return;
  //
  //   _isTrackingRunning = true;
  //   notifyListeners();
  //
  //   await _initLocation();
  //   await _positionStream?.cancel();
  //
  //   DateTime? _lastSentTime;
  //
  //   _positionStream = Geolocator.getPositionStream(
  //     locationSettings: const LocationSettings(
  //       accuracy: LocationAccuracy.high,
  //       distanceFilter: 5, // 🔥 reduced from 10
  //     ),
  //   ).listen((Position position) async {
  //     try {
  //       final now = DateTime.now();
  //
  //       // ✅ 1. TIME-BASED THROTTLING (instead of skipping by distance)
  //       if (_lastSentTime != null &&
  //           now.difference(_lastSentTime!) < const Duration(seconds: 10)) {
  //         return;
  //       }
  //
  //       double speedKmH = (position.speed >= 0 ? position.speed : 0) * 3.6;
  //
  //       // ✅ 2. KEEP LAST POSITION (no aggressive skip)
  //       if (lastPosition != null) {
  //         final distance = Geolocator.distanceBetween(
  //           lastPosition!.latitude,
  //           lastPosition!.longitude,
  //           position.latitude,
  //           position.longitude,
  //         );
  //
  //         // 🔥 Only ignore extreme GPS noise (<2m)
  //         if (distance < 2 && speedKmH < 1) {
  //           debugPrint("⚠️ Minor GPS jitter ignored");
  //         }
  //       }
  //
  //       lastPosition = position;
  //
  //       final rawTime = position.timestamp;
  //
  //       final karachiTime = rawTime.toUtc().add(const Duration(hours: 5));
  //
  //       final formattedTime =
  //           "${karachiTime.year.toString().padLeft(4, '0')}-"
  //           "${karachiTime.month.toString().padLeft(2, '0')}-"
  //           "${karachiTime.day.toString().padLeft(2, '0')}T"
  //           "${karachiTime.hour.toString().padLeft(2, '0')}:"
  //           "${karachiTime.minute.toString().padLeft(2, '0')}:"
  //           "${karachiTime.second.toString().padLeft(2, '0')}";
  //
  //       String currentAddress = "";
  //       try {
  //         List<Placemark> placemarks = await placemarkFromCoordinates(
  //           position.latitude,
  //           position.longitude,
  //         );
  //
  //         if (placemarks.isNotEmpty) {
  //           Placemark place = placemarks.first;
  //           currentAddress =
  //               "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}"
  //                   .replaceAll(RegExp(r'^,\s*|\s*,\s*$'), '')
  //                   .replaceAll(RegExp(r'(,\s*)+'), ', ');
  //         }
  //       } catch (e) {
  //         debugPrint("⚠️ Could not fetch address: $e");
  //         currentAddress = "Address unavailable";
  //       }
  //
  //       final data = {
  //         "trip_id": currentTripId ?? tripId,
  //         "lat": position.latitude,
  //         "lng": position.longitude,
  //         "speed": speedKmH,
  //         "accuracy": position.accuracy,
  //         "timestamp": formattedTime,
  //         "address": currentAddress,
  //       };
  //
  //       final response = await liveLocationUpdateApi(data);
  //
  //       _lastSentTime = now;
  //
  //       if (response != null) {
  //         final responseData = response["data"];
  //
  //         if (responseData["ignored"] == true) {
  //           debugPrint("⚠️ Ignored: ${responseData["reason"]}");
  //         }
  //
  //         // 🔥 AUTO TRIP SWITCH
  //         final int? backendTripId =
  //             responseData["trip_id"] ?? responseData["new_trip_id"];
  //
  //         if (backendTripId != null && backendTripId != currentTripId) {
  //           debugPrint("🔄 Backend auto-started new trip ID: $backendTripId");
  //
  //           currentTripId = backendTripId;
  //
  //           _activeTripModel = ActiveTripModel.fromJson(responseData);
  //
  //           _activeTripModel!.data?.isTracking = true;
  //           _activeTripModel!.data?.trackingMode = "auto";
  //
  //           Utils.toastMessage(
  //             "Previous trip auto-completed. New trip started!",
  //           );
  //         } else {
  //           if (_activeTripModel == null) {
  //             _activeTripModel = ActiveTripModel.fromJson(responseData);
  //
  //             _activeTripModel!.data?.isTracking = true;
  //             _activeTripModel!.data?.trackingMode = "auto";
  //           } else {
  //             _activeTripModel!.data?.currentDistance =
  //                 responseData["current_distance"] ??
  //                     _activeTripModel!.data?.currentDistance;
  //
  //             _activeTripModel!.data?.currentDuration =
  //                 responseData["current_duration"] ??
  //                     _activeTripModel!.data?.currentDuration;
  //
  //             _activeTripModel!.data?.lastLat =
  //                 responseData["last_lat"] ??
  //                     _activeTripModel!.data?.lastLat;
  //
  //             _activeTripModel!.data?.lastLng =
  //                 responseData["last_lng"] ??
  //                     _activeTripModel!.data?.lastLng;
  //
  //             _activeTripModel!.data?.pathPolyline =
  //                 responseData["path_polyline"] ??
  //                     _activeTripModel!.data?.pathPolyline;
  //           }
  //         }
  //
  //         notifyListeners();
  //       }
  //     } catch (e) {
  //       debugPrint("🔥 Stream error: $e");
  //     }
  //   });
  // }

  Future<void> stopLiveTracking() async {
    await _positionStream?.cancel();
    _positionStream = null;

    _isTrackingRunning = false;
  }

  Future<Map<String, dynamic>?> stopTripApi(dynamic data) async {
    trip = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.stopTripEndPoint(data: data);

      debugPrint("🔥 Live Location RESPONSE: $response");

      final status = response["status"];

      if (status == 1 || status == "1") {
        Utils.toastMessage(response["message"] ?? "Trip started");

        return response;
      } else {
        Utils.toastMessage(response["message"] ?? "Something went wrong");
        return response;
      }
    } catch (e, st) {
      debugPrint("🔥 ERROR: $e\n$st");
      Utils.toastMessage("Error: $e");
      return null;
    } finally {
      trip = false;
      notifyListeners();
    }
  }

  /// Create Trip Api

  Future<Map<String, dynamic>?> createTripApi(dynamic data) async {
    trip = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.createTripRepo(data: data);

      debugPrint("Create Trip Type RESPONSE: $response");

      final status = response["status"];

      if (status == 1 || status == "1") {
        Utils.toastMessage(response["message"]);

        return response;
      } else {
        Utils.toastMessage(response["message"] ?? "Something went wrong");
        return null;
      }
    } catch (e, st) {
      debugPrint("🔥 ERROR: $e\n$st");
      Utils.toastMessage("Error: $e");
      return null;
    } finally {
      trip = false;
      notifyListeners();
    }
  }

  /// Start Tracking Api

  Future<Map<String, dynamic>?> startTrackingApi(dynamic data) async {
    trip = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.startTrackingRepo(data: data);

      debugPrint("Start Tracking RESPONSE: $response");

      final status = response["status"];

      if (status == 1 || status == "1") {
        Utils.toastMessage(response["message"]);

        return response;
      } else {
        Utils.toastMessage(response["message"] ?? "Something went wrong");
        return null;
      }
    } catch (e, st) {
      debugPrint("🔥 ERROR: $e\n$st");
      Utils.toastMessage("Error: $e");
      return null;
    } finally {
      trip = false;
      notifyListeners();
    }
  }

  /// Get Trip Detail Api

  Future<void> getTripDetailApi(
    BuildContext context,
    int userId,
    int tripId,
  ) async {
    trip = true;
    notifyListeners();
    try {
      final response = await gasolineRepository.getTripDetailRepo(
        tripId,
        userId,
      );

      if (response.status == 1) {
        _getTripDetailModel = response;
        Utils.toastMessage(response.message!);
      } else {
        Utils.toastMessage(response.message!);
      }

      if (kDebugMode) {
        debugPrint("Get trip detail API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get trip detail data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      trip = false;
      notifyListeners();
    }
  }

  ///Update Tracking api

  // Future<Map<String, dynamic>?> updateTrackingApi(dynamic data) async {
  //   trip = true;
  //   notifyListeners();
  //
  //   try {
  //     final response = await gasolineRepository.updateTrackingRepo(data: data);
  //
  //     debugPrint("Update Tracking RESPONSE: $response");
  //
  //     final status = response["status"];
  //
  //     if (status == 1 || status == "1") {
  //       Utils.toastMessage(response["message"]);
  //       return response;
  //     } else {
  //       Utils.toastMessage(response["message"] ?? "Something went wrong");
  //       return null;
  //     }
  //   } catch (e, st) {
  //     debugPrint("🔥 ERROR: $e\n$st");
  //     Utils.toastMessage("Error: $e");
  //     return null;
  //   } finally {
  //     trip = false;
  //     notifyListeners();
  //   }
  // }

  ///End Trip api

  Future<Map<String, dynamic>?> endTripApi(dynamic data) async {
    endTrip = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.endTripRepo(data: data);

      debugPrint("End Trip RESPONSE: $response");

      final status = response["status"];

      if (status == 1 || status == "1") {
        Utils.toastMessage(response["message"]);
        return response;
      } else {
        Utils.toastMessage(response["message"] ?? "Something went wrong");
        return null;
      }
    } catch (e, st) {
      debugPrint("🔥 ERROR: $e\n$st");
      Utils.toastMessage("Error: $e");
      return null;
    } finally {
      endTrip = false;
      notifyListeners();
    }
  }

  /// Trip report api

  Future<void> tripReportApi({
    String? tabMode,
    String? language,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    _tripReportModel = null;
    trip = true;

    try {
      final response = await gasolineRepository.tripReportRepo(
        tabMode: tabMode,
        language: language,
        fromDate: fromDate,
        toDate: toDate,
      );

      if (response.status == 1) {
        _tripReportModel = response;
        notifyListeners();
        Utils.toastMessage(response.message!);
      } else {
        _tripReportModel = null;
        notifyListeners();
        Utils.toastMessage(response.message!);
      }
    } catch (e) {
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      trip = false;
    }
  }

  /// export to pdf report api

  Future<String?> exportToPdfReportApi({
    String? fromDate,
    String? toDate,
    required String language,
    String? tabMode,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final result = await gasolineRepository.exportToPdfRepo(
        fromDate: fromDate,
        toDate: toDate,
        language: language,
        tabMode: tabMode,
      );

      if (result["status"] == 1 && result["fileBytes"] != null) {
        final bytes = result["fileBytes"] as List<int>;

        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        debugPrint("✅ PDF saved at: $filePath");
        return filePath;
      } else {
        final message =
            (result["success"] is String)
                ? result["success"] as String
                : "Please update your account settings to proceed";

        Utils.toastMessage(message);
        return null;
      }
    } catch (e, stack) {
      debugPrint("❌ exportToPdfReport error: $e $stack");
      Utils.toastMessage("Something went wrong");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Report Trip forward api

  Future<void> reportTripForwardApi(
    BuildContext context,
    dynamic data,
    String language,
  ) async {
    trip = true;
    notifyListeners();

    try {
      debugPrint("Forward gasoline data: $data");

      final response = await gasolineRepository.tripForwardEmailReportRepo(
        data,
        language,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);
      } else {
        Utils.toastMessage(response["message"]);
      }

      if (kDebugMode) {
        debugPrint("Forward gasoline report API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("forward gasoline report error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      trip = false;
      notifyListeners();
    }
  }

  /// print Trip report api

  Future<String?> printTripReportApi({
    String? fromDate,
    String? toDate,
    required String language,
    String? tabMode,
  }) async {
    printTrip = true;
    notifyListeners();

    try {
      final result = await gasolineRepository.printTripReportRepo(
        fromDate: fromDate,
        toDate: toDate,
        language: language,
        tabMode: tabMode,
      );

      if (result["status"] == 1 && result["fileBytes"] != null) {
        final bytes = result["fileBytes"] as List<int>;

        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        debugPrint("✅ PDF saved at: $filePath");
        return filePath;
      } else {
        final message =
            (result["success"] is String)
                ? result["success"] as String
                : "Please update your account settings to proceed";

        Utils.toastMessage(message);
        return null;
      }
    } catch (e, stack) {
      debugPrint("❌ printReportApi error: $e $stack");
      Utils.toastMessage("Something went wrong");
      return null;
    } finally {
      printTrip = false;
      notifyListeners();
    }
  }
}
