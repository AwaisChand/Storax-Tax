import 'dart:io';

abstract class BaseApiServices {
  Future<dynamic> getRequestToken(String url);
  Future<dynamic> getRequestWithoutToken(String url);

  Future<dynamic> postLoginRequest(String url, dynamic data);
  Future<dynamic> postApiResponse(String url);
  Future<dynamic> postRequestWithoutToken(String url, dynamic data);
  Future<dynamic> postRequest(String url, dynamic data);
  Future<dynamic> putRequest(String url, dynamic data);
  Future<dynamic> deleteApiResponse(String url);
  Future<dynamic> multipartPostRequest(
      String url, {
        Map<String, dynamic>? fields,
        Map<String, File>? files,
      });
  Future<dynamic> multipartPutRequest(
      String url, {
        Map<String, dynamic>? fields,
        Map<String, File>? files,
      });




}
