import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_text_field.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/tax_manager_view_model/tax_manager_view_model.dart';

import '../../../res/app_assets.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';
import '../../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

class CreateTaxManagerScreen extends StatefulWidget {
  const CreateTaxManagerScreen({super.key, this.receiptData, this.receiptFile});
  final Map<String, dynamic>? receiptData;
  final File? receiptFile;

  @override
  State<CreateTaxManagerScreen> createState() => _CreateTaxManagerScreenState();
}

class _CreateTaxManagerScreenState extends State<CreateTaxManagerScreen> {
  final List<String> categories = ['Income', 'Expenses', 'Deductions'];
  final List<String> years = List.generate(7, (i) {
    final currentYear = DateTime.now().year;
    return '${currentYear - i}';
  });
  String? selectedYear;
  DateTime? selectedDate;
  String? selectedCategory;
  String? selectedFilePath;
  late String fileName;

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
    final data = widget.receiptData;
    final authViewModel = context.read<AuthViewModel>();

    fileName =
        widget.receiptFile != null
            ? widget.receiptFile!.path.split('/').last
            : 'No file chosen';

    if (data != null) {
      final yearFromData = int.tryParse(data['year'].toString());
      final now = DateTime.now();
      final minYear = now.year - 6;
      final maxYear = now.year;

      if (yearFromData != null &&
          yearFromData >= minYear &&
          yearFromData <= maxYear) {
        selectedYear = yearFromData.toString();
      } else {
        selectedYear = null; // Year is out of allowed range -> show empty
      }

      fileNameController.text = data['file_name'] ?? 'No File';
      selectedCategory = data['category'];
      if (data['date'] != null) {
        selectedDate = DateTime.tryParse(data['date']);
      }
    }
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
                )!.translate("createTaxManagerText") ??
                '',
            showBackButton: true,
            onBackTap: () {
              Navigator.of(context).pop();
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
                        strokeWidth: 4,
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
                            children: [buildForm()],
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

  Widget buildForm() {
    final provider = context.read<TaxManagerViewModel>();
    final authProvider = context.read<AuthViewModel>();
    final categories =
        provider.data
            .map((cat) => cat.value ?? "")
            .where((val) => val.isNotEmpty)
            .toSet()
            .toList();

    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      if (!categories.contains(selectedCategory)) {
        categories.insert(0, selectedCategory!);
      }
    }
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';

    final plans = context.watch<PricingPlansViewModel>();
    final planNames =
        plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();

    final isBusinessTaxManager = planNames.any(
      (n) => n.contains('business tax manager'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isBusinessTaxManager)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppLocalizations.of(context)!.translate("uploadReceiptText") ?? ''} *",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {},
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fileName,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          value: selectedYear,
          items:
              years.map((year) {
                return DropdownMenuItem(value: year, child: Text(year));
              }).toList(),

          // 🔥 CHANGE: auto set current date in that year
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

        // File Name
        AppTextField(
          controller: fileNameController,
          hintText:
              AppLocalizations.of(context)!.translate("fileNameText") ?? '',
          textInputType: TextInputType.name,
        ),
        const SizedBox(height: 12),

        // Category Dropdown
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

          /// Selected backend value
          value: selectedCategory,

          items:
              provider.data.where((e) => e.backendValue != null).map((cat) {
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
            final plans = context.watch<PricingPlansViewModel>();
            final planNames =
                plans.myPlans
                    .map((p) => p.name?.toLowerCase().trim() ?? '')
                    .toList();

            final isBusinessTaxManager = planNames.any(
              (n) => n.contains('business tax manager'),
            );

            if (!isBusinessTaxManager) {
              return const SizedBox.shrink();
            }

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
                    AppLocalizations.of(context)!.translate("updateFileText") ??
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

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldenOrangeColor,
                    ),
                    onPressed: () async {
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
                                    await authProvider.pickMultipleImages();
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
                      AppLocalizations.of(
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
                onPressed: () {},
                child: Text(
                  AppLocalizations.of(context)!.translate("cancelText") ?? '',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
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
                onPressed: () {
                  if (selectedYear == null) {
                    Utils.toastMessage("Please select year");
                  } else if (fileNameController.text.isEmpty) {
                    Utils.toastMessage("Please enter file name");
                  } else if (selectedCategory == null) {
                    Utils.toastMessage("Please select category");
                  } else if (selectedDate == null) {
                    Utils.toastMessage("Please select date");
                  } else {
                    Map<String, dynamic> fields = {
                      'year': selectedYear,
                      'file_name': fileNameController.text.trim(),
                      'category': selectedCategory,
                      'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
                      'comments': commentsController.text,
                    };

                    if (!isBusinessTaxManager) {
                      provider.createFileApi(
                        context,
                        fields,
                        widget.receiptFile != null ? [widget.receiptFile!] : [],
                      );
                    } else {
                      provider.createFileApi(
                        context,
                        fields,
                        authProvider.pickedImages
                            .map((x) => File(x.path))
                            .toList(),
                      );
                    }
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
                          AppLocalizations.of(context)!.translate("saveText") ??
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
