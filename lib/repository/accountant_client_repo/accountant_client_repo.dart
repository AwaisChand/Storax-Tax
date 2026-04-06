

import 'package:flutter/foundation.dart';
import 'package:storatax/models/get_accountants_model/get_accountants_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';

class AccountantClientRepo {
  BaseApiServices baseApiServices = NetworkApiService();



  ///Get Accountant Repo
  Future<GetAccountantsModel> getAccountantRepo({
    required int page,
    int perPage = 10,
    String? search,
  }) async {
    try {
      String url = "${AppUrl.getAccountantsEndPoint}?page=$page&per_page=$perPage";

      // ✅ Append search query if provided
      if (search != null && search.isNotEmpty) {
        url += "&search=${Uri.encodeComponent(search)}";
      }

      debugPrint("API URL: $url");

      final response = await baseApiServices.getRequestToken(url);

      debugPrint("Raw API response JSON: $response");

      return GetAccountantsModel.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching filtered accountants: $e");
      rethrow;
    }
  }


  ///Connect to accountant Repo

  Future<dynamic> connectAccountantRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.connectAccountantEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.connectAccountantEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Disconnect to accountant Repo

  Future<dynamic> disconnectAccountantRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.connectAccountantEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.connectAccountantEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

}