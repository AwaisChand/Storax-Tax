import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storatax/models/get_gasoline_list_model/get_gasoline_list_model.dart'
    as list;
import 'package:storatax/models/get_gasoline_report_model/get_gasoline_report_model.dart';
import 'package:storatax/models/get_transaction_report_model/get_transaction_report_model.dart';
import 'package:storatax/repository/gasoline_repository/gasoline_repository.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/gasoline_list_screen/gasoline_list_screen/gasoline_list_screen.dart';

import '../../utils/utils.dart';

class GasolineViewModel extends ChangeNotifier {
  final GasolineRepository gasolineRepository = GasolineRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  List<list.Data> _gasolineList = [];
  List<list.Data> get gasolineList => _gasolineList;

  List<MonthlySummary> _monthlySummary = [];
  List<MonthlySummary> get monthlySummary => _monthlySummary;

  GetGasolineReportModel? _gasolineReportModel;
  GetGasolineReportModel? get gasolineReportModel => _gasolineReportModel;

  GetTransactionReportModel? _getTransactionReportModel;
  GetTransactionReportModel? get getTransactionReportModel =>
      _getTransactionReportModel;

  DateTime? fromDate;
  DateTime? toDate;
  DateTime? selectedMonth;
  String? selectedYear;
  String? sortBy;
  String? sortOrder;

  ///Graph Entry
  DateTime? fromGraphDate;
  DateTime? toGraphDate;
  DateTime? selectedGraphMonth;
  String? selectedGraphYear;

  /// For Transaction
  DateTime? fromTransDate;
  DateTime? toTransDate;
  DateTime? selectedTransMonth;
  String? selectedTransYear;

  void clearFilters() {
    fromDate = null;
    toDate = null;
    selectedMonth = null;
    selectedYear = null;
    notifyListeners();
  }

  void clearGraphFilters() {
    fromGraphDate = null;
    toGraphDate = null;
    selectedGraphMonth = null;
    selectedGraphYear = null;
    notifyListeners();
  }

  void clearTransactionFilters() {
    fromDate = null;
    toDate = null;
    selectedMonth = null;
    selectedYear = null;
    sortBy = null;
    sortOrder = null;

    notifyListeners();
  }

  ///Get Gasoline Api Model

