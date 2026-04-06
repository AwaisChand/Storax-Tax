import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:storatax/models/get_category_model/get_category_model.dart';
import 'package:storatax/models/get_file_model/get_file_model.dart';
import 'package:storatax/models/get_personal_info_model/get_personal_info_model.dart';
import 'package:storatax/models/get_previous_info_model/get_previous_info_model.dart';
import 'package:storatax/repository/tax_manager_repository/tax_manager_repository.dart';
import 'package:storatax/res/app_assets.dart';
import 'package:storatax/screens/files/create_tax_manager/create_tax_manager_screen.dart';
import 'package:storatax/screens/files/get_files/get_files_screen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:storatax/screens/files/get_personal_info/get_personal_info_screen.dart';

import '../../utils/utils.dart';
import '../auth_view_model/auth_view_model.dart';

class TaxManagerViewModel extends ChangeNotifier {
  final TaxManagerRepository taxManagerRepository = TaxManagerRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  bool _categoryLoading = false;
  bool get categoryLoading => _categoryLoading;

  set category(bool setLoading) {
    _categoryLoading = setLoading;
    notifyListeners();
  }

  List<CategoryData> _data = [];
  List<CategoryData> get data => _data;

  List<FileData> _fileData = [];
  List<FileData> get fileData => _fileData;

  List<PersonalInfoList> _personalInfo = [];
  List<PersonalInfoList> get personalInfo => _personalInfo;

  GetPreviousInfoModel? _getPreviousInfoModel;
  GetPreviousInfoModel? get getPreviousInfoModel => _getPreviousInfoModel;

  GetPersonalInfoModel? _getPersonalInfoModel;
  GetPersonalInfoModel? get getPersonalInfoModel => _getPersonalInfoModel;
  DateTime? fromDate;
  DateTime? toDate;
  DateTime? selectedMonth;
  String? selectedYear;

  void clearFilters() {
    fromDate = null;
    toDate = null;
    selectedMonth = null;
    selectedYear = null;
    notifyListeners();
  }

