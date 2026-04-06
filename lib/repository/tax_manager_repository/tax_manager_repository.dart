import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:storatax/models/get_category_model/get_category_model.dart';
import 'package:storatax/models/get_file_model/get_file_model.dart';
import 'package:storatax/models/get_personal_info_model/get_personal_info_model.dart';
import 'package:storatax/models/get_previous_info_model/get_previous_info_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';
import 'package:http/http.dart' as http;

class TaxManagerRepository {
  BaseApiServices baseApiServices = NetworkApiService();

  Future<dynamic> createFileRepo({
    required Map<String, dynamic> fields,
    required List<File> files,
  }) async {
    try {
      final Map<String, File> fileMap = {};
      for (int i = 0; i < files.length; i++) {
        fileMap['files[$i]'] = files[i];
      }

      dynamic response = await baseApiServices.multipartPostRequest(
        AppUrl.createFileEndPoint,
        fields: fields,
        files: fileMap,
      );

      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.createFileEndPoint}");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<GetCategoryModel> getCategoryRepo() async {
    try {
      dynamic response = await baseApiServices.getRequestToken(
        AppUrl.getCategoryEndPoint,
      );
      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.getCategoryEndPoint}");

      return GetCategoryModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Get files

  Future<GetFileModel> getFilesRepo({
    String? year,
    String? month,
    String? fromDate,
    String? toDate,
    bool? uploadedByProfessional,
  }) async {
    try {
      // Base URL
      String url = AppUrl.filesEndPoint;

      // Add query parameters if filters are provided
      Map<String, String> queryParams = {};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;
      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;
      if (uploadedByProfessional != null) {
        queryParams['uploaded_by_professional'] =
            uploadedByProfessional.toString();
      }

      // If query parameters exist, build full query string
      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        url = uri.toString();
      }

      debugPrint("Final URL: $url");

      // Call API
      final response = await baseApiServices.getRequestToken(url);
      debugPrint("API Response: $response");

      return GetFileModel.fromJson(response);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  Future<dynamic> updateFileRepo({
    required int id,
    required Map<String, dynamic> fields,
    List<File>? filesPath,
  }) async {
    try {
      final String urlWithId = "${AppUrl.filesEndPoint}/$id";

      Map<String, File>? fileMap;
      if (filesPath != null && filesPath.isNotEmpty) {
        fileMap = {};
        for (int i = 0; i < filesPath.length; i++) {
          fileMap['files[$i]'] = filesPath[i]; // same as create method
        }
      }

      dynamic response = await baseApiServices.multipartPostRequest(
        urlWithId,
        fields: fields,
        files: fileMap,
      );

      debugPrint("Update File API response: $response");
      debugPrint("Update URL: $urlWithId");

      return response;
    } catch (e) {
      debugPrint("Error updating file: $e");
      rethrow;
    }
  }

  Future<dynamic> deleteFileRepo(int id) async {
    try {
      final String urlWithId = "${AppUrl.filesEndPoint}/$id";
      dynamic response = await baseApiServices.deleteApiResponse(urlWithId);
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.filesEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Forward File

  Future<dynamic> forwardFileRepo({
    required dynamic data,
  }) async {
    try {
      final url = Uri.parse(
        AppUrl.forwardFileEndPoint,
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

  ///Forward multiple file

  Future<dynamic> forwardMultipleFileRepo({
    required dynamic data,
  }) async {
    try {
      final url = Uri.parse(
        AppUrl.forwardMultipleFileEndPoint,
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

  ///Scan Tax Manager

  Future<dynamic> scanTaxManagerRepo({File? filesPath}) async {
    try {
      dynamic response = await baseApiServices.multipartPostRequest(
        AppUrl.scanTaxManagerEndPoint,
        files: filesPath != null ? {'file': filesPath} : null,
      );

      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.scanTaxManagerEndPoint}");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Create Personal Info

  Future<dynamic> createPersonalInfoRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.personalInfoEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.personalInfoEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Get Personal Info Repo

  Future<GetPersonalInfoModel> getPersonalInfoRepo() async {
    try {
      String url = AppUrl.personalInfoEndPoint;

      debugPrint("Final URL: $url");

      // Call API
      final response = await baseApiServices.getRequestToken(url);
      debugPrint("API Response: $response");

      return GetPersonalInfoModel.fromJson(response);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  ///Forward personal file

  Future<dynamic> forwardPersonalFileRepo({
    required int id,
    required dynamic data,
  }) async {
    try {
      final url = Uri.parse(
        AppUrl.forwardPersonalFileEndPoint(id),
      );

      final response = await baseApiServices.postRequest(
        url.toString(),
        data,
      );

      debugPrint("Response: $response");
      debugPrint("API URL: $url");

      return response;
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }


  /// delete personal file repo

  Future<dynamic> deletePersonalFileRepo(int id) async {
    try {
      final String urlWithId = "${AppUrl.personalInfoEndPoint}/$id";
      dynamic response = await baseApiServices.deleteApiResponse(urlWithId);
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.personalInfoEndPoint}/$id");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///print personal info

  Future<Map<String, dynamic>> printPersonalInfoRepo({
    required int id,
    required String language,
  }) async {
    final networkApiService = NetworkApiService();
    final token = await networkApiService.getToken();

    if (token == null) {
      return {"status": 0, "success": "Authorization token not found"};
    }

    // ✅ Attach language as query param
    final url = Uri.parse(
      "${AppUrl.personalInfoEndPoint}/$id/print",
    ).replace(
      queryParameters: {
        'language': language,
      },
    );

    debugPrint("📡 Calling print personal info API: $url");

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

    return {
      "status": 0,
      "success": "Unexpected response (status: ${response.statusCode})",
    };
  }

  /// edit personal info

  Future<dynamic> editPersonalInfoRepo(dynamic data, int id) async {
    try {
      final url = "${AppUrl.personalInfoEndPoint}/$id";
      dynamic response = await baseApiServices.putRequest(url, data);
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.personalInfoEndPoint}/$id");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
  ///Get Previous Personal Info Repo

  Future<GetPreviousInfoModel> getPreviousInfoRepo() async {
    try {
      String url = AppUrl.previousInfoEndPoint;

      debugPrint("Final URL: $url");

      final response = await baseApiServices.getRequestToken(url);
      debugPrint("API Response: $response");

      return GetPreviousInfoModel.fromJson(response);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }

  /// delete personal file repo

  Future<dynamic> deleteUploadedFile(int id) async {
    try {
      final String urlWithId = "${AppUrl.uploadFileEndPoint}/$id";
      dynamic response = await baseApiServices.deleteApiResponse(urlWithId);
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.uploadFileEndPoint}/$id");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
