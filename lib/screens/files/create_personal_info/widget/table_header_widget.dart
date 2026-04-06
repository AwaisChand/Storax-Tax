import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/dependants_model/dependants_model.dart';
import '../../../../models/get_personal_info_model/get_personal_info_model.dart'
    as personal;
import '../../../../res/components/app_localization.dart';
import '../create_personal_file_screen.dart';
import 'increament_decreament_double_widget.dart';
import 'increament_decreament_widget.dart';

class TableHeader extends StatelessWidget {
  final String title;
  const TableHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class DependentRow extends StatefulWidget {
  final Function(personal.Dependents) onChanged;
  final personal.Dependents? initialDependent;

  const DependentRow({
    required this.onChanged,
    this.initialDependent,
    super.key,
  });

  @override
  State<DependentRow> createState() => _DependentRowState();
}

class _DependentRowState extends State<DependentRow> {
  late final TextEditingController nameController;
  late final TextEditingController countryController;
  late final TextEditingController dateController;

  String disability = "No";
  DateTime? dob;
  int mLived = 0;
  double income = 0.0;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    countryController = TextEditingController();
    dateController = TextEditingController();

    // ✅ Prefill data if available
    if (widget.initialDependent != null) {
      final d = widget.initialDependent!;

      nameController.text = d.name ?? "";
      disability = d.disability.toString();
      countryController.text = d.citizenship ?? "";
      mLived = int.tryParse(d.months.toString()) ?? 0;

      // ✅ Safe income conversion: handles int, double, string
      if (d.income != null) {
        if (d.income is num) {
          income = (d.income as num).toDouble();
        } else {
          income = double.tryParse(d.income.toString()) ?? 0.0;
        }
      } else {
        income = 0.0;
      }

      // ✅ Improved DOB parsing with fallback
      if (d.dob != null && d.dob!.isNotEmpty) {
        try {
          dob = DateTime.parse(d.dob!);
        } catch (_) {
          // Try parsing manually if API sends format like DD/MM/YYYY
          final parts = d.dob!.split(RegExp(r'[-/T\s]'));
          if (parts.length >= 3) {
            final y =
                int.tryParse(parts[0]) ??
                int.tryParse(parts[2]) ??
                DateTime.now().year;
            final m = int.tryParse(parts[1]) ?? 1;
            final da = int.tryParse(parts[2]) ?? int.tryParse(parts[0]) ?? 1;
            dob = DateTime(y, m, da);
          }
        }

        if (dob != null) {
          dateController.text =
              "${dob!.year}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}";
        }
      }
    }
  }

  void _updateParent() {
    widget.onChanged(
      personal.Dependents(
        name: nameController.text,
        disability: int.tryParse(disability),
        dob: dob?.toIso8601String() ?? "",
        citizenship: countryController.text,
        months: mLived,
        income: income,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    countryController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: InputField(
              width: 180,
              hint: "",
              controller: nameController,
              onChanged: (_) => _updateParent(),
            ),
          ),
          SizedBox(
            width: 180,
            child: DropdownField(
              width: 180,
              items: [
                AppLocalizations.of(context)!.translate("yesText") ?? '',
                AppLocalizations.of(context)!.translate("noText") ?? '',
              ],
              initialValue: disability,
              onChanged: (value) {
                setState(() => disability = value!);
                _updateParent();
              },
            ),
          ),
          SizedBox(
            width: 180,
            child: DateField(
              width: 180,
              controller: dateController,
              onDateSelected: (date) {
                dob = date;
                dateController.text =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                _updateParent();
              },
            ),
          ),
          SizedBox(
            width: 180,
            child: InputField(
              width: 180,
              hint: "",
              controller: countryController,
              onChanged: (_) => _updateParent(),
            ),
          ),
          SizedBox(
            width: 180,
            child: IncrementDecrementFileWidget(
              labelText: "",
              initialValue: mLived,
              onChanged: (value) {
                setState(() => mLived = value);
                _updateParent();
              },
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 180,
            child: IncrementDecrementFileDouble(
              labelText: '',
              initialValue: income,
              onChanged: (value) {
                setState(() => income = value);
                _updateParent();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final double width;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final Function(String)? onChanged;

  const InputField({
    required this.width,
    required this.hint,
    this.controller,
    this.inputType,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class DateField extends StatefulWidget {
  final double width;
  final TextEditingController? controller;
  final Function(DateTime)? onDateSelected;

  const DateField({
    required this.width,
    this.controller,
    this.onDateSelected,
    super.key,
  });

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: TextFormField(
        controller: _controller,
        readOnly: true,
        decoration: InputDecoration(
          hintText: "mm/dd/yyyy",
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus();

          final DateTime today = DateTime.now();
          final DateTime sevenYearsAgo = DateTime(today.year - 6, 1, 1);
          final DateTime endOfCurrentYear = DateTime(today.year, 12, 31);

          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: today,
            firstDate: sevenYearsAgo,
            lastDate: endOfCurrentYear, // dropdown only shows 2019–2025
            helpText: "Select a date",
            fieldHintText: "yyyy-mm-dd",
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.orange,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                  dialogBackgroundColor: Colors.white,
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            // allow selection of today and future dates
            final DateTime pickedDate =
                picked.isBefore(today) ? picked : picked;
            final formatted = DateFormat('yyyy-MM-dd').format(pickedDate);
            setState(() {
              _controller.text = formatted;
            });
            widget.onDateSelected?.call(pickedDate);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }
}

class DropdownField extends StatefulWidget {
  final double width;
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;

  const DropdownField({
    required this.width,
    required this.items,
    this.initialValue,
    this.onChanged,
    super.key,
  });

  @override
  State<DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    // Initialize selected value only if it's in the list, otherwise null
    if (widget.initialValue != null &&
        widget.items.contains(widget.initialValue)) {
      selectedValue = widget.initialValue;
    } else {
      selectedValue = null;
    }
  }

  @override
  void didUpdateWidget(covariant DropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle case where items or initialValue update after API call
    if (widget.initialValue != oldWidget.initialValue ||
        widget.items != oldWidget.items) {
      if (widget.initialValue != null &&
          widget.items.contains(widget.initialValue)) {
        setState(() => selectedValue = widget.initialValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        isExpanded: true,
        items:
            widget.items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  ),
                )
                .toList(),
        onChanged: (value) {
          setState(() => selectedValue = value);
          widget.onChanged?.call(value);
        },
        decoration: InputDecoration(
          hintText: "Select",
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
