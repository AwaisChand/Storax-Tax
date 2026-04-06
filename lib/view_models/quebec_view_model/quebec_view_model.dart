import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:storatax/models/gst_qst_reporting_model/gst_qst_reporting_model.dart';
import 'package:storatax/repository/quebec_repository/quebec_repository.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/gst_qst_reporting_screen/gst_qst_reporting_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/quebec_create_screens/rides_gross_screen.dart';

import '../../models/quebec_model/quebec_model.dart';
import '../../utils/utils.dart';
import '../auth_view_model/auth_view_model.dart';

class QuebecViewModel extends ChangeNotifier {
  final QuebecRepository quebecRepository = QuebecRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  List<GstQstReportingData> _data = [];
  List<GstQstReportingData> get data => _data;

  String? selectedYear;

  void clearFilters() {
    selectedYear = null;
    notifyListeners();
  }

  ///Create Quebec Api

  Future<void> createQuebecApi(BuildContext context, dynamic data) async {
    loading = true;
    try {
      debugPrint("Quebec Creation data: $data");

      final response = await quebecRepository.createQuebecRepo(data);

      String message = "Something went wrong";

      if (response["success"] is String) {
        // normal success/error response
        message = response["success"];
      } else if (response["success"] is Map) {
        // validation errors
        final errors = response["success"] as Map<String, dynamic>;
        final allErrors =
            errors.values.expand((v) {
              if (v is List) return v.map((e) => e.toString());
              if (v is String) return [v];
              return [];
            }).toList();

        if (allErrors.isNotEmpty) {
          message = allErrors.join("\n");
        }
      }

      if (response["status"].toString() == "1") {
        Utils.toastMessage(message);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GstQstReportingScreen()),
        );
      } else {
        Utils.toastMessage(message);
      }

      if (kDebugMode) {
        debugPrint("Quebec Creation API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Quebec Creation error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  Future<void> gstQstReportingApi(BuildContext context, {String? year}) async {
    loading = true;
    notifyListeners();

    try {
      final response = await quebecRepository.getGstQstReportingModel(
        year: year,
      );

      if (response.status == 1) {
        _data = response.data!;
        // Utils.toastMessage(response.success!);
      } else {
        Utils.toastMessage(response.success!);
      }

      if (kDebugMode) {
        debugPrint("Get reporting Data API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get reporting data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuebecApi({
    required BuildContext context,
    dynamic data,
    required int id,
  }) async {
    loading = true;
    try {
      debugPrint("quebec Update data: $data");

      final response = await quebecRepository.updateQuebecRepo(
        data: data,
        id: id,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GstQstReportingScreen()),
        );
      } else {
        Utils.toastMessage(response["success"]);
      }
      if (kDebugMode) {
        debugPrint("quebec Update API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("quebec Update error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Delete Quebec Api

  Future<bool> deleteQuebecApi(BuildContext context, int id) async {
    loading = true;
    try {
      final response = await quebecRepository.deleteQuebecRepo(id);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        if (kDebugMode) {
          debugPrint("Delete Quebec API Response: $response");
        }
        return true;
      } else {
        Utils.toastMessage(response["success"]);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("Delete Quebec Api error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      return false;
    } finally {
      loading = false;
    }
  }

  /// Generate Gst/Qst Report Api
  Future<String?> generateGstQstReportApi({
    required int id,
    String language = 'en', // new parameter
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await quebecRepository.generateGstQstReportRepo(
        id: id,
        language: language,
      );

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/report_${id}_$language.pdf'; // include language
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (e) {
      Utils.toastMessage("Error: ${e.toString()}");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Generate Gross Income Report Api
  Future<String?> generateGrossIncomeReportApi({
    required int id,
    String language = 'en', // new parameter
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await quebecRepository.generateGrossIncomeReportRepo(
        id: id,
        language: language,
      );

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/report_${id}_$language.pdf'; // include language
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (e) {
      Utils.toastMessage("Error: ${e.toString()}");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  ///Scan Quebec Api

  Future<void> scanQuebecApi(BuildContext context, File? avatarFile) async {
    loading = true;
    try {
      debugPrint("files path: ${avatarFile?.path}");

      final response = await quebecRepository.scanQuebecRepo(
        filesPath: avatarFile,
      );
      final auth = Provider.of<AuthViewModel>(context, listen: false);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        // Navigator.pushNamed(context, RoutesNames.getFiles);
        final quebecData = response["data"];
        final quebecModel = QuebecModel.fromJson(quebecData);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RidesGrossScreen(quebecModel: quebecModel),
          ),
        );
        auth.clearPickedImage();
      }

      final success = response["success"];
      if (success is String) {
        Utils.toastMessage(success);
      } else if (success is Map<String, dynamic>) {
        final firstKey = success.keys.first;
        final firstError = success[firstKey];
        final message =
            (firstError is List && firstError.isNotEmpty)
                ? firstError.first.toString()
                : "Something went wrong";
        Utils.toastMessage(message);
      } else {
        Utils.toastMessage("Unexpected error format.");
      }

      if (kDebugMode) {
        debugPrint("Create File API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Scan Quebec error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///forward gross income report api

  Future<void> forwardGrossIncomeReportApi(
    BuildContext context,
    dynamic data,
  ) async {
    loading = true;

    try {
      debugPrint("Forward Gross Income Report data: $data");

      final response = await quebecRepository.forwardGrossIncomeReportRepo(
        data: data,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Forward Gross Income Report API Response: $response");
      }
    } catch (e) {
      debugPrint("Forward Gross Income Report error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///forward gst/qst report api

  Future<void> forwardGSTQSTReportApi(
    BuildContext context,
    dynamic data,
  ) async {
    loading = true;

    try {
      debugPrint("Forward GST QST Report data: $data");

      final response = await quebecRepository.forwardGSTQSTReportRepo(
        data: data,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Forward GST QST Report API Response: $response");
      }
    } catch (e) {
      debugPrint("Forward GST QST Report error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }
}
