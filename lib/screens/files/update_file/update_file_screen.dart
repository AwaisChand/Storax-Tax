import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storatax/models/get_file_model/get_file_model.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/tax_manager_view_model/tax_manager_view_model.dart';

import '../../../models/get_category_model/get_category_model.dart';
import '../../../res/app_assets.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';
import '../../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

class UpdateFileScreen extends StatefulWidget {
  const UpdateFileScreen({super.key, required this.fileData});
  final FileData fileData;

  @override
  State<UpdateFileScreen> createState() => _UpdateFileScreenState();
}

class _UpdateFileScreenState extends State<UpdateFileScreen> {
  final List<String> categories = ['Income', 'Expenses', 'Deductions'];
  final List<String> years = List.generate(7, (i) {
    final currentYear = DateTime.now().year;
    return '${currentYear - i}';
  });
  String? selectedYear;
  DateTime? selectedDate;
  String? selectedCategory;
  String? selectedFilePath;
  int? index;
  late String fileName;
  File? pickedReceipt;
  TextEditingController fileNameController = TextEditingController();
  TextEditingController commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final currentYear = DateTime.now().year.toString();
    if (years.contains(currentYear)) {
      selectedYear = currentYear;
      selectedDate = DateTime.now();
    }
    final file = widget.fileData;

