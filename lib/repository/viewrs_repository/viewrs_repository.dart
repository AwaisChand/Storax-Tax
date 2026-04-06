import 'package:flutter/foundation.dart';
import 'package:storatax/models/viewrs_model/get_all_viewrs_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';

class ViewrsRepository{
  BaseApiServices baseApiServices = NetworkApiService();

  ///Get All Viewrs Repository

  Future<GetAllViewrsModel> getAllViewrsRepo() async {
    try {
      dynamic response = await baseApiServices.getRequestToken(
        AppUrl.viewrsEndPoint,
      );
      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.viewrsEndPoint}");

      return GetAllViewrsModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }



  ///Create Viewrs Repo

  Future<dynamic> createViewrsRep(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.viewrsEndPoint,
        data,
      );

      debugPrint("Response: $response");
      debugPrint("Api url: ${AppUrl.viewrsEndPoint}");

      if (response is Map && response["status"] == 0 && response["errors"] != null) {
        String errorMessage = "";
        Map<String, dynamic> errors = response["errors"];
        errors.forEach((key, value) {
          if (value is List) {
            errorMessage += "${value.join("\n")}\n";
          } else {
            errorMessage += "$value\n";
          }
        });

        throw Exception(errorMessage.trim());
      }

      return response;
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }



  Future<dynamic> updateViewrsRepo({dynamic data, required int id}) async {
    try {
      final String url = '${AppUrl.viewrsEndPoint}/$id';

      dynamic response = await baseApiServices.putRequest(url, data);
      debugPrint("response$response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }



  Future<dynamic> deleteViewrsRepo(int id) async {
    try {
      final String urlWithId = "${AppUrl.viewrsEndPoint}/$id";
      dynamic response = await baseApiServices.deleteApiResponse(urlWithId);
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.viewrsEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

}