// Reusable generic dropdown widget
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';

class GenericDropdown<T> extends StatelessWidget {
  const GenericDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint,
    this.isExpanded = true,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T? newValue) onChanged;
  final String? hint;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          isExpanded: isExpanded,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
            ),
          ),
          hint: hint != null
              ? Text(hint!, style: GoogleFonts.poppins(fontWeight: FontWeight.w400))
              : null,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

Widget buildAssociatedInfo(dynamic rawEntry) {
  List<dynamic> infoList = [];
  try {
    final candidate = rawEntry.information;
    if (candidate is List) {
      infoList = candidate;
    }
  } catch (_) {
    // fallback: if rawEntry is Map-like
    if (rawEntry is Map && rawEntry['information'] is List) {
      infoList = rawEntry['information'];
    }
  }

  final names = <String>[];
  for (var info in infoList) {
    String first = '';
    String last = '';

    if (info is Map) {
      first = (info['first_name'] ?? info['firstName'] ?? '').toString();
      last = (info['last_name'] ?? info['lastName'] ?? '').toString();
    } else {
      // try camelCase then snake_case via dynamic
      try {
        first = (info as dynamic).firstName ?? '';
      } catch (_) {
        try {
          first = (info as dynamic).first_name ?? '';
        } catch (_) {}
      }
      try {
        last = (info as dynamic).lastName ?? '';
      } catch (_) {
        try {
          last = (info as dynamic).last_name ?? '';
        } catch (_) {}
      }
    }

    final full = "$first $last".trim();
    if (full.isNotEmpty) names.add(full);
  }

  if (names.isEmpty) return const SizedBox.shrink();

  return SizedBox();
}
