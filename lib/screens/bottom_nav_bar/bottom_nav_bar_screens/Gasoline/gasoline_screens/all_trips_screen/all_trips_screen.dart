import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/all_trips_screen/widget.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/gasoline_view_model/gasoline_view_model.dart';
import 'package:storatax/view_models/trip_view_model/trip_view_model.dart';
import '../../../../../../res/app_assets.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/utils.dart';

class AllTripsScreen extends StatefulWidget {
  const AllTripsScreen({super.key});

  @override
  State<AllTripsScreen> createState() => _AllTripsScreenState();
}

class _AllTripsScreenState extends State<AllTripsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  int? _getUserId() {
    final authProvider = context.read<AuthViewModel>().user;
    return (authProvider?.role == 'team')
        ? authProvider?.userId
        : authProvider?.id;
  }

  void _loadInitialData() {
    final userId = _getUserId();
    context.read<TripViewModel>().allTripsApi(
      userId: userId,
      perPage: '10',
      loadMore: false,
    );
  }

  void _onScroll() {
    final vm = context.read<TripViewModel>();

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!vm.loadingMoreTrips && vm.hasMoreTrips && !vm.allTripsLoading) {
        final userId = _getUserId();
        vm.allTripsApi(userId: userId, perPage: '10', loadMore: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double minTableWidth = 900.0;
    return Consumer<TripViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("allTripsText") ?? '',
            text2: "",
            showBackButton: true,
            onBackTap: () {
              Navigator.of(context).pop();
            },
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
              if (vm.allTripsLoading && vm.trips.isEmpty)
                const Center(
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: Colors.black,
                    ),
                  ),
                )
              else if (vm.trips.isEmpty)
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.translate("noTripsText") ??
                        '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: minTableWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        buildAllTripsFilter(context, () {}),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildHeader(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("stText") ??
                                      '',
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                flex: 3,
                                child: _buildHeader(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("fromLocationText") ??
                                      '',
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                flex: 3,
                                child: _buildHeader(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("toLocationText") ??
                                      '',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _buildHeader(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("distText") ??
                                      '',
                                  alignCenter: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: _buildHeader(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("tripTypeText") ??
                                      '',
                                  alignCenter: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: _buildHeader(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("purposeText") ??
                                      '',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: _buildHeader(
                                  // AppLocalizations.of(context)
                                  // !.translate("purposeText") ?? '',
                                  "Team Member",
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: _buildHeader(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("statusText") ??
                                      'Status',
                                  alignCenter: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 1),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            // Add 1 extra slot for the load-more spinner at the bottom
                            itemCount:
                                vm.trips.length + (vm.loadingMoreTrips ? 1 : 0),
                            itemBuilder: (context, index) {
                              // If index exceeds list range, render the bottom loader
                              if (index == vm.trips.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Center(
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final item = vm.trips[index];

                              return Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black12,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        item.startDateFormatted ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        item.fromLocation ?? 'No Location',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        item.toLocation ?? "No Location",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        item.totalDistance ?? '',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child:
                                            (item.tripType == null ||
                                                    item.tripType!.isEmpty)
                                                ? buildSelectTypeBtn(
                                                  onTap: () {
                                                    _showTripTypeDialog(
                                                      context,
                                                      item,
                                                      index,
                                                    );
                                                  },
                                                )
                                                : Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    _buildBadge(item.tripType!),
                                                    if (item.tripType!
                                                            .toLowerCase() ==
                                                        "business") ...[
                                                      const SizedBox(width: 4),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          final tripVm =
                                                              context
                                                                  .read<
                                                                    TripViewModel
                                                                  >();
                                                          if (item.tripId !=
                                                              null) {
                                                            await tripVm
                                                                .deleteTripApi(
                                                                  item.tripId!,
                                                                );
                                                          }
                                                          if (mounted) {
                                                            tripVm.trips
                                                                .removeAt(
                                                                  index,
                                                                );
                                                            setState(() {});
                                                          }
                                                        },
                                                        child: const Icon(
                                                          Icons.delete,
                                                          size: 16,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child:
                                          item.tripType?.toLowerCase() ==
                                                  "business"
                                              ? (item.purpose == null ||
                                                      item.purpose!.isEmpty
                                                  ? _buildAddPurposeBtn(
                                                    onTap: () {
                                                      _showPurposeDialog(
                                                        context,
                                                        item,
                                                        index,
                                                      );
                                                    },
                                                  )
                                                  : Text(
                                                    item.purpose ?? '',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                    ),
                                                  ))
                                              : const SizedBox(),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        item.creatorName ?? "N/A",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Consumer<TripViewModel>(
                                          builder: (context, vm, child) {
                                            final currentItem =
                                                (index < vm.trips.length)
                                                    ? vm.trips[index]
                                                    : item;

                                            final authUser =
                                                context
                                                    .read<AuthViewModel>()
                                                    .user;
                                            final isClient =
                                                authUser?.role == 'client';
                                            final isPending =
                                                currentItem.approvalStatus
                                                    ?.toLowerCase() ==
                                                'pending';

                                            return GestureDetector(
                                              onTap:
                                                  (isClient && isPending)
                                                      ? () =>
                                                          _showApprovalDialog(
                                                            context,
                                                            currentItem,
                                                            index,
                                                          )
                                                      : null,
                                              child: _buildStatusBadge(
                                                currentItem.approvalStatus ??
                                                    'N/A',
                                                isClickable:
                                                    isClient && isPending,
                                              ),
                                            );
                                          },
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
                ),
            ],
          ),
        );
      },
    );
  }

  void _showApprovalDialog(BuildContext context, dynamic item, int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isApproving = false;
        bool isRejecting = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final bool isLoading = isApproving || isRejecting;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              backgroundColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // =========================================================
                    // HEADER ICON
                    // =========================================================
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF1E88E5),
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =========================================================
                    // TITLE
                    // =========================================================
                    Text(
                      AppLocalizations.of(
                            dialogContext,
                          )?.translate("tripApprovalText") ??
                          'Trip Approval',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // =========================================================
                    // DESCRIPTION
                    // =========================================================
                    Text(
                      "Please review and select whether to approve or reject this trip submission.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =========================================================
                    // ACTION BUTTONS
                    // =========================================================
                    Row(
                      children: [
                        // =====================================================
                        // REJECT
                        // =====================================================
                        // =====================================================
                        // REJECT BUTTON
                        // =====================================================
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFE53935),
                              side: const BorderSide(color: Color(0xFFFFCDD2)),
                              backgroundColor: const Color(0xFFFFEBEE),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      final tripId = item.tripId ?? item.id;

                                      if (tripId == null) {
                                        Utils.toastMessage("Invalid Trip ID");
                                        return;
                                      }

                                      // Start loading
                                      setDialogState(() {
                                        isRejecting = true;
                                      });

                                      try {
                                        final vm =
                                            context.read<TripViewModel>();

                                        debugPrint(
                                          "========== REJECT TRIP ==========",
                                        );
                                        debugPrint("Trip ID: $tripId");

                                        // Call Reject API
                                        final result = await vm.rejectTripApi(
                                          tripId,
                                        );

                                        debugPrint(
                                          "Reject API result: $result",
                                        );

                                        // API successful
                                        if (result != null) {
                                          debugPrint("✅ Reject successful");

                                          debugPrint(
                                            "Removing trip locally: $tripId",
                                          );

                                          // 🔥 REMOVE TRIP IMMEDIATELY
                                          // This must call notifyListeners()
                                          vm.removeTripLocally(tripId);

                                          debugPrint("✅ Trip removed locally");

                                          // Close dialog
                                          if (dialogContext.mounted &&
                                              Navigator.canPop(dialogContext)) {
                                            Navigator.pop(dialogContext);
                                          }
                                        } else {
                                          // API returned null
                                          debugPrint(
                                            "❌ Reject API returned null",
                                          );

                                          if (dialogContext.mounted) {
                                            setDialogState(() {
                                              isRejecting = false;
                                            });
                                          }
                                        }
                                      } catch (e, stackTrace) {
                                        debugPrint("❌ Reject dialog error: $e");
                                        debugPrint("$stackTrace");

                                        if (dialogContext.mounted) {
                                          setDialogState(() {
                                            isRejecting = false;
                                          });
                                        }
                                      }
                                    },
                            child:
                                isRejecting
                                    ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFE53935),
                                      ),
                                    )
                                    : Text(
                                      AppLocalizations.of(
                                            dialogContext,
                                          )?.translate("rejectText") ??
                                          'Reject',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // =====================================================
                        // APPROVE
                        // =====================================================
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      final tripId = item.tripId ?? item.id;

                                      if (tripId == null) {
                                        Utils.toastMessage("Invalid Trip ID");
                                        return;
                                      }

                                      // -----------------------------------------
                                      // START APPROVE LOADING
                                      // -----------------------------------------
                                      setDialogState(() {
                                        isApproving = true;
                                      });

                                      try {
                                        final vm =
                                            context.read<TripViewModel>();

                                        debugPrint(
                                          "========== APPROVE TRIP ==========",
                                        );
                                        debugPrint("Trip ID: $tripId");

                                        // -----------------------------------------
                                        // CALL APPROVE API
                                        // -----------------------------------------
                                        final result = await vm.approvedTripApi(
                                          tripId,
                                        );

                                        debugPrint(
                                          "Approve API result: $result",
                                        );

                                        // -----------------------------------------
                                        // API SUCCESS
                                        // -----------------------------------------
                                        if (result != null) {
                                          debugPrint("Approve successful.");

                                          // 🔥 KEEP YOUR ORIGINAL
                                          // APPROVE BEHAVIOR
                                          vm.updateTripStatusLocally(
                                            index,
                                            "approved",
                                          );

                                          // ---------------------------------------
                                          // CLOSE DIALOG
                                          // ---------------------------------------
                                          if (dialogContext.mounted &&
                                              Navigator.canPop(dialogContext)) {
                                            Navigator.pop(dialogContext);
                                          }
                                        } else {
                                          // -----------------------------------------
                                          // API FAILED
                                          // -----------------------------------------
                                          debugPrint(
                                            "Approve API returned null.",
                                          );

                                          if (dialogContext.mounted) {
                                            setDialogState(() {
                                              isApproving = false;
                                            });
                                          }
                                        }
                                      } catch (e, stackTrace) {
                                        debugPrint("Approve dialog error: $e");
                                        debugPrint("$stackTrace");

                                        if (dialogContext.mounted) {
                                          setDialogState(() {
                                            isApproving = false;
                                          });
                                        }
                                      }
                                    },
                            child:
                                isApproving
                                    ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      AppLocalizations.of(
                                            dialogContext,
                                          )?.translate("approveText") ??
                                          'Approve',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // =========================================================
                    // CANCEL
                    // =========================================================
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                Navigator.pop(dialogContext);
                              },
                      child: Text(
                        AppLocalizations.of(
                              dialogContext,
                            )?.translate("cancelText") ??
                            'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(String status, {bool isClickable = false}) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'pending':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'rejected':
      case 'cancelled':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.black87;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              status.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          if (isClickable) ...[
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 14, color: textColor),
          ],
        ],
      ),
    );
  }

  Widget _buildAddPurposeBtn({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF18C16),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          AppLocalizations.of(context)!.translate("addPurposeText") ??
              'Add Purpose',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, {bool alignCenter = false}) {
    return Text(
      title,
      textAlign: alignCenter ? TextAlign.center : TextAlign.start,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // Select Trip Type Dialog
  void _showTripTypeDialog(BuildContext context, dynamic item, int index) {
    String selectedType = "Personal";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.swap_horiz, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(
                                dialogContext,
                              )!.translate("selectTripTypeText") ??
                              '',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        value: selectedType,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items:
                            ["Personal", "Business"]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            isLoading
                                ? null
                                : (value) {
                                  setDialogState(() {
                                    selectedType = value!;
                                  });
                                },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                          child: Text(
                            AppLocalizations.of(
                                  dialogContext,
                                )!.translate("cancelText") ??
                                '',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed:
                              isLoading
                                  ? null
                                  : () async {
                                    setDialogState(() {
                                      isLoading = true;
                                    });

                                    Map data = {
                                      "trip_id": item.tripId,
                                      "type": selectedType.toLowerCase(),
                                    };

                                    final vm = context.read<TripViewModel>();
                                    final result = await vm.updateTripTypeApi(
                                      data,
                                    );

                                    if (dialogContext.mounted &&
                                        Navigator.canPop(dialogContext)) {
                                      Navigator.pop(dialogContext);
                                    }

                                    if (result != null && mounted) {
                                      if (selectedType.toLowerCase() ==
                                          "personal") {
                                        vm.trips.removeAt(index);
                                      } else {
                                        item.tripType = selectedType;
                                      }
                                      setState(() {});
                                    }
                                  },
                          child:
                              isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    AppLocalizations.of(
                                          dialogContext,
                                        )!.translate("setText") ??
                                        '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Add Purpose Dialog
  void _showPurposeDialog(BuildContext context, dynamic item, int index) {
    final TextEditingController purposeController = TextEditingController(
      text: item.purpose ?? "",
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_note, color: Colors.orange),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(
                                dialogContext,
                              )!.translate("addPurposeText") ??
                              '',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: purposeController,
                      enabled: !isLoading,
                      maxLines: 2,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Enter purpose",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                          child: Text(
                            AppLocalizations.of(
                                  dialogContext,
                                )!.translate("cancelText") ??
                                '',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF18C16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          onPressed:
                              isLoading
                                  ? null
                                  : () async {
                                    final text = purposeController.text.trim();

                                    if (text.isEmpty) {
                                      Utils.toastMessage(
                                        "Please enter purpose",
                                      );
                                      return;
                                    }

                                    setDialogState(() {
                                      isLoading = true;
                                    });

                                    Map data = {
                                      "trip_id": item.tripId,
                                      "purpose": text,
                                    };
                                    final tripVm =
                                        context.read<TripViewModel>();

                                    final result = await tripVm.addPurposeApi(
                                      data,
                                    );

                                    if (dialogContext.mounted &&
                                        Navigator.canPop(dialogContext)) {
                                      Navigator.pop(dialogContext);
                                    }

                                    if (result != null && mounted) {
                                      setState(() {
                                        item.purpose = text;
                                      });
                                    }
                                  },
                          child:
                              isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    AppLocalizations.of(
                                          dialogContext,
                                        )!.translate("saveText") ??
                                        '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBadge(String type) {
    if (type == "-") {
      return Text("-", style: GoogleFonts.poppins(fontSize: 12));
    }
    final isBusiness = type.toLowerCase() == "business";
    final activeColor =
        isBusiness ? Colors.blue.shade600 : Colors.green.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isBusiness ? Colors.blue.shade50 : Colors.green.shade50,
        border: Border.all(color: activeColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: activeColor,
        ),
      ),
    );
  }
}
