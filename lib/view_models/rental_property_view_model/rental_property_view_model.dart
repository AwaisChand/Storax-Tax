import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:storatax/models/get_rental_property_plan_model/get_rental_property_plan_model.dart';
import 'package:storatax/models/get_reports_model/get_reports_model.dart';
import 'package:storatax/models/rental_property_models/database_entry_model/database_entry_model.dart';
import 'package:storatax/models/rental_property_models/get_all_regular_entries_model/get_all_regular_entries_model.dart';
import 'package:storatax/models/rental_property_models/get_income_types_model/get_income_types_model.dart';
import 'package:storatax/models/rental_property_models/property_owner_model/property_owner_model.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/entry/entry_screens/all_regular_entry_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/rental_income_type/rental_income_type_screen/rental_income_type_list_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/rental_income_type/rental_income_type_screen/rental_income_type_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/rental_property_tab_screen/rental_property_tab_screen.dart';
import 'package:storatax/utils/routes/routes_name.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/expense_type_model/expense_type_model.dart';
import '../../models/rental_property_models/account_setting_model/account_setting_model.dart';
import '../../repository/rental_property_repository/rental_property_repository.dart';

import '../../res/components/app_localization.dart';
import '../../utils/utils.dart';

class RentalPropertyViewModel extends ChangeNotifier {
  final RentalPropertyRepository rentalPropertyRepository =
      RentalPropertyRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _printLoading = false;
  bool get printLoading => _printLoading;

  set t776Loading(bool setLoading) {
    _printLoading = setLoading;
    notifyListeners();
  }

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  bool _otherLoading = false;
  bool get otherLoading => _otherLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  set save(bool setLoading) {
    _isSaving = setLoading;
    notifyListeners();
  }

  set otherLoad(bool setLoading) {
    _otherLoading = setLoading;
    notifyListeners();
  }

  List<Data> _getRentalPropertyPlanData = [];
  List<Data> get getRentalPropertyPlanData => _getRentalPropertyPlanData;

  final Map<int, AccountSettingModel?> _accountSettingByPlan = {};

  AccountSettingModel? accountSettingModelFor(int planId) =>
      _accountSettingByPlan[planId];

  final Map<int, PropertyOwnerModel?> _propertyOwnerModel = {};

  PropertyOwnerModel? propertyOwnerModel(int planId) =>
      _propertyOwnerModel[planId];

  final Map<int, GetIncomeTypesModel?> _incomeTypes = {};

  GetIncomeTypesModel? incomeTypes(int planId) => _incomeTypes[planId];

  List<IncomeTypesData> _data = [];
  List<IncomeTypesData> get data => _data;

  final Map<int, GetAllRegularEntriesModel?> _getAllRegularEntries = {};

  GetAllRegularEntriesModel? getAllRegularEntries(int planId) =>
      _getAllRegularEntries[planId];

  List<AllRegularEntriesData> _allEntries = [];
  List<AllRegularEntriesData> get allEntries => _allEntries;

  final Map<int, DatabaseEntriesModel?> _database = {};

  DatabaseEntriesModel? database(int planId) => _database[planId];

  DatabaseEntriesModel? _databaseEntriesModel;
  DatabaseEntriesModel? get databaseEntriesModel => _databaseEntriesModel;

  GetReportsModel? _getReportsModel;
  GetReportsModel? get getReportsModel => _getReportsModel;

  String? selectedYear;
  DateTime? fromDate;
  DateTime? toDate;
  DateTime? selectedMonth;
  IncomeTypeOption? selectedIncomeType;
  ExpenseType? selectedExpenseType;

  void clearDatabaseFilters() {
    fromDate = null;
    toDate = null;
    selectedMonth = null;
    selectedYear = null;
    notifyListeners();
  }

  void clearRegEntryFilters() {
    selectedIncomeType = null;
    selectedExpenseType = null;
    fromDate = null;
    toDate = null;
    selectedMonth = null;
    selectedYear = null;
    notifyListeners();
  }

