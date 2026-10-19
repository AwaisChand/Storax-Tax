import 'package:flutter/material.dart';
import 'package:storatax/screens/instructions/instructions_screens/instruction_detail_screen.dart';

class GasReceiptManagerScreen extends StatelessWidget {
  const GasReceiptManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InstructionDetailScreen(slug: 'gas-receipts');
  }
}