    fileNameController.text = file.fileName ?? '';
    selectedYear = file.year;
    selectedCategory = file.category?.trim();
    selectedDate = DateTime.tryParse(file.date ?? '');
    commentsController.text = file.comments ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TaxManagerViewModel>();
      provider.getCategoryApi(context);
    });
    Future.microtask(() {
      context.read<AuthViewModel>().clearPickedImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaxManagerViewModel>(
      builder: (context, taxManager, _) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(
                  context,
                )!.translate("updateTaxManagerText") ??
                '',
            showBackButton: true,
            onBackTap: () {
              Navigator.pop(context);
            },
          ),
          body: Stack(
            children: [
              // Background image
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
                      ),
                    ),
                  )
                  : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            right: 20,
                            left: 20,
                            bottom: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (taxManager.fileData.isNotEmpty)
                                buildForm(
                                  fileData: taxManager.fileData[index ?? 0],
                                )
                              else
                                Text(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("noFileAText") ??
                                      '',
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget buildForm({required FileData fileData}) {
    final provider = context.read<TaxManagerViewModel>();
    final authProvider = context.read<AuthViewModel>();
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    final plans = context.watch<PricingPlansViewModel>();
    final planNames =
        plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();

    final isBusinessTaxManager = planNames.any(
      (n) => n.contains('business tax manager'),
    );
    final now = DateTime.now();
    final years = List.generate(7, (i) => (now.year - i).toString());

    final categoryItems = provider.data
        .where((e) => e.backendValue != null)
        .toList()
        .fold<List<CategoryData>>([], (acc, cat) {
          if (!acc.any((c) => c.backendValue == cat.backendValue)) {
            acc.add(cat);
          }
          return acc;
        });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isBusinessTaxManager)
          Consumer<TaxManagerViewModel>(
            builder: (context, taxManagerVM, _) {
              final authVM = context.read<AuthViewModel>();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      /// Pick image
                      final image = await authVM.pickImageFromGallery();
                      if (image == null) return;

                      setState(() {
                        pickedReceipt = image;
                      });

                      /// Automatically start scanning
                      try {
                        final result = await taxManagerVM.scanTaxManagerApi(
                          image,
                        );

                        if (result != null &&
                            result["status"].toString() == "1") {
                          final data = result["data"];

                          setState(() {
                            fileNameController.text = data['file_name'] ?? '';
                            commentsController.text = data['comment'] ?? '';
                            selectedYear = data['year']?.toString();
                            selectedDate =
                                data['date'] != null
                                    ? DateTime.tryParse(data['date'])
                                    : null;

                            if (data['category'] != null &&
                                taxManagerVM.data.isNotEmpty) {
                              final apiCategory =
                                  data['category'].toString().trim();
                              final match = taxManagerVM.data.firstWhere(
                                (c) =>
                                    c.backendValue.toString().trim() ==
                                    apiCategory,
                                orElse: () => taxManagerVM.data.first,
                              );
                              selectedCategory = match.backendValue;
                            }
                          });

                          Utils.toastMessage(
                            result["success"] ?? "Scan Successful",
                          );
                        } else {
                          Utils.toastMessage("Scan failed");
                        }
                      } catch (e) {
                        debugPrint("Scan Tax Manager API error: $e");
                        Utils.toastMessage("Scan failed");
                      }
                    },
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey.shade100,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade400),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Choose File",
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                pickedReceipt?.path.split('/').last ??
                                    "No file chosen",
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      pickedReceipt != null
                                          ? Colors.grey.shade600
                                          : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Display picked image with loader overlay
                  if (pickedReceipt != null)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(pickedReceipt!.path),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (taxManagerVM.isLoading)
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha:0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              );
            },
          ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.translate("taxSummaryText") ?? '',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 13,
              horizontal: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
            ),
          ),
          hint: Text(
            AppLocalizations.of(context)!.translate("selectYearText") ?? '',
          ),

          // Only allow value if it exists in `years`
          initialValue: years.contains(selectedYear) ? selectedYear : null,

          items:
              years.map((year) {
                return DropdownMenuItem<String>(value: year, child: Text(year));
              }).toList(),

          onChanged: (value) {
            setState(() {
              selectedYear = value;
              selectedDate = null; // reset date when year changes
            });
          },
        ),
        const SizedBox(height: 12),

        // File Name
        AppTextField(
          controller: fileNameController,
          hintText:
              AppLocalizations.of(context)!.translate("fileNameText") ?? '',
          textInputType: TextInputType.name,
        ),
        const SizedBox(height: 12),

        Text(
          AppLocalizations.of(context)!.translate("selectCateText") ?? '',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 13,
              horizontal: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
            ),
          ),
          hint: Text(isFrench ? "Choisir" : "Choose One"),

          initialValue:
              categoryItems.any((c) => c.backendValue == selectedCategory)
                  ? selectedCategory
                  : null,

          items:
              categoryItems.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat.backendValue,
                  child: Text(cat.getDisplayLabel(isFrench)),
                );
              }).toList(),

          onChanged: (value) {
            setState(() {
              selectedCategory = value;
            });
            debugPrint("Selected backend value: $selectedCategory");
          },
        ),
        const SizedBox(height: 12),

        // Date Picker
        Text(
          AppLocalizations.of(context)!.translate("choiceYearText") ?? '',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final now = DateTime.now();

            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? now,
              firstDate: DateTime(now.year - 6, 1, 1), // last 7 years
              lastDate: now, // today
            );

            if (picked != null) {
              setState(() {
                selectedDate = picked;
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
              ),
              suffixIcon: Icon(
                Icons.calendar_today,
                size: 20,
                color: AppColors.goldenOrangeColor,
              ),
            ),
            child: Text(
              selectedDate != null
                  ? "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}"
                  : "mm/dd/yyyy",
              style: TextStyle(
                color:
                    selectedDate != null ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Upload File Section
        Consumer<AuthViewModel>(
          builder: (context, authProvider, child) {
            bool isBusinessPlan =
                authProvider.user?.plan == "Business Tax Manager";

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.goldenOrangeColor,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.orange.shade50,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 50,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.translate("uploadFileText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.pureGrayColor,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(
                          context,
                        )!.translate("copyAttachmentText") ??
                        '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: AppColors.pureGrayColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Upload button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldenOrangeColor,
                    ),
                    onPressed: () async {
                      // ✅ Show BottomSheet for options
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.photo_library,
                                    color: Colors.orange,
                                  ),
                                  title: Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("galleryText") ??
                                        '',
                                  ),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    if (isBusinessPlan) {
                                      await authProvider.pickMultipleImages();
                                    } else {
                                      await authProvider
                                          .pickSingleImageFromGallery();
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.orange,
                                  ),
                                  title: Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("cameraText") ??
                                        '',
                                  ),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await authProvider
                                        .pickSingleImageFromCamera();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      isBusinessPlan
                          ? AppLocalizations.of(
                                context,
                              )!.translate("chooseFileText") ??
                              ''
                          : AppLocalizations.of(
                                context,
                              )!.translate("chooseFileText") ??
                              '',
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (authProvider.pickedImages.isNotEmpty)
                    Column(
                      children:
                          authProvider.pickedImages.map((img) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Image.file(
                                    File(img.path),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(width: 10),
                                  // File name
                                  Expanded(
                                    child: Text(
                                      img.path.split('/').last,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 15),
        AppTextField(
          controller: commentsController,
          hintText:
              AppLocalizations.of(context)!.translate("commentsText") ?? '',
          textInputType: TextInputType.text,
          maxLines: 3,
        ),
        SizedBox(height: 8),
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
                onPressed: () {},
                child: Text(
                  AppLocalizations.of(context)!.translate("cancelText") ?? '',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              MaterialButton(
                height: 40,
                color: AppColors.goldenOrangeColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onPressed: () {
                  {
                    Map<String, dynamic> fields = {
                      'year': selectedYear,
                      'file_name': fileNameController.text.trim(),
                      'category': selectedCategory,
                      'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
                      'comments': commentsController.text.toString(),
                    };

                    provider.updateFileApi(
                      id: fileData.id ?? 0,
                      context: context,
                      fields: fields,
                      avatarFiles:
                          authProvider.pickedImages
                              .map((x) => File(x.path))
                              .toList(),
                    );
                    debugPrint("id: ${fileData.id}");
                  }
                },
                child:
                    provider.isLoading
                        ? Center(
                          child: SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.blackColor,
                            ),
                          ),
                        )
                        : Text(
                          AppLocalizations.of(
                                context,
                              )!.translate("updateText") ??
                              '',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
