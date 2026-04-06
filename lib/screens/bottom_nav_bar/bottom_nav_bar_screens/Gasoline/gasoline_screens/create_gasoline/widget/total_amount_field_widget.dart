import 'package:flutter/material.dart';

class TotalAmountField extends StatefulWidget {
  final double value;
  final Function(double) onChanged;

  const TotalAmountField({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<TotalAmountField> createState() => _TotalAmountFieldState();
}

class _TotalAmountFieldState extends State<TotalAmountField> {
  late TextEditingController controller;
  bool isUserTyping = false; // 👈 NEW FLAG

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(covariant TotalAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔥 Only update text if:
    //    1) external value changed
    //    2) user is NOT typing
    if (!isUserTyping &&
        oldWidget.value != widget.value &&
        controller.text != widget.value.toStringAsFixed(2)) {
      controller.text = widget.value.toStringAsFixed(2);

      // restore cursor at end
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              double newValue = widget.value - 0.01;
              if (newValue >= 0) {
                widget.onChanged(double.parse(newValue.toStringAsFixed(2)));
              }
            },
          ),

          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,

              onTap: () => isUserTyping = true, // 👈 Mark as typing

              onChanged: (text) {
                isUserTyping = true; // typing continues

                double? v = double.tryParse(text);
                if (v != null) widget.onChanged(v);
              },

              onEditingComplete: () {
                isUserTyping = false;

                // Format final value
                double? v = double.tryParse(controller.text);
                if (v != null) {
                  controller.text = v.toStringAsFixed(2);
                  widget.onChanged(v);
                }
              },

              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              double newValue = widget.value + 0.01;
              widget.onChanged(double.parse(newValue.toStringAsFixed(2)));
            },
          ),
        ],
      ),
    );
  }
}