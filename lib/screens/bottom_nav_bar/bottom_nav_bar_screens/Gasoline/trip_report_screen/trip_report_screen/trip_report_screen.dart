import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/trip_report_screen/widgets/build_trip_report_multiple_button.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/view_route/view_route.dart';
import 'package:storatax/view_models/trip_view_model/trip_view_model.dart';
import '../../../../../../../../../res/app_assets.dart';
import '../../../../../../../../../utils/utils.dart';
import '../../../../../../models/trip_report_model/trip_report_model.dart';
import '../../../../../../res/components/app_localization.dart';
import '../widgets/all_time_widget.dart';
import '../widgets/custom_trip_filter_widget.dart';

class TripReportScreen extends StatefulWidget {
  const TripReportScreen({super.key});

  @override
  State<TripReportScreen> createState() => _TripReportScreenState();
}

class _TripReportScreenState extends State<TripReportScreen> {
  String _selectedTab = 'All Time';

  final List<String> _tabs = [
    'All Time',
    'Today',
    'Yesterday',
    'This Week',
    'Previous Week',
    'This Month',
    'Previous Month',
    'This Year',
    'Custom',
  ];

  String _getTabTranslation(BuildContext context, String key) {
    switch (key) {
      case 'All Time':
        return AppLocalizations.of(context)!.translate("allTimeText") ??
            'All Time';
      case 'Today':
        return AppLocalizations.of(context)!.translate("todayText") ?? 'Today';
      case 'Yesterday':
        return AppLocalizations.of(context)!.translate("yesterdayText") ??
            'Yesterday';
      case 'This Week':
        return AppLocalizations.of(context)!.translate("thisWeekText") ??
            'This Week';
      case 'Previous Week':
        return AppLocalizations.of(context)!.translate("prevWeekText") ??
            'Previous Week';
      case 'This Month':
        return AppLocalizations.of(context)!.translate("thisMonthText") ??
            'This Month';
      case 'Previous Month':
        return AppLocalizations.of(context)!.translate("prevMonthText") ??
            'Previous Month';
      case 'This Year':
        return AppLocalizations.of(context)!.translate("thisYearText") ??
            'This Year';
      case 'Custom':
        return AppLocalizations.of(context)!.translate("customText") ??
            'Custom';
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTripReport(context);
    });
  }

  String _mapTabToFilterMode(String tab) {
    if (tab == 'All Time') return 'all_time';
    return tab.toLowerCase().replaceAll(' ', '_');
  }

  void _fetchTripReport(BuildContext context) {
    final String tabMode = _mapTabToFilterMode(_selectedTab);
    final languageCode = Localizations.localeOf(context).languageCode;
    context.read<TripViewModel>().tripReportApi(
      tabMode: tabMode,
      language: languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TripViewModel>();
    final reportData = viewModel.tripReportModel?.data;

    final stats = reportData?.stats;
    final chart = reportData?.chart;
    final List<dynamic> tripsList = reportData?.trips ?? [];
    final String tabMode = _mapTabToFilterMode(_selectedTab);
    return Scaffold(
      appBar: CustomAppBar(
        text1: AppLocalizations.of(context)!.translate("tripsReportText") ?? '',
        text2:
            AppLocalizations.of(context)!.translate("tripsReportDescText") ??
            '',
        showBackButton: true,
        onBackTap: () => Navigator.pop(context),
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
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildMultipleTripReportButtons(context, tabMode),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children:
                        _tabs.map((tabKey) {
                          final isSelected = _selectedTab == tabKey;
                          final String tabDisplayTitle = _getTabTranslation(
                            context,
                            tabKey,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                if (_selectedTab != tabKey) {
                                  setState(() {
                                    _selectedTab = tabKey;
                                    if (_selectedTab != 'Custom') {
                                      viewModel.fromDate = null;
                                      viewModel.toDate = null;
                                    }
                                  });
                                  if (_selectedTab != 'Custom') {
                                    _fetchTripReport(context);
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? const Color(0xFF4A6BE4)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.transparent
                                            : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  tabDisplayTitle,
                                  style: GoogleFonts.poppins(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                if (_selectedTab == 'Custom')
                  buildCustomFilterBar(context, _selectedTab, () {
                    setState(() {
                      _selectedTab = 'All Time';
                    });
                  }),

                const SizedBox(height: 4),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${AppLocalizations.of(context)!.translate("periodText")}: ',
                        ),
                        TextSpan(
                          text: reportData?.period?.label ?? _selectedTab,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child:
                      viewModel.tripReportLoading
                          ? Center(
                            child: SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 4,
                              ),
                            ),
                          )
                          : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Row(
                                    children: [
                                      buildMetricCard(
                                        title:
                                            AppLocalizations.of(
                                              context,
                                            )!.translate("totalTripsText") ??
                                            '',
                                        value:
                                            '${(stats?.totalTrips ?? 0).abs()}',
                                        leftBorderColor: Colors.blue,
                                        valueColor: Colors.black,
                                        iconColor: Colors.orange,
                                      ),
                                      buildMetricCard(
                                        title:
                                            AppLocalizations.of(
                                              context,
                                            )!.translate("kmTraveledText") ??
                                            '',
                                        value:
                                            stats?.totalKm != null
                                                ? double.parse(
                                                  stats!.totalKm.toString(),
                                                ).abs().toStringAsFixed(2)
                                                : "0.00",
                                        leftBorderColor: Colors.green,
                                        valueColor: Colors.green,
                                        iconColor: Colors.greenAccent,
                                      ),
                                      buildMetricCard(
                                        title:
                                            AppLocalizations.of(
                                              context,
                                            )!.translate("traveledTimeText") ??
                                            '',
                                        value:
                                            (stats?.totalTravelTime ?? '0m')
                                                .replaceAll('-', '')
                                                .trim(),
                                        leftBorderColor: Colors.orange,
                                        valueColor: Colors.orange,
                                        iconColor: Colors.orange,
                                      ),
                                      buildMetricCard(
                                        title:
                                            AppLocalizations.of(
                                              context,
                                            )!.translate("avgText") ??
                                            '',
                                        value:
                                            stats?.avgKmPerTrip != null
                                                ? double.parse(
                                                  stats!.avgKmPerTrip
                                                      .toString(),
                                                ).abs().toStringAsFixed(2)
                                                : "0.00",
                                        leftBorderColor: Colors.blue,
                                        valueColor: Colors.black,
                                        iconColor: Colors.orange,
                                      ),
                                      buildMetricCard(
                                        title:
                                            AppLocalizations.of(
                                              context,
                                            )!.translate("durationText") ??
                                            '',
                                        value:
                                            (stats?.avgDurationPerTrip ?? '0m')
                                                .replaceAll('-', '')
                                                .trim(),
                                        leftBorderColor: Colors.green,
                                        valueColor: Colors.green,
                                        iconColor: Colors.greenAccent,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(
                                                  context,
                                                )!.translate(
                                                  "tripsOverviewText",
                                                ) ??
                                                '',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            height: 240,
                                            child: buildBarChart(
                                              chart ?? Chart(),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              buildLegendItem(
                                                color: Colors.blue,
                                                label:
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.translate(
                                                      "tTripsText",
                                                    ) ??
                                                    '',
                                              ),
                                              const SizedBox(width: 16),
                                              buildLegendItem(
                                                color: const Color(0xFFF5B025),
                                                label:
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.translate("kmText") ??
                                                    '',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                      context,
                                                    )!.translate(
                                                      "businessTripText",
                                                    ) ??
                                                    '',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black87,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFF5B025,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  '${tripsList.length} ${AppLocalizations.of(context)!.translate("tripsText")}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(height: 1),

                                        tripsList.isEmpty
                                            ? Padding(
                                              padding: EdgeInsets.all(32.0),
                                              child: Center(
                                                child: Text(
                                                  AppLocalizations.of(
                                                        context,
                                                      )!.translate(
                                                        "noRecordFoundText",
                                                      ) ??
                                                      '',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.black45,
                                                  ),
                                                ),
                                              ),
                                            )
                                            : SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                headingRowColor:
                                                    WidgetStateProperty.all(
                                                      Colors.grey.shade50,
                                                    ),
                                                horizontalMargin: 16,
                                                columnSpacing: 24,
                                                dataRowMaxHeight: 65,
                                                columns: _buildTableHeaders(),
                                                rows: _buildTableRows(
                                                  tripsList,
                                                ),
                                              ),
                                            ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildTableHeaders() {
    final headers = [
      AppLocalizations.of(context)!.translate("fText") ?? '',
      AppLocalizations.of(context)!.translate("tText") ?? '',
      AppLocalizations.of(context)!.translate("tyText") ?? '',
      AppLocalizations.of(context)!.translate("pText") ?? '',
      AppLocalizations.of(context)!.translate("startedText") ?? '',
      AppLocalizations.of(context)!.translate("distanceText") ?? '',
      AppLocalizations.of(context)!.translate("dText") ?? '',
      'ACTION',
    ];
    return headers.map((title) {
      return DataColumn(
        label: Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }).toList();
  }

  List<DataRow> _buildTableRows(List<dynamic> records) {
    return records.map((data) {
      final String mode = (data.trackingMode ?? '').toString().toLowerCase();
      final bool isManual = mode == 'manual';

      // Safety calculation rounding numeric text elements safely
      final String displayDistance =
          data.totalDistanceKm != null
              ? double.parse(data.totalDistanceKm.toString()).toStringAsFixed(2)
              : "0.00";

      return DataRow(
        cells: [
          DataCell(
            SizedBox(
              width: 180,
              child: Text(
                data.fromLocation ?? '—',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 180,
              child: Text(
                data.toLocation ?? '—',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isManual
                        ? const Color(0xFF2D9CDB)
                        : const Color(0xFF00A389),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isManual ? 'Manual' : 'Auto',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          DataCell(
            Text(
              data.purpose ?? '—',
              style: const TextStyle(color: Colors.black45),
            ),
          ),
          DataCell(
            Text(
              data.startedAt ?? '—',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          DataCell(
            Text(
              displayDistance,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          DataCell(
            Text(
              (data.travelTimeFormatted ?? '—').replaceAll('-', '').trim(),
              style: TextStyle(
                fontSize: 13,
                color:
                    (data.travelTimeFormatted ?? '').toString().startsWith('-')
                        ? Colors.green
                        : Colors.black87,
              ),
            ),
          ),

          DataCell(
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewRouteScreen(tripsReport: data),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5B025),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.translate("viewRouteText") ?? '',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget buildBarChart(Chart chartData) {
    if (chartData.trips == null || chartData.trips!.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.translate("noChartFoundText") ?? '',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.black38,
            fontSize: 13,
          ),
        ),
      );
    }

    List<BarChartGroupData> structuralGroups = [];
    double calculatedMaxY = 50.0;

    for (int idx = 0; idx < chartData.trips!.length; idx++) {
      // ✅ CLEAN: no parsing, no casting
      final double tripValue = chartData.trips![idx];
      final double kmValue =
          chartData.km != null && idx < chartData.km!.length
              ? chartData.km![idx]
              : 0.0;

      // ✅ dynamic max calculation
      if (tripValue > calculatedMaxY) calculatedMaxY = tripValue;
      if (kmValue > calculatedMaxY) calculatedMaxY = kmValue;

      structuralGroups.add(
        BarChartGroupData(
          x: idx,
          barRods: [
            BarChartRodData(toY: tripValue, color: Colors.blue, width: 12),
            BarChartRodData(
              toY: kmValue,
              color: const Color(0xFFF5B025),
              width: 40,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,

        // ✅ safe dynamic max
        maxY: calculatedMaxY * 1.15,

        titlesData: FlTitlesData(
          show: true,

          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int index = value.toInt();

                if (chartData.categories != null &&
                    index >= 0 &&
                    index < chartData.categories!.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      chartData.categories![index],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),

        barGroups: structuralGroups,
      ),
    );
  }
}
