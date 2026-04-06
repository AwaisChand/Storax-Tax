import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../utils/app_colors.dart';

class IncrementDecrementFileWidget extends StatefulWidget {
  final String labelText;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const IncrementDecrementFileWidget({
    super.key,
    required this.labelText,
    this.initialValue = 0, // Default to 0
    required this.onChanged,
  });

  @override
  _IncrementDecrementFileWidgetState createState() =>
      _IncrementDecrementFileWidgetState();
}

class _IncrementDecrementFileWidgetState
    extends State<IncrementDecrementFileWidget> {
  late TextEditingController _controller;
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: _currentValue.toString());

    _controller.addListener(() {
      final int? parsed = int.tryParse(_controller.text);
      if (parsed != null && parsed >= 0 && parsed != _currentValue) {
        setState(() {
          _currentValue = parsed;
          widget.onChanged(_currentValue);
        });
      } else if (parsed != null && parsed < 0) {
        // Prevent showing negative values
        _controller.text = '0';
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
      if (_currentValue > 0) {
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
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
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
