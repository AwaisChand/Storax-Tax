import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/components/app_button.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/entry/widget/expense_type_summary_table_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/entry/widget/filter_graph_entries_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/entry/widget/forward_report_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/entry/widget/monthly_summary_table_widget.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/entry/widget/amount_by_month_chart_widget.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/res/app_assets.dart';
import 'package:storatax/view_models/rental_property_view_model/rental_property_view_model.dart';

import '../../../../../../../res/components/app_localization.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../../view_models/auth_view_model/auth_view_model.dart';
import '../../rental_property_tab_screen/rental_property_tab_screen.dart';
import '../widget/income_type_summary_table_widget.dart';

class GraphicEntryScreen extends StatefulWidget {
  const GraphicEntryScreen({super.key, this.planId, this.filePath});
  final int? planId;
  final String? filePath;

  @override
  State<GraphicEntryScreen> createState() => _GraphicEntryScreenState();
}

class _GraphicEntryScreenState extends State<GraphicEntryScreen> {
  List<double> income = List.filled(12, 0.0);
  List<double> expense = List.filled(12, 0.0);
  final currentYear = DateTime.now().year.toString();

  final Map<String, int> monthIndexMap = {
    'January': 0,
    'February': 1,
    'March': 2,
    'April': 3,
    'May': 4,
    'June': 5,
    'July': 6,
    'August': 7,
    'September': 8,
    'October': 9,
    'November': 10,
    'December': 11,
  };