  Future<void> createFileApi(
    BuildContext context,
    Map<String, dynamic> fields,
    List<File> files,
  ) async {
    loading = true;
    try {
      debugPrint("Create file fields: $fields");
      debugPrint("files path: ${files.map((f) => f.path).toList()}");

      final response = await taxManagerRepository.createFileRepo(
        fields: fields,
        files: files,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GetFilesScreen()),
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
        debugPrint("Create File API Response: $response");
      }
    } catch (e) {
      debugPrint("Update Profile error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  Future<void> getCategoryApi(BuildContext context) async {
    category = true;
    try {
      final response = await taxManagerRepository.getCategoryRepo();

      if (response.status == 1) {
        _data = response.data!;
        Utils.toastMessage(response.success!);
      } else {
        Utils.toastMessage(response.success!);
      }

      if (kDebugMode) {
        debugPrint("Get Category Data API Response: $response");
      }
    } catch (e) {
      debugPrint("Get Category data error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      category = false;
    }
  }

  ///Get Files Api
  Future<void> getFilesApi(
    BuildContext context, {
    String? year,
    String? month,
    String? fromDate,
    String? toDate,
    bool? uploadedByProfessional,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await taxManagerRepository.getFilesRepo(
        year: year,
        month: month,
        fromDate: fromDate,
        toDate: toDate,
        uploadedByProfessional: uploadedByProfessional,
      );

      if (response.status == 1) {
        _fileData = response.data!;
        // Utils.toastMessage(response.success!);
      } else {
        Utils.toastMessage(response.success!);
      }

      if (kDebugMode) {
        debugPrint("Get files Data API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get files data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateFileApi({
    required int id,
    required BuildContext context,
    required Map<String, dynamic> fields,
    List<File>? avatarFiles, // ✅ plural for clarity
  }) async {
    loading = true;
    try {
      debugPrint("Update file fields: $fields");
      if (avatarFiles != null && avatarFiles.isNotEmpty) {
        debugPrint("Files path: ${avatarFiles.map((f) => f.path).toList()}");
      } else {
        debugPrint("No files selected for update.");
      }

      final response = await taxManagerRepository.updateFileRepo(
        id: id,
        fields: fields,
        filesPath: avatarFiles, // ✅ directly pass list
      );

      // ✅ Success check
      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GetFilesScreen()),
        );
        return; // stop further error message handling
      }

      // ✅ Handle string or map error messages
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
        debugPrint("Update File API Response: $response");
      }
    } catch (e) {
      debugPrint("Update file error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  Future<bool> deleteFileApi(BuildContext context, int id) async {
    loading = true;
    try {
      final response = await taxManagerRepository.deleteFileRepo(id);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        if (kDebugMode) {
          debugPrint("Delete file API Response: $response");
        }
        return true; // ✅ success
      } else {
        Utils.toastMessage(response["success"]);
        return false; // ✅ failure case
      }
    } catch (e, stackTrace) {
      debugPrint("Delete file Api error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      return false; // ✅ error case
    } finally {
      loading = false;
    }
  }

  ///Forward File Api

  Future<void> forwardFileApi(
      BuildContext context,
      dynamic data,
      ) async {
    loading = true;

    try {
      debugPrint("Forward File data: $data");

      final response = await taxManagerRepository.forwardFileRepo(
        data: data,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Forward file API Response: $response");
      }
    } catch (e) {
      debugPrint("forward file error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Forward Multiple File

  Future<void> forwardMultipleFileApi(
      BuildContext context,
      dynamic data,
      ) async {
    loading = true;

    try {
      debugPrint("Forward multiple file data: $data");

      final response = await taxManagerRepository.forwardMultipleFileRepo(
        data: data,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Forward multiple file API Response: $response");
      }
    } catch (e) {
      debugPrint("forward multiple file error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  Future<void> generateAndOpenPDF({
    required String fileName,
    required String category,
    required String comments,
    required List<String>? filePaths,
  }) async {
    final pdf = pw.Document();
    List<pw.ImageProvider> images = [];

    if (filePaths != null && filePaths.isNotEmpty) {
      for (String path in filePaths) {
        try {
          if (path.startsWith('http')) {
            final response = await http.get(Uri.parse(path));

            if (response.statusCode == 200) {
              images.add(pw.MemoryImage(response.bodyBytes));
            } else {
              print("❌ Failed to download image: ${response.statusCode}");
            }
          } else {
            final bytes = await File(path).readAsBytes();
            images.add(pw.MemoryImage(bytes));
          }
        } catch (e) {
          print("❌ Error loading image: $e");
        }
      }
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Text(
                'File Details',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              /// Images Section
              if (images.isNotEmpty)
                pw.Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: images.map((img) {
                    return pw.Container(
                      height: 120,
                      width: 120,
                      child: pw.Image(img, fit: pw.BoxFit.cover),
                    );
                  }).toList(),
                ),

              pw.SizedBox(height: 20),

              pw.Text('File Name: $fileName'),
              pw.Text('Category: $category'),
              pw.Text('Comments: $comments'),
            ],
          );
        },
      ),
    );

    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/$fileName.pdf";
      final file = File(path);

      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(path);

    } catch (e) {
      print("❌ Error opening PDF: $e");
    }
  }

  ///Scan Tax Manager Api

  Future<Map<String, dynamic>?> scanTaxManagerApi(File? avatarFile) async {
    loading = true;
    notifyListeners();

    try {
      debugPrint("files path: ${avatarFile?.path}");

      final response = await taxManagerRepository.scanTaxManagerRepo(
        filesPath: avatarFile,
      );

      if (kDebugMode) {
        debugPrint("Scan TaxManager API Response: $response");
      }

      return response;
    } catch (e, stackTrace) {
      debugPrint("Scan TaxManager error: $e $stackTrace");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
  ///create personal info api

  Future<void> createPersonalInfoApi(BuildContext context, dynamic data) async {
    loading = true;
    notifyListeners();

    try {
      debugPrint("📦 Create Personal Info Request Body:\n${jsonEncode(data)}");

      final response = await taxManagerRepository.createPersonalInfoRepo(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);

        // 👇 return success to previous screen
        Navigator.pop(context, true);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("✅ Create Personal Info API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Create Personal Info Creation error: $e\n$stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  ///Get Personal Info api

  Future<void> getPersonalInfoApi(BuildContext context) async {
    loading = true;
    notifyListeners();

    try {
      final response = await taxManagerRepository.getPersonalInfoRepo();

      if (response.status == 1) {
        _personalInfo = response.data!;
        _getPersonalInfoModel = response;
        Utils.toastMessage(response.success ?? '');
      } else {
        Utils.toastMessage(response.success ?? '');
      }

      if (kDebugMode) {
        debugPrint("Get personal info API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get personal info data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// personal Forward file api

  Future<void> personalForwardFileApi(
      BuildContext context,
      dynamic data,
      int id,
      ) async {
    loading = true;

    try {
      debugPrint("Forward File data: $data");

      final response = await taxManagerRepository.forwardPersonalFileRepo(
        id: id,
        data: data,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Forward personal file API Response: $response");
      }
    } catch (e) {
      debugPrint("forward personal file error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }


  /// delete personal file api

  Future<bool> deletePersonalFileApi(BuildContext context, int id) async {
    loading = true;
    try {
      final response = await taxManagerRepository.deletePersonalFileRepo(id);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        if (kDebugMode) {
          debugPrint("Delete personal file API Response: $response");
        }
        // await getPersonalInfoApi(context);
        return true;
      } else {
        Utils.toastMessage(response["success"]);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("Delete personal file Api error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      return false;
    } finally {
      loading = false;
    }
  }

  /// print personal info api

  Future<String?> printPersonalInfoApi({
    required int id,
    required String language,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final result = await taxManagerRepository.printPersonalInfoRepo(
        id: id,
        language: language, // ✅ forwarded
      );

      if (result != null && result["status"] == 1 && result["file"] != null) {
        // ✅ Save PDF to local
        final response = result["file"] as http.Response;
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/report_$id.pdf';
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
      debugPrint("❌ printPersonalInfoApi error: $e $stack");
      Utils.toastMessage("Something went wrong");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  ///edit personal info api

  Future<void> editPersonalInfoApi(
    BuildContext context,
    dynamic data,
    int id,
  ) async {
    loading = true;
    try {
      debugPrint("📦 Edit Personal Info Request Body:\n${jsonEncode(data)}");

      final response = await taxManagerRepository.editPersonalInfoRepo(
        data,
        id,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GetPersonalInfoScreen()),
        );
        await getPersonalInfoApi(context);
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("✅ Edit Personal Info API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Edit Personal Info Creation error: $e\n$stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Get Previous info repo
  Future<void> getPreviousInfoApi(BuildContext context) async {
    loading = true;
    notifyListeners();

    try {
      final response = await taxManagerRepository.getPreviousInfoRepo();

      if (response.status == 1) {
        _getPreviousInfoModel = response;
        Utils.toastMessage(response.success ?? '');
      } else {
        Utils.toastMessage(response.success ?? '');
      }

      if (kDebugMode) {
        debugPrint("Get personal info API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get personal info data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUploadedFileApi(BuildContext context, int id) async {
    loading = true;
    try {
      final response = await taxManagerRepository.deleteUploadedFile(id);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        if (kDebugMode) {
          debugPrint("Delete uploaded file API Response: $response");
        }
        return true;
      } else {
        Utils.toastMessage(response["success"]);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("Delete file Api error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      return false;
    } finally {
      loading = false;
    }
  }
}
