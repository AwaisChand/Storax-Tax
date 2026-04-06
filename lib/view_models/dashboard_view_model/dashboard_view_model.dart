import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:storatax/models/get_dashboard_data_model/get_dashboard_data_model.dart';
import 'package:storatax/repository/dashboard_repository/dashboard_repository.dart';

import '../../utils/utils.dart';

class DashboardViewModel extends ChangeNotifier{
  final DashboardRepository dashboardRepository = DashboardRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  GetDashboardDataModel? _getDashboardDataModel;
  GetDashboardDataModel? get getDashboardModel => _getDashboardDataModel;

  ///Get dashboard api

  Future<void> getDashboardApi(BuildContext context) async {
    loading = true;
    try {
      final response = await dashboardRepository.dashboardRepo();

      if (response.status == 1) {
        _getDashboardDataModel = response;
        // Utils.toastMessage(response.success!);
      } else {
        Utils.toastMessage(response.success!);
      }

      if (kDebugMode) {
        debugPrint("Get Dashboard Data API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get Dashboard data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

}