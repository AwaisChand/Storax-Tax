import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/log_book_screen/widget/get_logbook_team_submission_widget.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/trip_view_model/trip_view_model.dart';
import '../../../../../../res/app_assets.dart';
import '../../../../../../res/components/app_localization.dart';
import '../../../../../../utils/utils.dart';

class LogBookReportScreen extends StatefulWidget {
  const LogBookReportScreen({super.key});

  @override
  State<LogBookReportScreen> createState() => _LogBookReportScreenState();
}

class _LogBookReportScreenState extends State<LogBookReportScreen> {
  final List<String> years = List.generate(7, (i) {
    final currentYear = DateTime.now().year;
    return '${currentYear - i}';
  });

  late String selectedYear;
  DateTime? selectedDate;

  final TextEditingController _startKmController = TextEditingController(
    text: '0.00',
  );
  final TextEditingController _endKmController = TextEditingController(
    text: '0.00',
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = now.year.toString();
    selectedDate = DateTime(now.year, now.month, now.day);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final langCode = Localizations.localeOf(context).languageCode;
      final authProvider = context.read<AuthViewModel>();
      final isClientRole = authProvider.user?.role == 'client';

      _fetchDataForYear(selectedYear);

      if (isClientRole) {
        context.read<TripViewModel>().getPendingSubmissionApi(
          context,
          lang: langCode,
        );
      }
    });
  }

  void _fetchDataForYear(String year) {
    _startKmController.text = '0.00';
    _endKmController.text = '0.00';

    context.read<TripViewModel>().getLogBookApi(context, year: year);
  }

  @override
  void dispose() {
    _startKmController.dispose();
    _endKmController.dispose();
    super.dispose();
  }

  void _updateKmValue(TextEditingController controller, bool isIncrement) {
    double currentValue = double.tryParse(controller.text) ?? 0.0;
    if (isIncrement) {
      currentValue += 0.01;
    } else {
      currentValue -= 0.01;
      if (currentValue < 0) currentValue = 0.0;
    }
    setState(() {
      controller.text = currentValue.toStringAsFixed(2);
    });
  }

  Widget _buildKmField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 13,
              horizontal: 10,
            ),
            prefixIcon: IconButton(
              icon: const Icon(Icons.remove, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _updateKmValue(controller, false),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _updateKmValue(controller, true),
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
        ),
      ],
    );
  }

  Widget _buildPendingSubmissionsTable(TripViewModel vm) {
    if (vm.pending.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Pending team submissions',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                columnSpacing: 24,
                horizontalMargin: 16,
                headingTextStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
                dataTextStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF475569),
                ),
                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                columns: const [
                  DataColumn(label: Text('Team member')),
                  DataColumn(label: Text('Year')),
                  DataColumn(label: Text('KM start')),
                  DataColumn(label: Text('KM end')),
                  DataColumn(label: Text('Total KM driven')),
                  DataColumn(label: Text('Submitted')),
                  DataColumn(label: Text('Actions')),
                ],
                rows:
                    vm.pending.map((submission) {
                      return DataRow(
                        cells: [
                          DataCell(Text(submission.creatorName ?? '-')),
                          DataCell(Text('${submission.year ?? '-'}')),
                          DataCell(
                            Text(
                              (submission.kmStart ?? 0.0).toStringAsFixed(2),
                            ),
                          ),
                          DataCell(
                            Text((submission.kmEnd ?? 0.0).toStringAsFixed(2)),
                          ),
                          DataCell(
                            Text(
                              (submission.totalKmDriven ?? 0.0).toStringAsFixed(
                                2,
                              ),
                            ),
                          ),
                          DataCell(Text(submission.createdAt ?? '-')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed:
                                      (submission.id == null ||
                                              vm.activeApproveId != null ||
                                              vm.activeRejectId != null)
                                          ? null
                                          : () async {
                                            Map<String, dynamic> data = {
                                              "device_time":
                                                  DateTime.now()
                                                      .toIso8601String(),
                                            };
                                            final res = await vm
                                                .approveLogSubApi(
                                                  submission.id!,
                                                  data,
                                                );
                                            if (res != null &&
                                                res["status"].toString() ==
                                                    "1") {
                                              if (context.mounted) {
                                                final langCode =
                                                    Localizations.localeOf(
                                                      context,
                                                    ).languageCode;
                                                vm.getPendingSubmissionApi(
                                                  context,
                                                  lang: langCode,
                                                );
                                              }
                                            }
                                          },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF59E0B),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child:
                                      vm.activeApproveId == submission.id
                                          ? Center(
                                            child: SizedBox(
                                              height: 15,
                                              width: 15,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.blackColor,
                                              ),
                                            ),
                                          )
                                          : Text(
                                            'Approve',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton(
                                  onPressed:
                                      (submission.id == null ||
                                              vm.activeApproveId != null ||
                                              vm.activeRejectId != null)
                                          ? null
                                          : () async {
                                            final res = await vm
                                                .rejectLogSubApi(
                                                  submission.id!,
                                                );
                                            if (res != null &&
                                                res["status"].toString() ==
                                                    "1") {
                                              if (context.mounted) {
                                                final langCode =
                                                    Localizations.localeOf(
                                                      context,
                                                    ).languageCode;
                                                vm.getPendingSubmissionApi(
                                                  context,
                                                  lang: langCode,
                                                );
                                              }
                                            }
                                          },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0284C7),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child:
                                      vm.activeRejectId == submission.id
                                          ? Center(
                                            child: SizedBox(
                                              height: 15,
                                              width: 15,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.blackColor,
                                              ),
                                            ),
                                          )
                                          : Text(
                                            'Reject',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String title, String value, {bool isLast = false}) {
    final borderSide = BorderSide(color: Colors.grey.shade300, width: 1);
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              right: borderSide,
              bottom: isLast ? BorderSide.none : borderSide,
            ),
          ),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: isLast ? BorderSide.none : borderSide),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthViewModel>();
    final isTeamRole = authProvider.user?.role == 'team';
    final isClientRole = authProvider.user?.role == 'client';

    return Consumer<TripViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: CustomAppBar(
            text1:
                AppLocalizations.of(context)!.translate("logBookReportText") ??
                '',
            text2: AppLocalizations.of(context)!.translate("logBookText") ?? '',
            onBackTap: () => Navigator.of(context).pop(),
            showBackButton: true,
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
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.translate("yearText") ??
                            '',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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
                            borderSide: BorderSide(
                              color: AppColors.blackColor,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.blackColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        hint: Text(
                          AppLocalizations.of(context)!.translate("yearText") ??
                              '',
                        ),
                        value: selectedYear,
                        items:
                            years.map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null && value != selectedYear) {
                            setState(() {
                              selectedYear = value;
                              final year = int.parse(value);
                              final now = DateTime.now();
                              selectedDate = DateTime(year, now.month, now.day);
                            });
                            _fetchDataForYear(selectedYear);
                          }
                        },
                      ),

                      if (isTeamRole) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFBAE6FD),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Submit odometer readings for client approval. Approved readings will appear in your log book report.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      if (isClientRole) ...[_buildPendingSubmissionsTable(vm)],

                      _buildKmField(
                        label:
                            AppLocalizations.of(
                              context,
                            )!.translate("kmBegText") ??
                            '',
                        controller: _startKmController,
                      ),

                      const SizedBox(height: 16),

                      _buildKmField(
                        label:
                            AppLocalizations.of(
                              context,
                            )!.translate("kmBEndText") ??
                            '',
                        controller: _endKmController,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topRight,
                        child: MaterialButton(
                          height: 40,
                          color: AppColors.goldenOrangeColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () async {
                            if (isTeamRole) {
                              final langCode =
                                  Localizations.localeOf(context).languageCode;

                              final Map<String, dynamic> teamData = {
                                "year": selectedYear,
                                "km_start": _startKmController.text.trim(),
                                "km_end": _endKmController.text.trim(),
                                "device_time": DateTime.now().toIso8601String(),
                              };

                              await vm.submitLogBookApi(teamData, langCode);
                            } else {
                              final Map<String, dynamic> clientData = {
                                "year": selectedYear,
                                "km_start": _startKmController.text.trim(),
                                "km_end": _endKmController.text.trim(),
                                "device_time": DateTime.now().toIso8601String(),

                              };

                              await vm.createLogBookApi(clientData);
                            }

                            if (mounted) {
                              _fetchDataForYear(selectedYear);
                            }
                          },
                          child:
                              (vm.allTripsLoading)
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
                                    isTeamRole
                                        ? (AppLocalizations.of(
                                              context,
                                            )!.translate(
                                              "submitForApprovalText",
                                            ) ??
                                            'Submit for approval')
                                        : (AppLocalizations.of(
                                              context,
                                            )!.translate("saveText") ??
                                            'Save'),
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      if (vm.logBookLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
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
                      else ...[
                        // Render Team Submissions Table for team members
                        if (isTeamRole) ...[
                          buildTeamSubmissionsTable(vm, selectedYear),
                          const SizedBox(height: 24),
                        ],

                        // Render Log Book Report Table for all roles
                        Text(
                          "${AppLocalizations.of(context)!.translate("logBookReportText")} — $selectedYear",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),

                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Table(
                              defaultColumnWidth: const IntrinsicColumnWidth(),
                              columnWidths: const {
                                0: FixedColumnWidth(230),
                                1: FixedColumnWidth(120),
                              },
                              children: [
                                _buildTableRow(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("kmBegText") ??
                                      '',
                                  "${vm.logBookReportModel?.data?.report?.kmStart ?? '0.00'}",
                                ),
                                _buildTableRow(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("kmBEndText") ??
                                      '',
                                  "${vm.logBookReportModel?.data?.report?.kmEnd ?? '0.00'}",
                                ),
                                _buildTableRow(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("totalKmDrivenText") ??
                                      '',
                                  "${vm.logBookReportModel?.data?.report?.totalKmDriven ?? '0.00'}",
                                ),
                                _buildTableRow(
                                  AppLocalizations.of(
                                        context,
                                      )!.translate("totalKmBusinessText") ??
                                      '',
                                  "${vm.logBookReportModel?.data?.report?.totalKmBusiness ?? '0.00'}",
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
}
