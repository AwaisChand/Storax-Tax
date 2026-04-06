import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/files/create_personal_info/create_personal_file_screen.dart';
import 'package:storatax/screens/files/dialog_box.dart';
import 'package:storatax/screens/files/edit_personal_info/edit_personal_info_screen.dart';
import 'package:storatax/utils/app_colors.dart';

import '../../../res/app_assets.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/utils.dart';
import '../../../view_models/tax_manager_view_model/tax_manager_view_model.dart';

class GetPersonalInfoScreen extends StatefulWidget {
  const GetPersonalInfoScreen({super.key});

  @override
  State<GetPersonalInfoScreen> createState() => _GetPersonalInfoScreenState();
}

class _GetPersonalInfoScreenState extends State<GetPersonalInfoScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TaxManagerViewModel>();
      if (provider.personalInfo.isEmpty) {
        provider.getPersonalInfoApi(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = AppLocalizations.of(context)?.locale.languageCode;
    return Consumer<TaxManagerViewModel>(
      builder: (context, taxManager, _) {
        return Scaffold(
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(
                  context,
                )!.translate("incomeTaxPersonalInfoText") ??
                '',
            showBackButton: true,
            onBackTap: () => Navigator.pop(context),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePersonalFileScreen(),
                ),
              );

              if (result == true) {
                context.read<TaxManagerViewModel>().getPersonalInfoApi(context);
              }
            },
            child: const Icon(Icons.add, size: 40),
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
                child:
                    taxManager.isLoading
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
                        : taxManager.personalInfo.isEmpty
                        ? Center(
                          child: Text(
                            AppLocalizations.of(
                                  context,
                                )!.translate("noPersonalInfoText") ??
                                '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        )
                        : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: taxManager.personalInfo.length,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: double.infinity,
                                    height: Utils.setHeight(context) * 0.24,
                                    margin: const EdgeInsets.only(
                                      right: 20,
                                      left: 20,
                                      top: 20,
                                    ),
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Main info content
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _rowWidget(
                                              "${AppLocalizations.of(context)!.translate("yearText") ?? ''}:",
                                              "${taxManager.personalInfo[index].year}",
                                            ),
                                            const SizedBox(height: 5),
                                            _rowWidget(
                                              "${AppLocalizations.of(context)!.translate("firstNameText") ?? ''}:",
                                              "${taxManager.personalInfo[index].firstName}",
                                            ),
                                            const SizedBox(height: 5),
                                            _rowWidget(
                                              "${AppLocalizations.of(context)!.translate("lastNameText") ?? ''}:",
                                              "${taxManager.personalInfo[index].lastName}",
                                            ),
                                            const SizedBox(height: 5),
                                            _rowWidget(
                                              "${AppLocalizations.of(context)!.translate("emailText") ?? ''}:",
                                              "${taxManager.personalInfo[index].email}",
                                            ),
                                            const SizedBox(height: 5),
                                            _rowWidget(
                                              "${AppLocalizations.of(context)!.translate("canadianCText") ?? ''}:",
                                              taxManager
                                                          .personalInfo[index]
                                                          .canadianCitizen ==
                                                      true
                                                  ? "Yes"
                                                  : "No",
                                            ),
                                            const SizedBox(height: 5),
                                            _rowWidget(
                                              "${AppLocalizations.of(context)!.translate("createdText") ?? ''}:",
                                              taxManager
                                                          .getPersonalInfoModel
                                                          ?.data?[index]
                                                          .createdAt !=
                                                      null
                                                  ? formatDateOnly(
                                                    taxManager
                                                        .getPersonalInfoModel!
                                                        .data![index]
                                                        .createdAt!,
                                                  )
                                                  : "N/A",
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          bottom: 0,
                                          child: Center(
                                            child: PopupMenuButton<String>(
                                              onSelected: (value) async {
                                                switch (value) {
                                                  case 'Forward File':
                                                    showPersonalForwardDialog(
                                                      context,
                                                      taxManager
                                                          .personalInfo[index]
                                                          .firstName!,
                                                      taxManager
                                                          .personalInfo[index]
                                                          .id!,
                                                      index,
                                                    );
                                                    break;
                                                  case 'Edit':
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              _,
                                                            ) => EditPersonalInfoScreen(
                                                              personalInfoList:
                                                                  taxManager
                                                                      .personalInfo[index],
                                                              dependent:
                                                                  (taxManager
                                                                          .personalInfo[index]
                                                                          .dependents ??
                                                                      []),
                                                            ),
                                                      ),
                                                    );
                                                    break;
                                                  case 'Print':
                                                    Utils.toastMessage(
                                                      AppLocalizations.of(
                                                            context,
                                                          )!.translate(
                                                            "preparingPdf",
                                                          ) ??
                                                          '',
                                                    );
                                                    final pdfPath = await taxManager
                                                        .printPersonalInfoApi(
                                                          id:
                                                              taxManager
                                                                  .personalInfo[index]
                                                                  .id!,
                                                          language:
                                                              language ?? '',
                                                        );

                                                    if (pdfPath != null) {
                                                      final file = File(
                                                        pdfPath,
                                                      );
                                                      if (await file.exists()) {
                                                        await Printing.layoutPdf(
                                                          onLayout:
                                                              (_) async =>
                                                                  await file
                                                                      .readAsBytes(),
                                                          name:
                                                              "Personal_Info_${taxManager.personalInfo[index].firstName}.pdf",
                                                        );
                                                      } else {
                                                        Utils.toastMessage(
                                                          "PDF file not found.",
                                                        );
                                                      }
                                                    } else {
                                                      Utils.toastMessage(
                                                        "Failed to load PDF file.",
                                                      );
                                                    }
                                                    break;
                                                  case 'Delete':
                                                    taxManager
                                                        .deletePersonalFileApi(
                                                          context,
                                                          taxManager
                                                              .personalInfo[index]
                                                              .id!,
                                                        )
                                                        .then((success) {
                                                          if (success) {
                                                            setState(() {
                                                              taxManager
                                                                  .personalInfo
                                                                  .removeAt(
                                                                    index,
                                                                  );
                                                            });
                                                          }
                                                        });
                                                    break;
                                                }
                                              },
                                              itemBuilder:
                                                  (BuildContext context) => [
                                                    PopupMenuItem(
                                                      value: 'Forward File',
                                                      child: Text(
                                                        AppLocalizations.of(
                                                              context,
                                                            )!.translate(
                                                              "forwardFileText",
                                                            ) ??
                                                            '',
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 'Edit',
                                                      child: Text(
                                                        AppLocalizations.of(
                                                              context,
                                                            )!.translate(
                                                              "editText",
                                                            ) ??
                                                            '',
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 'Print',
                                                      child: Text(
                                                        AppLocalizations.of(
                                                              context,
                                                            )!.translate(
                                                              "printText",
                                                            ) ??
                                                            '',
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 'Delete',
                                                      child: Text(
                                                        AppLocalizations.of(
                                                              context,
                                                            )!.translate(
                                                              "deleteText",
                                                            ) ??
                                                            '',
                                                      ),
                                                    ),
                                                  ],
                                              icon: const Icon(
                                                Icons.more_vert,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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

  static String formatDateOnly(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Invalid date";
    }
  }

  Widget _rowWidget(String text1, text2) {
    return Row(
      children: [
        Text(
          text1,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        SizedBox(width: 10),
        Text(
          text2,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
