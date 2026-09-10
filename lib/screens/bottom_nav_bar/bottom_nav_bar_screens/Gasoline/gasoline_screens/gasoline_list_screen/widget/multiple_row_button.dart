import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/gasoline_list_screen/widget/tracking_mode_dialog_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/log_book_screen/log_book_report_screen.dart';

import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/app_colors.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../../view_models/auth_view_model/auth_view_model.dart';
import '../../../../../../../view_models/gasoline_view_model/gasoline_view_model.dart';
import '../../../../../../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';
import '../../../trip_report_screen/trip_report_screen/trip_report_screen.dart';
import '../../manuel_tracking_screen/manuel_tracking_screen.dart';
import '../../transaction_report/transaction_report_screen/transaction_report_screen.dart';
import '../../view_report/view_report_screen/view_report_screen.dart';

class MultipleRowButton extends StatefulWidget {
  const MultipleRowButton({super.key, required this.onModeChanged});
  final VoidCallback onModeChanged;

  @override
  State<MultipleRowButton> createState() => _MultipleRowButtonState();
}

class _MultipleRowButtonState extends State<MultipleRowButton> {
  // Flag to prevent fast double-clicks or concurrent executions
  bool _isProcessing = false;

  /// Helper to build a clean cross-platform address without leading commas
  String _formatPlacemark(Placemark place) {
    List<String> addressParts = [];

    // On iOS, CLGeocoder populates thoroughfare / subThoroughfare rather than street
    String streetName = place.street ?? '';
    if (streetName.isEmpty || streetName.startsWith('+')) {
      final sub = place.subThoroughfare ?? '';
      final main = place.thoroughfare ?? '';
      streetName = '$sub $main'.trim();
    }

    // Fallback to feature name if street name is still empty
    if (streetName.isEmpty && place.name != null && place.name != place.locality) {
      streetName = place.name!;
    }

    if (streetName.isNotEmpty) addressParts.add(streetName);
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }

