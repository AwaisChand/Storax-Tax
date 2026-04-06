import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:storatax/models/get_gasoline_list_model/get_gasoline_list_model.dart';
import 'package:storatax/models/get_gasoline_report_model/get_gasoline_report_model.dart';
import 'package:storatax/models/get_transaction_report_model/get_transaction_report_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';
import 'package:http/http.dart' as http;

class GasolineRepository {
  BaseApiServices baseApiServices = NetworkApiService();

  Future<GetGasolineListModel> getGasolineRepo({
    String? year,
    DateTime? month,
    DateTime? fromDate,
    DateTime? toDate,
    // bool? uploadedByProfessional,
  }) async {
    try {
      // 1️⃣ Validate dates
      if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
        throw Exception("From date cannot be after To date.");
      }
      // Base URL
      String url = AppUrl.gasolineEndPoint;

      // Add query parameters if filters are provided
      final queryParams = <String, String>{
        if (year != null) 'year': year,
    if (fromDate != null) 'from_date': DateFormat('yyyy-MM-dd').format(fromDate),
    if (toDate != null) 'to_date': DateFormat('yyyy-MM-dd').format(toDate),
    if (month != null) 'month': DateFormat('yyyy-MM').format(month),
    // if (uploadedByProfessional != null) {
    //   queryParams['uploaded_by_professional'] =
    //       uploadedByProfessional.toString();
    // }
    };
      // If query parameters exist, build full query string
      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        url = uri.toString();
      }

      debugPrint("Final URL: $url");

      // Call API
      final response = await baseApiServices.getRequestToken(url);
      debugPrint("API Response: $response");

      return GetGasolineListModel.fromJson(response);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  ///Scan file

