import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;

import '../../../utils/sensitive_data_detector.dart';
import '../../../res/components/app_localization.dart';

class ScannedReceipt {
  ScannedReceipt({
    required this.id,
    required this.file,
    this.displayName,
    this.status = 'ready',
    this.sizeBytes = 0,
    List<SensitiveBox>? boxes,
    this.scanData,
    this.redactedTempPath,
  }) : boxes = boxes ?? [];

  final String id;
  File file;
  String? displayName;
  String status;
  int sizeBytes;
  List<SensitiveBox> boxes;
  Map<String, dynamic>? scanData;
  String? redactedTempPath;

  String get label =>
      (displayName != null && displayName!.isNotEmpty)
          ? displayName!
          : path.basename(file.path);
}

class ScannedReceiptCard extends StatelessWidget {
  const ScannedReceiptCard({
    super.key,
    required this.receipt,
    required this.onRemove,
  });

  final ScannedReceipt receipt;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E6EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  receipt.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                tooltip: AppLocalizations.of(context)?.translate('cancelText'),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 22,
                ),
              ),
            ],
          ),
          Text(
            AppLocalizations.of(context)?.translate('readyText') ?? '',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF16A34A),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              receipt.file,
              width: 132,
              height: 168,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
