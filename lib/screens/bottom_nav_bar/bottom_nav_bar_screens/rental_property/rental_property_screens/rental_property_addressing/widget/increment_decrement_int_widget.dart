import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../utils/app_colors.dart';

class IncrementDecrementFieldInt extends StatefulWidget {
  final String labelText;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const IncrementDecrementFieldInt({
    super.key,
    required this.labelText,
    this.initialValue = 0,
    required this.onChanged,
  });

  @override
  _IncrementDecrementFieldIntState createState() =>
      _IncrementDecrementFieldIntState();
}

class _IncrementDecrementFieldIntState
    extends State<IncrementDecrementFieldInt> {
  late TextEditingController _controller;
  late int _currentValue;
  bool _programmaticChange = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: _currentValue.toString());
    _controller.addListener(() {
      if (_programmaticChange) return;
      final int? parsed = int.tryParse(_controller.text);
      if (parsed != null && parsed != _currentValue) {
        _currentValue = parsed;
        widget.onChanged(_currentValue);
      }
    });
  }

  @override
  void didUpdateWidget(covariant IncrementDecrementFieldInt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _currentValue) {
      _currentValue = widget.initialValue;
      _programmaticChange = true;
      _controller.text = _currentValue.toString();
      _programmaticChange = false;
    }
  }

  void _increment() {
    setState(() {
      _currentValue++;
      _programmaticChange = true;
      _controller.text = _currentValue.toString();
      _programmaticChange = false;
      widget.onChanged(_currentValue);
    });
  }

  void _decrement() {
    setState(() {
      if (_currentValue > 0) {
        _currentValue--;
        _programmaticChange = true;
        _controller.text = _currentValue.toString();
        _programmaticChange = false;
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
    return _buildTextField();
  }

  Widget _buildTextField() {
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
          mainAxisAlignment: MainAxisAlignment.center,
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
