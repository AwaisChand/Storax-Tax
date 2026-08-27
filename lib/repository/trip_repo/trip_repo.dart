import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:storatax/models/list_auto_trips_model/list_auto_trips_model.dart';
import 'package:storatax/models/log_book_report_model/log_book_report_model.dart';
import 'package:storatax/models/pending_logbook_submission_model/pending_logout_submission_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import 'package:http/http.dart' as http;
import '../../models/trip_report_model/trip_report_model.dart';
import '../../res/app_url.dart';

class TripRepo {
  BaseApiServices baseApiServices = NetworkApiService();

  /// All Trip Repo

  Future<AllTripsModel> allTripsRepo({
    int? userId,
    String? perPage,
    int? page,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      if (fromDate != null &&
          toDate != null &&
          fromDate.isAfter(toDate)) {
        throw Exception("From date cannot be after To date.");
      }

      String url = AppUrl.allTripsEndPoint;

      final queryParams = <String, String>{
        if (perPage != null && perPage.isNotEmpty)
          'per_page': perPage,

        if (userId != null)
          'user_id': userId.toString(),

        if (page != null)
          'page': page.toString(),

        if (fromDate != null)
          'from_date': DateFormat('yyyy-MM-dd').format(fromDate),

        if (toDate != null)
          'to_date': DateFormat('yyyy-MM-dd').format(toDate),
      };

      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(
          queryParameters: queryParams,
        );

        url = uri.toString();
      }

      debugPrint("Final Request URL: $url");

      final response =
      await baseApiServices.getRequestToken(url);

      if (kDebugMode) {
        debugPrint("API Raw Response: $response");
      }

      return AllTripsModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint("Error in allTripsRepo: $e");
      debugPrint("Stack trace: $stackTrace");
      rethrow;
    }
  }

  /// Reject Trip Repo

  Future<dynamic> rejectTripRepo({required int tripId}) async {
    try {
      final url = Uri.parse(AppUrl.rejectTripEndPoint(tripId));

      final response = await baseApiServices.postApiResponse(url.toString());

      debugPrint("Response: $response");
      debugPrint("API URL: $url");

      return response;
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  /// Approved Trip Repo

  Future<dynamic> approvedTripRepo({required int tripId}) async {
    try {
      final url = Uri.parse(AppUrl.approveTripEndPoint(tripId));

      final response = await baseApiServices.postApiResponse(url.toString());

      debugPrint("Response: $response");
      debugPrint("API URL: $url");

      return response;
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  /// Add Purpose Repo

  Future<dynamic> addPurposeRepo({required dynamic data}) async {
    try {
      final url = Uri.parse(AppUrl.addPurposeEndPoint);

      final response = await baseApiServices.postRequest(url.toString(), data);

      debugPrint("response$response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Update Trip Type Repo

  Future<dynamic> updateTripType({required dynamic data}) async {
    try {
      final url = Uri.parse(AppUrl.updateTripTypeEndPoint);

      final response = await baseApiServices.postRequest(url.toString(), data);

      debugPrint("response$response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Trip Report Repo

  Future<TripReportModel> tripReportRepo({
    String? tabMode,
    String? language,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
        throw Exception("From date cannot be after To date.");
      }

      // Base URL
      String url = AppUrl.tripReportEndPoint;

      final queryParams = <String, String>{
        if (tabMode != null && tabMode.isNotEmpty)
          'filter': tabMode.toLowerCase(),
        if (language != null && language.isNotEmpty) 'lang': language,
        if (fromDate != null)
          'from_date': DateFormat('yyyy-MM-dd').format(fromDate),
        if (toDate != null) 'to_date': DateFormat('yyyy-MM-dd').format(toDate),
      };

      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        url = uri.toString();
      }

      debugPrint("Final Request URL: $url");

      final response = await baseApiServices.getRequestToken(url);

      if (kDebugMode) {
        debugPrint("API Raw Response: $response");
      }

      return TripReportModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint("Error in tripReport repository: $e");
      debugPrint("Stack trace: $stackTrace");
      rethrow;
    }
  }

  /// export to pdf repo

  Future<Map<String, dynamic>> exportToPdfRepo({
    String? fromDate,
    String? toDate,
    required String language,
    String? tabMode,
  }) async {
    final networkApiService = NetworkApiService();
    final token = await networkApiService.getToken();

    if (token == null) {
      return {"status": 0, "success": "Authorization token not found"};
    }

    Map<String, String> queryParams = {'lang': language};
    if (tabMode != null) queryParams['filter'] = tabMode.toLowerCase();
    if (fromDate != null) queryParams['from_date'] = fromDate;
    if (toDate != null) queryParams['to_date'] = toDate;

    final url = Uri.parse(
      AppUrl.tripReportDownloadPdfEndPoint,
    ).replace(queryParameters: queryParams);

    debugPrint("📡 Calling export to pdf report API: $url");

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/pdf, application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final contentType = response.headers['content-type'] ?? '';
    debugPrint("📑 Response status: ${response.statusCode}");
    debugPrint("📑 Response headers: $contentType");

    if (response.statusCode == 200 && contentType.contains("application/pdf")) {
      return {"status": 1, "fileBytes": response.bodyBytes};
    }

    if (contentType.contains("application/json")) {
      try {
        final data = jsonDecode(response.body);
        return data;
      } catch (e) {
        return {"status": 0, "success": "Invalid JSON response"};
      }
    }

    return {
      "status": 0,
      "success": "Unexpected response (status: ${response.statusCode})",
    };
  }

  ///Trip forward email report

  Future<dynamic> tripForwardEmailReportRepo(
    dynamic data,
    String language,
  ) async {
    try {
      final url = Uri.parse(
        AppUrl.forwardTripReportEndPoint,
      ).replace(queryParameters: {'lang': language});

      dynamic response = await baseApiServices.postRequest(
        url.toString(),
        data,
      );

      debugPrint("response$response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///print trip report repo

  Future<Map<String, dynamic>> printTripReportRepo({
    String? fromDate,
    String? toDate,
    required String language,
    String? tabMode,
  }) async {
    final networkApiService = NetworkApiService();
    final token = await networkApiService.getToken();

    if (token == null) {
      return {"status": 0, "success": "Authorization token not found"};
    }

    // Build query params
    Map<String, String> queryParams = {'lang': language};

    if (tabMode != null) queryParams['filter'] = tabMode.toLowerCase();
    if (fromDate != null) queryParams['from_date'] = fromDate;
    if (toDate != null) queryParams['to_date'] = toDate;

    final url = Uri.parse(
      AppUrl.printTripReportEndPoint,
    ).replace(queryParameters: queryParams);

    debugPrint("📡 Calling print report API: $url");

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/pdf, application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final contentType = response.headers['content-type'] ?? '';
    debugPrint("📑 Response status: ${response.statusCode}");
    debugPrint("📑 Response headers: $contentType");

    if (response.statusCode == 200 && contentType.contains("application/pdf")) {
      return {"status": 1, "fileBytes": response.bodyBytes};
    }

    if (contentType.contains("application/json")) {
      try {
        final data = jsonDecode(response.body);
        return data;
      } catch (e) {
        return {"status": 0, "success": "Invalid JSON response"};
      }
    }

    return {
      "status": 0,
      "success": "Unexpected response (status: ${response.statusCode})",
    };
  }

  /// delete trip repo

  Future<dynamic> deleteTripRepo(int id) async {
    try {
      final String urlWithId = "${AppUrl.deleteTripEndPoint}/$id";
      dynamic response = await baseApiServices.deleteApiResponse(urlWithId);
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.gasolineEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// get log book repo

  Future<LogBookReportModel> getLogBookRepo({String? year}) async {
    try {
      // Base URL
      String url = AppUrl.getLogBookEndPoint;

      final queryParams = <String, String>{if (year != null) 'year': year};
      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        url = uri.toString();
      }

      debugPrint("Final URL: $url");

      // Call API
      final response = await baseApiServices.getRequestToken(url);
      debugPrint("API Response: $response");

      return LogBookReportModel.fromJson(response);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  /// create log book report repo

  Future<dynamic> createLogBookReportRepo({required dynamic data}) async {
    try {
      final url = Uri.parse(AppUrl.createLogBookEndPoint);

      final response = await baseApiServices.postRequest(url.toString(), data);

      debugPrint("response$response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// get log book pending sub repo

  Future<PendingLogBookSubmissionsModel> getPendingSubRepo({
    String? lang,
  }) async {
    try {
      // Base URL
      String url = AppUrl.pendingSubmissionEndPoint;

      final queryParams = <String, String>{if (lang != null) 'lang': lang};
      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        url = uri.toString();
      }

      debugPrint("Final URL: $url");

      // Call API
      final response = await baseApiServices.getRequestToken(url);
      debugPrint("API Response: $response");

      return PendingLogBookSubmissionsModel.fromJson(response);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  /// Reject log sub Repo

  Future<dynamic> rejectLogSubRepo({required int subId}) async {
    try {
      final url = Uri.parse(AppUrl.rejectSubEndPoint(subId));

      final response = await baseApiServices.postApiResponse(url.toString());

      debugPrint("Response: $response");
      debugPrint("API URL: $url");

      return response;
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  /// Approved log Repo

  Future<dynamic> approvedLogSubRepo({required int subId, dynamic data}) async {
    try {
      final url = Uri.parse(AppUrl.approveSubEndPoint(subId));

      final response = await baseApiServices.postRequest(url.toString(),data);

      debugPrint("Response: $response");
      debugPrint("API URL: $url");

      return response;
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  /// submit log book repo

  Future<dynamic> submitLogBookRepo({
    required dynamic data,
    String? lang,
  }) async {
    try {
      final queryParams = lang != null ? {'lang': lang} : null;
      final url = Uri.parse(
        AppUrl.submitLogBookEndPoint,
      ).replace(queryParameters: queryParams);

      final response = await baseApiServices.postRequest(url.toString(), data);

      debugPrint("response$response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