  @override
  void initState() {
    super.initState();
    final rentalProvider = context.read<RentalPropertyViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final language = AppLocalizations.of(context)?.locale.languageCode;

      await rentalProvider.getAllDatabaseEntriesApi(
        context: context,
        planId: widget.planId ?? 0,
        year: currentYear,
        language: language,
      );
      _updateChartData(rentalProvider);
      _preloadReport();
    });
  }

  String? _lastLoadedYear;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final rentalProvider = context.watch<RentalPropertyViewModel>();
    final selectedYear = rentalProvider.selectedYear;

    if (selectedYear != null && selectedYear != _lastLoadedYear) {
      _lastLoadedYear = selectedYear;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preloadReport();
      });
    }

    _updateChartData(rentalProvider);
  }

  void _updateChartData(RentalPropertyViewModel rentalProvider) {
    final apiData = rentalProvider.databaseEntriesModel?.data;
    if (apiData != null) {
      List<double> tempIncome = List.filled(12, 0.0);
      List<double> tempExpense = List.filled(12, 0.0);

      for (var item in apiData.amountByMonth ?? []) {
        final String? monthName = item.month;
        final int? index = monthIndexMap[monthName ?? ''];

        if (index != null && index >= 0 && index < 12) {
          tempIncome[index] = item.income ?? 0.0;
          tempExpense[index] = item.expense ?? 0.0;
        }
      }

      setState(() {
        income = tempIncome;
        expense = tempExpense;
      });
    }
  }

  String? exportPdfPath;
  bool isExportPdfReady = false;

  String? caReportPath;
  String? usReportPath;

  bool isCaReportReady = false;
  bool isUsReportReady = false;

  Future<void> _preloadReport() async {
    final rentalProvider = context.read<RentalPropertyViewModel>();
    final authProvider = context.read<AuthViewModel>();

    final year =
        int.tryParse(rentalProvider.selectedYear ?? currentYear) ??
        DateTime.now().year;

    // Determine the current language (fr/en)
    final language = AppLocalizations.of(context)?.locale.languageCode ?? 'en';

    // 🔴 RESET OLD REPORT STATE FIRST
    if (mounted) {
      setState(() {
        caReportPath = null;
        usReportPath = null;
        exportPdfPath = null;

        isCaReportReady = false;
        isUsReportReady = false;
        isExportPdfReady = false;
      });
    }

    if (authProvider.user?.regCountry == "ca") {
      final path = await rentalProvider.printReportT776Api(
        clientPlansId: widget.planId!,
        year: year,
        language: language,
      );

      if (mounted) {
        setState(() {
          caReportPath = path;
          isCaReportReady = path != null;
        });
      }
    } else {
      final path = await rentalProvider.printReportF1040(
        clientPlansId: widget.planId!,
        year: year,
        language: language,
      );

      if (mounted) {
        setState(() {
          usReportPath = path;
          isUsReportReady = path != null;
        });
      }
    }

    // 🔹 2️⃣ Export PDF (Scheduled Report)
    final exportPath = await rentalProvider.reportScheduleApi(
      clientPlansId: widget.planId!,
      year: year,
      language: language,
    );

    if (mounted) {
      setState(() {
        exportPdfPath = exportPath;
        isExportPdfReady = exportPath != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rentalProvider = context.watch<RentalPropertyViewModel>();
    final authProvider = context.watch<AuthViewModel>();
    return Scaffold(
      appBar: CustomAppBar(
        text1:
            AppLocalizations.of(context)!.translate("graphicEntryText") ?? '',
        text2: AppLocalizations.of(context)!.translate("manageEntryText") ?? '',
        showBackButton: true,
        onBackTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RentalPropertyTabScreen(),
            ),
          );        },
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.backgroundImg),
                fit: BoxFit.cover,
              ),
            ),
          ),
          rentalProvider.otherLoading
              ? Center(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: AppColors.blackColor,
                  ),
                ),
              )
              : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppButton(
                        btnText:
                            authProvider.user?.regCountry == "ca"
                                ? AppLocalizations.of(
                                      context,
                                    )!.translate("repT776Text") ??
                                    ''
                                : AppLocalizations.of(
                                      context,
                                    )!.translate("repScheduleText") ??
                                    '',
                        onPressed: () async {
                          final isCanada =
                              authProvider.user?.regCountry == "ca";
                          final path = isCanada ? caReportPath : usReportPath;

                          if (path != null) {
                            await OpenFile.open(path);
                          }
                        },
                        isLoading:
                            authProvider.user?.regCountry == "ca"
                                ? !isCaReportReady
                                : !isUsReportReady,
                      ),

                      SizedBox(height: 10),
                      AppButton(
                        btnText:
                            authProvider.user?.regCountry == "ca"
                                ? AppLocalizations.of(
                                      context,
                                    )!.translate("printT776Text") ??
                                    ''
                                : AppLocalizations.of(
                                      context,
                                    )!.translate("printScheduleText") ??
                                    '',
                        onPressed: () async {
                          final isCanada =
                              authProvider.user?.regCountry == "ca";
                          final path = isCanada ? caReportPath : usReportPath;

                          if (path != null) {
                            final file = File(path);
                            if (await file.exists()) {
                              await Printing.layoutPdf(
                                name:
                                    isCanada
                                        ? "T776_Report.pdf"
                                        : "F1040_Report.pdf",
                                onLayout: (_) async => file.readAsBytes(),
                              );
                            }
                          }
                        },
                        isLoading:
                            authProvider.user?.regCountry == "ca"
                                ? !isCaReportReady
                                : !isUsReportReady,
                      ),

                      const SizedBox(height: 10),
                      AppButton(
                        btnText:
                            AppLocalizations.of(
                              context,
                            )!.translate("expToPdfText") ??
                            '',
                        onPressed: () async {
                          if (exportPdfPath == null) {
                            Utils.toastMessage("Report not ready yet");
                            return;
                          }

                          await OpenFile.open(exportPdfPath!);
                        },
                        isLoading: !isExportPdfReady,
                      ),

                      const SizedBox(height: 10),
                      AppButton(
                        btnText:
                            AppLocalizations.of(
                              context,
                            )!.translate("forwardRepText") ??
                            '',
                        onPressed: () {
                          final selectedYear =
                              rentalProvider.selectedYear ??
                              DateTime.now().year.toString();

                          showForwardReportDialog(
                            context,
                            widget.planId!,
                            int.parse(selectedYear),
                          );
                        },
                        isLoading: rentalProvider.otherLoading,
                      ),
                      const SizedBox(height: 20),
                      buildGraphEntryFilter(context, widget.planId!),
                      const SizedBox(height: 15),
                      AmountByMonthChartWidget(
                        income: income,
                        expense: expense,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Indicator(
                              color: Colors.blue,
                              text:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("incomeText") ??
                                  '',
                            ),
                            const SizedBox(width: 16),
                            Indicator(
                              color: AppColors.goldenOrangeColor,
                              text:
                                  AppLocalizations.of(
                                    context,
                                  )!.translate("expenseText") ??
                                  '',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      MonthlySummaryTableWidget(
                        income: income,
                        expense: expense,
                      ),
                      if (rentalProvider
                              .databaseEntriesModel
                              ?.data
                              ?.incomeByType
                              ?.isNotEmpty ??
                          false) ...[
                        const Divider(thickness: 1),
                        IncomeTypeTableWidget(
                          incomeByTypeList:
                              rentalProvider
                                  .databaseEntriesModel
                                  ?.data
                                  ?.incomeByType ??
                              [],
                        ),
                      ],
                      const Divider(thickness: 1),
                      if (rentalProvider
                              .databaseEntriesModel
                              ?.data
                              ?.expenseByCategory
                              ?.isNotEmpty ??
                          false)
                        ExpenseTypeTableWidget(
                          expenseList:
                              rentalProvider
                                  .databaseEntriesModel
                                  ?.data
                                  ?.expenseByCategory ??
                              [],
                        ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const Indicator({required this.color, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }
}
