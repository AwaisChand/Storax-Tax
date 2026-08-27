import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storatax/models/log_book_report_model/log_book_report_model.dart';
import 'package:storatax/repository/trip_repo/trip_repo.dart';

import '../../models/active_trip_model(auto)/active_trip_model.dart';
import '../../models/get_trip_detail_model/get_trip_detail_model.dart';
import '../../models/list_auto_trips_model/list_auto_trips_model.dart';
import '../../models/pending_logbook_submission_model/pending_logout_submission_model.dart';
import '../../models/trip_report_model/trip_report_model.dart';
import '../../utils/utils.dart';

class TripViewModel extends ChangeNotifier {
  final TripRepo tripRepo = TripRepo();

  bool _allTripsLoading = false;

  bool get allTripsLoading => _allTripsLoading;

  set allTrips(bool trip) {
    _allTripsLoading = trip;
    notifyListeners();
  }

  /// Trip report loading

  bool _tripReportLoading = false;

  bool get tripReportLoading => _tripReportLoading;

  set tripReport(bool report) {
    _tripReportLoading = report;
    notifyListeners();
  }

  /// exportPdfLoading

  bool _exportLoading = false;

  bool get exportLoading => _exportLoading;

  set exportPdf(bool export) {
    _exportLoading = export;
    notifyListeners();
  }

  /// forward trip loading

  bool _forwardTripLoading = false;

  bool get forwardTripLoading => _forwardTripLoading;

  set forwardTrip(bool forward) {
    _forwardTripLoading = forward;
    notifyListeners();
  }

  /// print trip loading

  bool _printTripLoading = false;

  bool get printTripLoading => _printTripLoading;

  set printTrip(bool print) {
    _printTripLoading = print;
    notifyListeners();
  }

  bool _logBookLoading = false;

  bool get logBookLoading => _logBookLoading;

  set logBook(bool log) {
    _logBookLoading = log;
    notifyListeners();
  }

  bool _logBookApproveLoading = false;

  bool get logBookApproveLoading => _logBookApproveLoading;

  set logApprove(bool approve) {
    _logBookApproveLoading = approve;
    notifyListeners();
  }




  bool _logBookRejectLoading = false;

  bool get logBookRejectLoading => _logBookRejectLoading;

  set logReject(bool reject) {
    _logBookApproveLoading = reject;
    notifyListeners();
  }
  List<Trips> _trips = [];
  List<Trips> get trips => _trips;

  TripReportModel? _tripReportModel;
  TripReportModel? get tripReportModel => _tripReportModel;

  LogBookReportModel? _logBookReportModel;
  LogBookReportModel? get logBookReportModel => _logBookReportModel;

  List<PendingSubmission> _pending = [];
  List<PendingSubmission> get pending => _pending;

  int? _activeApproveId;
  int? _activeRejectId;

  int? get activeApproveId => _activeApproveId;
  int? get activeRejectId => _activeRejectId;



  DateTime? fromDate;
  DateTime? toDate;
  int currentTripsPage = 1;
  static const int tripsPerPage = 10;
  bool hasMoreTrips = true;
  bool loadingMoreTrips = false;

  void clearFilters() {
    fromDate = null;
    toDate = null;
    notifyListeners();
  }

  void updateTripStatusLocally(int index, String newStatus) {
    if (index >= 0 && index < _trips.length) {
      _trips[index].approvalStatus = newStatus;
      notifyListeners();
    }
  }

  void removeTripLocally(dynamic tripId) {
    debugPrint("========== REMOVE TRIP LOCALLY ==========");
    debugPrint("Trip ID to remove: $tripId");
    debugPrint("Before remove: ${_trips.length}");

    final index = _trips.indexWhere(
      (trip) => (trip.tripId ?? trip.tripId).toString() == tripId.toString(),
    );

    debugPrint("Found index: $index");

    if (index != -1) {
      _trips.removeAt(index);

      debugPrint("After remove: ${_trips.length}");

      notifyListeners();
    } else {
      debugPrint("❌ Trip not found in _trips");
    }
  }

  /// all trips api


