import 'package:flutter/material.dart';

class EditableDualStepper extends StatefulWidget {
  final double actualValue;
  final double fetchedValue;
  final Function(double) onActualChanged;
  final Function(double) onFetchedChanged;

  const EditableDualStepper({
    Key? key,
    required this.actualValue,
    required this.fetchedValue,
    required this.onActualChanged,
    required this.onFetchedChanged,
  }) : super(key: key);

  @override
  State<EditableDualStepper> createState() => _EditableDualStepperState();
}

class _EditableDualStepperState extends State<EditableDualStepper> {
  late TextEditingController actualController;
  late TextEditingController fetchedController;

  double round2(double v) => double.parse(v.toStringAsFixed(2));

  @override
  void initState() {
    super.initState();
    actualController = TextEditingController(
      text: formatActual(widget.actualValue),
    );
    fetchedController = TextEditingController(
      text: round2(widget.fetchedValue).toString(),
    );
  }

  @override
  void didUpdateWidget(covariant EditableDualStepper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update only if value really changed
    if (oldWidget.actualValue != widget.actualValue) {
      actualController.text = formatActual(widget.actualValue);
    }

    if (oldWidget.fetchedValue != widget.fetchedValue) {
      fetchedController.text = round2(widget.fetchedValue).toString();
    }
  }

  @override
  void dispose() {
    actualController.dispose();
    fetchedController.dispose();
    super.dispose();
  }

  String formatActual(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(3);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Actual Value Field (Left)
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: actualController,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (text) {
                      double? newValue = double.tryParse(text);
                      if (newValue != null) {
                        widget.onActualChanged(
                          double.parse(newValue.toStringAsFixed(2)),
                        );
                      }
                    },
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        double newValue = widget.actualValue + 0.001;
                        widget.onActualChanged(
                          double.parse(newValue.toStringAsFixed(3)),
                        );
                      },
                      child: const Icon(Icons.arrow_drop_up, size: 20),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.actualValue > 0) {
                          double newValue = widget.actualValue - 0.001;
                          widget.onActualChanged(
                            double.parse(newValue.toStringAsFixed(2)),
                          );
                        }
                      },
                      child: const Icon(Icons.arrow_drop_down, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Fetched Value Field (Right)
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fetchedController,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (text) {
                      double? newValue = double.tryParse(text);
                      if (newValue != null) {
                        widget.onFetchedChanged(round2(newValue)); // <-- FIXED
                      }
                    },
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        double newValue = widget.fetchedValue + 0.001;
                        widget.onFetchedChanged(round2(newValue)); // <-- FIXED
                      },
                      child: const Icon(Icons.arrow_drop_up, size: 20),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.fetchedValue > 0) {
                          double newValue = widget.fetchedValue - 0.001;
                          widget.onFetchedChanged(
                            round2(newValue),
                          ); // <-- FIXED
                        }
                      },
                      child: const Icon(Icons.arrow_drop_down, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}