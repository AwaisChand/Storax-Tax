import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:storatax/models/get_file_model/get_file_model.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/screens/files/scan_tax_manager/crop_document_dialog.dart';
import 'package:storatax/screens/files/scan_tax_manager/scanned_receipt.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/tax_manager_view_model/tax_manager_view_model.dart';

import '../../../res/app_assets.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/camera_permission.dart';
import '../../../utils/scan_upload_file.dart';
import '../../../utils/utils.dart';
import '../../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

class UpdateFileScreen extends StatefulWidget {
  const UpdateFileScreen({super.key, required this.fileData});

  final FileData fileData;

  @override
  State<UpdateFileScreen> createState() => _UpdateFileScreenState();
}

class _UpdateFileScreenState extends State<UpdateFileScreen> {
  static const int _yearWindow = 7;
  static const int _maxFileBytes = 5 * 1024 * 1024;
  static const Color _borderGrey = Color(0xFFD0D5DD);
  static const Color _panelBorder = Color(0xFFD6DCEA);
  static const Color _chooserFill = Color(0xFFF8F9FB);
  static const Color _mutedText = Color(0xFF6B7280);
  static const Color _hintText = Color(0xFF8B93A7);

  late final List<String> _years;
  String? selectedYear;
  DateTime? selectedDate;
  String? selectedCategory;

  final TextEditingController fileNameController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  final List<ScannedReceipt> _receipts = [];
  bool _isIngesting = false;

  String _t(String key) => AppLocalizations.of(context)?.translate(key) ?? '';

  bool get _isBusinessTaxManager {
    final plans = context.read<PricingPlansViewModel>();
    return plans.myPlans
        .map((p) => p.name?.toLowerCase().trim() ?? '')
        .any((name) => name.contains('business tax manager'));
  }

  bool _isYearAllowed(int year) {
    final now = DateTime.now();
    return year >= now.year - (_yearWindow - 1) && year <= now.year;
  }