  Future<void> allTripsApi({
    int? userId,
    String? perPage,
    DateTime? fromDate,
    DateTime? toDate,
    bool loadMore = false,
  }) async {

    // ============================================================
    // LOAD MORE
    // ============================================================

    if (loadMore) {

      // Don't make another request if one is already running
      if (loadingMoreTrips) {
        return;
      }

      // Don't request if there are no more trips
      if (!hasMoreTrips) {
        return;
      }

      loadingMoreTrips = true;

    } else {

      // ============================================================
      // FIRST LOAD / REFRESH
      // ============================================================

      allTrips = true;

      currentTripsPage = 1;

      hasMoreTrips = true;

      _trips = [];
    }

    notifyListeners();

    try {

      final response = await tripRepo.allTripsRepo(
        userId: userId,

        // Always request 10
        perPage:
        perPage ?? tripsPerPage.toString(),

        // Page number
        page: currentTripsPage,

        fromDate: fromDate,
        toDate: toDate,
      );

      // ============================================================
      // SUCCESS
      // ============================================================

      if (response.status == 1) {

        final newTrips =
            response.data?.trips ?? [];

        debugPrint(
          "======================================",
        );

        debugPrint(
          "Trips Page: $currentTripsPage",
        );

        debugPrint(
          "New Trips: ${newTrips.length}",
        );

        debugPrint(
          "Existing Trips: ${_trips.length}",
        );

        // ==========================================================
        // FIRST PAGE
        // ==========================================================

        if (!loadMore) {

          _trips = [
            ...newTrips,
          ];

        }

        // ==========================================================
        // LOAD MORE
        // ==========================================================

        else {

          // IMPORTANT:
          // Don't replace existing trips.
          // Add the next page to existing trips.

          _trips.addAll(
            newTrips,
          );
        }

        // ==========================================================
        // CHECK IF MORE DATA EXISTS
        // ==========================================================

        if (newTrips.length < tripsPerPage) {

          // Example:
          // Page returns only 7 trips
          // Therefore there are no more pages.

          hasMoreTrips = false;

          debugPrint(
            "No more trips available.",
          );

        } else {

          // Move to next page

          currentTripsPage++;

          debugPrint(
            "Next page: $currentTripsPage",
          );
        }

        debugPrint(
          "Total trips now: ${_trips.length}",
        );

        debugPrint(
          "======================================",
        );
      }

      // ============================================================
      // API FAILED
      // ============================================================

      else {

        if (!loadMore) {
          _trips = [];
        }

        if (loadMore) {
          // Don't remove existing trips
          // when Load More fails.
          hasMoreTrips = true;
        } else {
          hasMoreTrips = false;
        }

        Utils.toastMessage(
          response.message ??
              "Unable to load trips",
        );
      }

    } catch (e, stackTrace) {

      debugPrint(
        "Get all trips data error: $e",
      );

      debugPrint(
        "$stackTrace",
      );

      // Only clear list on initial request.
      // Don't destroy already loaded trips
      // if Load More fails.

      if (!loadMore) {
        _trips = [];
      }

      Utils.toastMessage(
        "Error: ${e.toString()}",
      );

    } finally {

      // ============================================================
      // STOP LOADING
      // ============================================================

      if (loadMore) {

        loadingMoreTrips = false;

      } else {

        allTrips = false;
      }

      notifyListeners();
    }
  }

