import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../utils/app_colors.dart';

class IncrementDecrementInputFieldKmWidget extends StatefulWidget {
  final String labelText;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final double step;

  const IncrementDecrementInputFieldKmWidget({
    super.key,
    required this.labelText,
    this.initialValue = 0.0,
    required this.onChanged,
    this.step = 0.01,
  });

  @override
  _IncrementDecrementInputFieldKmWidgetState createState() =>
      _IncrementDecrementInputFieldKmWidgetState();
}

class _IncrementDecrementInputFieldKmWidgetState
    extends State<IncrementDecrementInputFieldKmWidget> {
  late TextEditingController _controller;
  late double _currentValue;
  bool _programmaticChange = false;

  static const double _epsilon = 0.000001;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: _currentValue.toStringAsFixed(2));
    _controller.addListener(() {
      if (_programmaticChange) return;
      final double? parsed = double.tryParse(_controller.text);
      if (parsed != null && (parsed - _currentValue).abs() > _epsilon) {
        _currentValue = parsed;
        widget.onChanged(_currentValue);
      }
    });
  }

  bool _doubleChanged(double a, double b) {
    return (a - b).abs() > _epsilon;
  }

  @override
  void didUpdateWidget(covariant IncrementDecrementInputFieldKmWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_doubleChanged(widget.initialValue, oldWidget.initialValue) &&
        _doubleChanged(widget.initialValue, _currentValue)) {
      _currentValue = widget.initialValue;
      _programmaticChange = true;
      _controller.text = _currentValue.toStringAsFixed(2);
      _programmaticChange = false;
    }
  }

  void _increment() {
    setState(() {
      _currentValue += widget.step;
      _programmaticChange = true;
      _controller.text = _currentValue.toStringAsFixed(2);
      _programmaticChange = false;
      widget.onChanged(_currentValue);
    });
  }

  void _decrement() {
    setState(() {
      if (_currentValue >= widget.step) {
        _currentValue -= widget.step;
        _programmaticChange = true;
        _controller.text = _currentValue.toStringAsFixed(2);
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
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 15,
        ),

        prefixIconConstraints: const BoxConstraints.tightFor(width: 50),
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
        // Add this suffix property
        suffix: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            "Km",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black, // or your desired color
            ),
          ),
        ),
        // End of new suffix property
      ),
      style: GoogleFonts.poppins(fontSize: 14),
    );
  }
}
