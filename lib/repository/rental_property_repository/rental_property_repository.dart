import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:storatax/models/get_rental_property_plan_model/get_rental_property_plan_model.dart';
import 'package:storatax/models/rental_property_models/account_setting_model/account_setting_model.dart';
import 'package:storatax/models/rental_property_models/database_entry_model/database_entry_model.dart';
import 'package:storatax/models/rental_property_models/get_all_regular_entries_model/get_all_regular_entries_model.dart';
import 'package:storatax/models/rental_property_models/get_income_types_model/get_income_types_model.dart';
import 'package:storatax/models/rental_property_models/property_owner_model/property_owner_model.dart';
import 'package:http/http.dart' as http;
import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../models/get_reports_model/get_reports_model.dart';
import '../../res/app_url.dart';

class RentalPropertyRepository {
  BaseApiServices baseApiServices = NetworkApiService();

  ///Get RentalProperty Plan Repo

  Future<GetRentalPropertyPlanModel> getRentalPropertyPlanRepo() async {
    try {
      dynamic response = await baseApiServices.getRequestToken(
        AppUrl.getRentalPropertyPlanEndPoint,
      );
      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.getRentalPropertyPlanEndPoint}");

      return GetRentalPropertyPlanModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Rental Account setting repo

  Future<AccountSettingModel> rentalAccountAddressRepo({
    required int planId,
  }) async {
    try {
      final uri = Uri.parse(
        AppUrl.rentalPropertyAccountSettingEndPoint,
      ).replace(queryParameters: {'planId': planId.toString()});

      debugPrint("Raw API request URL: $uri");

      final dynamic response = await baseApiServices.getRequestToken(
        uri.toString(),
      );

      debugPrint("Raw API response JSON: $response");

      return AccountSettingModel.fromJson(response);
    } catch (e, st) {
      debugPrint("Error in rentalAccountAddressRepo: $e");
      debugPrint("$st");
      rethrow;
    }
  }

  ///Create or Update Account Setting Repo

  Future<dynamic> createOrUpdateAccountSettingRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.rentalPropertyAccountSettingEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.rentalPropertyAccountSettingEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Property Owner Repo

  Future<PropertyOwnerModel> propertyOwnerRepo({required int planId}) async {
    try {
      final uri = Uri.parse(
        AppUrl.propertyOwnerEndPoint,
      ).replace(queryParameters: {'planId': planId.toString()});

      debugPrint("Raw API request URL: $uri");

      final dynamic response = await baseApiServices.getRequestToken(
        uri.toString(),
      );

      debugPrint("Raw API response JSON: $response");

      return PropertyOwnerModel.fromJson(response);
    } catch (e, st) {
      debugPrint("Error in propertyOwner: $e");
      debugPrint("$st");
      rethrow;
    }
  }

  ///Create or Update property Owner

  Future<dynamic> createOrUpdatePropertyOwnerRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.propertyOwnerEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.propertyOwnerEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Get Income Types Repo

  Future<GetIncomeTypesModel> getIncomeTypesRepo({required int planId}) async {
    try {
      final uri = Uri.parse(
        AppUrl.incomeTypesEndPoint,
      ).replace(queryParameters: {'planId': planId.toString()});

      debugPrint("Raw API request URL: $uri");

      final dynamic response = await baseApiServices.getRequestToken(
        uri.toString(),
      );

      debugPrint("Raw API response JSON: $response");

      return GetIncomeTypesModel.fromJson(response);
    } catch (e, st) {
      debugPrint("Error in incomeTypes: $e");
      debugPrint("$st");
      rethrow;
    }
  }

  ///Create Income Types

  Future<dynamic> createIncomeTypeRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.incomeTypesEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.incomeTypesEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Update Rental Income Type

  Future<dynamic> updateRentalIncomeRepo({
    dynamic data,
    required int id,
  }) async {
    try {
      final String url = '${AppUrl.incomeTypesEndPoint}/$id';

      dynamic response = await baseApiServices.putRequest(url, data);
      debugPrint("response$response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///delete income types repo

  Future<dynamic> deleteIncomeTypesRepo(int id) async {
    try {
      final String urlWithId = "${AppUrl.incomeTypesEndPoint}/$id";
      dynamic response = await baseApiServices.deleteApiResponse(urlWithId);
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.incomeTypesEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///All Regular Entries Repo
  Future<GetAllRegularEntriesModel> getAllRegularEntriesRepo({
    required int planId,
    String? year,
    DateTime? fromDate,
    DateTime? toDate,
    DateTime? month,
    int? incomeTypeId,
    String? expenseType,
  }) async {
    try {
      // 1️⃣ Validate dates
      if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
        throw Exception("From date cannot be after To date.");
      }

      // 2️⃣ Build query parameters safely
      final queryParams = <String, String>{
        'planId': planId.toString(),
        if (year != null) 'year': year,
        if (fromDate != null) 'from_date': DateFormat('yyyy-MM-dd').format(fromDate),
        if (toDate != null) 'to_date': DateFormat('yyyy-MM-dd').format(toDate),
        if (month != null) 'month': DateFormat('MMMM').format(month),
        if (incomeTypeId != null) 'income_type_id': incomeTypeId.toString(),
        if (expenseType != null) 'expense_type': expenseType,
      };

      final uri = Uri.parse(AppUrl.entriesEndPoint).replace(queryParameters: queryParams);

      debugPrint("Raw API request URL: $uri");

      // 3️⃣ Call API
      final dynamic response = await baseApiServices.getRequestToken(uri.toString());

      debugPrint("Raw API response JSON: $response");

      // 4️⃣ Parse safely
      return GetAllRegularEntriesModel.fromJson(response);
    } catch (e, st) {
      debugPrint("Error in allRegularEntries: $e");
      debugPrint("$st");
      return GetAllRegularEntriesModel(
        status: 0,
        success: e.toString(), // human-readable error
        data: null,
      );
    }
  }




  ///Create Entries

  Future<dynamic> createEntriesRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.entriesEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.entriesEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> createEntryProofRepo({
    required Map<String, dynamic> fields,
    File? avatarFile,
  }) async {
    try {
      dynamic response = await baseApiServices.multipartPostRequest(
        AppUrl.entriesEndPoint,
        fields: fields,
        files: avatarFile != null ? {'proof': avatarFile} : null,
      );

      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.entriesEndPoint}");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Forward Multiple Entries

  Future<dynamic> forwardMultipleEntriesRepo({
    required dynamic data,
    required String language,
  }) async {
    try {
      final url = Uri.parse(
        AppUrl.forwardMultipleEntriesEndPoint,
      ).replace(
        queryParameters: {
          'language': language,
        },
      );

      final response = await baseApiServices.postRequest(
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

  ///Forward Report

  Future<dynamic> forwardReportEndPointRepo(
      dynamic data,
      String? language,
      ) async {
    try {
      final url =
          "${AppUrl.forwardReportEndPoint}?language=${language ?? 'en'}";

      dynamic response = await baseApiServices.postRequest(
        url,
        data,
      );

      debugPrint("Response: $response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///delete entries repo

  Future<dynamic> deleteEntriesRepo(int id) async {
    try {
      final String urlWithId = "${AppUrl.entriesEndPoint}/$id";
      dynamic response = await baseApiServices.deleteApiResponse(urlWithId);
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.entriesEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Update Entry

  Future<dynamic> updateEntryRepo({dynamic data, required int id}) async {
    try {
      final String url = '${AppUrl.entriesEndPoint}/$id';

      dynamic response = await baseApiServices.putRequest(url, data);
      debugPrint("response$response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> updateEntryProofRepo({
    required Map<String, dynamic> fields,
    required int id,
    File? avatarFile,
  }) async {
    try {
      dynamic response = await baseApiServices.multipartPostRequest(
        "${AppUrl.expenseUpdateEndPoint}/$id",
        fields: fields,
        files: avatarFile != null ? {'proof': avatarFile} : null,
      );

      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.entriesEndPoint}/$id");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Database Entry Repo

  Future<DatabaseEntriesModel> databaseEntryRepo({
    required int planId,
    String? year,
    DateTime? month,
    DateTime? fromDate,
    DateTime? toDate,
    String? language,
  }) async {
    try {
      // Base URL
      String url = AppUrl.databaseEntriesEndPoint;

      // Prepare query parameters
      // Map<String, String> queryParams = {'planId': planId.toString()};

      // 1️⃣ Validate dates
      if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
        throw Exception("From date cannot be after To date.");
      }

      // 2️⃣ Build query parameters safely
      final queryParams = <String, String>{
        'planId': planId.toString(),
        if (year != null) 'year': year,
        if (fromDate != null) 'from_date': DateFormat('yyyy-MM-dd').format(fromDate),
        if (toDate != null) 'to_date': DateFormat('yyyy-MM-dd').format(toDate),
        if (month != null) 'month': DateFormat('MMMM').format(month),
        if(language !=null) 'language': language
      };


      // Build full URL with query parameters if present
      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        url = uri.toString();
      }

      debugPrint("Final Database Entries URL: $url");

      // API Call
      final response = await baseApiServices.getRequestToken(url);
      debugPrint("Database Entries API Response: $response");

      return DatabaseEntriesModel.fromJson(response);
    } catch (e, st) {
      debugPrint("Database Entry Error: $e");
      debugPrint("$st");
      rethrow;
    }
  }

  /// Report Schedule Repo
  Future<Map<String, dynamic>> reportScheduleRepo({
    required int clientPlansId,
    required int year,
    String language = 'en', // new parameter
  }) async {
    final networkApiService = NetworkApiService();
    final token = await networkApiService.getToken();

    if (token == null) {
      return {"status": 0, "success": "Authorization token not found"};
    }

    final url = Uri.parse(
      "${AppUrl.reportScheduleEndPoint}?client_plans_id=$clientPlansId&year=$year&language=$language",
    );

    debugPrint("📡 Calling Report Schedule API: $url");

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/pdf, application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final contentType = response.headers['content-type'] ?? '';
    debugPrint("📑 Response status: ${response.statusCode}");
    debugPrint("📑 Response headers: $contentType");

    // ✅ If PDF is received
    if (response.statusCode == 200 && contentType.contains("application/pdf")) {
      return {
        "status": 1,
        "file": response, // keep the http.Response here
      };
    }

    // ✅ If JSON error comes
    if (contentType.contains("application/json")) {
      try {
        final data = jsonDecode(response.body);
        return data; // directly return {status, success, ...}
      } catch (_) {
        return {"status": 0, "success": "Invalid JSON response"};
      }
    }

    // ❌ Unexpected fallback
    return {
      "status": 0,
      "success": "Unexpected response (status: ${response.statusCode})",
    };
  }

  Future<http.Response> printAllRegularEntriesRepo({
    required int clientPlansId,
    required int year,
    required String language,
  }) async {
    try {
      final networkApiService = NetworkApiService();
      final token = await networkApiService.getToken();

      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final url = Uri.parse(
        "${AppUrl.allRegularEntriesPrintEndPoint}"
            "?year=$year"
            "&planId=$clientPlansId"
            "&language=$language",
      );

      debugPrint("Generate Report API: $url");

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/pdf',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 302) {
        final redirectedUrl = response.headers['location'];
        debugPrint("⚠️ Got redirected to: $redirectedUrl");
        throw Exception(
          "Failed to fetch PDF: 302 Redirect. Possibly due to expired or missing token.",
        );
      } else {
        debugPrint("❌ Error Body: ${response.body}");
        throw Exception("Failed to fetch PDF: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Repo Error: $e");
      rethrow;
    }
  }


  Future<Map<String, dynamic>> printT776Repo({
    required int clientPlansId,
    required int year,
    String language = 'en',
  }) async {
    final networkApiService = NetworkApiService();
    final token = await networkApiService.getToken();

    if (token == null) return {"status": 0, "success": "Authorization token not found"};

    final url = Uri.parse(
        "${AppUrl.printT776EndPoint}?client_plans_id=$clientPlansId&year=$year&language=$language");

    debugPrint("📡 Calling Report T776 API: $url");

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/pdf, application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final contentType = response.headers['content-type'] ?? '';
    if (response.statusCode == 200 && contentType.contains("application/pdf")) {
      return {"status": 1, "file": response};
    }

    if (contentType.contains("application/json")) {
      try {
        final data = jsonDecode(response.body);
        return data;
      } catch (_) {
        return {"status": 0, "success": "Invalid JSON response"};
      }
    }

    return {"status": 0, "success": "Unexpected response (status: ${response.statusCode})"};
  }

  Future<Map<String, dynamic>> printF1040Repo({
    required int clientPlansId,
    required int year,
    String language = 'en',
  }) async {
    final networkApiService = NetworkApiService();
    final token = await networkApiService.getToken();

    if (token == null) return {"status": 0, "success": "Authorization token not found"};

    final url = Uri.parse(
        "${AppUrl.printF1040EndPoint}?client_plans_id=$clientPlansId&year=$year&language=$language");

    debugPrint("📡 Calling Report F1040 API: $url");

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/pdf, application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final contentType = response.headers['content-type'] ?? '';
    if (response.statusCode == 200 && contentType.contains("application/pdf")) {
      return {"status": 1, "file": response};
    }

    if (contentType.contains("application/json")) {
      try {
        final data = jsonDecode(response.body);
        return data;
      } catch (_) {
        return {"status": 0, "success": "Invalid JSON response"};
      }
    }

    return {"status": 0, "success": "Unexpected response (status: ${response.statusCode})"};
  }

}
