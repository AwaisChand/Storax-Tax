import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storatax/models/viewrs_model/get_all_viewrs_model.dart';
import 'package:storatax/repository/viewrs_repository/viewrs_repository.dart';

import '../../utils/utils.dart';

class ViewrsViewModel extends ChangeNotifier {
  final ViewrsRepository viewrsRepository = ViewrsRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  List<Data> _allViewrs = [];
  List<Data> get allViewrs => _allViewrs;

  ///Get all viewrs api

  Future<void> getAllViewrsApi(BuildContext context) async {
    loading = true;
    try {
      final response = await viewrsRepository.getAllViewrsRepo();

      if (response.status == 1) {
        _allViewrs = response.data!;
        Utils.toastMessage(response.success!);
      } else {
        Utils.toastMessage(response.success!);
      }

      if (kDebugMode) {
        debugPrint("Get All Viewrs Data API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get All Viewrs data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Create Viewrs Api


  Future<void> createViewrsApi(
      BuildContext context,
      dynamic data,
      ) async {
    loading = true;
    notifyListeners();

    try {
      debugPrint("create viewrs data: $data");

      final response = await viewrsRepository
          .createViewrsRep(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);

        context.pushNamed("allViewrs");
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("create viewrs API Response: $response");
      }
    } catch (e) {
      debugPrint("create viewrs error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateViewrsApi(
      BuildContext context,
      int id,
      dynamic data,
      ) async {
    loading = true;
    notifyListeners();

    try {
      debugPrint("Update viewrs data: $data");

      final response = await viewrsRepository
          .updateViewrsRepo(id: id, data: data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);

        context.pushNamed('allViewrs');
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("update viewrs API Response: $response");
      }
    } catch (e) {
      debugPrint("update viewrs error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteViewrsApi(BuildContext context, int id) async {
    loading = true;
    try {
      final response = await viewrsRepository.deleteViewrsRepo(id);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        if (kDebugMode) {
          debugPrint("Delete Viewrs API Response: $response");
        }
        return true;
      } else {
        Utils.toastMessage(response["success"]);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("Delete Viewrs Api error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      return false;
    } finally {
      loading = false;
    }
  }

}
