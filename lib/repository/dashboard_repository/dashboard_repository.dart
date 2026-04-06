import 'package:flutter/foundation.dart';
import 'package:storatax/models/get_dashboard_data_model/get_dashboard_data_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';

class DashboardRepository{
  BaseApiServices baseApiServices = NetworkApiService();



  Future<GetDashboardDataModel> dashboardRepo() async {
    try {
      dynamic response = await baseApiServices.getRequestToken(
        AppUrl.dashboardEndPoint,
      );
      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.dashboardEndPoint}");

      return GetDashboardDataModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}