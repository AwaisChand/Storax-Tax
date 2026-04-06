import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_drawer.dart';
import 'package:storatax/screens/files/create_tax_manager/create_tax_manager_screen.dart';

import '../../../res/app_assets.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';
import '../../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';
import '../../../view_models/tax_manager_view_model/tax_manager_view_model.dart';
import '../dialog_box.dart';
import '../scan_tax_manager/scan_tax_manager_screen.dart';
import '../update_file/update_file_screen.dart';
import '../view_file_detail/view_file_detail.dart';
import '../widgets.dart';

enum FileMenuAction { view, edit, delete, forward, download }

class GetFilesScreen extends StatefulWidget {
  const GetFilesScreen({super.key});

  @override
  State<GetFilesScreen> createState() => _GetFilesScreenState();
}

class _GetFilesScreenState extends State<GetFilesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaxManagerViewModel>().getFilesApi(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate).toLocal();
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final plans = context.watch<PricingPlansViewModel>();
    final planNames =
        plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();

    final isBusinessTaxManager = planNames.any(
      (n) => n.contains('business tax manager'),
    );

    return Consumer<TaxManagerViewModel>(
      builder: (context, getFiles, _) {
        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          drawer: AppDrawer(),
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("taxManagerListText") ??
                '',
            text2:
                AppLocalizations.of(context)!.translate("manageTaxesText") ??
                '',
            drawerTapped: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: null,
            onPressed: () {
              if (isBusinessTaxManager) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTaxManagerScreen(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanTaxManagerScreen(),
                  ),
                );
              }
            },
            child: Icon(Icons.add, size: 40),
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
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            buildFilterBar(context),
                            const SizedBox(height: 15),
                            buildForwardMultipleButton(context),
                            const SizedBox(height: 15),
                            if (getFiles.isLoading)
                              SizedBox(
                                height: Utils.setHeight(context) * 0.5,
                                child: Center(
                                  child: SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                      color: AppColors.blackColor,
                                    ),
                                  ),
                                ),
                              )
                            else if (getFiles.fileData.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 50),
                                  child: Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("noFilesText") ??
                                        '',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: getFiles.fileData.length,
                                itemBuilder: (context, index) {
                                  final file = getFiles.fileData[index];
                                  final uploads =
                                      file.uploads?.isNotEmpty == true
                                          ? file.uploads!.first
                                          : null;
                                  final isSelected = selectedFileIds.contains(
                                    file.id,
                                  );

                                  return Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(
                                          bottom: 20,
                                        ),
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.65,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _rowWidget(
                                                        "${AppLocalizations.of(context)!.translate("uploadedDateText") ?? ''}:",
                                                        formatDate(
                                                          file.updatedAt ?? '',
                                                        ),
                                                      ),
                                                      _rowWidget(
                                                        "${AppLocalizations.of(context)!.translate("fileNameText") ?? ''}:",
                                                        " ${file.fileName}",
                                                      ),
                                                      _rowWidget(
                                                        "${AppLocalizations.of(context)!.translate("cateText") ?? ''}:",
                                                        " ${file.category}",
                                                      ),
                                                      _rowWidget(
                                                        "${AppLocalizations.of(context)!.translate("yearText") ?? ''}:",
                                                        " ${file.year}",
                                                      ),
                                                      _rowWidget(
                                                        "Date:",
                                                        " ${file.date}",
                                                      ),
                                                      if (isBusinessTaxManager) ...[
                                                        _rowWidget(
                                                          "${AppLocalizations.of(context)!.translate("statusText") ?? ''}:",
                                                          " ${file.status}",
                                                        ),
                                                        _rowWidget(
                                                          "${AppLocalizations.of(context)!.translate("uploadByText") ?? ''}:",
                                                          " ${file.uploadedBy}",
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),

                                                // Menu
                                                PopupMenuButton<FileMenuAction>(
                                                  onSelected: (action) {
                                                    final file =
                                                        getFiles
                                                            .fileData[index];
                                                    final uploads =
                                                        file.uploads?.isNotEmpty ==
                                                                true
                                                            ? file
                                                                .uploads!
                                                                .first
                                                            : null;

                                                    switch (action) {
                                                      case FileMenuAction.view:
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (
                                                                  _,
                                                                ) => ViewFileDetail(
                                                                  fileData:
                                                                      file,
                                                                  uploads:
                                                                      file.uploads,
                                                                ),
                                                          ),
                                                        );
                                                        break;
                                                      case FileMenuAction.edit:
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (_) =>
                                                                    UpdateFileScreen(
                                                                      fileData:
                                                                          file,
                                                                    ),
                                                          ),
                                                        );
                                                        break;
                                                      case FileMenuAction
                                                          .delete:
                                                        getFiles
                                                            .deleteFileApi(
                                                              context,
                                                              file.id ?? 0,
                                                            )
                                                            .then((success) {
                                                              if (success) {
                                                                setState(
                                                                  () => getFiles
                                                                      .fileData
                                                                      .removeAt(
                                                                        index,
                                                                      ),
                                                                );
                                                              }
                                                            });
                                                        break;
                                                      case FileMenuAction
                                                          .forward:
                                                        showForwardDialog(
                                                          context,
                                                          file.fileName ?? '',
                                                          file.id ?? 0,
                                                        );
                                                        break;
                                                      case FileMenuAction
                                                          .download:
                                                        getFiles.generateAndOpenPDF(
                                                          fileName:
                                                              file.fileName ??
                                                              '',
                                                          category:
                                                              file.category ??
                                                              '',
                                                          comments:
                                                              file.comments ??
                                                              '',
                                                          filePaths: file.uploads
                                                              ?.map((e) => e.filePath ?? '')
                                                              .toList(),
                                                        );
                                                        break;
                                                    }
                                                  },
                                                  itemBuilder:
                                                      (context) => [
                                                        _popupItem(
                                                          Icons.remove_red_eye,
                                                          AppLocalizations.of(
                                                                context,
                                                              )!.translate(
                                                                "viewText",
                                                              ) ??
                                                              '',
                                                          FileMenuAction.view,
                                                        ),
                                                        _popupItem(
                                                          Icons.edit,
                                                          AppLocalizations.of(
                                                                context,
                                                              )!.translate(
                                                                "editText",
                                                              ) ??
                                                              '',
                                                          FileMenuAction.edit,
                                                        ),
                                                        _popupItem(
                                                          Icons.delete,
                                                          AppLocalizations.of(
                                                                context,
                                                              )!.translate(
                                                                "deleteText",
                                                              ) ??
                                                              '',
                                                          FileMenuAction.delete,
                                                          color: Colors.red,
                                                        ),
                                                        _popupItem(
                                                          Icons.forward,
                                                          AppLocalizations.of(
                                                                context,
                                                              )!.translate(
                                                                "forwardFileText",
                                                              ) ??
                                                              '',
                                                          FileMenuAction
                                                              .forward,
                                                        ),
                                                        _popupItem(
                                                          Icons.download,
                                                          AppLocalizations.of(
                                                                context,
                                                              )!.translate(
                                                                "downFileText",
                                                              ) ??
                                                              '',
                                                          FileMenuAction
                                                              .download,
                                                        ),
                                                      ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Checkbox
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: Checkbox(
                                          value: isSelected,
                                          activeColor:
                                              AppColors.goldenOrangeColor,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedFileIds.add(
                                                  file.id ?? 0,
                                                );
                                              } else {
                                                selectedFileIds.remove(file.id);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PopupMenuItem<FileMenuAction> _popupItem(
    IconData icon,
    String text,
    FileMenuAction value, {
    Color color = Colors.black,
  }) {
    return PopupMenuItem<FileMenuAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowWidget(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