    return addressParts.join(', ');
  }

  /// ---------------------------------------------------------------------------
  /// 🚨 iOS & ANDROID COMPLIANT BACKGROUND LOCATION PERMISSION FLOW
  /// ---------------------------------------------------------------------------
  Future<bool> _ensureLocationPermissionsWithDisclosure(
      BuildContext context,
      ) async {
    // STEP 1: Always check/request foreground permission first (Required for iOS)
    ph.PermissionStatus foregroundStatus = await ph.Permission.locationWhenInUse.status;
    if (foregroundStatus.isDenied) {
      foregroundStatus = await ph.Permission.locationWhenInUse.request();
    }

    if (foregroundStatus.isDenied) {
      Utils.toastMessage("Location permission is required to track trips");
      return false;
    }

    if (foregroundStatus.isPermanentlyDenied) {
      Utils.toastMessage("Please enable Location access in App Settings");
      await ph.openAppSettings();
      return false;
    }

    // STEP 2: Check background status
    ph.PermissionStatus backgroundStatus = await ph.Permission.locationAlways.status;
    if (backgroundStatus.isGranted) {
      return true;
    }

    // STEP 3: Show Prominent Disclosure Dialog before asking for Always access
    bool userAgreed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                "Background Location Access",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              content: Text(
                "StoraTax collects location data in the background to automatically track your trips, calculate distance, and log travel routes even when the app is closed or not in use.",
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "No thanks",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldenOrangeColor,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "Agree & Continue",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
            false;

    if (!userAgreed) {
      Utils.toastMessage(
        "Background location agreement required for Auto tracking",
      );
      return false;
    }

    // STEP 4: Request Background Permission
    backgroundStatus = await ph.Permission.locationAlways.request();

    if (backgroundStatus.isGranted) {
      return true;
    } else if (backgroundStatus.isPermanentlyDenied || backgroundStatus.isDenied) {
      Utils.toastMessage(
        "Please set location permission to 'Always Allow' in iOS Settings",
      );
      await ph.openAppSettings();
      return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final plans = context.watch<PricingPlansViewModel>();
    final auth = context.watch<AuthViewModel>();
    final planNames =
    plans.myPlans.map((p) => p.name?.toLowerCase().trim() ?? '').toList();
    final isFreeGasPlan = planNames.any(
          (n) => n.contains('free version') || n.contains('basic'),
    );

    final gasolineVM = context.watch<GasolineViewModel>();
    final isAutoTracking = gasolineVM.isTrackingRunning;

    return Row(
      children: [
        if (!isFreeGasPlan)
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 44,
              child: MaterialButton(
                color:
                isAutoTracking
                    ? AppColors.redColor
                    : AppColors.goldenOrangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAutoTracking
                      ? AppLocalizations.of(
                    context,
                  )!.translate("stopTrackingText") ??
                      ''
                      : AppLocalizations.of(
                    context,
                  )!.translate("starTrackingText") ??
                      '',
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () async {
                  if (_isProcessing) return;
                  setState(() => _isProcessing = true);

                  try {
                    final tripReportVM = context.read<GasolineViewModel>();

                    final String currentDeviceTime =
                    DateTime.now().toIso8601String();

                    // ============================================================
                    // 🛑 STOP TRACKING
                    // ============================================================
                    if (isAutoTracking) {
                      try {
                        debugPrint("🛑 Stop tracking pressed");

                        final tripId = tripReportVM.currentTripId;
                        if (tripId == null) {
                          Utils.toastMessage("Trip not found");
                          return;
                        }

                        Position? position;

                        LocationPermission permission =
                        await Geolocator.checkPermission();

                        if (permission == LocationPermission.denied) {
                          permission = await Geolocator.requestPermission();
                        }

                        if (permission == LocationPermission.denied ||
                            permission == LocationPermission.deniedForever) {
                          debugPrint("❌ Location permission denied on STOP");
                          position = tripReportVM.lastPosition;
                        } else {
                          try {
                            position = await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                              timeLimit: const Duration(seconds: 10),
                            );
                          } catch (e) {
                            debugPrint("⚠️ Failed to get fresh location: $e");
                            position = tripReportVM.lastPosition;
                          }
                        }

                        String address = "";

                        if (position != null &&
                            !(position.latitude == 0.0 &&
                                position.longitude == 0.0)) {
                          try {
                            List<Placemark> placemarks =
                            await placemarkFromCoordinates(
                              position.latitude,
                              position.longitude,
                            );

                            if (placemarks.isNotEmpty) {
                              address = _formatPlacemark(placemarks.first);
                            }
                          } catch (e) {
                            debugPrint("⚠️ Geocoding failed: $e");
                          }
                        }

                        await tripReportVM.stopLiveTracking();

                        final data = {
                          "trip_id": tripId,
                          if (position != null) "end_lat": position.latitude,
                          if (position != null) "end_lng": position.longitude,
                          if (address.isNotEmpty) "end_address": address,
                          "device_time": DateTime.now().toIso8601String(),
                        };

                        await tripReportVM.stopTripApi(data);

                        tripReportVM.activeTripModel?.data?.isTracking = false;
                        tripReportVM.activeTripModel?.data?.trackingMode = null;
                        tripReportVM.clearCurrentTrip();

                        if (mounted) {
                          setState(() {
                            Utils.selectedMode = '';
                          });
                          widget.onModeChanged();
                        }
                      } catch (e, st) {
                        debugPrint("🔥 Stop tracking error: $e\n$st");
                        Utils.toastMessage("Something went wrong");
                      }
                      return;
                    }

                    // ============================================================
                    // 🚀 START TRACKING
                    // ============================================================
                    String? result = await showTrackingModeDialogWidget(
                      context,
                    );

                    if (result != null && mounted) {
                      setState(() {
                        Utils.selectedMode = result;
                      });
                      widget.onModeChanged();

                      // ---------------- AUTO MODE ----------------
                      if (result == 'auto') {
                        try {
                          bool hasPermissions =
                          await _ensureLocationPermissionsWithDisclosure(
                            context,
                          );

                          if (!hasPermissions) {
                            debugPrint("❌ Permission denied/aborted.");
                            return;
                          }

                          // Get high accuracy GPS position with a 10s timeout
                          Position position =
                          await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high,
                            timeLimit: const Duration(seconds: 10),
                          );

                          if (position.latitude == 0.0 &&
                              position.longitude == 0.0) {
                            Utils.toastMessage(
                              "Invalid GPS location. Try again.",
                            );
                            return;
                          }

                          String address = "Unknown Location";
                          try {
                            List<Placemark> placemarks =
                            await placemarkFromCoordinates(
                              position.latitude,
                              position.longitude,
                            );

                            if (placemarks.isNotEmpty) {
                              address = _formatPlacemark(placemarks.first);
                            }
                          } catch (e) {
                            debugPrint("Geocoding failed: $e");
                          }

                          if (!mounted) return;

                          tripReportVM.setTrackingLocally();

                          final int? userId =
                          (auth.user?.role == 'team')
                              ? auth.user?.userId
                              : auth.user?.id;

                          Map<String, dynamic> data = {
                            "user_id": userId,
                            "start_lat": position.latitude,
                            "start_lng": position.longitude,
                            "start_address": address,
                            "device_time": currentDeviceTime,
                          };

                          debugPrint("🚀 START AUTO TRIP DATA: $data");
                          await tripReportVM.startTripApi(context, data);
                        } catch (e) {
                          debugPrint("🔥 Auto mode start error: $e");
                          tripReportVM.clearCurrentTrip();
                          Utils.toastMessage("Failed to start tracking");
                        }
                      }

                      // ---------------- MANUAL MODE ----------------
                      if (result == 'manual') {
                        await Future.delayed(const Duration(milliseconds: 100));
                        if (!mounted) return;

                        await Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context) => const ManuelTrackingScreen(),
                          ),
                        );

                        if (mounted) {
                          setState(() {
                            Utils.selectedMode = '';
                          });
                          widget.onModeChanged();
                        }
                      }
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isProcessing = false);
                    }
                  }
                },
              ),
            ),
          ),

        if (!isFreeGasPlan) const SizedBox(width: 10),

        Expanded(
          flex: 1,
          child: PopupMenuButton<int>(
            offset: const Offset(0, 50),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.goldenOrangeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Reports",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppColors.whiteColor),
                ],
              ),
            ),
            itemBuilder:
                (context) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      color: Colors.black54,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.translate("receiptsViewReport") ??
                          '',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (!isFreeGasPlan) ...[
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        color: Colors.black54,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.translate("transactionReportText") ??
                              '',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.book,
                        color: Colors.black54,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.translate("logBookText") ??
                            '',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 4,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.black54,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.translate("tripsReportText") ??
                            '',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewReportScreen()),
                );
              } else if (value == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionReportScreen(),
                  ),
                );
              } else if (value == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogBookReportScreen(),
                  ),
                );
              } else if (value == 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TripReportScreen()),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}