  /// Get Rental Property Plan Api
  Future<void> getRentalPropertyPlanApi(BuildContext context) async {
    _getRentalPropertyPlanData = [];
    loading = true;

    try {
      final response =
          await rentalPropertyRepository.getRentalPropertyPlanRepo();

      if (response.status == 1) {
        _getRentalPropertyPlanData = response.data!;
        // Utils.toastMessage(response.success ?? "Data loaded");
      } else {
        Utils.toastMessage(response.success ?? "Failed to load data");
      }

      if (kDebugMode) {
        debugPrint("Get Rental Property Plan Data API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get Rental Property Plan Data Error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  /// Rental Account address setting api
  Future<void> rentalAccountAddressSettingApi({
    required BuildContext context,
    required int planId,
  }) async {
    otherLoad = true;
    notifyListeners();
    try {
      final response = await rentalPropertyRepository.rentalAccountAddressRepo(
        planId: planId,
      );

      // Always overwrite entry, even if status == 0 (not found)
      _accountSettingByPlan[planId] = response;

      if (response.status == 1) {
        // Utils.toastMessage(response.success ?? "Success");
      } else {
        Utils.toastMessage(response.success ?? "Account settings not found");
      }

      if (kDebugMode) {
        debugPrint("Account settings for plan $planId: $response");
      }
    } catch (e, stackTrace) {
      debugPrint(
        "Get Rental Address Setting Data Error for plan $planId: $e $stackTrace",
      );
      Utils.toastMessage("Error: ${e.toString()}");
      _accountSettingByPlan[planId] = null; // clear on error if desired
    } finally {
      otherLoad = false;
      notifyListeners();
    }
  }

  ///Create or Update Account Setting

  Future<void> createOrUpdateAccountSettingApi(
    BuildContext context,
    dynamic data,
  ) async {
    otherLoad = true;
    notifyListeners();

    try {
      debugPrint("Update Account setting data: $data");

      final response = await rentalPropertyRepository
          .createOrUpdateAccountSettingRepo(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);

        // Re-fetch the updated account settings for this plan
        final planId = data['client_plans_id'] as int;
        await rentalAccountAddressSettingApi(context: context, planId: planId);

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => RentalPropertyTabScreen()),
        // );
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Update Account  API Response: $response");
      }
    } catch (e) {
      debugPrint("Update Account error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      otherLoad = false;
      notifyListeners();
    }
  }

  ///Property Owner Api

  Future<void> propertyOwnerApi({
    required BuildContext context,
    required int planId,
  }) async {
    otherLoad = true;
    notifyListeners();
    try {
      final response = await rentalPropertyRepository.propertyOwnerRepo(
        planId: planId,
      );

      // Always overwrite entry, even if status == 0 (not found)
      _propertyOwnerModel[planId] = response;

      if (response.status == 1) {
        // Utils.toastMessage(response.success ?? "Success");
        debugPrint("Success: ${response.success}");
      } else {
        Utils.toastMessage(
          response.success ?? "Property owner information not found",
        );
      }

      if (kDebugMode) {
        debugPrint("Property owner for plan $planId: $response");
      }
    } catch (e, stackTrace) {
      debugPrint(
        "Get Property Owner Data Error for plan $planId: $e $stackTrace",
      );
      Utils.toastMessage("Error: ${e.toString()}");
      _propertyOwnerModel[planId] = null;
    } finally {
      otherLoad = false;
      notifyListeners();
    }
  }

  ///Create or Update Property Owner

  Future<void> createOrUpdatePropertyOwnerApi(
    BuildContext context,
    dynamic data,
  ) async {
    _isSaving = true;
    notifyListeners();

    try {
      debugPrint("create or update property owner data: $data");

      final response = await rentalPropertyRepository
          .createOrUpdatePropertyOwnerRepo(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);

        // Re-fetch the updated account settings for this plan
        final planId = data['client_plans_id'] as int;
        // await rentalAccountAddressSettingApi(context: context, planId: planId);

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => RentalPropertyTabScreen()),
        // );
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("create or update property owner API Response: $response");
      }
    } catch (e) {
      debugPrint("create or update property owner error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  ///Get IncomeTypes Api

  Future<void> getIncomeTypesApi({
    required BuildContext context,
    required int planId,
  }) async {
    otherLoad = true;
    notifyListeners();
    try {
      final response = await rentalPropertyRepository.getIncomeTypesRepo(
        planId: planId,
      );

      // Always overwrite entry, even if status == 0 (not found)
      _incomeTypes[planId] = response;

      if (response.status == 1) {
        _data = response.data!;
        Utils.toastMessage(response.success ?? "Success");
      } else {
        Utils.toastMessage(response.success ?? "Income Types not found");
      }

      if (kDebugMode) {
        debugPrint("Income Types $planId: $response");
      }
    } catch (e, stackTrace) {
      debugPrint(
        "Get Income Types Data Error for plan $planId: $e $stackTrace",
      );
      Utils.toastMessage("Error: ${e.toString()}");
      _incomeTypes[planId] = null; // clear on error if desired
    } finally {
      otherLoad = false;
      notifyListeners();
    }
  }

  List<IncomeTypeOption> getIncomeTypeOptions(int planId) {
    final resp = _incomeTypes[planId];
    if (resp == null || resp.data == null) return [];
    return resp.data!.map((e) {
      final int id = e.id is int ? e.id as int : int.tryParse('${e.id}') ?? 0;
      final String name = e.name ?? '';
      return IncomeTypeOption(id: id, name: name, rawEntry: e);
    }).toList();
  }

  ///Create Income Types Api

  Future<void> createIncomeTypesApi(BuildContext context, dynamic data) async {
    otherLoad = true;
    notifyListeners();

    try {
      debugPrint("create income types data: $data");

      final response = await rentalPropertyRepository.createIncomeTypeRepo(
        data,
      );
      final planId = data['client_plans_id'] as int;

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RentalIncomeTypeListScreen(planId: planId),
          ),
        );
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("create income Types API Response: $response");
      }
    } catch (e) {
      debugPrint("create income Types error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      otherLoad = false;
      notifyListeners();
    }
  }

  ///Update Income Type Api

  Future<void> updateIncomeTypeApi({
    required BuildContext context,
    dynamic data,
    required int id,
  }) async {
    loading = true;
    try {
      debugPrint("Update Income type data: $data");

      final response = await rentalPropertyRepository.updateRentalIncomeRepo(
        data: data,
        id: id,
      );

      final planId = data['client_plans_id'] as int;

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RentalIncomeTypeListScreen(planId: planId),
          ),
        );
      } else {
        Utils.toastMessage(response["success"]);
      }
      if (kDebugMode) {
        debugPrint("Update Income Type API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Update Income Type error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Delete Income Types Api

  Future<bool> deleteIncomeTypesApi(BuildContext context, int id) async {
    loading = true;
    try {
      final response = await rentalPropertyRepository.deleteIncomeTypesRepo(id);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        if (kDebugMode) {
          debugPrint("Delete Income types API Response: $response");
        }
        return true;
      } else {
        Utils.toastMessage(response["success"]);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("Delete income types Api error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      return false;
    } finally {
      loading = false;
    }
  }

  ///Get All Regular Entries Api
  Future<void> getAllRegularEntriesApi({
    required BuildContext context,
    required int planId,
    String? year,
    DateTime? fromDate,
    DateTime? toDate,
    DateTime? month,
    int? incomeTypeId,
    String? expenseType,
  }) async {
    otherLoad = true;
    notifyListeners();

    try {
      final response = await rentalPropertyRepository.getAllRegularEntriesRepo(
        planId: planId,
        year: year,
        fromDate: fromDate,
        toDate: toDate,
        month: month,
        incomeTypeId: incomeTypeId,
        expenseType: expenseType,
      );

      _getAllRegularEntries[planId] = response;

      // ✅ Show human-readable message
      if (response.success != null && response.success!.isNotEmpty) {
        Utils.toastMessage(response.success!);
      }

      if (response.status == 1 && response.data != null) {
        _allEntries = response.data!;
      } else if (response.status != 1) {
        // Optional: If API returns status 0, still show toast (already handled above)
        _allEntries = [];
      }

      if (kDebugMode) {
        debugPrint("All Regular Entries $planId: $response");
      }
    } catch (e, stackTrace) {
      debugPrint(
        "Get All Regular Entries Error for plan $planId: $e $stackTrace",
      );
      Utils.toastMessage("Error: ${e.toString()}");
      _getAllRegularEntries[planId] = null;
    } finally {
      otherLoad = false;
      notifyListeners();
    }
  }

  ///Create Entries Api

  Future<void> createEntriesApi(BuildContext context, dynamic data) async {
    otherLoad = true;
    notifyListeners();

    try {
      debugPrint("create income types data: $data");

      final response = await rentalPropertyRepository.createEntriesRepo(data);
      final planId = data['client_plans_id'] as int;

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AllRegularEntryScreen(planId: planId),
          ),
        );
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("create entries API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("create entries error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      otherLoad = false;
      notifyListeners();
    }
  }

  Future<void> createEntriesProofApi(
    BuildContext context,
    Map<String, dynamic> fields,
    File? avatarFile,
  ) async {
    otherLoad = true;
    try {
      debugPrint("Update Profile fields: $fields");
      debugPrint("Avatar file: ${avatarFile?.path}");
      final planId = fields['client_plans_id'] as int;

      final response = await rentalPropertyRepository.createEntryProofRepo(
        fields: fields,
        avatarFile: avatarFile,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AllRegularEntryScreen(planId: planId),
          ),
        );
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
        debugPrint("Add Entry API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Add Entry error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      otherLoad = false;
    }
  }

  ///Forward Multiple entries

  Future<void> forwardMultipleEntriesApi(
    BuildContext context,
    dynamic data,
    String language,
  ) async {
    otherLoad = true;

    try {
      debugPrint("Forward entries data: $data");

      final response = await rentalPropertyRepository
          .forwardMultipleEntriesRepo(
            data: data,
            language: language, // ✅ added
          );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Forward multiple entries API Response: $response");
      }
    } catch (e) {
      debugPrint("forward multiple entries error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      otherLoad = false;
    }
  }

  Future<void> forwardReportApi(
    BuildContext context,
    dynamic data,
    String? language,
  ) async {
    otherLoad = true;
    try {
      debugPrint("Forward entries data: $data");

      final response = await rentalPropertyRepository.forwardReportEndPointRepo(
        data,
        language,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Forward report API Response: $response");
      }
    } catch (e) {
      debugPrint("Forward report error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      otherLoad = false;
    }
  }

  /// Delete Entries Api

  Future<bool> deleteEntriesApi(BuildContext context, int id) async {
    loading = true;
    try {
      final response = await rentalPropertyRepository.deleteEntriesRepo(id);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        if (kDebugMode) {
          debugPrint("Delete entries API Response: $response");
        }
        return true;
      } else {
        Utils.toastMessage(response["success"]);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("Delete entries Api error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      return false;
    } finally {
      loading = false;
    }
  }

  ///Update Entry Api

  Future<void> updateEntryApi({
    required BuildContext context,
    dynamic data,
    required int id,
  }) async {
    loading = true;
    try {
      debugPrint("Update entry data: $data");

      final response = await rentalPropertyRepository.updateEntryRepo(
        data: data,
        id: id,
      );

      // ✅ Safely read planId
      final planId =
          data['client_plans_id'] != null
              ? int.tryParse(data['client_plans_id'].toString())
              : null;

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);

        if (planId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AllRegularEntryScreen(planId: planId),
            ),
          );
        }
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Update Entry API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Update Entry error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  Future<void> updateEntryProofApi(
    BuildContext context,
    Map<String, dynamic> fields,
    int id,
    File? avatarFile,
  ) async {
    loading = true;
    try {
      debugPrint("Update Entry fields: $fields");
      debugPrint("Avatar file: ${avatarFile?.path}");

      // SAFELY EXTRACT PLAN ID AS INT
      final planId = int.tryParse(fields['client_plans_id'].toString()) ?? 0;

      final response = await rentalPropertyRepository.updateEntryProofRepo(
        fields: fields,
        avatarFile: avatarFile,
        id: id,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);

        // NAVIGATE WITH SAFE PLAN ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AllRegularEntryScreen(planId: planId),
          ),
        );
        return;
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
        debugPrint("Update Entry API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Update Entry error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Get All Database Entries Api

  Future<void> getAllDatabaseEntriesApi({
    required BuildContext context,
    required int planId,
    String? year,
    DateTime? month,
    DateTime? fromDate,
    DateTime? toDate,
    String? language,
  }) async {
    otherLoad = true;
    notifyListeners();
    try {
      final response = await rentalPropertyRepository.databaseEntryRepo(
        planId: planId,
        year: year,
        month: month,
        fromDate: fromDate,
        toDate: toDate,
        language: language,
      );

      _database[planId] = response;

      if (response.status == 1) {
        _databaseEntriesModel = response;
        Utils.toastMessage(response.success!);
      } else {
        Utils.toastMessage(response.success!);
      }

      if (kDebugMode) {
        debugPrint("Database entry $planId: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get Data base entry Error for plan $planId: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      _database[planId] = null;
    } finally {
      otherLoad = false;
      notifyListeners();
    }
  }

  ///Report Schedule Api
  Future<String?> reportScheduleApi({
    required int clientPlansId,
    required int year,
    String language = 'en',
  }) async {
    loading = true;
    notifyListeners();

    try {
      final result = await rentalPropertyRepository.reportScheduleRepo(
        clientPlansId: clientPlansId,
        year: year,
        language: language, // pass language here
      );

      if (result != null && result["status"] == 1 && result["file"] != null) {
        // ✅ Save PDF to local
        final response = result["file"] as http.Response;
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/report_${clientPlansId}_$language.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        // ✅ Show clean server message (never crashes)
        final message =
            (result != null && result["success"] is String)
                ? result["success"] as String
                : "Please update your account settings to proceed";

        Utils.toastMessage(message);
        return null;
      }
    } catch (e, stack) {
      debugPrint("❌ reportScheduleApi error: $e $stack");
      Utils.toastMessage("Something went wrong");
      return null;
    } finally {
      // ✅ Always stop loader
      loading = false;
      notifyListeners();
    }
  }

  Future<void> generateAndOpenPDF({
    required AllRegularEntriesData entry,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Regular Entry Details',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${entry.date ?? "-"}'),
              pw.Text('Expense: ${entry.expenseType ?? "-"}'),
              if (entry.expenseType == 'Other expenses (BusAuto)' ||
                  entry.expenseType == 'Other expenses')
                pw.Text('Only For Rental: ${entry.onlyForRental ?? "-"}'),
              pw.Text('Income Type: ${entry.incomeTypeName ?? "-"}'),
              pw.Text('Amount: ${entry.amount?.toString() ?? "-"}'),
            ],
          );
        },
      ),
    );

    try {
      // 📁 Save to app's internal directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/entry_${entry.id ?? DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print("✅ PDF saved at $filePath");

      // 📂 Open the file
      final result = await OpenFile.open(filePath);
      print("📂 Open result: ${result.message}");
    } catch (e) {
      print("❌ Error opening PDF: $e");
    }
  }

  Future<void> exportEntriesToCsv(
    BuildContext context,
    List<dynamic> entries,
  ) async {
    try {
      // 1️⃣ Empty check with language handling
      if (entries.isEmpty) {
        Utils.toastMessage(
          Localizations.localeOf(context).languageCode == 'fr'
              ? 'Aucune entrée à exporter'
              : 'No entries to export',
        );
        return;
      }

      final l10n = AppLocalizations.of(context)!;

      // 2️⃣ CSV Header using translate()
      List<List<String>> rows = [
        [
          l10n.translate("date") ?? "",
          l10n.translate("expense") ?? "",
          l10n.translate("onlyForRental") ?? "",
          l10n.translate("incomeType") ?? "",
          l10n.translate("amount") ?? "",
        ],
      ];

      // 3️⃣ CSV Data rows
      for (var entry in entries) {
        rows.add([
          entry.date?.toString() ?? "",
          entry.expenseType?.toString() ?? "",
          entry.onlyForRental?.toString() ?? "",
          entry.incomeTypeName?.toString() ?? "",
          entry.amount?.toString() ?? "",
        ]);
      }

      // 4️⃣ Convert to CSV
      final csv = const ListToCsvConverter().convert(rows);

      // 5️⃣ Save file
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/entry_export.csv";

      final file = File(path);
      await file.writeAsString(csv);

      // 6️⃣ Share CSV
      await Share.shareXFiles([
        XFile(file.path),
      ], text: l10n.translate("exportedEntries") ?? "Exported Entries");

      // 7️⃣ Success message
      Utils.toastMessage(
        "${entries.length} ${l10n.translate("exportedEntries") ?? "Exported Entries"}",
      );
    } catch (e) {
      debugPrint("Export failed: $e");

      Utils.toastMessage(
        AppLocalizations.of(context)!.translate("exportFailed") ??
            "Export failed",
      );
    }
  }

  Future<String?> allRegularEntriesPrintApi({
    required int clientPlansId,
    required int year,
    required String language,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await rentalPropertyRepository
          .printAllRegularEntriesRepo(
            year: year,
            clientPlansId: clientPlansId,
            language: language,
          );

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/report_$clientPlansId.pdf';
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

  Future<String?> printReportT776Api({
    required int clientPlansId,
    required int year,
    String language = 'en', // default to English
  }) async {
    loading = true;
    notifyListeners();

    try {
      final result = await rentalPropertyRepository.printT776Repo(
        clientPlansId: clientPlansId,
        year: year,
        language: language,
      );

      if (result != null && result["status"] == 1 && result["file"] != null) {
        final response = result["file"] as http.Response;
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/report_${clientPlansId}_$language.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        final message =
            (result != null && result["success"] is String)
                ? result["success"] as String
                : "Please update your account settings to proceed";
        Utils.toastMessage(message);
        return null;
      }
    } catch (e, stack) {
      debugPrint("❌ reportT776 error: $e $stack");
      Utils.toastMessage("Something went wrong");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> printReportF1040({
    required int clientPlansId,
    required int year,
    String language = 'en',
  }) async {
    loading = true;
    notifyListeners();

    try {
      final result = await rentalPropertyRepository.printF1040Repo(
        clientPlansId: clientPlansId,
        year: year,
        language: language,
      );

      if (result != null && result["status"] == 1 && result["file"] != null) {
        final response = result["file"] as http.Response;
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/report_${clientPlansId}_$language.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        final message =
            (result != null && result["success"] is String)
                ? result["success"] as String
                : "Please update your account settings to proceed";
        Utils.toastMessage(message);
        return null;
      }
    } catch (e, stack) {
      debugPrint("❌ reportF1040 error: $e $stack");
      Utils.toastMessage("Something went wrong");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
