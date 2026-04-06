import 'package:flutter/material.dart';

class StaticDualStepper extends StatelessWidget {
  final double actualValue;
  final double fetchedValue;

  const StaticDualStepper({
    Key? key,
    required this.actualValue,
    required this.fetchedValue,
  }) : super(key: key);

  String formatActual(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(3);
  }

  String round2(double value) => value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Actual Value (Left)
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey.shade200, // optional: make it look static
            ),
            child: Center(
              child: Text(
                formatActual(actualValue),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Fetched Value (Right)
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey.shade200, // optional: make it look static
            ),
            child: Center(
              child: Text(
                round2(fetchedValue),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
