import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:storatax/models/gst_qst_reporting_model/gst_qst_reporting_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';

class QuebecRepository {
  BaseApiServices baseApiServices = NetworkApiService();

  Future<dynamic> createQuebecRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.quebecEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.quebecEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<GetGstQstReportingModel> getGstQstReportingModel({
    String? year,
  }) async {
    try {
      String url = AppUrl.quebecEndPoint;

      Map<String, String> queryParams = {};
      if (year != null) queryParams['year'] = year;

      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        url = uri.toString();
      }

      debugPrint("Final URL: $url");

      final response = await baseApiServices.getRequestToken(url);
      debugPrint("API Response: $response");

      return GetGstQstReportingModel.fromJson(response);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  /// Update Quebec

  Future<dynamic> updateQuebecRepo({dynamic data, required int id}) async {
    try {
      final String url = '${AppUrl.quebecEndPoint}/$id';

      dynamic response = await baseApiServices.putRequest(url, data);
      debugPrint("response$response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Delete Quebec

  Future<dynamic> deleteQuebecRepo(int id) async {
    try {
      final String urlWithId = "${AppUrl.quebecEndPoint}/$id";
      dynamic response = await baseApiServices.deleteApiResponse(urlWithId);
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.quebecEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Generate Gst/Qst Report Repo
  Future<http.Response> generateGstQstReportRepo({
    required int id,
    String language = 'en', // new parameter
  }) async {
    try {
      final networkApiService = NetworkApiService();
      final token = await networkApiService.getToken();

      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final url = Uri.parse("${AppUrl.quebecEndPoint}/$id/generate-pdf?language=$language");

      debugPrint("Generate Gst/Qst Report API: $url");

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

  /// Generate Gross Income Report Repo
  Future<http.Response> generateGrossIncomeReportRepo({
    required int id,
    String language = 'en', // new parameter
  }) async {
    try {
      final networkApiService = NetworkApiService();
      final token = await networkApiService.getToken();

      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final url = Uri.parse("${AppUrl.quebecEndPoint}/gross-income-report/pdf/$id?language=$language");

      debugPrint("Generate Gross Income Report API: $url");

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
        throw Exception("Failed to fetch PDF: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Repo Error: $e");
      rethrow;
    }
  }


  Future<dynamic> scanQuebecRepo({File? filesPath}) async {
    try {
      dynamic response = await baseApiServices.multipartPostRequest(
        AppUrl.quebecScanEndPoint,
        files: filesPath != null ? {'file': filesPath} : null,
      );

      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.quebecScanEndPoint}");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///forward gross income repo

  Future<dynamic> forwardGrossIncomeReportRepo({
    required dynamic data,
  }) async {
    try {
      final url = Uri.parse(
        AppUrl.forwardGrossIncomeEndPoint,
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

  ///forward gst qst repo

  Future<dynamic> forwardGSTQSTReportRepo({
    required dynamic data,
  }) async {
    try {
      final url = Uri.parse(
        AppUrl.forwardGSTQSTEndPoint,
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
}