  Future<dynamic> scanFile({File? filesPath}) async {
    try {
      dynamic response = await baseApiServices.multipartPostRequest(
        AppUrl.scanFileEndPoint,
        files: filesPath != null ? {'image': filesPath} : null,
      );

      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.scanFileEndPoint}");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Gasoline create repo

  Future<dynamic> gasolineCreateRepo({
    required Map<String, dynamic> fields,
    File? avatarFile,
  }) async {
    try {
      dynamic response = await baseApiServices.multipartPostRequest(
        AppUrl.gasolineEndPoint,
        fields: fields,
        files: avatarFile != null ? {'image': avatarFile} : null,
      );

      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.gasolineEndPoint}");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///delete Gasoline

  Future<dynamic> deleteGasolineRepo(int id) async {
    try {
      final String urlWithId = "${AppUrl.gasolineEndPoint}/$id";
      dynamic response = await baseApiServices.deleteApiResponse(urlWithId);
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.gasolineEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Update Gasoline

  Future<dynamic> updateGasolineRepo({
    required Map<String, dynamic> fields,
    File? avatarFile,
    required int id,
  }) async {
    try {
      final String url = '${AppUrl.gasolineEndPoint}/$id';

      dynamic response = await baseApiServices.multipartPostRequest(
        url,
        fields: fields,
        files: avatarFile != null ? {'image': avatarFile} : null,
      );
      debugPrint("response$response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Forward Multiple Gasoline

  Future<dynamic> forwardMultipleGasolineRepo({
    required dynamic data,
    required String language,
  }) async {
    try {
      final url = Uri.parse(
        AppUrl.multipleForwardGasolineEndPoint,
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

  ///Gasoline Report Repo

  Future<GetGasolineReportModel> gasolineReportRepo({
    String? year,
    DateTime? month,
    DateTime? fromDate,
    DateTime? toDate,
    String? language
  }) async {
    try {
      // 1️⃣ Validate dates
      if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
        throw Exception("From date cannot be after To date.");
      }
      // Base URL
      String url = AppUrl.gasolineReportEndPoint;

      // Add query parameters if filters are provided
      final queryParams = <String, String>{
        if (year != null) 'year': year,
        if (fromDate != null) 'from_date': DateFormat('yyyy-MM-dd').format(fromDate),
        if (toDate != null) 'to_date': DateFormat('yyyy-MM-dd').format(toDate),
        if (month != null) 'month': DateFormat('yyyy-MM').format(month),
        if(language != null) 'language': language
        // if (uploadedByProfessional != null) {
        //   queryParams['uploaded_by_professional'] =
        //       uploadedByProfessional.toString();
        // }
      };
      // if (uploadedByProfessional != null) {
      //   queryParams['uploaded_by_professional'] =
      //       uploadedByProfessional.toString();
      // }

      // If query parameters exist, build full query string
      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        url = uri.toString();
      }

      debugPrint("Final URL: $url");

      // Call API
      final response = await baseApiServices.getRequestToken(url);
      debugPrint("API Response: $response");

      return GetGasolineReportModel.fromJson(response);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  ///Report forward gasoline

  Future<dynamic> reportForwardRepo(
      dynamic data,
      String language,
      ) async {
    try {
      // ✅ Append language as query param
      final url = Uri.parse(
        AppUrl.gasolineReportForwardEndPoint,
      ).replace(
        queryParameters: {
          'language': language,
        },
      );

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

  Future<Map<String, dynamic>> printReportRepo({
    String? year,
    String? month,
    String? fromDate,
    String? toDate,
    required String language,
  }) async {
    final networkApiService = NetworkApiService();
    final token = await networkApiService.getToken();

    if (token == null) {
      return {"status": 0, "success": "Authorization token not found"};
    }

    // Build query params
    Map<String, String> queryParams = {
      'language': language, // ✅ added
    };

    if (year != null) queryParams['year'] = year;
    if (month != null) queryParams['month'] = month;
    if (fromDate != null) queryParams['from_date'] = fromDate;
    if (toDate != null) queryParams['to_date'] = toDate;

    // Attach query params to URL
    final url = Uri.parse(AppUrl.printReportEndPoint).replace(
      queryParameters: queryParams,
    );

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



  ///Get Transaction Report Repo

  Future<GetTransactionReportModel> getTransactionReportRepo({
    String? year,
    String? month,
    String? fromDate,
    String? toDate,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // Base URL
      String url = AppUrl.getTransactionReportReportEndPoint;

      // Add query parameters if filters are provided
      Map<String, String> queryParams = {};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;
      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      // if (uploadedByProfessional != null) {
      //   queryParams['uploaded_by_professional'] =
      //       uploadedByProfessional.toString();
      // }

      // If query parameters exist, build full query string
      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        url = uri.toString();
      }

      debugPrint("Final URL: $url");

      // Call API
      final response = await baseApiServices.getRequestToken(url);
      debugPrint("API Response: $response");

      return GetTransactionReportModel.fromJson(response);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> printTransactionReportRepo({
    String? year,
    String? month,
    String? fromDate,
    String? toDate,
    String? sortBy,
    String? sortOrder,
    String? language,
  }) async {
    final networkApiService = NetworkApiService();
    final token = await networkApiService.getToken();

    if (token == null) {
      return {"status": 0, "success": "Authorization token not found"};
    }

    Map<String, String> queryParams = {};
    if (year != null) queryParams['year'] = year;
    if (month != null) queryParams['month'] = month;
    if (fromDate != null) queryParams['from_date'] = fromDate;
    if (toDate != null) queryParams['to_date'] = toDate;
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (sortOrder != null) queryParams['sort_order'] = sortOrder;
    if (language != null) queryParams['language'] = language;


    // ✅ Attach filters to URL
    final uri = Uri.parse(AppUrl.printTransactionReportEndPoint)
        .replace(queryParameters: queryParams);

    debugPrint("📡 Print report URL: $uri");

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/pdf, application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final contentType = response.headers['content-type'] ?? '';

    if (response.statusCode == 200 &&
        contentType.contains("application/pdf")) {
      return {
        "status": 1,
        "fileBytes": response.bodyBytes,
      };
    }

    if (contentType.contains("application/json")) {
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {"status": 0, "success": "Invalid JSON response"};
      }
    }

    return {
      "status": 0,
      "success": "Unexpected response (${response.statusCode})",
    };
  }



  ///forward email report


  Future<dynamic> forwardEmailReportRepo(
      dynamic data,
      String language,
      ) async {
    try {
      final url = Uri.parse(
        AppUrl.forwardEmailReportEndPoint,
      ).replace(
        queryParameters: {
          'language': language,
        },
      );

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
}
