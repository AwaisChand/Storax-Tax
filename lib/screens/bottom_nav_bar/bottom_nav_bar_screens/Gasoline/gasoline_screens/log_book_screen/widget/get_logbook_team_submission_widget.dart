import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../view_models/trip_view_model/trip_view_model.dart';

Widget buildTeamSubmissionsTable(TripViewModel vm, String selectedYear) {
  final reportData = vm.logBookReportModel?.data;
  final submissions = reportData?.submissions ?? [];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Your submissions — $selectedYear",
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DataTable(
            headingRowHeight: 42,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 56,
            columnSpacing: 36,
            horizontalMargin: 16,
            headingRowColor: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
            border: TableBorder.symmetric(
              inside: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
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
            columns: const [
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('KM start')),
              DataColumn(label: Text('KM end')),
              DataColumn(label: Text('Submitted')),
            ],
            rows: submissions.map((item) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      item.approvalStatus ?? 'Pending',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: (item.approvalStatus?.toLowerCase() == 'approved')
                            ? Colors.green
                            : (item.approvalStatus?.toLowerCase() == 'rejected')
                            ? Colors.red
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  DataCell(
                    Text((item.kmStart ?? 0.0).toStringAsFixed(2)),
                  ),
                  DataCell(
                    Text((item.kmEnd ?? 0.0).toStringAsFixed(2)),
                  ),
                  DataCell(
                    Text(item.createdAt ?? '-'),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    ],
  );
}