  Future<void> getGasolineApi(
    BuildContext context, {
    String? year,
    DateTime? month,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.getGasolineRepo(
        year: year,
        month: month,
        fromDate: fromDate,
        toDate: toDate,
      );

      if (response.status == 1 && response.data != null) {
        _gasolineList = response.data!;
      } else {
        Utils.toastMessage(response.success ?? "Failed to fetch gasoline data");
      }

      if (kDebugMode) {
        debugPrint("Get gasoline Data API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get gasoline data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  ///Scan file api

  Future<Map<String, dynamic>?> scanFileApi(File? avatarFile) async {
    loading = true;
    notifyListeners();

    try {
      debugPrint("files path: ${avatarFile?.path}");

      final response = await gasolineRepository.scanFile(filesPath: avatarFile);

      if (kDebugMode) {
        debugPrint("Scan File API Response: $response");
      }

      return response;
    } catch (e) {
      debugPrint("Scan file error: $e");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
  ///Create Gasoline Api

  Future<void> createGasolineApi(
    BuildContext context,
      Map<String, dynamic> fields,
    File? avatarFile,
  ) async {
    loading = true;
    try {
      debugPrint("Gasoline Creation data: $fields");

      final response = await gasolineRepository.gasolineCreateRepo(
        fields: fields,
        avatarFile: avatarFile,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GasolineListScreen()),
        );
      } else {
        Utils.toastMessage(response["success"]);
      }
      if (kDebugMode) {
        debugPrint("Gasoline Creation API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Gasoline Creation error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Delete Gasoline Api

  Future<bool> deleteGasolineApi(BuildContext context, int id) async {
    loading = true;
    try {
      final response = await gasolineRepository.deleteGasolineRepo(id);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        if (kDebugMode) {
          debugPrint("Delete Gasoline API Response: $response");
        }
        return true;
      } else {
        Utils.toastMessage(response["success"]);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("Delete Gasoline Api error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      return false; // ✅ error case
    } finally {
      loading = false;
    }
  }

  ///Update Gasoline Api

  Future<void> updateGasolineApi({
    required BuildContext context,
    Map<String,dynamic>? fields,
    required int id,
    File? avatarFile,

  }) async {
    loading = true;
    try {
      debugPrint("Gasoline Update data: $fields");

      final response = await gasolineRepository.updateGasolineRepo(
        fields: fields!,
        id: id,
        avatarFile: avatarFile
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GasolineListScreen()),
        );
      } else {
        Utils.toastMessage(response["success"]);
      }
      if (kDebugMode) {
        debugPrint("Gasoline Update API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Gasoline Update error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Forward multiple gasoline

  Future<void> forwardMultipleGasolineFileApi(
    BuildContext context,
    dynamic data,
    String language,
  ) async {
    loading = true;

    try {
      debugPrint("Forward gasoline data: $data");

      final response = await gasolineRepository.forwardMultipleGasolineRepo(
        data: data,
        language: language,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Forward multiple gasoline API Response: $response");
      }
    } catch (e) {
      debugPrint("forward multiple gasoline error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Get Gasoline Report

  Future<void> getGasolineReportApi(
    BuildContext context, {
    String? year,
    DateTime? month,
    DateTime? fromDate,
    DateTime? toDate,
    String? language,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.gasolineReportRepo(
        year: year,
        month: month,
        fromDate: fromDate,
        toDate: toDate,
        language: language,
      );

      if (response.status == 1) {
        _gasolineReportModel = response;
        _monthlySummary = response.data!.monthlySummary!;
        Utils.toastMessage(response.success!);
      } else {
        Utils.toastMessage(response.success!);
      }

      if (kDebugMode) {
        debugPrint("Get gasoline Report API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get gasoline Report error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Report forward api

  Future<void> reportForwardApi(
    BuildContext context,
    dynamic data,
    String language,
  ) async {
    loading = true;

    try {
      debugPrint("Forward gasoline data: $data");

      final response = await gasolineRepository.reportForwardRepo(
        data,
        language, // ✅ forwarded
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Forward gasoline report API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("forward gasoline report error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  /// print report api

  Future<String?> printReportApi({
    String? year,
    String? month,
    String? fromDate,
    String? toDate,
    required String language,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final result = await gasolineRepository.printReportRepo(
        year: year,
        month: month,
        fromDate: fromDate,
        toDate: toDate,
        language: language, // ✅ forwarded
      );

      if (result["status"] == 1 && result["fileBytes"] != null) {
        final bytes = result["fileBytes"] as List<int>;

        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        debugPrint("✅ PDF saved at: $filePath");
        return filePath;
      } else {
        final message =
            (result["success"] is String)
                ? result["success"] as String
                : "Please update your account settings to proceed";

        Utils.toastMessage(message);
        return null;
      }
    } catch (e, stack) {
      debugPrint("❌ printReportApi error: $e $stack");
      Utils.toastMessage("Something went wrong");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<int> getMonthlyReceiptCount() async {
    final now = DateTime.now();

    final monthReceipts =
        _gasolineList.where((r) {
          if (r.date == null) return false; // ✅ skip null dates
          try {
            // ✅ convert string date to DateTime
            final date = DateTime.parse(r.date!);
            return date.month == now.month && date.year == now.year;
          } catch (e) {
            debugPrint("Date parse error for ${r.date}: $e");
            return false;
          }
        }).toList();

    return monthReceipts.length;
  }

  ///Get Transaction report api

  Future<void> getTransactionReportApi(
    BuildContext context, {
    String? year,
    String? month,
    String? fromDate,
    String? toDate,
    String? sortBy,
    String? sortOrder,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await gasolineRepository.getTransactionReportRepo(
        year: year,
        month: month,
        fromDate: fromDate,
        toDate: toDate,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (response.status == 1 && response.data != null) {
        _getTransactionReportModel = response;
      } else {
        Utils.toastMessage(
          response.message ?? "Failed to fetch transaction report data",
        );
      }

      if (kDebugMode) {
        debugPrint("Get transaction report Data API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get transaction report data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Get transaction report api

  Future<String?> getTransactionPdfReportApi(String? language) async {
    loading = true;
    notifyListeners();

    try {
      String? yearParam;
      String? monthParam;
      String? fromParam;
      String? toParam;

      // 🔥 Priority 1: Date range
      if (fromTransDate != null && toTransDate != null) {
        fromParam = DateFormat('yyyy-MM-dd').format(fromTransDate!);
        toParam = DateFormat('yyyy-MM-dd').format(toTransDate!);
      }
      // 🔥 Priority 2: Year
      else if (selectedTransYear != null && selectedTransYear!.isNotEmpty) {
        yearParam = selectedTransYear;
      }

      // Optional: Month in YYYY-MM format
      if (selectedTransMonth != null) {
        monthParam = DateFormat('yyyy-MM').format(selectedTransMonth!);
      }

      final result = await gasolineRepository.printTransactionReportRepo(
        year: yearParam,
        month: monthParam,
        fromDate: fromParam,
        toDate: toParam,
        sortBy: sortBy,
        sortOrder: sortOrder,
        language: language,
      );

      if (result["status"] == 1 && result["fileBytes"] != null) {
        final bytes = result["fileBytes"] as List<int>;
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';

        final file = File(filePath);
        await file.writeAsBytes(bytes);

        return filePath;
      }

      Utils.toastMessage(result["success"] ?? "Failed to generate PDF");
      return null;
    } catch (e) {
      Utils.toastMessage("Something went wrong");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
  ///forward email report api
  Future<void> forwardEmailReportApi(
    BuildContext context,
    dynamic data,
    String language,
  ) async {
    loading = true;

    try {
      debugPrint("Forward email report data: $data");

      final response = await gasolineRepository.forwardEmailReportRepo(
        data,
        language,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);
      } else {
        Utils.toastMessage(response["message"]);
      }

      if (kDebugMode) {
        debugPrint("Forward email report API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("forward email report error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }
}
