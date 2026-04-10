import 'dart:async';
import 'dart:io' hide Context;

import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../../../res/app_assets.dart';
import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../res/ios_scanner.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';
import 'add_receipt_data_screen.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/gasoline_view_model/gasoline_view_model.dart';

class AddReceiptScanScreen extends StatefulWidget {
  const AddReceiptScanScreen({super.key});

  @override
  State<AddReceiptScanScreen> createState() => _AddReceiptScanScreenState();
}

class _AddReceiptScanScreenState extends State<AddReceiptScanScreen>
    with SingleTickerProviderStateMixin {
  File? localPickedImage;
  int elapsedSeconds = 0;
  bool isAutoScanning = false;

  Timer? scanTimer;
  Timer? textCycleTimer;
  int currentTextIndex = 0;

  final List<String> scanningTexts = [
    "Planning to move next...",
    "Thinking...",
  ];

  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_scanController);
  }

  // Future<void> startSmartCameraCapture() async {
  //   try {
  //     // 1. Corrected options for version 0.4.1
  //     final options = DocumentScannerOptions(
  //       documentFormats: {DocumentFormat.jpeg}, // Use {} to make it a Set
  //       mode: ScannerMode.full,
  //       isGalleryImport: false,
  //       pageLimit: 1,
  //     );
  //
  //     final documentScanner = DocumentScanner(options: options);
  //
  //     final result = await documentScanner.scanDocument();
  //
  //     if (result.images!.isNotEmpty) {
  //       final File capturedFile = File(result.images!.first);
  //
  //       if (!mounted) return;
  //
  //       setState(() {
  //         localPickedImage = capturedFile;
  //         elapsedSeconds = 0;
  //         currentTextIndex = 0;
  //         isAutoScanning = true;
  //       });
  //
  //       startTextCycle();
  //       startAutoScan(capturedFile);
  //     }
  //
  //     await documentScanner.close();
  //   } catch (e) {
  //     debugPrint("Document Scanner Error: $e");
  //     // If the user presses the back button without scanning,
  //     // it might throw an exception or return empty.
  //   }
  // }

  Future<void> startSmartCameraCapture() async {
    try {
      if (Platform.isAndroid) {
        // --- ANDROID: GOOGLE ML KIT (Fixed for your TECNO) ---
        final options = DocumentScannerOptions(
          documentFormats: {DocumentFormat.jpeg},
          mode: ScannerMode.full,
          isGalleryImport: false,
          pageLimit: 1,
        );

        final documentScanner = DocumentScanner(options: options);
        final result = await documentScanner.scanDocument();

        if (result.images != null && result.images!.isNotEmpty) {
          _processScannedFile(File(result.images!.first));
        }

        await documentScanner.close();
      } else if (Platform.isIOS) {
        // --- iOS: APPLE VISIONKIT (Using flutter_doc_scanner) ---
        // This launches the native iOS scanner with the yellow box edge detection.
        final result = await FlutterDocScanner().getScanDocuments();

        if (result != null && result.containsKey('images')) {
          List<dynamic> images = result['images'];
          if (images.isNotEmpty) {
            // The result returns the path as a string in the first index
            _processScannedFile(File(images.first.toString()));
          }
        }
      }
    } catch (e) {
      debugPrint("Document Scanner Error: $e");
      // Show a user-friendly message if the scanner fails or user cancels
      if (e.toString().contains("cancel")) {
        debugPrint("User cancelled the scan");
      } else {
        Utils.toastMessage("Could not launch camera");
      }
    }
  }

  void _processScannedFile(File file) {
    if (!mounted) return;

    setState(() {
      localPickedImage = file;
      elapsedSeconds = 0;
      currentTextIndex = 0;
      isAutoScanning = true;
    });

    // These are your existing methods for the Stora Tax receipt logic
    startTextCycle();
    startAutoScan(file);
  }

  Future<File> copyToTemp(File original) async {
    final tempDir = await getTemporaryDirectory();
    final newPath = '${tempDir.path}/${path.basename(original.path)}';
    return original.copy(newPath);
  }

  /// Pick image, crop, and start auto-scan
  Future<void> handleImage(File image) async {
    try {
      print("Camera image path: ${image.path}");
      print("File exists: ${await image.exists()}");

      await Future.delayed(const Duration(milliseconds: 300));

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Receipt',
            toolbarColor: Colors.orange,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Receipt'),
        ],
      );

      print("Cropped file: $croppedFile");

      if (croppedFile == null) {
        print("Crop cancelled or failed");
        return;
      }

      final croppedImage = File(croppedFile.path);

      if (!mounted) return;

      setState(() {
        localPickedImage = croppedImage;
        elapsedSeconds = 0;
        currentTextIndex = 0;
        isAutoScanning = true;
      });

      startTextCycle();
      startAutoScan(croppedImage);
    } catch (e) {
      print("ImageCropper error: $e");
      Utils.toastMessage("Failed to crop image.");
    }
  }

  void startTextCycle() {
    textCycleTimer?.cancel();
    textCycleTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        currentTextIndex = (currentTextIndex + 1) % scanningTexts.length;
      });
    });
  }

  void startAutoScan(File image) {
    scanTimer?.cancel();
    elapsedSeconds = 0;

    scanTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() => elapsedSeconds++);

      if (elapsedSeconds == 3) {
        timer.cancel(); // Stop timer first!

        final gasoline = Provider.of<GasolineViewModel>(context, listen: false);
        final auth = Provider.of<AuthViewModel>(context, listen: false);

        try {
          final response = await gasoline.scanFileApi(image);

          if (!mounted) return;

          // Stop animations before navigation
          setState(() => isAutoScanning = false);
          textCycleTimer?.cancel();

          // 4. CHECK FOR DATA: If response or data is null, navigation will crash.
          if (response != null && response["data"] != null) {
            if (response["status"].toString() == "1") {
              // Critical check before Push
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => AddReceiptDataScreen(
                          receiptData: response['data'],
                          receiptFile: image,
                        ),
                  ),
                );
                auth.clearPickedImage();
              }
            } else {
              Utils.showErrorDialog(
                context: context,
                message: response["success"] ?? "Scan failed.",
              );
            }
          } else {
            Utils.showErrorDialog(
              context: context,
              message: response?["success"] ?? "Scan failed.",
            );
          }
        } catch (e) {
          debugPrint("AutoScan error: $e");
          if (mounted) {
            setState(() => isAutoScanning = false);
            Utils.showErrorDialog(
              context: context,
              message:
                  "Unable to scan the document. Please try again or enter manually.",
            );
          }
        }
      }
    });
  }

  String get formattedElapsedTime {
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(1, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _scanController.dispose();
    scanTimer?.cancel();
    textCycleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Consumer<GasolineViewModel>(
      builder: (context, gasoline, _) {
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
                child: Column(
                  children: [
                    Utils.buildAppBar(
                      context,
                      AppLocalizations.of(
                            context,
                          )!.translate("addNewReceiptText") ??
                          '',
                      AppLocalizations.of(
                            context,
                          )!.translate("descNewReceiptText") ??
                          '',
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: Utils.setHeight(context) * 0.06,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tips for best results:",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: const Color(0xFF2A9DB8),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE1F5FA),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "Use good lighting; keep the receipt flat and in focus; avoid glare and shadows; include the entire receipt in the frame; hold the camera steady to avoid blur.",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                color: const Color(0xFF2A9DB8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Upload Section
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

                                /// Choose file
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
                                      builder: (_) {
                                        return Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Wrap(
                                            children: [
                                              /// Gallery
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
                                                  final image =
                                                      await auth
                                                          .pickImageFromGallery();
                                                  if (image != null)
                                                    handleImage(image);
                                                },
                                              ),

                                              /// Camera (IMAGE ONLY)
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
                                                  Navigator.of(context).pop();
                                                  startSmartCameraCapture();
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

                          // Image Preview + Scanner
                          if (localPickedImage != null) ...[
                            const SizedBox(height: 20),
                            Center(
                              child: SizedBox(
                                height: Utils.setHeight(context) * 0.2,
                                width: Utils.setHeight(context) * 0.15,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        localPickedImage!,
                                        fit: BoxFit.fill,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    if (isAutoScanning)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    if (isAutoScanning)
                                      AnimatedBuilder(
                                        animation: _scanAnimation,
                                        builder: (context, child) {
                                          double containerHeight =
                                              Utils.setHeight(context) * 0.2;
                                          return Positioned(
                                            top:
                                                _scanAnimation.value *
                                                (containerHeight - 4),
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              height: 4,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.blueAccent,
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (isAutoScanning)
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      formattedElapsedTime,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      scanningTexts[currentTextIndex],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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
}