  /// Reject trip API
  Future<Map<String, dynamic>?> rejectTripApi(int tripId) async {
    allTrips = true;
    notifyListeners();

    try {
      final response = await tripRepo.rejectTripRepo(tripId: tripId);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(
          response["message"]?.toString() ?? "Trip rejected successfully",
        );
      } else {
        Utils.toastMessage(
          response["message"]?.toString() ?? "Failed to reject trip",
        );
      }

      if (kDebugMode) {
        debugPrint("Reject Trip API Response: $response");
      }

      return Map<String, dynamic>.from(response);
    } catch (e, stackTrace) {
      debugPrint("Reject Trip file error: $e");
      debugPrint("$stackTrace");

      Utils.toastMessage("Error: ${e.toString()}");

      return null;
    } finally {
      allTrips = false;
      notifyListeners();
    }
  }

  /// approved trip api

  Future<Map<String, dynamic>?> approvedTripApi(int tripId) async {
    allTrips = true;
    notifyListeners();

    try {
      final response = await tripRepo.approvedTripRepo(tripId: tripId);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(
          response["message"]?.toString() ?? "Trip approved successfully",
        );
      } else {
        Utils.toastMessage(
          response["message"]?.toString() ?? "Failed to approve trip",
        );
      }

      if (kDebugMode) {
        debugPrint("Approved Trip API Response: $response");
      }

      return Map<String, dynamic>.from(response);
    } catch (e, stackTrace) {
      debugPrint("Approved Trip file error: $e");
      debugPrint("$stackTrace");

      Utils.toastMessage("Error: ${e.toString()}");

      return null;
    } finally {
      allTrips = false;
      notifyListeners();
    }
  }

  Future<void> tripReportApi({
    String? tabMode,
    String? language,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    _tripReportModel = null;
    tripReport = true;

    try {
      final response = await tripRepo.tripReportRepo(
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
      tripReport = false;
    }
  }

  /// Update Trip Type api

  Future<Map<String, dynamic>?> updateTripTypeApi(dynamic data) async {
    allTrips = true;
    notifyListeners();

    try {
      final response = await tripRepo.updateTripType(data: data);

      debugPrint("Add Trip Type RESPONSE: $response");

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
      allTrips = false;
      notifyListeners();
    }
  }

  /// Add Purpose api

  Future<Map<String, dynamic>?> addPurposeApi(dynamic data) async {
    allTrips = true;
    notifyListeners();

    try {
      final response = await tripRepo.addPurposeRepo(data: data);

      debugPrint("Add Purpose RESPONSE: $response");

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
      allTrips = false;
      notifyListeners();
    }
  }

  /// export to pdf report api

  Future<String?> exportToPdfReportApi({
    String? fromDate,
    String? toDate,
    required String language,
    String? tabMode,
  }) async {
    exportPdf = true;
    notifyListeners();

    try {
      final result = await tripRepo.exportToPdfRepo(
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
      exportPdf = false;
      notifyListeners();
    }
  }

  /// Report Trip forward api

  Future<void> reportTripForwardApi(
    BuildContext context,
    dynamic data,
    String language,
  ) async {
    forwardTrip = true;
    notifyListeners();

    try {
      debugPrint("Forward gasoline data: $data");

      final response = await tripRepo.tripForwardEmailReportRepo(
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
      forwardTrip = false;
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
      final result = await tripRepo.printTripReportRepo(
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

  ///delete trip api

  Future<bool> deleteTripApi(int id) async {
    allTrips = true;
    try {
      final response = await tripRepo.deleteTripRepo(id);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);
        if (kDebugMode) {
          debugPrint("Delete trip API Response: $response");
        }
        return true;
      } else {
        Utils.toastMessage(response["message"]);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("Delete trip Api error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      return false;
    } finally {
      allTrips = false;
    }
  }

  /// get log book api

  Future<void> getLogBookApi(BuildContext context, {String? year}) async {
    logBook = true;
    notifyListeners();

    try {
      final response = await tripRepo.getLogBookRepo(year: year);

      if (response.status == 1 && response.data != null) {
        _logBookReportModel = response;
        Utils.toastMessage(response.message ?? "");
      } else {
        Utils.toastMessage(response.message ?? "Failed to fetch log book data");
      }

      if (kDebugMode) {
        debugPrint("Get log book Data API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get log book data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      logBook = false;
      notifyListeners();
    }
  }

  /// create log book  api

  Future<Map<String, dynamic>?> createLogBookApi(dynamic data) async {
    logBook = true;
    notifyListeners();

    try {
      final response = await tripRepo.createLogBookReportRepo(data: data);

      debugPrint("Create Log Book RESPONSE: $response");

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
      logBook = false;
      notifyListeners();
    }
  }

  /// get log book pending submission api

  Future<void> getPendingSubmissionApi(
    BuildContext context, {
    String? lang,
  }) async {
    logBook = true;
    notifyListeners();

    try {
      final response = await tripRepo.getPendingSubRepo(lang: lang);

      if (response.status == 1 && response.data != null) {
        _pending = response.data!;
        // Utils.toastMessage(response.message ?? "");
      } else {
        Utils.toastMessage(response.message ?? "Failed to fetch log book data");
      }

      if (kDebugMode) {
        debugPrint("Get pending sub Data API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get pending sub data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      logBook = false;
      notifyListeners();
    }
  }

  /// Reject log sub API
  Future<Map<String, dynamic>?> rejectLogSubApi(int subId) async {
    _activeRejectId = subId;
    notifyListeners();

    try {
      final response = await tripRepo.rejectLogSubRepo(subId: subId);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(
          response["message"]?.toString() ?? "Trip rejected successfully",
        );
      } else {
        Utils.toastMessage(
          response["message"]?.toString() ?? "Failed to reject trip",
        );
      }

      if (kDebugMode) {
        debugPrint("Reject Trip API Response: $response");
      }

      return Map<String, dynamic>.from(response);
    } catch (e, stackTrace) {
      debugPrint("Reject Trip file error: $e");
      debugPrint("$stackTrace");

      Utils.toastMessage("Error: ${e.toString()}");

      return null;
    } finally {
      _activeRejectId = null;
      notifyListeners();
    }
  }

  /// Approved log sub API
  Future<Map<String, dynamic>?> approveLogSubApi(int subId, dynamic data) async {
    _activeApproveId = subId;
    notifyListeners();

    try {
      final response = await tripRepo.approvedLogSubRepo(subId: subId,data: data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]?.toString() ?? "");
      } else {
        Utils.toastMessage(response["message"]?.toString() ?? "");
      }

      if (kDebugMode) {
        debugPrint("Approved Trip API Response: $response");
      }

      return Map<String, dynamic>.from(response);
    } catch (e, stackTrace) {
      debugPrint("Approved sub file error: $e");
      debugPrint("$stackTrace");

      Utils.toastMessage("Error: ${e.toString()}");

      return null;
    } finally {
      _activeApproveId = null;
      notifyListeners();
    }
  }

  /// Submit log book api

  Future<Map<String, dynamic>?> submitLogBookApi(
    dynamic data,
    String lang,
  ) async {
    logBook = true;
    notifyListeners();

    try {
      final response = await tripRepo.submitLogBookRepo(data: data, lang: lang);

      debugPrint("Submit Log Book RESPONSE: $response");

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
      logBook = true;
      notifyListeners();
    }
  }
}
