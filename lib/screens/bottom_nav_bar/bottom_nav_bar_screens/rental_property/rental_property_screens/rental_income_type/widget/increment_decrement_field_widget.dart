
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../utils/app_colors.dart';

class IncrementDecrementFieldWidget extends StatefulWidget {
  final String labelText;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const IncrementDecrementFieldWidget({
    super.key,
    required this.labelText,
    this.initialValue = 1, // Default to 1 instead of 0
    required this.onChanged,
  });

  @override
  _IncrementDecrementFieldWidgetState createState() =>
      _IncrementDecrementFieldWidgetState();
}

class _IncrementDecrementFieldWidgetState
    extends State<IncrementDecrementFieldWidget> {
  late TextEditingController _controller;
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue =
    widget.initialValue < 1
        ? 1
        : widget.initialValue; // Ensure min value is 1
    _controller = TextEditingController(text: _currentValue.toString());

    _controller.addListener(() {
      final int? parsed = int.tryParse(_controller.text);
      if (parsed != null && parsed >= 1 && parsed != _currentValue) {
        setState(() {
          _currentValue = parsed;
          widget.onChanged(_currentValue);
        });
      } else if (parsed != null && parsed < 1) {
        // Prevent showing zero or less
        _controller.text = '1';
      }
    });
  }

  void _increment() {
    setState(() {
      _currentValue++;
      _controller.text = _currentValue.toString();
      widget.onChanged(_currentValue);
    });
  }

  void _decrement() {
    setState(() {
      if (_currentValue > 1) {
        _currentValue--;
        _controller.text = _currentValue.toString();
        widget.onChanged(_currentValue);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: widget.labelText,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 15),
        suffixIcon: Column(
          children: [
            InkWell(
              onTap: _increment,
              child: Icon(
                Icons.arrow_drop_up_outlined,
                color: AppColors.goldenOrangeColor,
              ),
            ),
            InkWell(
              onTap: _decrement,
              child: Icon(
                Icons.arrow_drop_down_outlined,
                color: AppColors.goldenOrangeColor,
              ),
            ),
          ],
        ),
      ),
      style: GoogleFonts.poppins(fontSize: 14),
    );
  }
}