  String? _redactedPathOf(ScannedReceipt receipt) {
    final fromReceipt = receipt.redactedTempPath;
    if (fromReceipt != null && fromReceipt.isNotEmpty) return fromReceipt;
    return receipt.scanData?['redacted_temp_path']?.toString();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _years = List.generate(_yearWindow, (i) => '${now.year - i}');

    final file = widget.fileData;
    fileNameController.text = file.fileName ?? '';
    commentsController.text = file.comments ?? '';
    selectedCategory = file.category?.trim();
    selectedDate = DateTime.tryParse(file.date ?? '') ?? now;
    final yearFromFile = int.tryParse(file.year ?? '');
    selectedYear =
        yearFromFile != null && _isYearAllowed(yearFromFile)
            ? yearFromFile.toString()
            : (_years.contains(file.year) ? file.year : now.year.toString());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaxManagerViewModel>().getCategoryApi(context);
      context.read<AuthViewModel>().clearPickedImages();
    });
  }

  @override
  void dispose() {
    fileNameController.dispose();
    commentsController.dispose();
    super.dispose();
  }

  Future<bool> _ensureFileSizeOk(File file) async {
    try {
      if (await file.length() > _maxFileBytes) {
        Utils.toastMessage(_t('fileTooLargeText'));
        return false;
      }
    } catch (_) {}
    return true;
  }

  Future<File> _copyToTemp(File original) async {
    final dir = await getTemporaryDirectory();
    final newPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${path.basename(original.path)}';
    return original.copy(newPath);
  }

  Future<File> _prepareCameraImage(File file) async {
    var persisted = file;
    try {
      persisted = await _copyToTemp(file);
    } catch (_) {}

    try {
      final dir = await getTemporaryDirectory();
      final target =
          '${dir.path}/tax_detect_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final out = await FlutterImageCompress.compressAndGetFile(
        persisted.absolute.path,
        target,
        quality: 90,
        format: CompressFormat.jpeg,
        autoCorrectionAngle: true,
      );
      if (out != null) {
        final jpeg = File(out.path);
        if (await jpeg.exists() && await jpeg.length() > 0) {
          return jpeg;
        }
      }
    } catch (_) {}

    return normalizeScanUploadToJpegIfNeeded(
      persisted,
      logFlow: 'TaxManagerUpdate',
    );
  }

  bool _guardNewFile() {
    final blocked =
        _isIngesting || (!_isBusinessTaxManager && _receipts.isNotEmpty);
    if (blocked) {
      Utils.toastMessage(_t('finishCurrentFileText'));
      return false;
    }
    return true;
  }

  Future<void> _openCropThenAdd(File image) async {
    if (!mounted) return;
    final result = await CropDocumentDialog.open(
      context,
      imageFile: image,
      fileName: path.basename(image.path),
    );
    if (!mounted || result == null) return;

    var size = 0;
    try {
      size = await result.file.length();
    } catch (_) {}

    final tempPath =
        result.redactedTempPath ??
        result.scanData?['redacted_temp_path']?.toString();

    setState(() {
      if (!_isBusinessTaxManager) _receipts.clear();
      _receipts.add(
        ScannedReceipt(
          id: '${DateTime.now().millisecondsSinceEpoch}_${_receipts.length}',
          file: result.file,
          displayName: result.fileName,
          status: 'ready',
          sizeBytes: size,
          scanData: result.scanData,
          redactedTempPath: tempPath,
        ),
      );
    });
    _applyScanData(result.scanData);
  }

  Future<void> _showPickSheet() async {
    if (!_guardNewFile()) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppColors.goldenOrangeColor,
                ),
                title: Text(_t('galleryText')),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickFromGallery();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: AppColors.goldenOrangeColor,
                ),
                title: Text(_t('cameraText')),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _startSmartCameraCapture();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    if (!_guardNewFile()) return;
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      _isIngesting = true;
      final raw = File(image.path);
      if (!await _ensureFileSizeOk(raw)) return;
      await _openCropThenAdd(raw);
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      _isIngesting = false;
    }
  }

  Future<void> _startSmartCameraCapture() async {
    if (!_guardNewFile()) return;
    final granted = await ensureCameraPermission(context);
    if (!granted) return;

    _isIngesting = true;
    try {
      if (Platform.isAndroid) {
        final scanner = DocumentScanner(
          options: DocumentScannerOptions(
            documentFormats: {DocumentFormat.jpeg},
            mode: ScannerMode.full,
            isGalleryImport: false,
            pageLimit: 1,
          ),
        );
        final result = await scanner.scanDocument();
        if (result.images != null && result.images!.isNotEmpty) {
          await _processCameraFile(File(result.images!.first));
        }
        await scanner.close();
      } else if (Platform.isIOS) {
        final pictures = await CunningDocumentScanner.getPictures(
          noOfPages: 1,
          isGalleryImportAllowed: true,
        );
        if (pictures != null && pictures.isNotEmpty) {
          var cleanedPath = pictures.first;
          if (cleanedPath.startsWith('file://')) {
            cleanedPath = cleanedPath.replaceFirst('file://', '');
          }
          await _processCameraFile(File(Uri.decodeFull(cleanedPath)));
        }
      }
    } catch (e) {
      if (!e.toString().toLowerCase().contains('cancel')) {
        Utils.toastMessage(_t('cameraLaunchFailedText'));
      }
    } finally {
      _isIngesting = false;
    }
  }

  Future<void> _processCameraFile(File file) async {
    var retry = 0;
    while (!await file.exists() && retry < 5) {
      await Future.delayed(const Duration(milliseconds: 200));
      retry++;
    }
    if (!await file.exists()) {
      Utils.toastMessage(_t('scannedFileNotFoundText'));
      return;
    }
    if (!await _ensureFileSizeOk(file)) return;
    final prepared = await _prepareCameraImage(file);
    if (!mounted) return;
    await _openCropThenAdd(prepared);
  }

  void _applyScanData(Map<String, dynamic>? data) {
    if (data == null) return;
    setState(() {
      final name = data['file_name']?.toString();
      if (name != null && name.isNotEmpty) {
        fileNameController.text = name;
      }
      final category = data['category']?.toString();
      if (category != null && category.isNotEmpty) {
        selectedCategory = category;
      }
      if (data['date'] != null) {
        selectedDate =
            DateTime.tryParse(data['date'].toString()) ?? selectedDate;
      }
      final yearFromData = int.tryParse(data['year']?.toString() ?? '');
      if (yearFromData != null && _isYearAllowed(yearFromData)) {
        selectedYear = yearFromData.toString();
      }
    });
  }

  bool _attachRedactedTempPaths(Map<String, dynamic> fields) {
    if (_receipts.isEmpty) return true;

    final paths = <String>[];
    for (final receipt in _receipts) {
      final pathValue = _redactedPathOf(receipt);
      if (pathValue == null || pathValue.isEmpty) {
        Utils.toastMessage(_t('scanEachFileBeforeSaveText'));
        return false;
      }
      paths.add(pathValue);
    }

    if (paths.length == 1) {
      fields['redacted_temp_path'] = paths.first;
    } else {
      for (var i = 0; i < paths.length; i++) {
        fields['redacted_temp_path[$i]'] = paths[i];
      }
    }
    return true;
  }

  void _onUpdate(TaxManagerViewModel provider) {
    if (selectedYear == null) {
      Utils.toastMessage(_t('pleaseSelectYear'));
      return;
    }
    if (fileNameController.text.trim().isEmpty) {
      Utils.toastMessage(_t('pleaseEnterFileNameText'));
      return;
    }
    if (selectedCategory == null) {
      Utils.toastMessage(_t('pleaseSelectCategoryText'));
      return;
    }
    if (selectedDate == null) {
      Utils.toastMessage(_t('pleaseSelectDateText'));
      return;
    }

    final fields = <String, dynamic>{
      'year': selectedYear,
      'file_name': fileNameController.text.trim(),
      'category': selectedCategory,
      'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
      'comments': commentsController.text,
    };

    if (!_attachRedactedTempPaths(fields)) return;

    provider.updateFileApi(
      id: widget.fileData.id ?? 0,
      context: context,
      fields: fields,
    );
  }

  InputDecoration get _inputDecoration => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
    ),
  );

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
    );
  }

  Widget _fileChooserRow({
    required String actionLabel,
    required String chosenLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _borderGrey),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(
                color: _chooserFill,
                border: Border(right: BorderSide(color: _borderGrey)),
              ),
              alignment: Alignment.center,
              child: Text(
                actionLabel,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF444444),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                chosenLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 13, color: _mutedText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadPanel({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _panelBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _receiptList() {
    return Column(
      children:
          _receipts.map((receipt) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ScannedReceiptCard(
                receipt: receipt,
                onRemove: () {
                  setState(
                    () => _receipts.removeWhere((r) => r.id == receipt.id),
                  );
                },
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTaxManagerScan() {
    final chosenLabel =
        _receipts.isEmpty ? _t('noFileChosenText') : _receipts.first.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('uploadReceiptText'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        _uploadPanel(
          children: [
            _fileChooserRow(
              actionLabel: _t('chooseFileText'),
              chosenLabel: chosenLabel,
              onTap: _showPickSheet,
            ),
            const SizedBox(height: 10),
            Text(
              _t('dropFilesHintText'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.4,
                color: _hintText,
              ),
            ),
          ],
        ),
        _receiptList(),
      ],
    );
  }

  Widget _buildBusinessUpload() {
    final chosenLabel =
        _receipts.isEmpty
            ? _t('noFileChosenText')
            : '${_receipts.length} ${_t('filesChosenText')}';

    return Column(
      children: [
        _uploadPanel(
          children: [
            _fileChooserRow(
              actionLabel: _t('chooseFilesText'),
              chosenLabel: chosenLabel,
              onTap: _showPickSheet,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _showPickSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldenOrangeColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                _t('addMoreFilesText'),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _t('dropFilesHintText'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.4,
                color: _hintText,
              ),
            ),
          ],
        ),
        _receiptList(),
      ],
    );
  }

  Widget _buildForm() {
    final provider = context.read<TaxManagerViewModel>();
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    final plans = context.watch<PricingPlansViewModel>();
    final isBusiness = plans.myPlans
        .map((p) => p.name?.toLowerCase().trim() ?? '')
        .any((name) => name.contains('business tax manager'));

    final categoryValue =
        provider.data.any((c) => c.backendValue == selectedCategory)
            ? selectedCategory
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isBusiness) _buildTaxManagerScan(),
        if (!isBusiness) const SizedBox(height: 16),
        _fieldLabel(_t('taxSummaryText')),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          decoration: _inputDecoration,
          hint: Text(_t('selectYearText')),
          initialValue: _years.contains(selectedYear) ? selectedYear : null,
          items:
              _years
                  .map(
                    (year) => DropdownMenuItem(value: year, child: Text(year)),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              selectedYear = value;
              if (value != null) {
                final year = int.parse(value);
                final now = DateTime.now();
                selectedDate = DateTime(year, now.month, now.day);
              }
            });
          },
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: fileNameController,
          hintText: _t('fileNameText'),
          textInputType: TextInputType.name,
        ),
        const SizedBox(height: 12),
        _fieldLabel(_t('selectCateText')),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          decoration: _inputDecoration,
          hint: Text(_t('chooseOneText')),
          initialValue: categoryValue,
          items:
              provider.data
                  .where((e) => e.backendValue != null)
                  .map(
                    (cat) => DropdownMenuItem<String>(
                      value: cat.backendValue,
                      child: Text(cat.getDisplayLabel(isFrench)),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => selectedCategory = value),
        ),
        const SizedBox(height: 12),
        _fieldLabel(_t('choiceYearText')),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? now,
              firstDate: DateTime(now.year - (_yearWindow - 1), 1, 1),
              lastDate: now,
            );
            if (picked != null) {
              setState(() => selectedDate = picked);
            }
          },
          child: InputDecorator(
            decoration: _inputDecoration.copyWith(
              suffixIcon: Icon(
                Icons.calendar_today,
                size: 20,
                color: AppColors.goldenOrangeColor,
              ),
            ),
            child: Text(
              selectedDate != null
                  ? DateFormat('MM/dd/yyyy').format(selectedDate!)
                  : _t('datePlaceholderText'),
              style: TextStyle(
                color:
                    selectedDate != null
                        ? AppColors.blackColor
                        : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (isBusiness) _buildBusinessUpload(),
        if (isBusiness) const SizedBox(height: 15),
        AppTextField(
          controller: commentsController,
          hintText: _t('commentsText'),
          textInputType: TextInputType.text,
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MaterialButton(
                height: 40,
                color: AppColors.lightPinkColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  _t('cancelText'),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              MaterialButton(
                height: 40,
                color: AppColors.goldenOrangeColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onPressed:
                    provider.isLoading ? null : () => _onUpdate(provider),
                child:
                    provider.isLoading
                        ? SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.blackColor,
                          ),
                        )
                        : Text(
                          _t('updateText'),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaxManagerViewModel>(
      builder: (context, taxManager, _) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: CustomAppBar(
            text1: _t('updateTaxManagerText'),
            showBackButton: true,
            onBackTap: () => Navigator.of(context).pop(),
          ),
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.backgroundImg),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              taxManager.categoryLoading
                  ? Center(
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: AppColors.blackColor,
                        strokeWidth: 4,
                      ),
                    ),
                  )
                  : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: _buildForm(),
                  ),
            ],
          ),
        );
      },
    );
  }
}
