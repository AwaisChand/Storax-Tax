import 'package:flutter/material.dart';
import 'package:storatax/screens/instructions/instructions_screens/instruction_detail_screen.dart';

class UberScreen extends StatelessWidget {
  const UberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InstructionDetailScreen(slug: 'uber-gst-qst');
  }
}
