import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/gasoline_view_model/gasoline_view_model.dart';
import 'package:storatax/view_models/quebec_view_model/quebec_view_model.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/camera_permission.dart';
import '../../../../../../../utils/doc_scanner_ios_result.dart';
import '../../../../../../../utils/scan_flow_log.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../res/components/app_localization.dart';
import '../quebec_create_screens/rides_gross_screen.dart';

class ScanQuebecScreen extends StatefulWidget {
  const ScanQuebecScreen({super.key});

  @override
  State<ScanQuebecScreen> createState() => _ScanQuebecScreenState();
}

class _ScanQuebecScreenState extends State<ScanQuebecScreen> {
  File? pickedFile;

  /// `gallery` | `pdf` | `doc_scanner` (for tracing iOS PNG vs JPG/PDF paths).
  String _receiptSource = 'unknown';

  Future<void> startSmartQuebecCameraCapture() async {
    // Camera permission must be granted before any iOS/Android doc-scanner.
    // See `ensureCameraPermission` for the full state machine and rationale.
    final granted = await ensureCameraPermission(context);
    if (!granted) {
      docScannerLog(
        'QuebecScan',
        'startSmartQuebecCameraCapture aborted (camera permission not granted)',
      );
      return;
    }

    quebecScanLog('UI: opening document scanner / smart camera capture');
    docScannerLog(
      'QuebecScan',
      'startSmartQuebecCameraCapture begin os=${Platform.operatingSystem}',
    );
    try {
      if (Platform.isAndroid) {
        // --- ANDROID: Google ML Kit Scanner ---
        final options = DocumentScannerOptions(
          documentFormats: {DocumentFormat.jpeg},
          mode: ScannerMode.full,
          isGalleryImport: false,
          pageLimit: 1,
        );

        final documentScanner = DocumentScanner(options: options);
        final result = await documentScanner.scanDocument();
        final n = result.images?.length ?? 0;
        docScannerLog('QuebecScan', 'Android ML Kit scan finished imageCount=$n');

        if (result.images != null && result.images!.isNotEmpty) {
          final File capturedFile = File(result.images!.first);

          if (!mounted) return;

          _receiptSource = 'doc_scanner';
          quebecScanLog(
            'UI: pickedFile set source=doc_scanner (Android ML Kit) path=${capturedFile.path}',
          );
          docScannerLog(
            'QuebecScan',
            'pickedFile set from ML Kit path=${capturedFile.path} exists=${capturedFile.existsSync()}',
          );
          setState(() {
            pickedFile = capturedFile;
          });
        } else {
          docScannerLog('QuebecScan', 'Android ML Kit: no images returned');
        }

        await documentScanner.close();

      } else if (Platform.isIOS) {
        // --- iOS: VisionKit via flutter_doc_scanner ---
        final result = await FlutterDocScanner().getScanDocuments();
        final paths = pathsFromIosDocScannerResult(result, flow: 'QuebecScan');
        if (paths.isNotEmpty) {
          final File capturedFile = File(paths.first);

          if (!mounted) return;

          _receiptSource = 'doc_scanner';
          quebecScanLog(
            'UI: pickedFile set source=doc_scanner (iOS VisionKit) path=${capturedFile.path}',
          );
          docScannerLog(
            'QuebecScan',
            'pickedFile set from iOS doc scan path=${capturedFile.path} exists=${capturedFile.existsSync()}',
          );
          setState(() {
            pickedFile = capturedFile;
          });
        } else {
          docScannerLog(
            'QuebecScan',
            'iOS doc scan: normalized paths empty',
          );
        }
      }
    } catch (e, st) {
      docScannerLog('QuebecScan', 'startSmartQuebecCameraCapture error: $e');
      debugPrintStack(stackTrace: st);

      if (e.toString().toLowerCase().contains("cancel")) {
        docScannerLog('QuebecScan', 'user cancelled scan (message matched)');
      } else {
        Utils.toastMessage("Could not launch camera");
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Consumer<QuebecViewModel>(
      builder: (context, quebec, _) {
        return Scaffold(
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

              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Utils.buildAppBar(
                      context,
                      AppLocalizations.of(
                            context,
                          )!.translate("scanQuebecText") ??
                          '',
                      AppLocalizations.of(context)!.translate("scanDescText") ??
                          '',
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: Utils.setHeight(context) * 0.1,
                      ),
                      child: Consumer<AuthViewModel>(
                        builder: (context, authViewModel, child) {
                          return Column(
                            children: [
                              // Upload container
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.goldenOrangeColor,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
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
                                      AppLocalizations.of(
                                            context,
                                          )!.translate("uploadFileText") ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.pureGrayColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.goldenOrangeColor,
                                      ),
                                      onPressed: () {
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
                                                  // Gallery
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.photo_library,
                                                      color: Colors.orange,
                                                    ),
                                                    title: Text(
                                                      AppLocalizations.of(
                                                            context,
                                                          )!.translate(
                                                            "galleryText",
                                                          ) ??
                                                          '',
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      final file =
                                                          await authViewModel
                                                              .pickImageFromGallery();
                                                      if (file != null) {
                                                        _receiptSource =
                                                            'gallery';
                                                        quebecScanLog(
                                                          'UI: pickedFile set source=gallery path=${file.path}',
                                                        );
                                                        setState(() {
                                                          pickedFile = file;
                                                        });
                                                      } else {
                                                        quebecScanLog(
                                                          'UI: gallery picker returned null',
                                                        );
                                                      }
                                                    },
                                                  ),

                                                  // PDF
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.picture_as_pdf,
                                                      color: Colors.red,
                                                    ),
                                                    title: Text(
                                                      AppLocalizations.of(
                                                            context,
                                                          )!.translate(
                                                            "pickPdfFileText",
                                                          ) ??
                                                          '',
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      final file =
                                                          await authViewModel
                                                              .pickPdfFile();
                                                      if (file != null) {
                                                        _receiptSource = 'pdf';
                                                        quebecScanLog(
                                                          'UI: pickedFile set source=pdf path=${file.path}',
                                                        );
                                                        setState(() {
                                                          pickedFile = file;
                                                        });
                                                      } else {
                                                        quebecScanLog(
                                                          'UI: pdf picker returned null',
                                                        );
                                                      }
                                                    },
                                                  ),

                                                  // Scan with Camera
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.camera_alt,
                                                      color: Colors.orange,
                                                    ),
                                                    title: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.translate(
                                                        "cameraText",
                                                      ) ??
                                                          '',
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);

                                                      startSmartQuebecCameraCapture();

                                                      if (auth.pickedImage !=
                                                          null) {
                                                        setState(() {
                                                          pickedFile =
                                                              auth.pickedImage;
                                                        });
                                                      }
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
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (pickedFile != null) ...[
                                const SizedBox(height: 20),
                                Consumer<GasolineViewModel>(
                                  builder: (context, gasoline, _) {
                                    final file = pickedFile!;
                                    final isPdf = file.path
                                        .toLowerCase()
                                        .endsWith(".pdf");

                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width:
                                              Utils.setHeight(context) * 0.35,
                                          height:
                                              Utils.setHeight(context) * 0.35,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange,
                                              width: 1,
                                            ),
                                          ),
                                          child:
                                              isPdf
                                                  ? Center(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.picture_as_pdf,
                                                          size: 70,
                                                          color: Colors.red,
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          file.path
                                                              .split('/')
                                                              .last,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color:
                                                                    Colors
                                                                        .black87,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        ElevatedButton(
                                                          style:
                                                              ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .orange,
                                                              ),
                                                          onPressed: () {
                                                            // Open PDF with 'open_file' package
                                                            OpenFile.open(
                                                              file.path,
                                                            );
                                                          },
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                  context,
                                                                )!.translate(
                                                                  "viewPdfText",
                                                                ) ??
                                                                '',
                                                            style: GoogleFonts.montserrat(
                                                              fontSize: 15,
                                                              color:
                                                                  AppColors
                                                                      .whiteColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  : Image.file(
                                                    file,
                                                    fit: BoxFit.contain,
                                                    width: double.infinity,
                                                  ),
                                        ),
                                        if (gasoline.isLoading)
                                          Container(
                                            width: double.infinity,
                                            height:
                                                Utils.setHeight(context) * 0.35,
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.orange),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],

                              const SizedBox(height: 30),
                              AppButton(
                                isLoading: quebec.isLoading,
                                btnText:
                                    AppLocalizations.of(
                                      context,
                                    )!.translate("nextText") ??
                                    '',
                                onPressed: () {
                                  if (pickedFile == null) {
                                    quebecScanLog(
                                      'UI: Next pressed with no pickedFile, blocked',
                                    );
                                    Utils.toastMessage(
                                      "Please choose receipt (image or pdf)",
                                    );
                                  } else {
                                    quebecScanLog(
                                      'UI: invoking scanQuebecApi source=$_receiptSource '
                                      'file=${pickedFile!.path}',
                                    );
                                    quebec.scanQuebecApi(context, pickedFile);
                                  }
                                },
                              ),
                              SizedBox(height: 10),
                              AppButton(
                                btnText:
                                    AppLocalizations.of(
                                      context,
                                    )!.translate("skipScanText") ??
                                    '',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RidesGrossScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
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
}
