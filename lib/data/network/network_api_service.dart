import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/login_model/login_model.dart';
import '../app_exception.dart';
import 'base_api_service.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';


class NetworkApiService extends BaseApiServices {
  @override
  Future getRequestToken(String url) async {
    dynamic responseJson;
    String? token = await NetworkApiService().getToken();
    debugPrint("Get Token===$token");
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      responseJson = returnResponse(response);
      debugPrint("Raw response body: ${response.body}");
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }
    return responseJson;
  }

  @override
  Future getRequestWithoutToken(String url) async {
    dynamic responseJson;
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      responseJson = returnResponse(response);
      debugPrint("Raw response body: ${response.body}");
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }
    return responseJson;
  }

  @override
  Future<dynamic> postApiResponse(String url) async {
    try {
      String? token = await NetworkApiService().getToken();
      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 30));

      debugPrint("Url === $url");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Do not throw on API-level status == "0"
        final responseJson = jsonDecode(response.body);
        return responseJson;
      } else {
        // ❌ Only throw on HTTP error status
        return returnResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> deleteApiResponse(String url) async {
    try {
      String? token = await NetworkApiService().getToken();
      final response = await http
          .delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 30));

      debugPrint("Url === $url");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Do not throw on API-level status == "0"
        final responseJson = jsonDecode(response.body);
        return responseJson;
      } else {
        // ❌ Only throw on HTTP error status
        return returnResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } catch (e) {
      rethrow;
    }
  }


  @override
  Future<dynamic> postLoginRequest(String url, dynamic data) async {
    try {
      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'FlutterApp/1.0',
        },
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 30));

      debugPrint("login url === $url");
      debugPrint("login raw response === ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);

        if (responseBody["status"].toString() == "1") {
          final loginData = LoginModel.fromJson(responseBody).user;
          final loginToken = LoginModel.fromJson(responseBody);

          final token = loginToken.accessToken;
          // final userId = loginData?.id;
          // final email = loginData?.email;
          // final phone = loginData?.phone;

          // Save token
          await NetworkApiService().setToken(token ?? '');
          debugPrint("login token === $token");

          // Save user info in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", token ?? '');
          // await prefs.setString("userId", userId.toString());
          // await prefs.setString("email", email ?? '');
          // await prefs.setString("phone", phone ?? '');

          debugPrint("User info saved in SharedPreferences");
        }

        return responseBody;
      } else {
        // ❌ HTTP error status
        return returnResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> postRequestWithoutToken(String url, dynamic data) async {
    try {
      final Map<String, String> formData = Map<String, String>.from(data);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: formData,
      ).timeout(const Duration(seconds: 30));

      debugPrint("POST URL: $url");
      debugPrint("POST Body: $formData");
      debugPrint("Response Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      final responseJson = jsonDecode(response.body);

      return responseJson; // ✅ Always return the JSON
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> postRequest(String url, dynamic data) async {
    try {
      String? token = await NetworkApiService().getToken();
      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 30));

      debugPrint("Url === $url");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // ✅ return directly
      } else {
        return returnResponse(response); // ❌ Throws if not 200/201
      }
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> putRequest(String url, dynamic data) async {
    try {
      String? token = await NetworkApiService().getToken();
      final response = await http
          .put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 30));

      debugPrint("Url === $url");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // ✅ return directly
      } else {
        return returnResponse(response); // ❌ Throws if not 200/201
      }
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> multipartPostRequest(
      String url, {
        Map<String, dynamic>? fields,
        Map<String, File>? files,
      }) async {
    try {
      String? token = await getToken();
      final uri = Uri.parse(url);

      final request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Fields
      if (fields != null) {
        fields.forEach((key, value) {
          request.fields[key] = value?.toString() ?? '';
        });
      }

      // Files (images or pdfs)
      if (files != null) {
        for (final entry in files.entries) {
          final name = entry.key;
          final file = entry.value;

          if (!await file.exists()) {
            debugPrint("⚠️ File not found: ${file.path}");
            continue;
          }

          final path = file.path;
          final filename = basename(path);

          // determine content type by extension
          final ext = filename.split('.').last.toLowerCase();
          MediaType contentType;
          if (ext == 'pdf') {
            contentType = MediaType('application', 'pdf');
          } else if (ext == 'png') {
            contentType = MediaType('image', 'png');
          } else if (ext == 'jpg' || ext == 'jpeg') {
            contentType = MediaType('image', 'jpeg');
          } else if (ext == 'gif') {
            contentType = MediaType('image', 'gif');
          } else {
            // fallback
            contentType = MediaType('application', 'octet-stream');
          }

          final multipartFile = await http.MultipartFile.fromPath(
            name,
            path,
            filename: filename,
            contentType: contentType,
          );

          request.files.add(multipartFile);
          debugPrint("Added file field='$name' filename='$filename' contentType='$contentType'");
        }
      }

      // Send
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Multipart POST ${uri.toString()} -> ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed: ${response.statusCode} ${response.body}");
      }
    } catch (e, st) {
      debugPrint("Multipart request error: $e\n$st");
      rethrow;
    }
  }

  @override
  Future<dynamic> multipartPutRequest(
      String url, {
        Map<String, dynamic>? fields,
        Map<String, File>? files,
      }) async {
    try {
      String? token = await getToken();
      final uri = Uri.parse(url);

      final request = http.MultipartRequest('PUT', uri);

      // Headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Fields
      if (fields != null) {
        fields.forEach((key, value) {
          request.fields[key] = value?.toString() ?? '';
        });
      }

      // Files (images or pdfs)
      if (files != null) {
        for (final entry in files.entries) {
          final name = entry.key;
          final file = entry.value;

          if (!await file.exists()) {
            debugPrint("⚠️ File not found: ${file.path}");
            continue;
          }

          final path = file.path;
          final filename = basename(path);

          // determine content type by extension
          final ext = filename.split('.').last.toLowerCase();
          MediaType contentType;
          if (ext == 'pdf') {
            contentType = MediaType('application', 'pdf');
          } else if (ext == 'png') {
            contentType = MediaType('image', 'png');
          } else if (ext == 'jpg' || ext == 'jpeg') {
            contentType = MediaType('image', 'jpeg');
          } else if (ext == 'gif') {
            contentType = MediaType('image', 'gif');
          } else {
            // fallback
            contentType = MediaType('application', 'octet-stream');
          }

          final multipartFile = await http.MultipartFile.fromPath(
            name,
            path,
            filename: filename,
            contentType: contentType,
          );

          request.files.add(multipartFile);
          debugPrint("Added file field='$name' filename='$filename' contentType='$contentType'");
        }
      }

      // Send
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Multipart POST ${uri.toString()} -> ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed: ${response.statusCode} ${response.body}");
      }
    } catch (e, st) {
      debugPrint("Multipart request error: $e\n$st");
      rethrow;
    }
  }

  dynamic returnResponse(http.Response response) {
    final status = response.statusCode;

    print("📥 STATUS CODE: $status");
    print("📥 RESPONSE BODY: ${response.body}");

    dynamic responseJson;

    try {
      responseJson = jsonDecode(response.body);
    } catch (e) {
      print("❌ JSON PARSE ERROR: $e");
      responseJson = response.body;
    }

    switch (status) {

    /// ✅ SUCCESS
      case 200:
      case 201:
        return responseJson;

    /// ⚠️ CLIENT ERRORS (DON'T THROW)
      case 400:
      case 401:
      case 403:
      case 404:
      case 422:
        print("⚠️ API ERROR (Handled): $responseJson");
        return responseJson; // ✅ RETURN, DON'T THROW

    /// ❌ SERVER ERROR
      case 500:
      default:
        print("🔥 SERVER ERROR: $responseJson");
        throw Exception("Server Error: $responseJson");
    }
  }


  // Never _throwMessage(dynamic message, {required String fallback}) {
  //   if (message != null && message.toString().isNotEmpty) {
  //     throw FetchDataException(message.toString());
  //   } else {
  //     throw FetchDataException(fallback);
  //   }
  // }

  Future<bool> setToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('token', value);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    debugPrint("Get Token=== $token");
    return token;
  }


  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

}

/// Optional helper to capitalize first letter
extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return this[0].toUpperCase() + substring(1);
  }
}
